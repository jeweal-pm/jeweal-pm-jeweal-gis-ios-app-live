//
//  PromptChipSection.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct PromptChipSection: View {

    let prompts: [String]
    let completed: [String]
    let answers: [DiscoveryAnswer]
    @Binding var selected: String?

    init(
        prompts: [String],
        completed: [String] = [],
        answers: [DiscoveryAnswer] = [],
        selected: Binding<String?>
    ) {
        self.prompts = prompts
        self.completed = completed
        self.answers = answers
        self._selected = selected
    }

    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 10)
    ]

    var body: some View {
        WrappingHStack(
            orderedPrompts,
            spacing: 12,
            lineSpacing: 12
        ) { item in

            PromptChip(
                title: item,
                state: {
                    if selected == item {
                        return .active
                    }

                    if completed.contains(item) {
                        return .completed
                    }

                    return .normal
                }()
            ) {
                withAnimation(
                    .interactiveSpring(
                        response: 0.35,
                        dampingFraction: 0.88
                    )
                ) {
                    selected = item
                }
            }
        }
    }

    private var orderedPrompts: [String] {
        prompts
    }
}
