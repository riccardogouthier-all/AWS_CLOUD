# AWS_CLOUD - guida alla repository

Raccolta dei laboratori AWS svolti sul Learner Lab (account Academy, regione `us-east-1`). Ogni corso ha una cartella con le consegne (`DLVRBL-LAB-*.md`), gli screenshot e i log dei lab (`screenshots-*/lab-N/`), lo script con tutta la procedura e, dove presenti, i PDF consegnati.

## Come orientarsi

| Cerco... | Vado in... |
|---|---|
| La consegna di un lab (configurazione, motivazioni, comandi, cleanup) | `<corso>/DLVRBL-LAB-N.md` |
| Gli screenshot e i log di un lab | `<corso>/screenshots-<corso>/lab-N/` (elencati in fondo a ogni consegna, sezione "Screenshot e log") |
| Tutti i comandi di un corso in sequenza | `CORSO_*-WholeCourseProcedure.sh` |
| Il PDF consegnato | `AWS ... Labs ... .pdf` nella cartella del corso |

Dentro `screenshots-*/lab-N/`: `passo-NN` sono i passi del lab, `cleanup-NN` la pulizia finale, `log-lab-N.txt` e `log-cleanup-N.txt` l'output dei comandi.

| Corso | Cartella | Lab | Consegne | Screenshot |
|---|---|---|---|---|
| Sicurezza AWS | [AWS_SECURITY](AWS_SECURITY) | 1-11 | `DLVRBL-LAB-01.md` ... `11.md` | `screenshots-sicurezza/` |
| VM, Reti e Storage | [AWS_VM_RETI_STORAGE](AWS_VM_RETI_STORAGE) | 1-14 | `DLVRBL-LAB-1.md` ... `14.md` | `screenshots-vm-reti-storage/` |
| Serverless | [AWS_SERVERLESS](AWS_SERVERLESS) | 1-18 | `DLVRBL-LAB-01.md` ... `18.md` | `screenshots-serverless/` |
| Architettura e progettazione | [ARCHITETTURA_PROGETTAZIONE](ARCHITETTURA_PROGETTAZIONE) | 2 lab + verifica finale | documenti e schemi | nella cartella |

---

## Sicurezza AWS - [AWS_SECURITY](AWS_SECURITY)

Il corso parte dai principi (responsabilità condivisa, privilegio minimo, confini di fiducia), passa ai servizi che proteggono dati, identità e rete e finisce con rilevamento, risposta e recupero. Alcuni servizi (Organizations, Access Analyzer) non sono disponibili nel Learner Lab: in quei lab la consegna lo dichiara e lavora su un modello locale.

| Lab | Consegna | Di cosa parla |
|---|---|---|
| 01 | [DLVRBL-LAB-01.md](AWS_SECURITY/DLVRBL-LAB-01.md) | Fondamenti: responsabilità, flusso dei dati, confini di fiducia, controlli e prove positive/negative su uno scenario. |
| 02 | [DLVRBL-LAB-02.md](AWS_SECURITY/DLVRBL-LAB-02.md) | Regioni e zone, bucket S3 con cifratura, prova di lettura. |
| 03 | [DLVRBL-LAB-03.md](AWS_SECURITY/DLVRBL-LAB-03.md) | Compliance, KMS e identità: trust policy contro permessi, integrità dei dati, stato della chiave. |
| 04 | [DLVRBL-LAB-04.md](AWS_SECURITY/DLVRBL-LAB-04.md) | IAM: buone pratiche, MFA e policy JSON valutate caso per caso. |
| 05 | [DLVRBL-LAB-05.md](AWS_SECURITY/DLVRBL-LAB-05.md) | SCP e Access Analyzer (modello locale): gerarchia, matrice delle decisioni, finding. |
| 06 | [DLVRBL-LAB-06.md](AWS_SECURITY/DLVRBL-LAB-06.md) | VPC, Security Group e Network ACL: come si combinano e perché. |
| 07 | [DLVRBL-LAB-07.md](AWS_SECURITY/DLVRBL-LAB-07.md) | Connettività sicura (VPN, Direct Connect) e tracciamento con CloudTrail. |
| 08 | [DLVRBL-LAB-08.md](AWS_SECURITY/DLVRBL-LAB-08.md) | Monitoraggio con CloudWatch e conformità con AWS Config. |
| 09 | [DLVRBL-LAB-09.md](AWS_SECURITY/DLVRBL-LAB-09.md) | AWS WAF, Shield e Secrets Manager: scelta dei controlli. |
| 10 | [DLVRBL-LAB-10.md](AWS_SECURITY/DLVRBL-LAB-10.md) | GuardDuty e Inspector: finding di esempio, priorità e risposta. |
| 11 | [DLVRBL-LAB-11.md](AWS_SECURITY/DLVRBL-LAB-11.md) | Backup e ripristino di un volume EBS con AWS Backup, e cosa questo prova (e cosa no). |

