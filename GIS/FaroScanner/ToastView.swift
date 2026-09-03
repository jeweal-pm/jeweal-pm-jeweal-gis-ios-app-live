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
                .foregroundColor(.green)

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

        .shadow(radius:10)

        .padding()

    }

}
