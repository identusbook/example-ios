# FlightTix — Language-Neutral Specification

This document specifies the **FlightTix** sample app — a digital airline-ticketing demo for the [Identus](https://www.hyperledger.org/projects/identus) SSI platform — in a form that can be reimplemented in any language whose Identus SDK exposes the same edge-agent and Cloud Agent capabilities the iOS reference uses.

The iOS source under `FlightTix/FlightTix/` is the authoritative behavior; everything below restates that behavior in language-neutral form. Where this spec describes a screen, controls and copy are normative; layout is not. Where it describes a flow, the sequence of Cloud Agent endpoints and DIDComm messages is normative; intermediate SDK calls are illustrative.

---

## 1. Overview

FlightTix demonstrates an SSI use case with three actors and two verifiable credentials.

- **Traveller** — the user of the mobile app. Holds a wallet (edge agent) on-device.
- **Airline / Issuer** — runs an Identus Cloud Agent. Issues the Passport VC and the Ticket VC.
- **Security Officer / Verifier** — also driven through the Cloud Agent in this sample. Requests proof that the Traveller holds a valid Ticket VC.

Flow:

1. The Traveller opens the app. The edge agent boots, connects to a mediator, and pairs with the airline's Cloud Agent.
2. The Traveller fills in passport details. The airline issues a **Passport VC**, the wallet stores it. Holding a valid Passport VC counts as being "logged in".
3. The Traveller picks a flight and taps Purchase. The airline issues a **Ticket VC** for that flight.
4. At the airport, the security officer issues a proof request. The Traveller's wallet replies with a **Presentation** of the Ticket VC. The verifier confirms the presentation.

No payment, no real flight search, no server-side user accounts. All "auth" is "does the wallet hold a valid Passport VC?" — that is the entire login model.

---

## 2. Glossary

- **DID** — Decentralized Identifier. A URI that resolves to a DID Document containing public keys and services. Two forms: **long-form** (self-certifying, usable immediately) and **short-form** (only valid once published to the underlying ledger).
- **Prism DID** — Identus's DID method, anchored to a ledger.
- **Peer DID** — DID type used between peers (mediator, agents) that doesn't need to be published.
- **VC (Verifiable Credential)** — Cryptographically signed JSON document with claims about a subject, signed by an issuer DID.
- **Schema** — JSON Schema describing the claims a particular type of VC carries. Identified by a stable schema ID (a URL) and a Cloud-Agent–assigned GUID.
- **OOB invitation (Out-of-Band)** — A URL or QR that bootstraps a DIDComm relationship.
- **DIDComm** — Encrypted peer-to-peer messaging protocol carrying issuance, presentation, mediation, and other SSI messages.
- **Mediator** — A relay service that forwards DIDComm messages to mobile agents that aren't always reachable directly.
- **Holder** — The party holding a VC in their wallet (the Traveller).
- **Issuer** — The party that issues a VC (the airline, via the Cloud Agent).
- **Verifier** — The party that requests proof of a VC (the airport security check, also via the Cloud Agent).
- **Cloud Agent** — Identus server component exposing REST endpoints for issuance, presentation, DID and schema management.
- **Edge Agent** — Identus client component (in the mobile app) holding the seed, keys, and credentials.
- **Presentation** — A DIDComm response to a `RequestPresentation`, containing a JWS-wrapped proof derived from a VC.
- **`thid`** — DIDComm "thread ID". A correlation ID that ties together the offer / request / issue messages of one credential exchange.

---

## 3. Configuration

Every port must supply these values before the app can run. iOS holds them in `Agent/IdentusConfig.swift`.

### 3.1 Required configuration

| Key | Purpose | Example |
| --- | --- | --- |
| `mediatorOOBString` | OOB invitation URL the edge agent uses to register with a DIDComm mediator. Determines who relays messages. | `https://mediator2.trust0.id?_oob=<base64-invite>` |
| `mediatorDidString` | Peer DID of the mediator. Encodes the mediator's HTTPS + WebSocket endpoints inside the DID itself. | `did:peer:2.Ez6LS…` |
| Cloud Agent base URL | Where REST calls go. Must be reachable both from the mobile device *and* from inside the Cloud Agent container (the agent dereferences `schemaId` URLs itself). | `http://localhost:8085` for dev (see Section 8.6 note) |
| `cloudAgentConnectionLabel` | Human-readable label stamped on the agent⇄app DIDComm connection. | `FlightTixiOS-CloudAgent` |
| `passportSchemaId` | Stable `$id` for the Passport credential schema. | `https://identusbook.com/flighttix-passport-1.0.0` |
| `ticketSchemaId` | Stable `$id` for the Ticket credential schema. | `https://identusbook.com/flighttix-ticket-1.0.0` |

Three sample mediators are commented in `IdentusConfig.swift` — **RootsID**, **Csign**, **Trust0** — the reference uses Trust0. Any RFC-0434-compatible mediator will work.

### 3.2 Secure storage

The iOS app stores everything in the OS keychain. A port should use whatever the platform-equivalent secure store is. Logical entries:

| Logical key | Holds | Why kept |
| --- | --- | --- |
| `seed` | Edge agent seed (the root cryptographic material) | Required to re-instantiate the same wallet across launches |
| `cloudAgentConnectionId` | The connection ID returned by the Cloud Agent for the app⇄agent DIDComm pair | Reused; created only on first run |
| `cloudAgentIssuerDID` | The issuer DID (base64-encoded long-form on creation, short-form once published) | The Cloud Agent's authoring DID for both schemas and credentials |
| `passportSchemaId` | GUID of the Passport schema registration on the Cloud Agent | Lookup, and avoids re-creating on every launch |
| `ticketSchemaId` | GUID of the Ticket schema registration on the Cloud Agent | Same |
| `passportVCThid` | DIDComm `thid` of the in-flight Passport credential exchange | Lets the message handler match the incoming offer/issue to the right VC type |
| `ticketVCThid` | DIDComm `thid` of the in-flight Ticket credential exchange | Same |

The wallet itself (issued VCs, private keys, connections) is managed by the edge agent SDK. No app-level database.

---

## 4. Data Models

Language-neutral structs used inside the app. The wallet stores VCs; these structs only exist in memory while a screen is rendering.

```
Passport {
    id:              UUID         // local-only; not on the VC
    name:            string
    did:             string?      // subject DID, populated from the VC's `sub`
    passportNumber:  string
    dob:             datetime
    dateOfIssuance:  datetime?    // populated from the VC
}

Ticket {
    price:     number
    departure: string
    arrival:   string
}

Flight {
    id:        UUID
    departure: string
    arrival:   string
    price:     number
}

Traveller {
    passport: Passport
    tickets:  Ticket[]            // empty in current UI; reserved
}

SecurityOfficer {
    id: UUID                      // unused in current UI; reserved
}
```

The wallet holds at most one Passport VC and (in the current UI) one Ticket VC at a time. There is no list view of multiple tickets.

---

## 5. Verifiable Credential Schemas

Both schemas are registered to the Cloud Agent via the schema registry (Section 9). Each registration is one JSON object containing metadata + an embedded JSON Schema 2020-12 document.

### 5.1 Passport schema

Schema registration body:

```json
{
  "name": "passport",
  "version": "1.0.0",
  "description": "Passport Schema",
  "type": "https://w3c-ccg.github.io/vc-json-schemas/schema/2.0/schema.json",
  "author": "<short-form issuer DID>",
  "tags": ["passport", "schema"],
  "schema": {
    "$id": "https://identusbook.com/flighttix-passport-1.0.0",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "description": "Passport",
    "type": "object",
    "properties": {
      "name":           { "type": "string" },
      "dateOfIssuance": { "type": "string", "format": "date-time" },
      "passportNumber": { "type": "string" },
      "dob":            { "type": "string", "format": "date-time" }
    },
    "required": ["name", "dateOfIssuance", "passportNumber", "dob"],
    "additionalProperties": true
  }
}
```

Credential claims sent at issuance time (`PassportClaimsRequest`):

```
name:           string
dateOfIssuance: string  // ISO-8601, set to "now" when the offer is created
passportNumber: string
dob:            string  // ISO-8601
```

### 5.2 Ticket schema

```json
{
  "name": "ticket",
  "version": "1.0.0",
  "description": "Ticket Schema",
  "type": "https://w3c-ccg.github.io/vc-json-schemas/schema/2.0/schema.json",
  "author": "<short-form issuer DID>",
  "tags": ["ticket", "schema"],
  "schema": {
    "$id": "https://identusbook.com/flighttix-ticket-1.0.0",
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "description": "Ticket",
    "type": "object",
    "properties": {
      "name":           { "type": "string" },
      "dateOfIssuance": { "type": "string", "format": "date-time" },
      "price":          { "type": "number" },
      "departure":      { "type": "string" },
      "arrival":        { "type": "string" },
      "flightId":       { "type": "string" }
    },
    "required": ["name", "dateOfIssuance"],
    "additionalProperties": true
  }
}
```

Note that on the Ticket only `name` and `dateOfIssuance` are JSON-Schema-required, even though every claim is set in practice. The iOS app sends `name = flight.id` (the local UUID); a port can do the same or substitute a more meaningful label.

Ticket claims sent at issuance time (`TicketClaimsRequest`):

```
name:           string  // flight UUID in the iOS reference
dateOfIssuance: string  // ISO-8601 "now"
flightId:       string  // flight UUID
price:          number
departure:      string
arrival:        string
```

---

## 6. Screens & Behavior

The app has **one entry point**, **three top-level states**, **four tabs**, and **two modals**. Screen layout is up to each port; controls, copy, and on-action behavior listed below are normative.

### 6.1 Loading screen

Shown while the edge agent boots and finishes one-time setup (mediator handshake, connection to Cloud Agent, issuer DID, schemas).

- **Static text**: `FlightTxt` (large), `powered by` (caption), Identus logo image, plus an SDK version line `IdentusSwift: vX.Y.Z` (any port may omit or relabel).
- **Progress indicator** whose label is the current Identus status (Section 7.3). Cycles through `Starting Agent → Starting DIDComm Message Listener → Creating Connection to Cloud Agent → Creating New Issuer DID / Issuer DID Already Exists → Publishing Issuer DID → Issuer DID Published → Checking Passport Schema → Created Passport Schema → Ready`.
- **Button**: `Tear Down and Stop` — dev affordance; calls teardown (Section 8.7) then stops the agent.
- **Transition**: when status reaches `Ready`, wait ~2 seconds, then transition to the Tabs state. The 2 s delay is cosmetic — keep it for UX parity.

### 6.2 Register screen (modal)

Presented as a full-screen cover whenever the user is in Tabs state and `Auth.isLoggedIn()` returns false (Section 7.4).

- **Form** under section header `Passport Information`:
  - Text field `Name`
  - Text field `Passport Number`
  - Date picker `Birthdate` (date only)
- **Button** `Submit` (inside the form):
  1. Local validation: both `name` and `passportNumber` must be > 1 character.
  2. Call the **Passport issuance flow** (Section 8.4) with the form values.
  3. Wait **20 seconds** for the DIDComm round-trip to settle. (The reference uses a hard delay; a port may listen for the `IssueCredential3_0` message and proceed when the VC actually lands in the wallet instead.)
  4. Call the **self-presentation** flow (Section 8.5) against the passport schema, to confirm the wallet actually now holds the VC.
  5. Dismiss the modal.
- **Button** `Close` (below the form): dismisses without doing anything else.

Focus the Name field on appear.

### 6.3 Purchase tab

- **Label** `Choose Flight:`
- **Dropdown picker** `Flights` showing all entries returned by the flight catalog (Section 11), each formatted as `<DEP> → <ARR> – $<PRICE in USD>`. Default selection: first entry.
- **Button** `Purchase Ticket`: triggers the **Ticket issuance flow** (Section 8.4) for the selected flight. On success, the view model sets a `purchaseComplete` flag (no in-screen confirmation in the current UI — the Ticket tab is where the user sees the issued ticket).
- **Top-right** profile icon (person.crop.circle): opens the Profile modal (6.7).

### 6.4 Ticket tab

Loads on appear. Until loaded, shows `Loading Ticket Details...`. Once loaded, shows:

```
Your Ticket Details:
Departure: <departure>
Arrival:   <arrival>
Price:     <price with 2 decimal places>
```

The load consists of:
1. Read `ticketSchemaId` from secure storage.
2. Ask the edge agent for the first stored VC whose schema GUID matches that ID (Section 8.5 helper).
3. Pull `departure`, `arrival`, `price` from the credential claims into a `Ticket` value.

There is a 1-second cosmetic delay before flipping the loaded flag. Keep or drop at the port's discretion.

### 6.5 Airport Security tab

- **Button** `Request Proof of Ticket`.

The reference iOS button is wired to a stub (`requestProof()` is empty). The intended behavior — and what a port should implement — is the **verifier-initiated presentation flow** (Section 8.5) against the Ticket schema. A successful presentation indicates the Traveller holds a valid Ticket VC. The Dev Utils tab already contains a working `requestProofOfTicket` implementation that ports can mirror.

### 6.6 Profile (modal)

Loads on appear. Until loaded: `Loading Passport Details...`. Once loaded:

```
Passport Details
Name:            <name>
Passport Number: <passportNumber>
Birthdate:       <dob formatted as date>
```

Plus a `Close` button that dismisses the modal.

Load = fetch the Passport VC via the same schema-ID-match approach used by the Ticket tab; map `name`, `passportNumber`, `dob`, `dateOfIssuance` claims into a `Passport` value, then into a `Traveller`.

### 6.7 Dev Utils tab

Developer-only screen. Not a user feature; useful for any port during bring-up.

- **Reset Wallet** — call teardown (Section 8.7).
- **Start Up and Connect** — re-run the full startup sequence (Section 8.1).
- **Stop** — stop the agent without wiping storage.
- **Issue Passport** — synthesize a hardcoded `Passport` (`Jon Bauer / 12345 / dob=now`) and run the passport issuance flow, wait 30 s, then run the passport self-presentation. Used to exercise issuance independently of the registration screen.
- **Issue Ticket** — synthesize a hardcoded `Flight` (`SFO → TYO / $700`) and run the ticket issuance flow, wait 30 s, then run the ticket self-presentation.

---

## 7. Navigation & State Machine

### 7.1 Top-level state

```
viewState ∈ { loading, login, tabs }
```

- Start in `loading`.
- When `IdentusStatus.status == ready`, transition to `tabs` (after the cosmetic 2 s delay).
- `login` is reserved in the enum but **unused** in the current UI — the "login" UX is implemented as a modal over Tabs, not as a top-level state. Ports may collapse this enum to two states.

### 7.2 Tabs

Four tabs, fixed order:

1. `Purchase` — airplane icon
2. `Ticket` — ticket icon
3. `Airport Security` — raised-hand icon
4. `Dev Utils` — wrench icon

### 7.3 Modals

A single "active modal" slot — only one modal at a time. Cases: `register`, `profile`. Implemented in iOS via `ModalManager` (an observable holding `activeModal: ActiveModal?` with `show(_)` and `dismiss()`). A port should mirror this — having both modals open simultaneously is not a supported state.

### 7.4 Login gating

`Auth.isLoggedIn()` resolves to true iff a Passport VC is held by the wallet:

```
isLoggedIn():
    if cached "valid" flag is true: return true
    if a credential whose schema GUID == stored passportSchemaId exists in the wallet:
        cache "valid" = true
        return true
    return false
```

When the Tabs view appears, **and** on every tab switch, the app checks `isLoggedIn()` and, if false, presents the Register modal. This means the modal will keep coming back on any tab change until a Passport VC is in the wallet.

### 7.5 Identus status

The startup sequence publishes a stream of states to a shared `IdentusStatus` observable. The Loading screen displays the description for the current state.

```
disconnected
startingAgent
startingDIDCommMessageListener
creatingConnectionToCloudAgent
issuerDIDAlreadyExists
creatingIssuerDID
publishingIssuerDID
issuerDIDPublished
checkingPassportSchema
creatingPassportSchema
createdPassportSchema
connected         // declared, not used in the reference startup
ready
error(<message>)
```

A port should at minimum emit `startingAgent`, `creatingConnectionToCloudAgent`, the issuer-DID states, the schema state(s), and `ready` — those are what drive the visible Loading screen progress.

---

## 8. Identus Flows

Each subsection gives the conceptual sequence and lists the underlying Cloud Agent REST endpoints + DIDComm messages. All HTTP responses are JSON; field names are listed in Section 9 for the request/response shapes specifically referenced here.

### 8.1 Startup & mediation

Concept: bring the edge agent online, connect to a mediator, then run the one-time setup steps if needed (connection to Cloud Agent, issuer DID, schemas), and only then signal `ready`.

Steps:

1. If a seed is in secure storage, load it. Otherwise create a random seed and store it.
2. Construct an edge agent (`DIDCommAgent`) bound to (seed, mediator peer DID).
3. Start the agent. Mediation handshake runs as part of starting.
4. Subscribe to incoming DIDComm messages — see Section 8.8.
5. Run `createConnectionToCloudAgentIfNotExists` (Section 8.2).
6. Run `createIssuerDIDOnCloudAgentIfNotExists` (Section 8.3).
7. Run `createPassportSchemaIfNotExists` (Section 8.6).
   (Ticket schema is created lazily on first Ticket purchase; ports may either also create it eagerly or follow the lazy approach.)
8. Set status `ready`.

Steps 5–7 are idempotent: each checks secure storage / Cloud Agent state and short-circuits if already done.

### 8.2 Connection between app and Cloud Agent

Concept: the app must hold a Cloud Agent connection ID to issue credentials against it. Establish one DIDComm connection on first run; reuse it forever after.

Steps:

1. If a `cloudAgentConnectionId` is in secure storage, ask the Cloud Agent whether that connection still exists with the configured label:
   - `GET /connections` and check `contents[*].connectionId == stored && label == cloudAgentConnectionLabel`.
   - If present, done.
2. Otherwise:
   1. Ask the Cloud Agent to create an OOB invitation: `POST /connections` with `{ "label": "<cloudAgentConnectionLabel>" }`. Response includes `invitation.invitationUrl`.
   2. Parse the OOB invitation in the edge agent.
   3. Accept the OOB invitation through the edge agent — this triggers a DIDComm `connectionRequest` → `connectionResponse` exchange under the hood.
   4. Persist the new connection's ID under `cloudAgentConnectionId`.

### 8.3 Issuer DID setup (one-time)

Concept: the airline needs a published issuer DID. The reference assumes one issuer DID per Cloud Agent and treats whatever is already on the Cloud Agent as canonical.

Steps:

1. `GET /did-registrar/dids`. If a DID already exists, store its short form under `cloudAgentIssuerDID`, set status `issuerDIDAlreadyExists`, done.
2. Otherwise create one:
   - `POST /did-registrar/dids` with body:
     ```json
     {
       "documentTemplate": {
         "publicKeys": [
           { "id": "auth-1",  "purpose": "authentication" },
           { "id": "issue-1", "purpose": "assertionMethod" }
         ],
         "services": []
       }
     }
     ```
   - Response contains `longFormDid`. Persist (base64-encoded) under `cloudAgentIssuerDID`.
3. Resolve the short form:
   - `GET /did-registrar/dids/<longFormDid>`. Response has `did` (the short form) and `status`.
4. Request publication:
   - `POST /did-registrar/dids/<shortFormDid>/publications` with body `{ "didRef": "<shortFormDid>" }`.
   - Verify response.scheduledOperation.didRef matches.
5. **Block on publication.** Poll `GET /did-registrar/dids/<shortFormDid>` once per second; treat `status == "PUBLISHED"` as success. Surface `publishingIssuerDID` → `issuerDIDPublished` status to the UI. This step can take a long time (depends on the underlying ledger) but the issuer DID *must* be published before schema registration or credential issuance.

### 8.4 Credential issuance (Passport and Ticket)

Conceptually identical for both VC types — only schema, claim shape, and the secure-storage `thid` key differ.

Preconditions (validated for every issuance):

- Issuer DID present in secure storage.
- Issuer DID is in `PUBLISHED` state (re-verify each issuance — `GET /did-registrar/dids/<short>`).
- Target schema GUID present in secure storage.
- Cloud Agent connection ID present in secure storage.

Steps:

1. The app (acting as the issuer's mobile interface) asks the Cloud Agent to create a credential offer:
   - `POST /issue-credentials/credential-offers`
   - Body (Passport):
     ```json
     {
       "validityPeriod": 3600,
       "schemaId": "<cloudAgentBaseUrl>/schema-registry/schemas/<schemaGuid>/schema",
       "credentialFormat": "JWT",
       "claims": {
         "name": "...",
         "dateOfIssuance": "<ISO-8601 now>",
         "passportNumber": "...",
         "dob": "<ISO-8601>"
       },
       "automaticIssuance": true,
       "issuingDID": "<short-form issuer DID>",
       "connectionId": "<stored connectionId>"
     }
     ```
   - Body (Ticket): same shape, `claims` matches `TicketClaimsRequest` (Section 5.2).
   - Response includes `recordId`, `thid`, etc.
2. Persist `thid` under `passportVCThid` or `ticketVCThid`. The app uses this to correlate incoming DIDComm messages with the right VC type.
3. Wait for the DIDComm message handler (Section 8.8) to process the offer and issuance asynchronously.

The reference iOS app sleeps for 20 s after kicking off issuance (Register) or 30 s (Dev Utils) before asserting the credential is in the wallet. A port that wires the proof step directly to the wallet's "credential added" event can skip the sleep.

Important about `schemaId` in the offer body: the value is the **full URL the Cloud Agent will use to dereference the schema**, not just the GUID. Because the Cloud Agent runs in a container while the mobile device is on a different network, the iOS reference hardcodes `http://localhost:8085/...` (the URL inside the agent container). A port should use whatever URL is correct from the agent's perspective.

### 8.5 Presentation (proof)

There are two presentation flows in the app:

1. **Self-presentation** at the end of registration — the holder asks the verifier (also the Cloud Agent in this sample) for a proof request against the Passport schema, then satisfies it from the wallet. Confirms the VC actually exists.
2. **Verifier-initiated presentation** at airport security — same shape, against the Ticket schema.

Both use the same steps.

Concept: a verifier creates a proof request; the holder receives it via DIDComm, builds a presentation against a matching VC, sends the presentation back via DIDComm; the verifier polls the result.

Steps (verifier side):

1. Read the Cloud Agent connection ID from secure storage (in this sample the verifier role is run from the same connection).
2. `POST /present-proof/presentations` with body:
   ```json
   {
     "connectionId": "<stored connectionId>",
     "options": { "challenge": "<random UUID>", "domain": "identusbook.com" },
     "proofs": [
       {
         "schemaId": "<cloudAgentBaseUrl>/schema-registry/schemas/<schemaGuid>/schema",
         "trustIssuers": ["<short-form issuer DID, or 'some-issuer' placeholder>"]
       }
     ]
   }
   ```
3. Response is a presentation record. Persist its `presentationId` if the port needs to poll.
4. `GET /present-proof/presentations/{presentationId}` to inspect status.
5. Optionally `PATCH /present-proof/presentations/{presentationId}` to accept (`AcceptPresentationProofRequest`).
6. `GET /present-proof/presentations` lists all records (the iOS reference has this implemented but commented out in some places — JSON parsing issue noted in the source).

Steps (holder side, automatic, in the DIDComm handler):

1. Receive `RequestPresentation` message.
2. Look up the right VC in the wallet:
   - For Ticket-only flows: explicitly fetch a credential matching the Ticket schema GUID (Section 8.5.1).
   - For the self-presentation after registration: take the first available VC.
3. Build a presentation: edge agent's `createPresentationForRequestProof(request, credential)`.
4. Send the presentation back via DIDComm (`Presentation` message).

#### 8.5.1 Selecting a VC by schema

To match a VC in the wallet to a schema GUID:

1. Fetch all VCs from the wallet.
2. For each, decode the JWS payload to a `VerifiableCredentialEnvelope` (`{ vc: { credentialSchema: [{ id }] } }`). Some envelopes are the Ticket variant; decode both shapes.
3. From each `credentialSchema[*].id` URL, extract the GUID by matching `schemas/([a-f0-9-]+)/schema`.
4. Compare to the stored `passportSchemaId` or `ticketSchemaId` GUID; return the first match.

### 8.6 Schema registration

Concept: register the Passport and Ticket schemas exactly once per Cloud Agent. The schema GUID returned by the agent is what the app stores; the stable `$id` URL is what travels inside credentials.

Steps (per schema):

1. If `<X>SchemaId` GUID is in secure storage *and* the Cloud Agent still has it (`GET /schema-registry/schemas/<guid>` 200s), do nothing.
2. Otherwise:
   - Confirm the issuer DID is in storage and resolved to short form.
   - `POST /schema-registry/schemas` with the body from Section 5.
   - Response includes the assigned GUID; persist it under the corresponding `<X>SchemaIdKeychainKey`.

The reference creates the Passport schema during startup and the Ticket schema lazily on first Ticket purchase. A port can be eager about both.

### 8.7 Teardown (dev)

Stops the agent and removes every secure-storage key the app might have written:

```
stop agent
delete seed
delete cloudAgentIssuerDID  (if present)
delete cloudAgentConnectionId (if present)
delete passportVCThid (if present)
delete passportSchemaId (if present)
delete ticketVCThid (if present)
delete ticketSchemaId (if present)
```

Note: this only wipes app state. The Cloud Agent still holds the issuer DID, the schemas, and any past credential records. On next startup the app will rediscover the issuer DID and reuse it.

### 8.8 DIDComm message handler

The edge agent emits an event stream of received DIDComm messages. The app starts fetching messages on startup, runs a deduplication step on `createdTime`, and dispatches by message type.

Active handling (the reference dispatches only these explicitly; all others are logged as "unhandled"):

| Message type | Handler |
| --- | --- |
| `didcommconnectionResponse` | log only |
| `didcommOfferCredential3_0` | **handle offered credential** — see below |
| `didcommIssueCredential3_0` | **handle issued credential** — process and persist in wallet |
| `didcommRequestPresentation` | **handle presentation request** — fetch matching VC, build presentation, send |

**Handle offered credential**:

1. Read `passportVCThid` from secure storage. If the incoming offer's `thid` doesn't match, return (this is how the reference distinguishes Passport offers from other offers — Ticket offers are handled the same way but a port should generalize this; see TODO note in the source).
2. Edge agent: `createNewPrismDID()` — the subject DID for this VC.
3. Edge agent: `prepareRequestCredentialWithIssuer(did, offer)` → a `RequestCredential3_0` message.
4. Send the request message via DIDComm.

**Handle issued credential**: edge agent's `processIssuedCredentialMessage(issueCredential)`. This stores the VC in the wallet.

**Handle presentation request**: build a `Presentation` (Section 8.5) and send.

---

## 9. Cloud Agent API Reference

All paths are relative to the configured Cloud Agent base URL. All requests/responses are `application/json`. The dev script `create-issuer-did.sh` includes an `apikey` header — production deployments will need authentication that the reference does not document; treat the table as a starting list and add headers per deployment.

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/connections` | Create an OOB invitation (mobile pairs to this) |
| GET | `/connections` | List connections (used to verify a stored connection still exists) |
| POST | `/did-registrar/dids` | Create an issuer DID (long-form returned) |
| GET | `/did-registrar/dids` | List DIDs on the Cloud Agent |
| GET | `/did-registrar/dids/{shortOrLongFormDID}` | Get a DID and its publication status |
| POST | `/did-registrar/dids/{didRef}/publications` | Schedule publication of an issuer DID |
| POST | `/schema-registry/schemas` | Register a credential schema |
| GET | `/schema-registry/schemas/{guid}` | Get a registered schema by GUID |
| POST | `/issue-credentials/credential-offers` | Issuer: create a credential offer |
| GET | `/issue-credentials/records/{recordId}` | Get an issuance record |
| POST | `/issue-credentials/records/{recordId}/accept-offer` | Holder side: accept an offer (used when not relying on automatic flow) |
| POST | `/present-proof/presentations` | Verifier: create a proof request |
| GET | `/present-proof/presentations` | List proof requests |
| GET | `/present-proof/presentations/{presentationId}` | Inspect a single proof exchange |
| PATCH | `/present-proof/presentations/{presentationId}` | Accept a proof presentation |
| POST | `/verification/credential` | Verify a credential outside a presentation exchange |

Request/response shapes called out earlier:

- `CreateDIDRequest` — Section 8.3.
- `CreateDIDResponse` — `{ longFormDid: string }`.
- `PublishDIDRequest` — `{ didRef: string }`.
- `DIDStatusResponse` — `{ did: string, status: string, ... }`.
- `DIDsOnCloudAgentResponse` — `{ contents: [{ did: string, ... }] }`.
- `CreateCredentialOfferRequest` / `CreateTicketCredentialOfferRequest` — Section 8.4.
- `CreateCredentialOfferResponse` — `{ recordId, thid, credentialFormat, validityPeriod, claims, automaticIssuance, createdAt, role, protocolState, metaRetries }`.
- `CreateProofPresentationRequest` — Section 8.5.
- `PassportSchema` / `TicketSchema` — Section 5.

---

## 10. DIDComm Message Types Handled

The reference is built against the DIDComm v2 protocol set. Message PIURI strings come from the SDK; the conceptual types the app cares about are:

| Conceptual message | When |
| --- | --- |
| `OfferCredential3_0` | Cloud Agent → app, after a credential-offer is created |
| `RequestCredential3_0` | app → Cloud Agent, in response to an offer, with subject DID |
| `IssueCredential3_0` | Cloud Agent → app, final VC delivery |
| `RequestPresentation` | Verifier → app, proof request |
| `Presentation` | app → Verifier, proof response |
| Connection / mediation lifecycle | mediator and Cloud Agent connection setup |

A port using a non-Identus DIDComm library should ensure compatibility with these specific PIURIs.

---

## 11. Hardcoded Demo Data

### 11.1 Flight catalog

From `FlightSearch.availableFlights()`:

| id (UUID at runtime) | departure | arrival | price (USD) |
| --- | --- | --- | --- |
| auto | ATL | SCL | 500.00 |
| auto | SFO | TYO | 800.00 |
| auto | LAS | VIE | 700.00 |

(There is a dead-code `Flights` enum in `ContentView.swift` with different routes/dates — `ATL → SCL` 20:00 Mar 23 2025, `AMS → VIE` 09:30 May 29 2025, `SFO → HND` 11:00 Oct 25 2025. It is not displayed anywhere in the running app. Use the `FlightSearch` list above.)

### 11.2 Dev Utils stub data

- Issue Passport: `name="Jon Bauer"`, `did="did:example:123"`, `passportNumber="12345"`, `dob=now`.
- Issue Ticket: `Flight(departure="SFO", arrival="TYO", price=700.0)`.

These exist only on the Dev Utils tab.

---

## 12. Setup Scripts

The repo's `setup.sh` runs two helper scripts in order:

1. `create-issuer-did.sh` — `POST /did-registrar/dids` with the same `documentTemplate` the app sends (two keys: `auth-1` for `authentication`, `issue-1` for `assertionMethod`). Uses an `apikey` header and `http://localhost/cloud-agent/...` as base URL. Useful for pre-seeding a Cloud Agent before the first app launch.
2. `create-passport-schema.sh` — `POST /schema-registry/schemas` with a Passport schema. **Note:** the JSON in this script differs from what the app posts at runtime — the script includes a `did` claim (required) and the `$id` is `https://identusbook.com/passport-1.0.0` (without the `flighttix-` prefix). The runtime app uses `https://identusbook.com/flighttix-passport-1.0.0` with no `did` claim. Treat the in-app version (Section 5.1) as authoritative; reconcile or replace the script when porting.

A port may either reuse these shell scripts (they just hit the Cloud Agent) or produce equivalents in the target language.

---

## 13. Out of Scope

The reference iOS app does not implement, and a faithful port does not need:

- Real flight search, pricing, or booking.
- Payment.
- Multiple tickets per traveller, multi-passenger bookings, or a ticket list view.
- Multiple traveller profiles.
- Account recovery / seed export.
- Polished error UX (most error paths in the reference just `print` and rethrow).
- Tuning of the long pre-presentation sleeps (20 s / 30 s) — these can be replaced with event-driven waits in a port.
- Production-grade configuration of the Cloud Agent URL (the hardcoded `http://localhost:8085` is dev-only).
- Production authentication on Cloud Agent endpoints.
