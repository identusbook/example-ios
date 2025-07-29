//
//  IdentusConfig.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

struct IdentusConfig {
//    // RootsID
//    let mediatorOOBString: String = "https://mediator.rootsid.cloud?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiYmYzMTY4ZjQtMjIyZC00NmJiLWE1ZjMtMTFiNzAyMzZjNDg0IiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNtczU1NVloRnRobjFXVjhjaURCcFptODZoSzl0cDgzV29qSlVteFBHazFoWi5WejZNa21kQmpNeUI0VFM1VWJiUXc1NHN6bTh5dk1NZjFmdEdWMnNRVllBeGFlV2hFLlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd2N6b3ZMMjFsWkdsaGRHOXlMbkp2YjNSemFXUXVZMnh2ZFdRaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMCIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwibGFiZWwiOiJNZWRpYXRvciIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
//    
    // Csign
    let mediatorOOBString: String = "https://mediator.csign.io?_oob=eyJpZCI6IjQxYzNkMDQ5LWVjZDEtNDFhZC05ZDI0LTE1YzlmOGRkMjMwNiIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNxU3hUTWtKVHJxZ2lqcGdIVVZ5NkJyYndpc3BUenhmVU05azI3SEpNUW9hNS5WejZNa3ZSV2tCUmVTUXAxUWpRNjFhUktzUWVwR0tSRnNiMUQyOXFyNVlxaTdxMUh5LlNleUowSWpvaVpHMGlMQ0p6SWpwN0luVnlhU0k2SW1oMGRIQnpPaTh2YldWa2FXRjBiM0l1WTNOcFoyNHVhVzhpTENKaElqcGJJbVJwWkdOdmJXMHZkaklpWFgxOSIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwiYWNjZXB0IjpbImRpZGNvbW0vdjIiXX0sInR5cCI6ImFwcGxpY2F0aW9uL2RpZGNvbW0tcGxhaW4ranNvbiJ9"
    
//    let mediatorDidString: String = "did:peer:2.Ez6LSqSxTMkJTrqgijpgHUVy6BrbwispTzxfUM9k27HJMQoa5.Vz6MkvRWkBReSQp1QjQ61aRKsQepGKRFsb1D29qr5Yqi7q1Hy.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6Imh0dHBzOi8vbWVkaWF0b3IuY3NpZ24uaW8iLCJhIjpbImRpZGNvbW0vdjIiXX19"
    
    let mediatorDidString: String = "did:peer:2.Ez6LSghwSE437wnDE1pt3X6hVDUQzSjsHzinpX3XFvMjRAm7y.Vz6Mkhh1e5CEYYq6JBUcTZ6Cp2ranCWRrv7Yax3Le4N59R6dd.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6Imh0dHA6Ly9pZGVudHVzLW1lZGlhdG9yOjgwODAiLCJhIjpbImRpZGNvbW0vdjIiXX19.SeyJ0IjoiZG0iLCJzIjp7InVyaSI6IndzOi8vaWRlbnR1cy1tZWRpYXRvcjo4MDgwL3dzIiwiYSI6WyJkaWRjb21tL3YyIl19fQ"
    
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
