//
//  FaroHeader.swift
//  GIS
//
//  Created by Jeweal on 5/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI

struct FaroHeader: View {

    let onClose: () -> Void
    @State private var hasAppeared = false

    var body: some View {

        HStack {

            Button(action: onClose) {
                Image("faro_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : -12)
                    .frame(width: 64, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onClose) {

                Image(systemName:"chevron.down")
                    .font(.system(size:20,weight:.light))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())

            }
            .buttonStyle(.plain)

        }
        .padding(.horizontal,18)
        .padding(.top,10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.28).delay(0.10)) {
                hasAppeared = true
            }
        }

    }

}
