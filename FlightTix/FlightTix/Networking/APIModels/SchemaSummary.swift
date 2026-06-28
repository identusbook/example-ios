//
//  SchemaSummary.swift
//  FlightTix
//
//  Lightweight view of the schema-registry list response, used to find an
//  already-published schema (by name + author) so we can adopt its GUID instead
//  of re-creating it (schema creation is not idempotent and errors on duplicates).
//

import Foundation

struct SchemaSummaryPage: Decodable {
    let contents: [SchemaSummary]
}

struct SchemaSummary: Decodable {
    let guid: String
    let name: String
    let version: String?
    let author: String?
}
