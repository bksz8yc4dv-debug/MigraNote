# MigraNote — app iOS nativa

Questa cartella contiene la base SwiftUI dell'app iOS. La versione web in `index.html` non viene modificata.

## Funzioni presenti nel codice
- Registrazione immediata con data e ora correnti.
- Modifica di data/ora, intensità, durata, fattori e note.
- Salvataggio locale degli attacchi sul dispositivo.
- Home, storico, calendario mensile e statistiche essenziali.
- Esportazione PDF e CSV tramite il foglio Condividi di iOS.
- Schermata privacy e impostazioni.
- Struttura acquisti in-app con StoreKit 2 e ripristino acquisti.

## Generazione del progetto Xcode
È richiesto un Mac con Xcode. Installare XcodeGen e, dalla cartella `ios`, eseguire:

```sh
brew install xcodegen
xcodegen generate
open MigraNote.xcodeproj
```

Selezionare un team di firma in Xcode per installare l'app su iPhone.

## Configurazione Premium
Gli identificativi attesi sono:
- `it.migranote.premium.monthly`
- `it.migranote.premium.yearly`

Devono essere creati come abbonamenti auto-rinnovabili in App Store Connect, con prezzi, durata, localizzazioni e stato di disponibilità corretti. Fino a quel momento l'app mostrerà che i prodotti non sono configurati e gli acquisti non saranno disponibili.

## Stato e verifiche necessarie
Questa è una base di sviluppo, non una build compilata o collaudata. Non è stato possibile eseguire Xcode in questo ambiente. Prima della distribuzione servono build e test su Xcode, test degli acquisti con StoreKit Sandbox, verifica del flusso PDF/CSV, onboarding definitivo, backup iCloud e informativa privacy completa.

I dati di questa versione sono conservati localmente tramite UserDefaults. Non vengono inviati a un server. La sincronizzazione iCloud non è ancora implementata.
