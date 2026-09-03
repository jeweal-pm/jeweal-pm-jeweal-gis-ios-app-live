//
//  SelectedPromptChip.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct SelectedPromptChip: View {

    let title: String
    let onRemove: () -> Void

    var body: some View {

        HStack(spacing: 6) {

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black)

            Button {

                onRemove()

            } label: {

                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)

            }

        }
        .padding(.horizontal,10)
        .padding(.vertical,6)
//        .background(
//            Capsule()
//                .fill(Color("themeColor"))
//        )
        .background(
            Capsule()
                .fill(Color.white)
                .overlay(

                    Capsule()
                        .stroke(
                            Color.gray.opacity(0.15),
                            lineWidth:1
                        )

                )
                .foregroundColor(.black)
        )

    }

}
