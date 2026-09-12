//
//  ToastView.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct ToastView: View {

    var body: some View {

        HStack {

            Image(systemName:"checkmark.circle.fill")
                .foregroundColor(Color(red: 82/255, green: 203/255, blue: 196/255))

            Text("Item added to order.")

            Spacer()

        }
        .padding()

        .background(.white)

        .clipShape(
            RoundedRectangle(
                cornerRadius:14
            )
        )

        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)

        .padding()

    }

}
