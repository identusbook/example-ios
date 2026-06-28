//
//  SecurityFlowUITests.swift
//  FlightTixUITests
//
//  UI tests for the Airport Security present-proof flow.
//
//  REQUIREMENTS: these tests drive a real agent, so the local Identus backend
//  (identus-docker) must be running and reachable, exactly as for running the app
//  by hand (see the repo README). They launch with `-skipLoginGate` so the
//  registration modal doesn't block navigation.
//
//  - testSecurityScreenWiring: fast smoke test. Confirms the screen renders and the
//    "Request Proof of Ticket" button is wired. Does NOT require issued credentials.
//  - testHappyPathRequestProofAndAccept: slow end-to-end. Issues a passport and a
//    ticket via Dev Utils, requests proof, asserts both verify, and accepts. Expect
//    this to take a couple of minutes due to real DIDComm credential exchanges.
//

import XCTest

final class SecurityFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    @discardableResult
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-skipLoginGate")
        app.launch()
        return app
    }

    /// Wait for the app to finish bootstrapping and present the tab bar.
    ///
    /// NOTE: on a *cold* wallet the app publishes a new issuer DID during startup, which
    /// can take several minutes; the XCUITest runner uses a fresh simulator clone, so this
    /// timeout must be generous. For fast, reliable runs, bootstrap the app once on the
    /// target simulator first (so the issuer DID is cached) before running the suite.
    private func waitForTabs(_ app: XCUIApplication, timeout: TimeInterval = 360) {
        let securityTab = app.tabBars.buttons["Airport Security"]
        XCTAssertTrue(
            securityTab.waitForExistence(timeout: timeout),
            "Tab bar never appeared within \(Int(timeout))s — is identus-docker running, and did "
            + "the app finish bootstrapping (issuer DID publication can be slow on a cold wallet)?"
        )
    }

    // MARK: - Fast wiring/reachability smoke test (no credentials required)

    /// Verifies the app boots, the Airport Security tab is reachable, the screen renders
    /// its controls, and the "Request Proof of Ticket" button is enabled and accepts a tap
    /// without crashing. It deliberately does NOT assert a specific proof outcome — that
    /// depends on issued credentials and is covered by the happy-path test.
    @MainActor
    func testSecurityScreenWiring() throws {
        let app = launchApp()
        waitForTabs(app)

        app.tabBars.buttons["Airport Security"].tap()

        // Key controls render.
        XCTAssertTrue(app.staticTexts["security.header"].waitForExistence(timeout: 10),
                      "Security header missing")
        let requestButton = app.buttons["security.requestProofButton"]
        XCTAssertTrue(requestButton.waitForExistence(timeout: 10), "Request Proof button missing")
        XCTAssertTrue(requestButton.isEnabled, "Request Proof button should be enabled")

        // The history area renders (either the empty state or a populated list).
        let emptyState = app.staticTexts["security.emptyState"]
        let list = app.descendants(matching: .any)["security.presentationsList"]
        XCTAssertTrue(emptyState.exists || list.exists,
                      "Neither the empty state nor the presentations list rendered")

        // Tapping triggers the flow without crashing; the app stays responsive.
        requestButton.tap()
        XCTAssertTrue(app.staticTexts["security.header"].waitForExistence(timeout: 10),
                      "App became unresponsive after tapping Request Proof")
    }

    // MARK: - Slow happy-path end-to-end test

    @MainActor
    func testHappyPathRequestProofAndAccept() throws {
        let app = launchApp()
        waitForTabs(app)

        // 1. Issue a passport and a ticket via Dev Utils. Each starts a real credential
        //    exchange (~30s internal wait) with no completion UI, so wait generously.
        app.tabBars.buttons["Dev Utils"].tap()

        let issuePassport = app.buttons["devutils.issuePassportButton"]
        XCTAssertTrue(issuePassport.waitForExistence(timeout: 10), "Issue Passport button missing")
        issuePassport.tap()
        sleep(50)

        let issueTicket = app.buttons["devutils.issueTicketButton"]
        XCTAssertTrue(issueTicket.waitForExistence(timeout: 10), "Issue Ticket button missing")
        issueTicket.tap()
        sleep(50)

        // 2. Request proof of the ticket (the app also requests the passport).
        app.tabBars.buttons["Airport Security"].tap()
        let requestButton = app.buttons["security.requestProofButton"]
        XCTAssertTrue(requestButton.waitForExistence(timeout: 10), "Request Proof button missing")
        requestButton.tap()

        // 3. Wait for the review sheet (two presentations are exchanged + verified).
        let denyButton = app.buttons["proofReview.denyButton"]
        XCTAssertTrue(denyButton.waitForExistence(timeout: 120),
                      "Proof review sheet never appeared")

        // 4. Both credentials should verify as Valid.
        let ticketStatus = app.staticTexts["proofReview.ticketStatus"]
        let passportStatus = app.staticTexts["proofReview.passportStatus"]
        XCTAssertTrue(ticketStatus.waitForExistence(timeout: 5))
        XCTAssertEqual(ticketStatus.label, "Valid", "Ticket should verify as Valid")
        XCTAssertEqual(passportStatus.label, "Valid", "Passport should verify as Valid")

        // 5. Accept and confirm the sheet dismisses and history populates.
        let acceptButton = app.buttons["proofReview.acceptButton"]
        XCTAssertTrue(acceptButton.isEnabled, "Accept should be enabled for a fully-valid proof")
        acceptButton.tap()

        XCTAssertTrue(denyButton.waitForNonExistence(timeout: 30),
                      "Review sheet should dismiss after Accept")
        XCTAssertTrue(app.staticTexts["Previous Presentations"].waitForExistence(timeout: 30),
                      "Presentation history should list at least one record after accepting")
    }
}
