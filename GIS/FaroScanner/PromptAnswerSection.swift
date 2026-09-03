//
//  PromptAnswerSection.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct PromptAnswerSection: View {

    let selectedPrompt: String?

    let selectedAnswers: [String]

    let onAnswerSelected: (String) -> Void

    private func answers(for question: String) -> [String] {

        switch question {

        case "Who is it for?":
            return [
                "Myself",
                "Wife",
                "Husband",
                "Fiancée",
                "Fiancé",
                "Girlfriend",
                "Boyfriend",
                "Mother",
                "Father",
                "Daughter",
                "Son",
                "Friend",
                "Client",
                "Bride",
                "Groom"
            ]

        case "Occasion":
            return [
                "Anniversary",
                "Engagement",
                "Wedding",
                "Birthday",
                "Graduation",
                "Mother's Day",
                "Valentine's",
                "Christmas",
                "Push Present",
                "Everyday",
                "Gift",
                "Celebration",
            ]

        case "Jewelry Type":
            return [
                "Ring",
                "Necklace",
                "Pendant",
                "Earrings",
                "Bracelet",
                "Bangle",
                "Brooch",
                "Set"
            ]

        case "Metal":
            return [
                "White Gold",
                "Yellow Gold",
                "Rose Gold",
                "Platinum",
                "Silver",
                "Two-Tone",
                "18K",
                "14K"
            ]

        case "Gemstone":
            return [
                "Diamond",
                "Sapphire",
                "Emerald",
                "Ruby",
                "Pearl",
                "Opal",
                "Morganite",
                "Aquamarine",
                "Tanzanite",
                "Topaz",
                "No Gemstone"
            ]

        case "Style":
            return [
                "Classic",
                "Timeless",
                "Minimal",
                "Modern",
                "Vintage",
                "Luxury",
                "Elegant",
                "Romantic",
                "Bold",
                "Statement",
                "Delicate",
                "Chic"
            ]

        case "Budget":
            return [
                "< $500",
                "$500–1K",
                "$1K–3K",
                "$3K–5K",
                "$5K+",
                "Flexible"
            ]

        case "Theme":
            return [
                "Floral",
                "Nature",
                "Celestial",
                "Heart",
                "Infinity",
                "Geometric",
                "Art Deco",
                "Vintage",
                "Ocean",
                "Butterfly",
                "Royal",
                "Contemporary"
            ]

        case "Color":
            return [
                "White",
                "Yellow",
                "Rose",
                "Blue",
                "Green",
                "Pink",
                "Red",
                "Black",
                "Champagne",
                "Rainbow"
            ]

        case "Size":
            return [
                "US 5",
                "US 6",
                "US 7",
                "US 8",
                "US 9",
//                "Unknown",
                "Small",
                "Medium",
                "Large",
                "Adjustable"
            ]

        case "Wear/Lifestyle":
            return [
                "Everyday",
                "Office",
                "Casual",
                "Formal",
                "Evening",
                "Wedding",
                "Party",
                "Travel"
            ]

        case "Avoid":
            return [
                "Yellow Gold",
                "Large Stones",
                "Bold Designs",
                "Trendy",
                "Heavy",
                "Color Gems",
                "Halo",
                "Vintage",
                "Oversized",
                "High Maintenance"
            ]

        default:
            return []

        }
    }

    var body: some View {

        if let selectedPrompt {

            VStack(alignment: .leading, spacing: 12) {

                Text(selectedPrompt)
                    .font(FaroFont.regular(20))
//                    .padding(.top, 8)

                FaroLowerAnswerChipSection(
                    answers: answers(for: selectedPrompt),
                    selectedAnswers: selectedAnswers,
                    onSelect: { answer in
                        withAnimation(.easeInOut(duration: 0.20)) {
                            onAnswerSelected(answer)
                        }
                    }
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            

        }

    }

}


// -------------------------------------------------------------
// MARK: - Lower Answer Chips (border-only selected state)
// -------------------------------------------------------------

private struct FaroLowerAnswerChipSection: View {

    let answers: [String]
    let selectedAnswers: [String]
    let onSelect: (String) -> Void

    private let teal = Color(
        red: 82 / 255,
        green: 203 / 255,
        blue: 196 / 255
    )

    var body: some View {
        WrappingHStack(
            answers,
            spacing: 10,
            lineSpacing: 10
        ) { answer in
                let isSelected = selectedAnswers.contains(answer)

                Button {
                    onSelect(answer)
                } label: {
                    Text(answer)
                        .font(FaroFont.regular(14))
                        // SELECTED = green text; NOT a filled green chip.
                        .foregroundColor(
                            isSelected ? teal : Color(white: 0.42)
                        )
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(minHeight: 34)
                        .padding(.horizontal, 12)
                        // Always white. This is the key difference from the
                        // old AnswerChipSection implementation.
                        .background(Color.white)
                        .clipShape(Capsule())
                        // SELECTED = green border only.
                        .overlay {
                            Capsule()
                                .stroke(
                                    isSelected ? teal : Color.clear,
                                    lineWidth: 1.2
                                )
                        }
                        .shadow(
                            color: .black.opacity(0.035),
                            radius: 4,
                            y: 2
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
