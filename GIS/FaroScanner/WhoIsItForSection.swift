//
//  WhoIsItForSection.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct WhoIsItForSection: View {

    let onSelect: (String) -> Void
    
    @State private var selectedPerson: String?

    private let people = [

        "Myself",
        "Wife",
        "Husband",
        "Fiancée",
        "Fiancé",
        "Girlfriend",
        "Boyfriend",
        "Mother",
        "Father",
        "Daughter",
        "Son",
        "Friend",
        "Client",
        "Bride",
        "Groom"

    ]

    var body: some View {

        VStack(alignment: .leading, spacing: 18) {

            Text("Who is it for?")
                .font(.system(size: 28, weight: .bold))

            WrappingHStack(people, spacing: 12) { person in

                PersonChip(

                    title: person,

                    selected: selectedPerson == person

                ) {

                    withAnimation(.spring()) {

                        selectedPerson = person

                    }

                }

            }

        }
        .transition(
            .move(edge: .top)
            .combined(with: .opacity)
        )

    }

}