## VM, Reti e Storage - [AWS_VM_RETI_STORAGE](AWS_VM_RETI_STORAGE)

Il corso costruisce un'infrastruttura a strati: prima le macchine virtuali e la loro scalabilità (lab 1-3), poi la rete (4-6), poi lo storage (7-10), l'architettura ibrida (11) e infine esercizio e controllo dell'ambiente: diagnosi, audit, backup e costi (12-14).

| Lab | Consegna | Di cosa parla |
|---|---|---|
| 1 | [DLVRBL-LAB-1.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-1.md) | Istanze EC2: scelta del tipo, creazione, raggiungibilità e SSH. |
| 2 | [DLVRBL-LAB-2.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-2.md) | AMI personalizzata e Elastic Load Balancing con health check. |
| 3 | [DLVRBL-LAB-3.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-3.md) | Auto Scaling Group, allarmi CloudWatch e sostituzione automatica delle istanze. |
| 4 | [DLVRBL-LAB-4.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-4.md) | VPC: pianificazione dei CIDR, subnet pubbliche e private, route table. |
| 5 | [DLVRBL-LAB-5.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-5.md) | Internet Gateway, NAT Gateway e bastion host. |
| 6 | [DLVRBL-LAB-6.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-6.md) | Security Group e Network ACL: architetture di rete sicure e test. |
| 7 | [DLVRBL-LAB-7.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-7.md) | EBS, EFS e S3 a confronto; gestione e snapshot dei volumi EBS. |
| 8 | [DLVRBL-LAB-8.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-8.md) | S3: versioning, lifecycle, eliminazione e recupero. |
| 9 | [DLVRBL-LAB-9.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-9.md) | Tipi di Storage Gateway (solo esame) e cifratura a riposo. |
| 10 | [DLVRBL-LAB-10.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-10.md) | EBS contro EFS: storage condiviso tra due istanze. |
| 11 | [DLVRBL-LAB-11.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-11.md) | Architettura multi-tier, catena di Security Group e VPN contro Direct Connect (VPN solo documentale). |
| 12 | [DLVRBL-LAB-12.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-12.md) | Diagnosi rete/storage con le metriche, snapshot e versioning, policy IAM a minimo privilegio simulata. |
| 13 | [DLVRBL-LAB-13.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-13.md) | CloudTrail (trail e evento di audit), SNS e allarmi CloudWatch. |
| 14 | [DLVRBL-LAB-14.md](AWS_VM_RETI_STORAGE/DLVRBL-LAB-14.md) | RPO/RTO e Disaster Recovery, piano di AWS Backup, costi con Cost Explorer. |

## Serverless - [AWS_SERVERLESS](AWS_SERVERLESS)

Il corso inizia con la parte di ragionamento (impatto ambientale e costi), poi costruisce applicazioni senza server: funzioni Lambda, API, database, flussi di eventi, workflow e deploy con codice. I lab 1-5 sono calcoli e analisi; dal 6 si lavora su AWS.

