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

    var body: some View {

        HStack {

            Image("faro_logo")
                .resizable()
                .scaledToFit()
                .frame(width:72)

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

    }

}
