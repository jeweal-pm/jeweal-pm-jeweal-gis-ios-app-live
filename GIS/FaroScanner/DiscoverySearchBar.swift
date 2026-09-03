//
//  DiscoverySearchBar.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI

struct DiscoverySearchBar: View {

    @Binding var searchText: String
    @Binding var selectedPrompt: String?
    
    let onDeleteLastPrompt: () -> Void
    let onClear: () -> Void
    let onSearch: (String) -> Void
    
    @FocusState.Binding
    var searchFocused: Bool

    init(
        searchText: Binding<String>,
        selectedPrompt: Binding<String?>,
        searchFocused: FocusState<Bool>.Binding,
        onDeleteLastPrompt: @escaping () -> Void,
        onClear: @escaping () -> Void,
        onSearch: @escaping (String) -> Void
    ) {

        self._searchText = searchText
        self._selectedPrompt = selectedPrompt
        self._searchFocused = searchFocused

        self.onDeleteLastPrompt = onDeleteLastPrompt
        self.onClear = onClear
        self.onSearch = onSearch
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            //----------------------------------
            // TOP ROW
            //----------------------------------

            HStack(spacing: 10) {

                TextField(
                    "Describe the jewelry you're looking for...",
                    text: $searchText
                )
                .focused($searchFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit {

                        NotificationCenter.default.post(
                            name: .faroSearch,
                            object: searchText
                        )

                    }
                .onChange(of: searchText) { newValue in

                    guard newValue.isEmpty else {
                        return
                    }

                    guard searchFocused else {
                        return
                    }

                    onDeleteLastPrompt()

                }
                
//                if !searchText.isEmpty {

                    Button {

                        if searchText.isEmpty {

                            onDeleteLastPrompt()

                        } else {

                            onClear()

                        }

                    } label: {

                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(
                                Color(
                                    red: 102/255,
                                    green: 102/255,
                                    blue: 102/255
                                )
                            )
                    }

//                }

            }

            //----------------------------------
            // BOTTOM ROW
            //----------------------------------

            HStack {

                Image(systemName: "mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)

                Spacer()

                Button {

                    let keyword = searchText
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                    guard !keyword.isEmpty else {
                        return
                    }
                    
                    print("GREEN BUTTON")
                    print(keyword)
                    
                    onSearch(keyword)

                } label: {

                    Circle()
                        .fill(Color(
                            red: 82/255,
                            green: 203/255,
                            blue: 196/255
                        ))
                        .frame(width: 38, height: 38)
                        .overlay {

                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))

                        }

                }

            }

        }
        .frame(height: 96)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {

            RoundedRectangle(cornerRadius: 16)
                .stroke(

                    LinearGradient(

                        colors: [
                            Color(
                                red: 91/255,
                                green: 127/255,
                                blue: 255/255
                            ),
                            Color(
                                red: 82/255,
                                green: 203/255,
                                blue: 196/255
                            )

                        ],

                        startPoint: .leading,
                        endPoint: .trailing

                    ),

                    lineWidth: 1

                )

        }
        .shadow(
            color: .black.opacity(0.05),
            radius: 4,
            y: 2
        )

    }

}
