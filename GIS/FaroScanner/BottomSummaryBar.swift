//
//  BottomSummaryBar.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI

struct BottomSummaryBar: View {

    let itemCount: Int

    let total: Double

    var onContinue: () -> Void

    var body: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("\(itemCount) Items Selected")
                    .font(.system(size: 15))

                Text(
                    total,
                    format: .currency(code: "THB")
                )
                .font(
                    .system(
                        size: 22,
                        weight: .bold
                    )
                )

            }

            Spacer()

            Button {

                onContinue()

            } label: {

                Text("Continue")
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .clipShape(Capsule())

            }

        }
        .padding()

        .background(.ultraThinMaterial)

        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )

        .padding()

    }

}
