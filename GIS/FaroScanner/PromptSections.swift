//
//  PromptSections.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct OccasionSection: View {

    @Binding var selected: String?

    var body: some View {

        PromptChipSection(
            prompts: [
                "Engagement",
                "Wedding",
                "Anniversary",
                "Birthday",
                "Graduation",
                "Everyday"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct JewelryTypeSection: View {

    @Binding var selected: String?

    var body: some View {

        PromptChipSection(
            prompts: [
                "Ring",
                "Necklace",
                "Bracelet",
                "Pendant",
                "Earrings"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct MetalSection: View {

    @Binding var selected: String?

    var body: some View {

        PromptChipSection(
            prompts: [
                "White Gold",
                "Yellow Gold",
                "Rose Gold",
                "Platinum"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct GemstoneSection: View {
    @Binding var selected: String?
    var body: some View {

        PromptChipSection(
            prompts: [
                "Diamond",
                "Ruby",
                "Sapphire",
                "Emerald"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct StyleSection: View {
    @Binding var selected: String?
    var body: some View {

        PromptChipSection(
            prompts: [
                "Classic",
                "Modern",
                "Minimal",
                "Vintage"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct BudgetSection: View {
    @Binding var selected: String?
    var body: some View {

        PromptChipSection(
            prompts: [
                "< $1K",
                "$1K–3K",
                "$3K–5K",
                "$5K+"
            ],
            answers: [],
            selected: $selected
        )

    }

}

struct ThemeSection: View {
    let onSelect: (String) -> Void
    var body: some View {

        EmptyView()

    }

}

struct ColorSection: View {
    let onSelect: (String) -> Void
    var body: some View {

        EmptyView()

    }

}

struct SizeSection: View {
    let onSelect: (String) -> Void
    var body: some View {

        EmptyView()

    }

}

struct EverydaySection: View {
    let onSelect: (String) -> Void
    var body: some View {

        EmptyView()

    }

}

struct AvoidSection: View {
    let onSelect: (String) -> Void
    var body: some View {

        EmptyView()

    }

}
