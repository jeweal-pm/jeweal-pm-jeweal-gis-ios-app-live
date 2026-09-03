//
//  QuestionSection.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct QuestionSection: View {

    let title: String

    var body: some View {

        VStack(alignment:.leading){

            Text(title)
                .font(.system(size:30,weight:.bold))

        }
        .frame(maxWidth:.infinity,alignment:.leading)

    }

}
