//
//  IdentusConfig.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

struct IdentusConfig {
    
    // Local
//    let mediatorOOBString: String = "http://10.43.1.41:8800?_oob=eyJpZCI6ImZjNzliMzMxLTVhMWQtNGMwZi05YzBlLTk3ZjdiNDcyY2MwNCIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNnaHdTRTQzN3duREUxcHQzWDZoVkRVUXpTanNIemlucFgzWEZ2TWpSQW03eS5WejZNa2hoMWU1Q0VZWXE2SkJVY1RaNkNwMnJhbkNXUnJ2N1lheDNMZTRONTlSNmRkLlNleUowSWpvaVpHMGlMQ0p6SWpwN0luVnlhU0k2SW1oMGRIQTZMeTlzYjJOaGJHaHZjM1E2T0Rnd01DSXNJbUVpT2xzaVpHbGtZMjl0YlM5Mk1pSmRmWDAuU2V5SjBJam9pWkcwaUxDSnpJanA3SW5WeWFTSTZJbmR6T2k4dmJHOWpZV3hvYjNOME9qZzRNREF2ZDNNaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMTkiLCJib2R5Ijp7ImdvYWxfY29kZSI6InJlcXVlc3QtbWVkaWF0ZSIsImdvYWwiOiJSZXF1ZXN0TWVkaWF0ZSIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
    
    let mediatorOOBString: String = "http://10.43.1.41:8800?_oob=eyJpZCI6IjM4MzhkM2Y3LTQ5YTAtNDc1OC1iODBhLTg1ZGY5YjgzOWY3OSIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNnaHdTRTQzN3duREUxcHQzWDZoVkRVUXpTanNIemlucFgzWEZ2TWpSQW03eS5WejZNa2hoMWU1Q0VZWXE2SkJVY1RaNkNwMnJhbkNXUnJ2N1lheDNMZTRONTlSNmRkLlNleUowSWpvaVpHMGlMQ0p6SWpwN0luVnlhU0k2SW1oMGRIQTZMeTh4TUM0ME15NHhMalF4T2pnNE1EQWlMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDE5LlNleUowSWpvaVpHMGlMQ0p6SWpwN0luVnlhU0k2SW5kek9pOHZNVEF1TkRNdU1TNDBNVG80T0RBd0wzZHpJaXdpWVNJNld5SmthV1JqYjIxdEwzWXlJbDE5ZlEiLCJib2R5Ijp7ImdvYWxfY29kZSI6InJlcXVlc3QtbWVkaWF0ZSIsImdvYWwiOiJSZXF1ZXN0TWVkaWF0ZSIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
    
    // TEST (revert later): 1.1.0 mediator on :8080. identus-mediator resolves to 127.0.0.1 via /etc/hosts from the simulator.
    let mediatorDidString: String =  "did:peer:2.Ez6LSghwSE437wnDE1pt3X6hVDUQzSjsHzinpX3XFvMjRAm7y.Vz6Mkhh1e5CEYYq6JBUcTZ6Cp2ranCWRrv7Yax3Le4N59R6dd.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6Imh0dHA6Ly9pZGVudHVzLW1lZGlhdG9yOjgwODAiLCJhIjpbImRpZGNvbW0vdjIiXX19.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6IndzOi8vaWRlbnR1cy1tZWRpYXRvcjo4MDgwL3dzIiwiYSI6WyJkaWRjb21tL3YyIl19fQ"
    
    let seedKeychainKey: String = "FlightTixSeed"
    let urlSessionConfig: URLSessionConfig = FlightTixSessionConfigStruct()
    
    let cloudAgentConnectionLabel: String = "FlightTixiOS-CloudAgent"
    let cloudAgentConnectionIdKeychainKey: String = "CloudAgentConnectionId"
    let cloudAgentIssuerDIDKeychainKey: String = "CloudAgentIssuerDID"
    
    let passportIssueVCThidKeychainKey: String = "IssuePassportVC"
    let passportSchemaId: String = "https://identusbook.com/flighttix-passport-1.0.0"
    let passportSchemaIdKeychainKey: String = "PassportSchemaId"
    let ticketSchemaId: String = "https://identusbook.com/flighttix-ticket-1.0.0"
    let ticketSchemaIdKeychainKey: String = "TicketSchemaId"
    let ticketIssueVCThidKeychainKey: String = "IssueTicketVC"
}
