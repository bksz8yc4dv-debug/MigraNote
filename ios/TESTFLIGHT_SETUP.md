# Preparazione TestFlight

Il workflow `.github/workflows/testflight.yml` è predisposto, ma resta disattivato fino a quando il titolare non configura l'account Apple e i segreti GitHub.

## Prerequisiti Apple

1. Iscrizione Apple Developer Program attiva.
2. App creata in App Store Connect con Bundle ID `it.migranote.app`.
3. Contratti e accordi Apple completati.
4. Chiave API App Store Connect creata con ruolo sufficiente a gestire build e TestFlight.
5. Prodotti Premium creati separatamente in App Store Connect.

## Segreti da configurare nel repository GitHub

In **Settings → Secrets and variables → Actions → New repository secret**, aggiungere:

- `APPLE_TEAM_ID`: Team ID del team Apple Developer.
- `ASC_KEY_ID`: Key ID della chiave API.
- `ASC_ISSUER_ID`: Issuer ID.
- `ASC_KEY_CONTENT_BASE64`: contenuto del file .p8 codificato in Base64.

Non inserire mai la chiave privata .p8 nei file del repository, nelle issue o nei messaggi. Va conservata solo nei GitHub Actions Secrets.

## Avvio

Dopo aver completato i prerequisiti, aprire la scheda Actions del repository, selezionare **Upload MigraNote to TestFlight** e avviare **Run workflow**. Il workflow genera il progetto Xcode, compila la configurazione Release con firma automatica e carica la build su TestFlight.

Il caricamento riuscito non equivale all'approvazione App Review né garantisce che la build sia già installabile: Apple deve prima elaborarla e il titolare deve aggiungere i tester.
