# MigraNote

MigraNote è un diario personale per registrare gli attacchi di emicrania con un solo tocco. Non fornisce diagnosi o indicazioni terapeutiche.

## Versioni

- **Versione web:** https://bksz8yc4dv-debug.github.io/MigraNote/
- **Progetto iOS nativo:** [cartella ios](ios/)
- **Istruzioni di compilazione e funzioni:** [ios/README.md](ios/README.md)

## Stato del progetto

Il repository contiene il prototipo web e il progetto SwiftUI nativo per iOS 17+. La pipeline GitHub Actions compila e testa il progetto nel simulatore iOS. La pipeline Fastlane per TestFlight è predisposta ma richiede l'account Apple Developer e i segreti GitHub del titolare.

## Funzioni iOS presenti nel codice

- Registrazione immediata con salvataggio di data e ora.
- Dettagli modificabili anche dopo la registrazione.
- Diario, storico, calendario e statistiche.
- Esportazione CSV; report PDF Premium.
- Campi personalizzati Premium.
- Backup e ripristino manuale JSON Premium.
- Protezione facoltativa con Face ID o codice del dispositivo.
- Abbonamenti mensile e annuale tramite StoreKit 2.

## Prima della distribuzione

La build del simulatore non è una versione installabile su iPhone. Per TestFlight/App Store servono firma Apple, prodotti configurati in App Store Connect, dati reali del titolare, privacy policy definitiva, supporto e materiali grafici. Consultare:

- [Prerequisiti App Store Connect](ios/APP_STORE_CONNECT_SETUP.md)
- [Configurazione TestFlight](ios/TESTFLIGHT_SETUP.md)
- [Bozza informativa privacy](ios/PRIVACY_POLICY_DRAFT.md)

La sincronizzazione automatica iCloud non è attualmente implementata. Il backup Premium è manuale tramite file JSON.
