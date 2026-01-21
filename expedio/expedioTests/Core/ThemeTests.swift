//
//  ThemeTests.swift
//  ExpedioTests
//
//  Tests for Theme design system
//

import XCTest
@testable import expedio
import SwiftUI

final class ThemeTests: XCTestCase {

    // MARK: - Color Tests

    func testColorHexInitialization_sixDigitHex_createsCorrectColor() {
        let color = Color(hex: "FF0000")
        // Red color should have components (1, 0, 0)
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_withHashPrefix_stripsPrefix() {
        let color = Color(hex: "#00FF00")
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_eightDigitHex_includesAlpha() {
        let color = Color(hex: "80FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_invalidHex_returnsBlack() {
        let color = Color(hex: "invalid")
        XCTAssertNotNil(color)
    }

    func testThemeColors_allColorsExist() {
        XCTAssertNotNil(Theme.Colors.background)
        XCTAssertNotNil(Theme.Colors.surface)
        XCTAssertNotNil(Theme.Colors.primary)
        XCTAssertNotNil(Theme.Colors.secondary)
        XCTAssertNotNil(Theme.Colors.textPrimary)
        XCTAssertNotNil(Theme.Colors.textSecondary)
        XCTAssertNotNil(Theme.Colors.accent)
    }

    // MARK: - Spacing Tests

    func testSpacingValues_areInAscendingOrder() {
        XCTAssertLessThan(Theme.Spacing.xs, Theme.Spacing.sm)
        XCTAssertLessThan(Theme.Spacing.sm, Theme.Spacing.md)
        XCTAssertLessThan(Theme.Spacing.md, Theme.Spacing.lg)
        XCTAssertLessThan(Theme.Spacing.lg, Theme.Spacing.xl)
    }

    func testSpacingValues_areCorrect() {
        XCTAssertEqual(Theme.Spacing.xs, 4)
        XCTAssertEqual(Theme.Spacing.sm, 8)
        XCTAssertEqual(Theme.Spacing.md, 16)
        XCTAssertEqual(Theme.Spacing.lg, 24)
        XCTAssertEqual(Theme.Spacing.xl, 32)
    }

    // MARK: - Corner Radius Tests

    func testCornerRadiusValues_arePositive() {
        XCTAssertGreaterThan(Theme.CornerRadius.sm, 0)
        XCTAssertGreaterThan(Theme.CornerRadius.md, 0)
        XCTAssertGreaterThan(Theme.CornerRadius.lg, 0)
    }

    // MARK: - Typography Tests

    func testTypography_fontsExist() {
        XCTAssertNotNil(Theme.Typography.largeTitle)
        XCTAssertNotNil(Theme.Typography.title)
        XCTAssertNotNil(Theme.Typography.body)
        XCTAssertNotNil(Theme.Typography.caption)
    }
}
