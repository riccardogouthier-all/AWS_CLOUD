# Deliverable Lab 14 - Backup, Disaster Recovery e ottimizzazione dei costi

## RPO/RTO e strategia
| Parametro | Valore |
|---|---|
| RPO | 24 ore |
| RTO | poche ore |
| Strategia | Backup and Restore |

Motivazione: per un progetto didattico a basso traffico è la strategia più economica e un ripristino in qualche ora è accettabile. Sono obiettivi di progetto, non misurati: creare il piano non dimostra il tempo di ripristino.

## Backup plan
| Elemento | Valore |
|---|---|
| Vault | `demo-backup-vault` |
| Piano | `demo-backup-plan` (`5551155c-c480-48c8-a6c4-afe2b9906ef2`) |
| Regola | `demo-daily-rule`: giornaliera, `cron(0 5 * * ? *)` (05:00 UTC), retention 7 giorni |
| Assegnazione | `demo-assignment-ebs`, ruolo `LabRole` (nessun `AWSBackupDefaultServiceRole` creato) |
| Risorsa | volume EBS `demo-data-vol` (`vol-0e8b37592343a0e9b`) |
| Trust di `LabRole` | contiene `backup.amazonaws.com` |
| Backup job | 0: il primo parte nella finestra prevista. **Nessun backup dichiarato completato per questo piano.** |

## Analisi costi (Cost Explorer, 16-22 novembre, giornaliero, per servizio)
Totale 0,40 $ su 23 servizi (dati reali; l'ultimo giorno può non essere aggiornato).

| Servizio | Costo (circa) |
|---|---|
| EC2 - Other | 0,12 $ |
| Amazon EC2 - Compute | 0,12 $ |
| Amazon VPC | 0,06 $ |
| Elastic Load Balancing | 0,045 $ |
| AWS WAF | 0,03 $ |

La spesa è quasi tutta del 16 e 17 novembre (giorni dei lab con istanze, VPC e load balancer). Il totale per servizio non dice quale risorsa precisa abbia generato la spesa: ho controllato EC2, volumi, bucket, trail e vault prima di creare le risorse dei lab, e oltre a quelle di questi tre lab non c'era nulla rimasto acceso. Snapshot e NAT Gateway li ho controllati solo in un secondo momento, a fine cleanup, quindi per questi due non so dire cosa ci fosse prima.

Azione di ottimizzazione: a fine di ogni sessione fermare le istanze ed eliminare VPC, load balancer, volumi e snapshot di test invece di lasciarli fino alla fine del corso, perché istanze, VPC e ELB costano a ore anche quando non servono.

## Screenshot e log
Cartella: `screenshots/`

| File | Contenuto |
|---|---|
| `passo-02.jpg` | AWS Backup > piano `demo-backup-plan`: regola `demo-daily-rule` e assegnazione `demo-assignment-ebs` con `LabRole` |
| `passo-03.jpg` | Cost Explorer: ultimi 7 giorni, giornaliero, per servizio |
| `log-lab-14.txt` | piano, assegnazione, trust di `LabRole`, output `ce get-cost-and-usage` |

## Checkpoint
- [x] RPO e RTO concreti, coerenti con un progetto didattico
- [x] Backup plan con una risorsa reale del corso (`demo-data-vol`)
- [x] Azione di ottimizzazione basata su un dato osservato
- [x] Cleanup (piano, assegnazione, vault) eseguito

## Cleanup
Assegnazione, piano e vault eliminati con `terraform destroy` (il vault era vuoto: nessun recovery point). Volume sorgente eliminato solo alla fine del Lab 12-14, non per rimuovere il backup. `LabRole` non toccato. Verifica via CLI: nessun vault e nessun piano del lab.

## Nota metodologica
```bash
aws iam get-role --role-name LabRole --query "Role.AssumeRolePolicyDocument.Statement[].Principal.Service[]" --output text   # cerca backup.amazonaws.com
aws backup list-backup-plans --query "BackupPlansList[?BackupPlanName=='demo-backup-plan']"
aws backup list-backup-selections --backup-plan-id <plan-id> --query "BackupSelectionsList[].SelectionName"
aws ce get-cost-and-usage --region us-east-1 --time-period Start=2026-11-16,End=2026-11-23 \
  --granularity DAILY --metrics UnblendedCost --group-by Type=DIMENSION,Key=SERVICE
```
Vault, piano e assegnazione sono stati creati con Terraform (`aws_backup_vault`, `aws_backup_plan`, `aws_backup_selection`) e rimossi con `terraform destroy`.
