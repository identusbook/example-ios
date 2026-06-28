//
//  CredentialRecordStatus.swift
//  FlightTix
//
//  Minimal view of an issue-credential record used only to read its protocol
//  state while polling. Decodes just recordId + protocolState so it works for
//  any credential type (the full CredentialRecordResponse types `claims` to a
//  specific schema and would fail to decode for, e.g., a ticket record).
//

import Foundation

struct CredentialRecordStatus: Decodable {
    let recordId: String
    let protocolState: String
}