| Lab | Consegna | Di cosa parla |
|---|---|---|
| 01 | [DLVRBL-LAB-01.md](AWS_SERVERLESS/DLVRBL-LAB-01.md) | Green IT: consumi di un data center, smart working e smart grid. |
| 02 | [DLVRBL-LAB-02.md](AWS_SERVERLESS/DLVRBL-LAB-02.md) | Economia circolare (RAEE), prova di elaborazione CSV con Lambda, EC2 acceso sempre contro Lambda. |
| 03 | [DLVRBL-LAB-03.md](AWS_SERVERLESS/DLVRBL-LAB-03.md) | Fondamenti serverless e confronto di architetture e costi. |
| 04 | [DLVRBL-LAB-04.md](AWS_SERVERLESS/DLVRBL-LAB-04.md) | Casi d'uso (blog, e-commerce, stagionale) e punto di pareggio. |
| 05 | [DLVRBL-LAB-05.md](AWS_SERVERLESS/DLVRBL-LAB-05.md) | Limiti del serverless e buone pratiche: revisione di un codice con problemi. |
| 06 | [DLVRBL-LAB-06.md](AWS_SERVERLESS/DLVRBL-LAB-06.md) | Prima funzione Lambda e misura del cold start. |
| 07 | [DLVRBL-LAB-07.md](AWS_SERVERLESS/DLVRBL-LAB-07.md) | Trigger di Lambda: evento S3 e schedulazione. |
| 08 | [DLVRBL-LAB-08.md](AWS_SERVERLESS/DLVRBL-LAB-08.md) | Memoria, concorrenza riservata, allarme CloudWatch e Logs Insights. |
| 09 | [DLVRBL-LAB-09.md](AWS_SERVERLESS/DLVRBL-LAB-09.md) | Sicurezza: IAM minimo con DynamoDB e Secrets Manager. |
| 10 | [DLVRBL-LAB-10.md](AWS_SERVERLESS/DLVRBL-LAB-10.md) | API REST con API Gateway e Lambda, CORS. |
| 11 | [DLVRBL-LAB-11.md](AWS_SERVERLESS/DLVRBL-LAB-11.md) | API CRUD protetta da un Lambda authorizer. |
| 12 | [DLVRBL-LAB-12.md](AWS_SERVERLESS/DLVRBL-LAB-12.md) | Versioni, stage, cache e monitoraggio delle API. |
| 13 | [DLVRBL-LAB-13.md](AWS_SERVERLESS/DLVRBL-LAB-13.md) | DynamoDB: Lambda CRUD su una tabella di ordini. |
| 14 | [DLVRBL-LAB-14.md](AWS_SERVERLESS/DLVRBL-LAB-14.md) | Pipeline S3, Lambda e DynamoDB: metadati dei file e import CSV con indice secondario. |
| 15 | [DLVRBL-LAB-15.md](AWS_SERVERLESS/DLVRBL-LAB-15.md) | DynamoDB TTL, backup con PITR e lifecycle di S3. |
| 16 | [DLVRBL-LAB-16.md](AWS_SERVERLESS/DLVRBL-LAB-16.md) | Step Functions: workflow di elaborazione ordini. |
| 17 | [DLVRBL-LAB-17.md](AWS_SERVERLESS/DLVRBL-LAB-17.md) | Step Functions: gestione degli errori e integrazioni dirette. |
| 18 | [DLVRBL-LAB-18.md](AWS_SERVERLESS/DLVRBL-LAB-18.md) | AWS SAM e CloudFormation: deploy automatizzato e monitoraggio. |

## Architettura e progettazione - [ARCHITETTURA_PROGETTAZIONE](ARCHITETTURA_PROGETTAZIONE)

Materiale sul disegno di architetture AWS, non su laboratori da eseguire.

| Contenuto | Cartella |
|---|---|
| Schema di un'architettura (testo e diagramma PDF) | `Lab 5 giugno` |
| Proposta di architettura (modello Word), stima dei costi e slide | `Lab 7 Luglio` |
| Verifica finale: scenario "ShopShop" (e-commerce con picchi di traffico), schemi, screenshot delle risorse, relazione e PDF consegnato | `VERIFICA FINALE — ARCHITETTURA E PROGETTAZIONE` |

---

## Cosa c'è da sapere sulle evidenze

- Le procedure dei lab Sicurezza 1-10, VM 1-11 e Serverless 1-18 sono state eseguite sul Learner Lab; i lab 1, 3, 4 e 5 di Serverless sono calcoli e controlli locali. I loro screenshot (`.png`) mostrano il terminale con comandi e output reali, non la console.
- Sicurezza 11 e VM 12-14 hanno screenshot reali della console AWS (`.jpg`), inseriti anche nei Google Docs di consegna.
- Alcune parti non sono possibili nel Learner Lab e le consegne lo dichiarano: Organizations e Access Analyzer (Sicurezza 05, modello locale), Customer Gateway e VPN (Sicurezza 07 e VM 11, solo documentale), invio email SNS e backup job pianificato (VM 13 e 14).
- Le prove di Serverless 15 (scadenza TTL e ripristino PITR) e di Serverless 12 (X-Ray Service Map) non sono state completate.
- Le risorse create sono state eliminate dopo ogni lab. Restano solo un segreto e una chiave KMS in cancellazione pianificata (Sicurezza).
- Il codice Terraform è nelle cartelle `Terraform-lab-<numero>-<corso>/` dentro ogni corso: `AWS_SECURITY/Terraform-lab-06..11-sicurezza/`, `AWS_VM_RETI_STORAGE/Terraform-lab-08-11-vm-reti-storage/` e `Terraform-lab-12-14-vm-reti-storage/` (VM 8-11 e 12-14 sono raggruppati perché condividono rete o istanza). Non serve per i lab Serverless e VM 1-7.

## Verifica delle consegne

Il rapporto di verifica dei DLVRBL (correzioni, difetti trovati, giudizi sui lab 12-14 di VM Reti Storage e segnalazioni finali su falle ed errori) è in [REPORT_VERIFICA_DLVRBL.md](REPORT_VERIFICA_DLVRBL.md).
