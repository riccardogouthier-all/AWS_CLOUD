# Deliverable Lab 13 - Logging con CloudTrail e allarmi CloudWatch

## Trail CloudTrail
| Campo | Valore |
|---|---|
| Nome | `demo-trail` |
| Bucket log | `demo-cloudtrail-logs-rg` (nuovo, policy di scrittura per `cloudtrail.amazonaws.com`) |
| Copertura | multi-regione, solo eventi di gestione (lettura e scrittura) |
| Validazione dei log | attiva |
| Cifratura KMS / CloudWatch Logs | non attive |
| Stato | `IsLogging: true` (console: Logging) |

## Evento di audit
Generato creando e poi eliminando un volume gp3 da 1 GiB (`vol-091d55c5daf6c5d8c`).

| Campo | CreateVolume | DeleteVolume |
|---|---|---|
| Data/ora (ora italiana) | 2026-11-23 14:35:32 | 2026-11-23 14:35:39 |
| Origine | `ec2.amazonaws.com` | `ec2.amazonaws.com` |
| Utente | sessione Learner Lab (`voclabs`) | idem |
| Risorsa | `vol-091d55c5daf6c5d8c` | idem |
| Errore | nessuno | nessuno |

La sola Event history non prova che il trail scriva su S3: i file `.json.gz` sono comparsi in `AWSLogs/533267308404/CloudTrail/us-east-1/2026/11/23/` (5 file al primo controllo, 16 al momento dello screenshot).

## SNS e allarmi
| Elemento | Configurazione | Stato osservato |
|---|---|---|
| Topic | `demo-topic-alarm` (Standard) | creato, **0 sottoscrizioni** |
| `demo-alarm-ebs-queue` | `VolumeQueueLength` > 5, media, 5 min, 1 su 1, volume `demo-data-vol` collegato | `OK` |
| `demo-cpu-alta` | `CPUUtilization` > 70, media, 5 min, 1 su 1, istanza `demo-web-01` | `OK` → `ALARM` (14:41, durante il carico) → `OK` (14:42) |

Entrambi gli allarmi hanno come unica azione il topic SNS. Per `demo-cpu-alta` la cronologia riporta "Successfully executed action ... demo-topic-alarm" in corrispondenza del passaggio ad `ALARM`: il superamento è reale, non simulato (`set-alarm-state` non è stato usato).

Limite: non ho creato la sottoscrizione email (richiede la conferma dal link ricevuto e non ho usato un indirizzo per un test). Il topic ha quindi 0 sottoscrizioni: l'azione è partita verso il topic ma la ricezione di una email **non è stata verificata**.

## Screenshot e log
Cartella: `screenshots-vm-reti-storage/lab-13/`

| File | Contenuto |
|---|---|
| `passo-02.jpg` | CloudTrail > `demo-trail`: Logging, ultimo file consegnato |
| `passo-03.jpg` | Event history filtrata per `CreateVolume` |
| `passo-04.jpg` | S3 `demo-cloudtrail-logs-rg`: file `.json.gz` consegnati |
| `passo-05.jpg` | SNS: topic `demo-topic-alarm` (0 sottoscrizioni) |
| `passo-06.jpg` | CloudWatch > Alarms: i due allarmi con azioni abilitate |
| `log-lab-13.txt` | evento CreateVolume/DeleteVolume e stato del trail |

## Checkpoint
- [x] Trail attivo (`IsLogging: true`) che scrive sul bucket dedicato
- [x] Evento di audit documentato con azione, utente, timestamp ed esito
- [x] Entrambi gli allarmi collegati al topic SNS
- [ ] Ricezione di una email di notifica: non verificata (nessuna sottoscrizione)
- [x] Cleanup eseguito

## Cleanup
`stop-logging` ed eliminazione del trail; bucket dei log svuotato ed eliminato; allarmi e topic SNS eliminati con `terraform destroy`. Verifica via CLI: nessun trail, nessun bucket, nessun allarme e nessun topic del lab.

## Nota metodologica
```bash
# Trail (S3 con policy per CloudTrail già applicata al bucket)
aws cloudtrail create-trail --name demo-trail --s3-bucket-name demo-cloudtrail-logs-rg --is-multi-region-trail --enable-log-file-validation
aws cloudtrail start-logging --name demo-trail
aws cloudtrail get-trail-status --name demo-trail --query "{IsLogging:IsLogging}"

# Evento generato
V=$(aws ec2 create-volume --availability-zone us-east-1a --size 1 --volume-type gp3 --query VolumeId --output text)
aws ec2 wait volume-available --volume-ids $V && aws ec2 delete-volume --volume-id $V
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateVolume --max-results 1

# Allarmi (creati con Terraform: aws_sns_topic, aws_cloudwatch_metric_alarm)
aws cloudwatch describe-alarms --alarm-names demo-alarm-ebs-queue demo-cpu-alta --query "MetricAlarms[].{Name:AlarmName,State:StateValue,Actions:AlarmActions}"
aws cloudwatch describe-alarm-history --alarm-name demo-cpu-alta --max-records 5

# Cleanup
aws cloudtrail stop-logging --name demo-trail && aws cloudtrail delete-trail --name demo-trail
aws s3 rm s3://demo-cloudtrail-logs-rg --recursive && aws s3api delete-bucket --bucket demo-cloudtrail-logs-rg
```
