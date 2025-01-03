//
//  IdentusConfig.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/20/24.
//

import Foundation

struct IdentusConfig {
    // RootsID
    let mediatorOOBString: String = "https://mediator.rootsid.cloud?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiYmYzMTY4ZjQtMjIyZC00NmJiLWE1ZjMtMTFiNzAyMzZjNDg0IiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNtczU1NVloRnRobjFXVjhjaURCcFptODZoSzl0cDgzV29qSlVteFBHazFoWi5WejZNa21kQmpNeUI0VFM1VWJiUXc1NHN6bTh5dk1NZjFmdEdWMnNRVllBeGFlV2hFLlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd2N6b3ZMMjFsWkdsaGRHOXlMbkp2YjNSemFXUXVZMnh2ZFdRaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMCIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwibGFiZWwiOiJNZWRpYXRvciIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
//
    let mediatorDidString: String = "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPKg1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE"
    
    let seedKeychainKey: String = "FlightTixSeed"
    let urlSessionConfig: URLSessionConfig = FlightTixSessionConfigStruct()
    
    let cloudAgentConnectionLabel: String = "FlightTixiOS-CloudAgent"
    let cloudAgentConnectionIdKeychainKey: String = "CloudAgentConnectionId"
}
