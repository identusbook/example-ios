# FlightTix — Identus Example iOS App

FlightTix is a SwiftUI demonstration app for the [Hyperledger Identus](https://hyperledger-identus.github.io/docs/)
self-sovereign-identity stack. It runs an **edge agent** on-device that:

- requests **mediation** from an Identus Mediator (so it can receive DIDComm messages while offline),
- establishes a connection to an Identus **Cloud Agent**,
- and issues / holds verifiable credentials (a "passport" and a flight "ticket").

This README covers running the full stack locally and pointing the iOS app at it for development.

There are **two independent projects**: this iOS app repository (which you're reading), and the
**identus-docker** backend stack (a separate repository). Clone them wherever you like — they don't
need to be siblings — and follow the steps below to connect them.

---

## Architecture

```
            ┌─────────────────────────── your Mac ───────────────────────────┐
            │                                                                 │
  iOS app   │   identus-docker (Docker Compose)                               │
 (Simulator)│                                                                 │
   ┌──────┐ │   ┌───────────────┐  DIDComm   ┌────────────────────────────┐   │
   │ Edge │─┼──▶│ Mediator      │◀──────────▶│ Cloud Agent (PRISM)        │   │
   │ Agent│ │   │ :8080 (1.1.0) │            │ REST :8085 / DIDComm :8090 │   │
   └──────┘ │   └───────────────┘            └──────────┬─────────────────┘   │
       │    │                                           │                     │
       └────┼────────── REST :8085 ────────────────────▶│  prism-node, db,    │
            │                                            │  mongo (internal)   │
            └─────────────────────────────────────────────────────────────────┘
```

Two backends matter to the app, configured in `FlightTix/FlightTix/Agent/IdentusConfig.swift`:

| Backend | Purpose | Host port | App reaches it via |
| --- | --- | --- | --- |
| **Mediator** | DIDComm message routing / mailbox | `8080` | `mediatorDidString` (DID encodes `identus-mediator:8080`) |
| **Cloud Agent** | REST API: connections, schemas, issuing | `8085` | `FlightTixSessionConfigStruct.baseURL = http://cloud-agent:8085` |

> ⚠️ **The hostnames `cloud-agent` and `identus-mediator` are required** — see [Name resolution](#3-name-resolution-required) below. They are not optional aliases; the Cloud Agent bakes them into the DIDs and schema URLs it generates, and the app must reach the services at the *same* names.

---

## Prerequisites

- **macOS** with **Xcode 26.x** (project was built against Xcode 26.3) and an iOS Simulator.
- **Docker Desktop** (running).
- A **GitHub SSH key**, configured and added to your account — the Swift Package dependencies resolve over `git@github.com:` URLs (`hyperledger-identus/sdk-swift`, `goodfuturellc/identus-swift`). Verify with `ssh -T git@github.com`.
- `jq` (only for the optional helper scripts): `brew install jq`.
- The **identus-docker** stack — a separate project that bundles the Cloud Agent, Mediator, and their
  dependencies as Docker Compose services. Obtain it and place it anywhere on your machine. This README
  refers to its directory as `$IDENTUS_DOCKER`; set it once for the commands below, e.g.:

  ```bash
  export IDENTUS_DOCKER=~/path/to/identus-docker
  ```

---

## Part 1 — Run the backend (identus-docker)

```bash
cd "$IDENTUS_DOCKER"
docker compose up -d
```

This starts five containers: `cloud-agent`, `identus-mediator`, `prism-node`, `db` (Postgres), `mongo`.

### Ports exposed to the host

| Port | Service |
| --- | --- |
| `8080` | Mediator — DIDComm endpoint |
| `8085` | Cloud Agent — REST API |
| `8090` | Cloud Agent — DIDComm endpoint |

### Apple Silicon M4 note

On an M4 CPU the Cloud Agent may fail to boot with `No java installations was detected.`
Use the bundled workaround image: in `docker-compose.yaml`, switch the `cloud-agent` service from
`image: …/identus-cloud-agent:2.0.0` to `build: ./cloud-agent-M4-workaround`, then:

```bash
docker compose up --build --remove-orphans --force-recreate
```

See `identus-docker/dockerize-identus.md` for full details.

### Verify it's up

```bash
curl -s http://localhost:8085/_system/health   # → {"version":"2.0.0"}
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080   # → 200 (mediator)
```

---

## Part 2 — Configure the host

### 3. Name resolution (required)

The Cloud Agent and Mediator advertise themselves using their **Docker hostnames**
(`http://cloud-agent:8085`, `http://identus-mediator:8080`). For the app — running on the Simulator,
which uses your Mac's resolver — to reach them at those same names, add them to `/etc/hosts`:

```bash
sudo sh -c 'echo "127.0.0.1 localhost cloud-agent identus-mediator" >> /etc/hosts'
```

(If a `127.0.0.1 localhost` line already exists, edit it to append `cloud-agent identus-mediator` instead of adding a duplicate.)

Verify from the host (the Simulator resolves identically):

```bash
curl -s -o /dev/null -w "cloud-agent:8085 → %{http_code}\n" http://cloud-agent:8085/_system/health
curl -s -o /dev/null -w "identus-mediator:8080 → %{http_code}\n" http://identus-mediator:8080
```

---

## Part 3 — Configure & run the iOS app

### Open the project

```bash
open FlightTix/FlightTix.xcodeproj
```

Select the **FlightTix** scheme and an iOS Simulator (e.g. iPhone 17 Pro). Xcode resolves the Swift
Packages on first open — this needs your GitHub SSH access.

### Key configuration files

**`FlightTix/FlightTix/Agent/IdentusConfig.swift`**

- `mediatorDidString` — the mediator's peer DID. For this stack it must point at the **1.1.0** mediator on `:8080`. With the default compose keys it is deterministic:

  ```
  did:peer:2.Ez6LSghwSE437wnDE1pt3X6hVDUQzSjsHzinpX3XFvMjRAm7y.Vz6Mkhh1e5CEYYq6JBUcTZ6Cp2ranCWRrv7Yax3Le4N59R6dd.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6Imh0dHA6Ly9pZGVudHVzLW1lZGlhdG9yOjgwODAiLCJhIjpbImRpZGNvbW0vdjIiXX19.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6IndzOi8vaWRlbnR1cy1tZWRpYXRvcjo4MDgwL3dzIiwiYSI6WyJkaWRjb21tL3YyIl19fQ
  ```

  To fetch the current value yourself, open `http://localhost:8080/` and copy the `did:peer:…` from the page's `<meta name="did">` tag. (Only `mediatorDidString` drives mediation; `mediatorOOBString` is currently unused by the mediation flow.)

**`FlightTix/FlightTix/Networking/FlightTixURLSessionConfig.swift`**

- `baseURL = http://cloud-agent:8085` — the Cloud Agent REST API. Leave it as the `cloud-agent` hostname; this is also embedded into the schema URLs the Cloud Agent must dereference internally, which is why `/etc/hosts` matters.

**`FlightTix/FlightTix/Info.plist`**

- Allows the app to talk to the local HTTP backends (App Transport Security):

  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key><true/>
      <key>NSAllowsLocalNetworking</key><true/>
  </dict>
  <key>NSLocalNetworkUsageDescription</key>
  <string>FlightTix connects to a DIDComm mediator on your local network.</string>
  ```

### Run

Build & run (⌘R). On launch the app bootstraps automatically (`Identus.startUpAndConnect()`):

1. Starts the edge agent and **achieves mediation** with the mediator.
2. Creates a connection to the Cloud Agent.
3. Creates the issuer DID and publishes the passport schema if they don't exist.

A successful start logs (in the Xcode console):

```
[Core] Starting agent
[Core] … Mediation Achieved
```

---

## ⚠️ Mediator version compatibility

The edge agent uses **EdgeAgentSDK 7.2.0**, which works with **identus-mediator 1.1.0**
but **not 1.2.1**. With 1.2.1 the mediator grants mediation but returns an *empty HTTP body*
to the return-routed `mediate-request`, and the SDK fails with:

```
mediationRequestFailedError: "Trying to achieve mediation returned empty data"
```

…which then cascades into repeated **"There is no mediator"** errors. The `identus-docker`
stack pins `1.1.0`, so keep `mediatorDidString` pointed at the `:8080` mediator. Do **not**
point it at a standalone 1.2.1 mediator unless you also upgrade the SDK.

---

## Running on a physical device (instead of the Simulator)

A real device does not use your Mac's `/etc/hosts`, so the `cloud-agent` / `identus-mediator`
names won't resolve. To run on-device:

1. Put your Mac and the device on the **same Wi-Fi**, and find your Mac's LAN IP (e.g. `ipconfig getifaddr en0`).
2. In `identus-docker/docker-compose.yaml`, change the services to advertise that IP:
   - Mediator: `SERVICE_ENDPOINTS=http://<MAC_LAN_IP>:8080;ws://<MAC_LAN_IP>:8080/ws`
   - Cloud Agent: `DIDCOMM_SERVICE_URL=http://<MAC_LAN_IP>:8090`, `REST_SERVICE_URL=http://<MAC_LAN_IP>:8085`
3. `docker compose up -d --force-recreate`, then update the app:
   - `mediatorDidString` ← the mediator's new DID from `http://<MAC_LAN_IP>:8080/`
   - `baseURL` ← `http://<MAC_LAN_IP>:8085`

---

## Resetting state

- **App / agent state** (seed, connections — persisted in the Simulator keychain & store):
  Simulator menu → **Device → Erase All Content and Settings**, or delete the app.
- **Backend data** (DIDs, schemas, mediator mailbox):
  ```bash
  cd "$IDENTUS_DOCKER"
  docker compose down -v && docker compose up -d
  ```

---

## Optional helper scripts

`create-issuer-did.sh` and `create-passport-schema.sh` (run via `./setup.sh`) create an issuer DID
and schema directly against the Cloud Agent. The app already does this on startup, so they're
optional. Note their `BASE_URL` assumes an API gateway at `http://localhost/cloud-agent/…`; if you
aren't running that gateway, point them at the direct REST endpoint `http://localhost:8085/…`
instead. The stack ships with `API_KEY_ENABLED=false`, so no API key is required in development.

---

## Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| `"There is no mediator"` (repeating) | Mediation never achieved. Check the mediator is up and `mediatorDidString` targets the **1.1.0** `:8080` mediator. |
| `"Trying to achieve mediation returned empty data"` | You're pointed at a **1.2.1** mediator — incompatible with EdgeAgentSDK 7.2.0. Use 1.1.0. |
| `"A server with the specified hostname could not be found"` | Missing `/etc/hosts` entry for `cloud-agent` / `identus-mediator`. |
| REST calls hang / time out | Cloud Agent not healthy: `curl http://localhost:8085/_system/health`. |
| Swift Package resolution fails in Xcode | GitHub SSH not configured: `ssh -T git@github.com`. |
| Cloud Agent won't start on M4 Mac (`No java …`) | Use the `cloud-agent-M4-workaround` build (see Part 1). |
