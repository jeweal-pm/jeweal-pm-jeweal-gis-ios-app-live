//
//  PersonChip.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct PersonChip: View {

    let title: String

    let selected: Bool

    let action: () -> Void

    var body: some View {

        Button {

            action()

        } label: {

            Text(title)
                .font(.system(size:14,weight:.medium))
                .foregroundColor(

                    selected
                    ? .white
                    : Color(.darkGray)

                )
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(

                    Capsule()

                        .fill(

                            selected

                            ? Color(
                                red: 92/255,
                                green: 218/255,
                                blue: 205/255
                            )

                            : .white

                        )

                )
                .overlay(

                    Capsule()
                        .stroke(

                            Color.black.opacity(0.05),

                            lineWidth: selected ? 0 : 1

                        )

                )
                .shadow(
                    radius:3,
                    y:1
                )

        }
        .buttonStyle(.plain)

    }

}
