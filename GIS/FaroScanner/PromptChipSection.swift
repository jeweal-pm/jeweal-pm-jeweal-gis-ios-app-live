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
    let onSelect: ((String, Bool) -> Void)?

    init(
        prompts: [String],
        completed: [String] = [],
        answers: [DiscoveryAnswer] = [],
        selected: Binding<String?>,
        onSelect: ((String, Bool) -> Void)? = nil
    ) {
        self.prompts = prompts
        self.completed = completed
        self.answers = answers
        self._selected = selected
        self.onSelect = onSelect
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
                    let willSelect = selected != item
                    selected = willSelect ? item : nil
                    onSelect?(item, willSelect)
                }
            }
        }
    }

    private var orderedPrompts: [String] {
        prompts
    }
}
