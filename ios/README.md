# MigraNote iOS

Progetto nativo SwiftUI per iOS 17 o successivo. Il progetto Xcode viene generato da `project.yml` tramite XcodeGen.

## Funzioni implementate nel codice

- Registrazione immediata: il pulsante crea e salva subito l'attacco con data e ora correnti; i dettagli si possono completare dopo.
- Modifica di data/ora, fattori, intensità, durata e note.
- Storico modificabile ed eliminabile.
- Calendario mensile e riepilogo statistico.
- Esportazione CSV gratuita; report PDF e backup/ripristino JSON manuale riservati a Premium.
- Campi personalizzati configurabili con Premium.\n- Protezione locale tramite autenticazione del dispositivo (Face ID o codice).
- Abbonamenti StoreKit 2 con verifica delle transazioni e ripristino acquisti.

## Compilazione locale

Requisiti: macOS, Xcode 16 o successivo e XcodeGen.

```sh
cd ios
xcodegen generate
xcodebuild test -project MigraNote.xcodeproj -scheme MigraNote -destination 'platform=iOS Simulator,name=iPhone 16'
```

Per aprire il progetto: `ios/MigraNote.xcodeproj` dopo aver eseguito XcodeGen.

## StoreKit 2

Gli identificativi attesi sono:

- `it.migranote.premium.monthly`
- `it.migranote.premium.annual`

I prodotti devono essere creati nell'account App Store Connect che pubblicherà l'app, con prezzi, durata, localizzazioni e condizioni definite dal titolare. Il codice non inventa prezzi e non attiva acquisti se Apple non restituisce i prodotti.

## Limiti prima della distribuzione

La compilazione del simulatore non equivale a una build firmata né a una pubblicazione. Per distribuire servono l'account Apple Developer del titolare, il Team ID e la firma, i prodotti e gli accordi fiscali in App Store Connect, i metadati, gli screenshot, le informazioni privacy e i recapiti reali del responsabile. Vedi `APP_STORE_CONNECT_SETUP.md`.

La sincronizzazione automatica iCloud non è implementata. Il backup Premium è manuale tramite file JSON, con ripristino e controllo dei duplicati.

## Dati e uso sanitario

Le registrazioni sono memorizzate localmente tramite SwiftData. Non è presente un backend, un account utente, pubblicità o SDK di tracciamento in questa versione. MigraNote è un diario personale e non fornisce diagnosi o indicazioni terapeutiche.
