//
//  DesignSystem.swift
//  FlightTix
//
//  A small, shared set of styles so every screen looks consistent. This is an
//  example app — the goal is a clean, professional baseline, not a design library.
//

import SwiftUI

// MARK: - Button styles

/// Full-width, filled primary action button. Dims automatically when disabled.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(
                (isEnabled ? tint : Color.gray).opacity(configuration.isPressed ? 0.8 : 1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .opacity(isEnabled ? 1 : 0.5)
    }
}

/// Full-width, outlined secondary action button (Close / Cancel / Deny).
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(tint)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(tint.opacity(0.5), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.7 : (isEnabled ? 1 : 0.5))
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static func primary(tint: Color) -> PrimaryButtonStyle { PrimaryButtonStyle(tint: tint) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondaryAction: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func secondaryAction(tint: Color) -> SecondaryButtonStyle { SecondaryButtonStyle(tint: tint) }
}

// MARK: - Async button

/// A button that runs an async action, showing a spinner and disabling itself
/// while the work is in flight. This is good practice for Identus apps: most
/// actions involve network / DIDComm round-trips, so the UI should reflect that
/// something is happening and prevent double-taps.
///
/// Apply a button style as usual, e.g. `AsyncButton("Submit") { ... }.buttonStyle(.primary)`.
/// The action is non-throwing on purpose — handle errors inside the closure so the
/// call site decides how to surface them.
struct AsyncButton<Label: View>: View {
    var spinnerTint: Color = .white
    var action: () async -> Void
    @ViewBuilder var label: () -> Label

    @State private var isRunning = false

    var body: some View {
        Button {
            guard !isRunning else { return }
            isRunning = true
            Task {
                await action()
                isRunning = false
            }
        } label: {
            ZStack {
                label().opacity(isRunning ? 0 : 1)
                if isRunning {
                    ProgressView().tint(spinnerTint)
                }
            }
        }
        .disabled(isRunning)
    }
}

extension AsyncButton where Label == Text {
    init(_ title: String, spinnerTint: Color = .white, action: @escaping () async -> Void) {
        self.init(spinnerTint: spinnerTint, action: action) { Text(title) }
    }
}

// MARK: - Detail card row

/// A label/value row for detail cards (e.g. ticket / passport details).
struct LabeledRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundColor(.secondary)
            Spacer(minLength: 16)
            Text(value).fontWeight(.medium).multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Screen header

/// Consistent large title (+ optional subtitle) used at the top of each screen.
struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.largeTitle.weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
