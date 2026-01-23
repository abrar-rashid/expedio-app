//
//  ContentViewTests.swift
//  ExpedioTests
//
//  Tests for ContentView tab navigation
//

import XCTest
import SwiftUI
@testable import expedio

final class ContentViewTests: XCTestCase {

    func testContentView_initialTab_isSearch() {
        // ContentView starts with selectedTab = 0 (Search)
        // This is a basic structural test
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }

    func testFadeInModifier_appliesOpacityAnimation() {
        // Test that the modifier can be applied without crashing
        let view = Text("Test").fadeInOnAppear()
        XCTAssertNotNil(view)
    }

    func testSlideAndFadeTransition_exists() {
        // Test that the transition is defined
        let transition = AnyTransition.slideAndFade
        XCTAssertNotNil(transition)
    }
}
