# Operazioni necessarie sul conto Apple del titolare

Questa checklist contiene attività che non possono essere completate senza l'accesso e le decisioni del titolare dell'account Apple.

## Identità dell'app

- Bundle identifier nel progetto: `it.migranote.app`.
- Nome visualizzato: MigraNote.
- Piattaforma minima: iOS 17.
- Prima di creare l'app in App Store Connect, verificare che il Bundle ID sia disponibile e registrarlo nel team corretto.

## Abbonamenti auto-rinnovabili

Creare un gruppo di abbonamenti e due prodotti:

| Prodotto | Product ID previsto | Durata |
|---|---|---|
| Premium mensile | `it.migranote.premium.monthly` | 1 mese |
| Premium annuale | `it.migranote.premium.annual` | 1 anno |

Il titolare deve scegliere prezzi, disponibilità territoriale, nome e descrizione localizzati, eventuale periodo di prova e condizioni. Il codice StoreKit 2 carica i prodotti usando esattamente questi identificativi. Gli acquisti reali non sono verificabili finché i prodotti non sono configurati e testati con account Sandbox.

## Distribuzione e firma

- Attivare l'iscrizione Apple Developer Program e accettare gli accordi aggiornati.
- Configurare il team di firma e il provisioning profile.
- Verificare l'identificativo Bundle ID e le capability effettivamente richieste.
- Eseguire test su iPhone fisico, inclusi Face ID/codice, persistenza, esportazioni e acquisti Sandbox.
- Caricare una build firmata tramite Xcode/Transporter e attendere l'elaborazione Apple.

## Materiali e dichiarazioni

Servono informazioni reali del titolare che non vanno inventate:

- Nome legale dello sviluppatore o dell'organizzazione e recapito di supporto.
- URL pubblico della privacy policy e URL di supporto.
- Descrizione, parole chiave, categoria, età consigliata e screenshot per i dispositivi supportati.
- Risposte accurate al questionario App Privacy.
- Eventuali dichiarazioni richieste da Apple per un'app che tratta informazioni inserite dall'utente relative alla salute.

## Funzioni non attive da non dichiarare come disponibili

- Sincronizzazione automatica iCloud: non implementata; è disponibile il backup/ripristino manuale JSON Premium.
- Campi personalizzati: implementati e riservati a Premium.
- PDF Premium e abbonamenti: codice presente; necessitano di prodotti Apple configurati e test reali.
