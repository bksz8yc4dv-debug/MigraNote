# MigraNote — app iOS nativa

Questa cartella contiene la prima base SwiftUI del progetto iOS. La versione web in `index.html` non viene modificata.

## Contenuto iniziale
- Registrazione immediata di un attacco con data e ora correnti.
- Modifica di data/ora, intensità, durata, fattori e note.
- Salvataggio locale sul dispositivo.
- Storico, riepilogo e statistiche essenziali.
- Esportazione nativa PDF e CSV tramite il foglio Condividi di iOS.

## Generazione del progetto Xcode
È richiesto un Mac con Xcode. Installare XcodeGen e, dalla cartella `ios`, eseguire:

```sh
brew install xcodegen
xcodegen generate
open MigraNote.xcodeproj
```

Selezionare un team di firma in Xcode per installare l'app su iPhone.

## Stato
Questa è una prima base di sviluppo, non una build compilata o collaudata. Prima della distribuzione vanno eseguiti build e test su Xcode e completati calendario, privacy/onboarding, backup iCloud e acquisti Premium con StoreKit 2. Per gli acquisti in-app e la pubblicazione serve un account Apple Developer e la configurazione App Store Connect.

I dati di questa prima versione sono conservati localmente tramite UserDefaults. Non vengono inviati a un server.
