//
//  AnswerChipSection.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct AnswerChipSection: View {

    let answers: [String]

    let selectedAnswers: [String]

    let onSelect: (String) -> Void

    var body: some View {

        WrappingHStack(
            answers,
            spacing: 12
        ) { item in

            Button {

                onSelect(item)

            } label: {

                Text(item)
                    .lineLimit(1)
                    .fixedSize()
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        selectedAnswers.contains(item)
                            ? .white
                            : .gray
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .shadow(
                        color: .black.opacity(0.04),
                        radius: 3,
                        y: 1
                    )
                    .background(

                        Capsule()
                            .fill(
                                selectedAnswers.contains(item)
                                    ? selectionColor
                                    : .white
                            )

                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                Color.clear,
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: selectedAnswers
                    )

            }

            .buttonStyle(.plain)

        }
        .fixedSize(
                horizontal: false,
                vertical: true
            )

    }

    private let selectionColor = Color(
        red: 82/255,
        green: 203/255,
        blue: 196/255
    )

}
