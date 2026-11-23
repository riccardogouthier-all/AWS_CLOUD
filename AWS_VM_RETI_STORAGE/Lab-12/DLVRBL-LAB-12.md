# Deliverable Lab 12 - Diagnosi rete/storage, resilienza e policy IAM a minimo privilegio

## Ambiente (dato reale)
Account Learner Lab, `us-east-1`, ruolo `voclabs`. Risorse create con Terraform per questo lab:

| Risorsa | Valore |
|---|---|
| Istanza | `demo-web-01` (`i-06fac3ff9bd024e44`), t3.micro, Amazon Linux 2023, `LabInstanceProfile` |
| Volume dati | `demo-data-vol` (`vol-0e8b37592343a0e9b`), gp3, 2 GiB, cifrato, montato su `/dati` |
| Snapshot | `demo-data-snap` (`snap-025208256e65720bf`) |
| Bucket | `demo-lab12-versioning-rg`, versioning attivo |

## Carico generato (via SSM)
3 cicli di scrittura/lettura da 400 MB sul volume con `dd` (`oflag=direct`), alcuni download da internet e due processi che tengono la CPU occupata per 4 minuti. Il carico è mio: la diagnosi vale solo per questo test.

## Diagnosi collo di bottiglia (periodo 5 minuti)
| Metrica | Valore osservato | Confronto |
|---|---|---|
| `CPUUtilization` (media) | picco 55,8%, poi 24,9% e 0,2% | non saturata |
| `NetworkIn` (somma) | picco 479.451.077 B in 5 min (circa 1,6 MB/s) | basso per una t3.micro |
| `NetworkOut` (somma) | picco 1.135.720 B | trascurabile |
| `VolumeWriteOps` (somma) | 5.199 in 5 min (circa 17/s) | gp3 ha 3.000 IOPS di base |
| `VolumeReadOps` (somma) | 5.070 in 5 min (circa 17/s) | idem |
| `VolumeQueueLength` (media) | massimo 0,094 | nessuna coda persistente |

Conclusione: non emerge nessun collo di bottiglia, né di rete né di storage. Un numero alto di operazioni da solo non prova saturazione: va rapportato al periodo, alla capacità del volume e alla coda.

## Resilienza verificata
| Elemento | Evidenza |
|---|---|
| Snapshot | `snap-025208256e65720bf`, volume 2 GiB, `Completed`, 100%, cifrato |
| Versioning S3 | `demo-lab12-versioning-rg`: Bucket Versioning = `Enabled` |

## Policy IAM (`lab12-s3-readonly.json`)
Solo `s3:ListBucket` sull'ARN del bucket e `s3:GetObject` sugli oggetti (`/*`). Il file è in `screenshots/`.

Simulazione con `aws iam simulate-custom-policy` (solo del documento, non della sessione):

| Azione | Risorsa | Decisione |
|---|---|---|
| `s3:ListBucket` | `arn:aws:s3:::demo-lab12-versioning-rg` | `allowed` |
| `s3:GetObject` | `.../report.txt` del bucket scelto | `allowed` |
| `s3:PutObject` | `.../report.txt` del bucket scelto | `implicitDeny` |
| `s3:GetObject` | `arn:aws:s3:::lab12-altro-bucket-esempio/report.txt` | `implicitDeny` |

Limite: la simulazione non dimostra cosa farebbe `LabRole` con una richiesta reale (può avere altri Allow) e non è stato fatto nessun upload reale. Nota: nella shell Git Bash `file://` sul JSON dava `Policy input list item 1 has invalid content`; la stessa policy passata inline ha funzionato.

Ruoli, policy gestite e instance profile creati o modificati: nessuno. `LabRole` invariato; `LabInstanceProfile` letto in sola lettura (contiene `LabRole`).

## Screenshot e log
Cartella: `screenshots/`

| File | Contenuto |
|---|---|
| `passo-02.jpg` | EC2 > Snapshots: `demo-data-snap` Completed |
| `passo-03.jpg` | S3 > bucket > Properties: Bucket Versioning Enabled |
| `passo-04.jpg` | CloudWatch: `CPUUtilization` dell'istanza |
| `passo-05.jpg` | CloudWatch: `NetworkIn` e `NetworkOut` |
| `passo-06.jpg` | CloudWatch: `VolumeReadOps`, `VolumeWriteOps`, `VolumeQueueLength` |
| `lab12-s3-readonly.json` | policy simulata |
| `log-lab-12.txt` | valori metriche e output della simulazione |

## Checkpoint
- [x] Metriche CloudWatch confrontate esplicitamente
- [x] Snapshot e versioning verificati
- [x] Policy limitata a un bucket e agli oggetti necessari
- [x] Simulazione distinta da un test effettivo su S3
- [x] Nessuna creazione di ruoli o modifica di `LabRole`/`LabInstanceProfile`

## Cleanup
Istanza, volume e snapshot eliminati con `terraform destroy` (insieme alle risorse dei Lab 13 e 14); bucket svuotato (versioni e delete marker) ed eliminato via CLI. Verifica via CLI: nessuna istanza, volume, snapshot o bucket del lab.

## Nota metodologica
Comandi principali (AWS CLI, `us-east-1`):

```bash
# Carico sull'istanza (SSM)
aws ssm send-command --instance-ids <instance-id> --document-name AWS-RunShellScript --parameters file://cmd.json

# Metriche (esempio: scritture sul volume, somma a 5 minuti)
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeWriteOps \
  --dimensions Name=VolumeId,Value=<volume-id> --start-time <inizio-UTC> --end-time <fine-UTC> \
  --period 300 --statistics Sum --query "sort_by(Datapoints,&Timestamp)[].[Timestamp,Sum]" --output text

# Simulazione della policy (documento inline)
aws iam simulate-custom-policy --policy-input-list "$(tr -d '\n' < lab12-s3-readonly.json)" \
  --action-names s3:ListBucket --resource-arns arn:aws:s3:::demo-lab12-versioning-rg \
  --query "EvaluationResults[].{Action:EvalActionName,Resource:EvalResourceName,Decision:EvalDecision}" --output table

# Sola lettura
aws iam get-instance-profile --instance-profile-name LabInstanceProfile --query "InstanceProfile.{Name:InstanceProfileName,Roles:Roles[].RoleName}"
```
