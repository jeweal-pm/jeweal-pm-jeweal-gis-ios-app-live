//
//  FloatingCartButton.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct FloatingCartButton: View {

    let count: Int

    var action: () -> Void

    var body: some View {

        Button(action: action) {

            ZStack {

                Circle()
                    .fill(.black)
                    .frame(width: 62, height: 62)

                Image(systemName: "bag")
                    .font(.system(size: 24))
                    .foregroundColor(.white)

            }
            .overlay(alignment: .topTrailing) {

                if count > 0 {

                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)

                }

            }

        }
        .shadow(
            color: .black.opacity(0.25),
            radius: 10,
            y: 4
        )

    }

}
