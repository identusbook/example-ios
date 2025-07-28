//
//  ModalManager.swift
//  FlightTix
//
//  Created by Jon Bauer on 7/28/25.
//

import SwiftUI

class ModalManager: ObservableObject {
    @Published var activeModal: ActiveModal? = nil

    func show(_ modal: ActiveModal) {
        activeModal = modal
    }

    func dismiss() {
        activeModal = nil
    }
}
