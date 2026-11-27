//
//  AppCoordinatorTests.swift
//  momens-iosTests
//

@testable import momens_ios
import SwiftUI
import UIKit
import XCTest

final class AppCoordinatorTests: XCTestCase {
    func testMoveToSignInUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToSignIn()

        XCTAssertEqual(coordinator.state, .signIn)
    }

    func testMoveToOnboardingUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToOnboarding()

        XCTAssertEqual(coordinator.state, .onboarding)
    }

    func testMoveToMainUpdatesAppState() {
        let coordinator = AppCoordinator()

        coordinator.moveToMain()

        XCTAssertEqual(coordinator.state, .main)
    }
}

// MARK: - Completion rule input regressions

final class TaskEditCompletionRuleInputTests: XCTestCase {
    private final class State {
        var text: String
        var focused = false

        init(_ text: String) { self.text = text }
    }

    private struct Fixture {
        let state: State
        let coordinator: TaskEditCompletionRuleInput.Coordinator
        let view: UITextView
    }

    private func makeInput(_ text: String) -> Fixture {
        let state = State(text)
        let input = TaskEditCompletionRuleInput(
            text: Binding(get: { state.text }, set: { state.text = $0 }),
            isFocused: Binding(get: { state.focused }, set: { state.focused = $0 })
        )
        let view = UITextView()
        view.text = text
        view.selectedRange = NSRange(location: text.utf16.count, length: 0)
        let coordinator = TaskEditCompletionRuleInput.Coordinator(parent: input)
        coordinator.accept(view)
        return Fixture(state: state, coordinator: coordinator, view: view)
    }

    func testInsertionAtLimitPreservesExistingTail() {
        let original = String(repeating: "가", count: 49) + "끝"
        let fixture = makeInput(original)
        let state = fixture.state
        let coordinator = fixture.coordinator
        let view = fixture.view
        let allowed = coordinator.textView(view, shouldChangeTextIn: NSRange(location: 0, length: 0),
                                           replacementText: "새")
        XCTAssertFalse(allowed)
        XCTAssertEqual(state.text, original)
        XCTAssertEqual(view.text, original)
    }

    func testReplacingSelectionAtLimitIsAllowed() {
        let fixture = makeInput(String(repeating: "가", count: 50))
        let coordinator = fixture.coordinator
        let view = fixture.view
        XCTAssertTrue(coordinator.textView(view, shouldChangeTextIn: NSRange(location: 5, length: 1),
                                          replacementText: "나"))
    }

    func testSpacesAndLongPasteCountTowardLimit() {
        let fixture = makeInput(String(repeating: " ", count: 49))
        let coordinator = fixture.coordinator
        let view = fixture.view
        let range = NSRange(location: 49, length: 0)
        XCTAssertTrue(coordinator.textView(view, shouldChangeTextIn: range, replacementText: "가"))
        XCTAssertFalse(coordinator.textView(view, shouldChangeTextIn: range, replacementText: "가나"))
    }

    func testEmojiCountsAsOneCharacter() {
        let fixture = makeInput(String(repeating: "가", count: 49))
        let coordinator = fixture.coordinator
        let view = fixture.view
        XCTAssertTrue(coordinator.textView(view, shouldChangeTextIn: NSRange(location: 49, length: 0),
                                          replacementText: "👨‍👩‍👧‍👦"))
    }

    func testMarkedKoreanTextIsNotPublishedUntilCommitted() {
        let initial = String(repeating: "가", count: 49)
        let fixture = makeInput(initial)
        let state = fixture.state
        let coordinator = fixture.coordinator
        let view = fixture.view
        view.setMarkedText("ㅎ", selectedRange: NSRange(location: 1, length: 0))
        XCTAssertNotNil(view.markedTextRange)
        coordinator.textViewDidChange(view)
        XCTAssertEqual(state.text, initial)
        view.setMarkedText("한", selectedRange: NSRange(location: 1, length: 0))
        view.unmarkText()
        coordinator.textViewDidChange(view)
        XCTAssertEqual(state.text, initial + "한")
    }

    func testOverLimitCompositionRestoresOriginalAndSelection() {
        let initial = String(repeating: "가", count: 50)
        let fixture = makeInput(initial)
        let state = fixture.state
        let coordinator = fixture.coordinator
        let view = fixture.view
        view.selectedRange = NSRange(location: 0, length: 0)
        coordinator.textViewDidChangeSelection(view)
        view.setMarkedText("한", selectedRange: NSRange(location: 1, length: 0))
        coordinator.textViewDidChange(view)
        XCTAssertNotNil(view.markedTextRange)
        XCTAssertEqual(state.text, initial)
        view.unmarkText()
        coordinator.textViewDidChange(view)
        XCTAssertEqual(view.text, initial)
        XCTAssertEqual(state.text, initial)
        XCTAssertEqual(view.selectedRange, NSRange(location: 0, length: 0))
    }
}
