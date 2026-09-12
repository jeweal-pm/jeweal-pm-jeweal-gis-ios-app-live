//
//  DiscoveryView.swift
//  GIS
//
//  Created by Jeweal on 6/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI
import UIKit

struct DiscoveryView: View {

    
    
    //-----------------------------------------
    // MARK: - Binding
    //-----------------------------------------

    @Binding var searchText: String

    @Binding var selectedPrompt: String?

    @Binding var faroMode: FaroMode
    
    @State
    private var baseKeyword = ""
    @State
    private var isApplyingPromptText = false
    

    //-----------------------------------------
    // MARK: - State
    //-----------------------------------------

    @State
    private var selectedAnswers: [DiscoveryAnswer] = []

    //-----------------------------------------
    // MARK: - Prompt List
    //-----------------------------------------
    
    let onSearch: (String) -> Void
    let onClose: () -> Void

    private let prompts = [

        "Who is it for?",
        "Occasion",
        "Jewelry Type",
        "Metal",
        "Gemstone",
        "Style",
        "Budget",
        "Theme",
        "Color",
        "Size",
        "Wear/Lifestyle",
        "Avoid"

    ]

    // -----------------------------------------
    // MARK: - Keyboard
    // -----------------------------------------

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    //-----------------------------------------
    // MARK: - Body
    //-----------------------------------------

    var body: some View {
//        GeometryReader { geo in

            ScrollView(showsIndicators: false) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Spacer()
                        .frame(height: 16)

//                            if let currentPrompt = selectedPrompt {
//
//                                promptAnswerView(currentPrompt)
//
//                            } else {

                                PromptChipSection(
                                    prompts: prompts,
                                    completed: selectedAnswers.map(\.questionId),
                                    answers: selectedAnswers,
                                    selected: $selectedPrompt,
                                    onSelect: { prompt, isSelected in
                                        if isSelected {
                                            previewPrompt(prompt)
                                        } else {
                                            clearPromptPreview()
                                        }
                                    }
                                ).animation(
                                    .interactiveSpring(
                                        response: 0.45,
                                        dampingFraction: 0.82
                                    ),
                                    value: selectedPrompt
                                )
                            
                            if let currentPrompt = selectedPrompt {
                                Spacer().frame(height: 16)
                                promptAnswerView(currentPrompt)
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .top)
                                                .combined(with: .opacity),

                                            removal: .opacity
                                        )
                                    )

                            }
//                            }

//                        }

//                    }
                    
//                    if let currentPrompt = selectedPrompt {
//                        promptAnswerView(currentPrompt)
//                    } else {
//
//                        PromptChipSection(
//                            prompts: prompts,
//                            answers: selectedAnswers,
//                            selected: $selectedPrompt
//                        )
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    }


                }
//                .frame(
//                    minHeight: geo.size.height,
//                    alignment: .top
//                )
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 16)

            }
            // Hide the keyboard when the user taps anywhere in the
            // Discovery content and also when the ScrollView is dismissed.
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        hideKeyboard()
                    }
            )
            .onAppear {
                // Discovery can be opened by typing in the persistent parent
                // search field, before this view is mounted.
                baseKeyword = searchText
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .faroSearch
                )
            ) { notification in

                guard let keyword = notification.object as? String else {
                    return
                }

                searchText = keyword

                if !keyword.isEmpty {

                    faroMode = .discover

                }

            }
            .onChange(of: searchText) { value in
                // A direct edit is a new free-text search.  Do not leave a
                // parent/child chip looking selected after its generated text
                // has been changed by the user.
                guard !isApplyingPromptText else { return }
                baseKeyword = value
                selectedPrompt = nil
                selectedAnswers.removeAll()

            }

//        }

    }

    //-----------------------------------------
    // MARK: - Prompt Answer
    //-----------------------------------------

    @ViewBuilder
    private func promptAnswerView(
        _ currentPrompt: String
    ) -> some View {

        if currentPrompt == "Who is it for?" {
            FaroWhoIsItForAnswerChips(
                selectedAnswers: answers(for: currentPrompt) ?? []
            ) { answer in
                saveAnswer(
                    question: currentPrompt,
                    answer: answer
                )
            }
            .padding(.top, -2)
        } else if currentPrompt == "Occasion" {
            FaroBorderAnswerChips(
                title: currentPrompt,
                options: [
                    "Anniversary", "Engagement", "Wedding",
                    "Birthday", "Graduation", "Mother's Day",
                    "Valentine's", "Christmas", "Push Present",
                    "Everyday", "Gift", "Celebration"
                ],
                selectedAnswers: answers(for: currentPrompt) ?? []
            ) { answer in
                saveAnswer(
                    question: currentPrompt,
                    answer: answer
                )
            }
            .padding(.top, -2)
        } else if currentPrompt == "Jewelry Type" {
            FaroBorderAnswerChips(
                title: currentPrompt,
                options: [
                    "Ring", "Necklace", "Pendant", "Earrings",
                    "Bracelet", "Bangle", "Brooch", "Set"
                ],
                selectedAnswers: answers(for: currentPrompt) ?? []
            ) { answer in
                saveAnswer(
                    question: currentPrompt,
                    answer: answer
                )
            }
            .padding(.top, -2)
        } else {
            PromptAnswerSection(
                selectedPrompt: currentPrompt,
                selectedAnswers: answers(for: currentPrompt) ?? []
            ) { answer in
                saveAnswer(
                    question: currentPrompt,
                    answer: answer
                )
            }
            .padding(.top, -2)
        }
//        .transition(
//            .asymmetric(
//                insertion: .move(edge: .top)
//                    .combined(with: .opacity),
//
//                removal: .opacity
//            )
//        )

    }
    
    //-----------------------------------------
    // MARK: - Save Answer
    //-----------------------------------------

    private func saveAnswer(
        question: String,
        answer: String
    ) {

        //---------------------------------
        // Toggle Answer
        //---------------------------------

        if let index = selectedAnswers.firstIndex(where: {
            $0.questionId == question
        }) {

            // เลือกอันเดิม = ยกเลิก, เลือกอันใหม่ = เพิ่ม
            if let answerIndex = selectedAnswers[index].answers.firstIndex(of: answer) {
                selectedAnswers[index].answers.remove(at: answerIndex)
            } else {
                selectedAnswers[index].answers.append(answer)
            }

            // หากยกเลิกคำตอบสุดท้าย ให้ลบคำถามนี้ออกด้วย
            if selectedAnswers[index].answers.isEmpty {
                selectedAnswers.remove(at: index)
            }

        } else {

            selectedAnswers.append(
                DiscoveryAnswer(
                    questionId: question,
                    answers: [answer]
                )
            )

        }

        //---------------------------------
        // Refresh Search
        //---------------------------------

        refreshSearchText()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
//            onSearch(query)
        }

        //---------------------------------
        // Keep Prompt Open
        //---------------------------------

        // Keep the question open so the user can choose more than one answer.

    }

    private func previewPrompt(_ prompt: String) {
        // Show the active question in the input before rendering its child
        // chips.  This gives the user immediate context and mirrors the Faro
        // discovery flow instead of leaving an apparently unchanged field.
        let preview: String
        switch prompt {
        case "Who is it for?": preview = "I'm shopping for"
        case "Occasion": preview = "I'm looking for jewelry for"
        case "Jewelry Type": preview = "I'm looking for a"
        default: preview = prompt
        }

        baseKeyword = ""
        isApplyingPromptText = true
        searchText = preview
        DispatchQueue.main.async {
            isApplyingPromptText = false
        }
    }

    private func clearPromptPreview() {
        guard selectedAnswers.isEmpty else {
            refreshSearchText()
            return
        }
        isApplyingPromptText = true
        searchText = baseKeyword
        DispatchQueue.main.async {
            isApplyingPromptText = false
        }
    }
    
    
    private func removeAnswer(
        question: String
    ) {

        selectedAnswers.removeAll {

            $0.questionId == question

        }

        refreshSearchText()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            onSearch(query)
        }

    }
    
    func removeLastAnswer() {

        if let last = selectedAnswers.last {

            removeAnswer(question: last.questionId)

        } else {

            onClose()

        }

    }
    
    
    //-----------------------------------------
    // MARK: - Build Search Prompt
    //-----------------------------------------

    private func buildSearchText() -> String {

        var parts: [String] = []

        //---------------------------------
        // Who is it for?
        //---------------------------------

        if let person = answers(for: "Who is it for?") {

            switch person {

            case ["Myself"]:
                parts.append("I'm shopping for myself")

            default:
                parts.append(
                    "I'm shopping for my \(person.map { $0.lowercased() }.joined(separator: " or "))"
                )

            }

        }

        //---------------------------------
        // Occasion
        //---------------------------------

        if let occasion = answers(for: "Occasion") {

            parts.append(
                "for \(occasion.map { $0.lowercased() }.joined(separator: " or "))"
            )

        }

        //---------------------------------
        // Jewelry Type
        //---------------------------------

        if let type = answers(for: "Jewelry Type") {

            parts.append(type.joined(separator: ", "))

        }

        //---------------------------------
        // Metal
        //---------------------------------

        if let metal = answers(for: "Metal") {

            parts.append(metal.joined(separator: ", "))

        }

        //---------------------------------
        // Gemstone
        //---------------------------------

        if let gem = answers(for: "Gemstone") {

            parts.append(gem.joined(separator: ", "))

        }

        //---------------------------------
        // Style
        //---------------------------------

        if let style = answers(for: "Style") {

            parts.append(style.joined(separator: ", "))

        }

        //---------------------------------
        // Budget
        //---------------------------------

        if let budget = answers(for: "Budget") {

            parts.append(
                "Budget \(budget.joined(separator: ", "))"
            )

        }

        //---------------------------------
        // Theme
        //---------------------------------

        if let theme = answers(for: "Theme") {

            parts.append(theme.joined(separator: ", "))

        }

        //---------------------------------
        // Color
        //---------------------------------

        if let color = answers(for: "Color") {

            parts.append(color.joined(separator: ", "))

        }

        //---------------------------------
        // Size
        //---------------------------------

        if let size = answers(for: "Size") {

            parts.append(
                "Size \(size.joined(separator: ", "))"
            )

        }

        //---------------------------------
        // Everyday
        //---------------------------------

        if let everyday = answers(for: "Wear/Lifestyle") {

            parts.append(everyday.joined(separator: ", "))

        }

        //---------------------------------
        // Avoid
        //---------------------------------

        if let avoid = answers(for: "Avoid") {

            parts.append(
                "Avoid \(avoid.joined(separator: ", "))"
            )

        }

        return parts.joined(separator: ", ")

    }
    
    //-----------------------------------------
    // MARK: - Helper
    //-----------------------------------------

    private func answers(
        for question: String
    ) -> [String]? {

        selectedAnswers.first {

            $0.questionId == question

        }?.answers

    }
    
    //-----------------------------------------
    // MARK: - Reset
    //-----------------------------------------

    private func resetDiscovery() {

        selectedPrompt = nil

        selectedAnswers.removeAll()

        searchText = ""

        faroMode = .search

    }
    
    private func refreshSearchText() {

        let discovery = buildSearchText()

        let keyword = baseKeyword
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        isApplyingPromptText = true
        if keyword.isEmpty {
            searchText = discovery
        } else if discovery.isEmpty {
            searchText = keyword
        } else {
            searchText = "\(keyword), \(discovery)"
        }
        DispatchQueue.main.async {
            isApplyingPromptText = false
        }

        faroMode =
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? .search
        : .discover
//        if selectedAnswers.isEmpty {
//
//            faroMode = .search
//
//        } else {
//
//            faroMode = .discover
//
//        }

    }
    
    private func clearDiscovery() {

        searchText = ""

        selectedPrompt = nil

        selectedAnswers.removeAll()

        faroMode = .search

    }
    
    private var isGeneralSearch: Bool {

        let keyword = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return !keyword.isEmpty && selectedAnswers.isEmpty

    }
}


private struct FaroWhoIsItForAnswerChips: View {
    let selectedAnswers: [String]
    let onSelect: (String) -> Void

    private let options = [
        "Myself", "Wife", "Husband", "Fiancée", "Fiancé",
        "Girlfriend", "Boyfriend", "Mother", "Father",
        "Daughter", "Son", "Friend", "Client", "Bride", "Groom"
    ]

    private let teal = Color(red: 82/255, green: 203/255, blue: 196/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Who is it for?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.56))

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 72), spacing: 10)
                ],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selectedAnswers.contains(option)

                    Button {
                        onSelect(option)
                    } label: {
                        Text(option)
                            .font(FaroFont.regular(14))
                            .foregroundColor(isSelected ? teal : Color(white: 0.42))
                            .frame(minWidth: 64, minHeight: 34)
                            .padding(.horizontal, 8)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected
                                            ? teal
                                            : Color.gray.opacity(0.16),
                                        lineWidth: isSelected ? 1.2 : 1
                                    )
                            )
                            .shadow(
                                color: .black.opacity(0.035),
                                radius: 4,
                                y: 2
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


private struct FaroBorderAnswerChips: View {
    let title: String
    let options: [String]
    let selectedAnswers: [String]
    let onSelect: (String) -> Void

    private let teal = Color(red: 82/255, green: 203/255, blue: 196/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 0.08))

            LazyVGrid(
                columns: title == "Occasion"
                    ? Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
                    : [GridItem(.adaptive(minimum: 82), spacing: 10)],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selectedAnswers.contains(option)

                    Button {
                        onSelect(option)
                    } label: {
                        Text(option)
                            .font(FaroFont.regular(14))
                            .foregroundColor(
                                isSelected ? teal : Color(white: 0.42)
                            )
                            .lineLimit(1)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 34
                            )
                            .padding(.horizontal, title == "Occasion" ? 4 : 8)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected
                                            ? teal
                                            : Color.gray.opacity(0.16),
                                        lineWidth: isSelected ? 1.2 : 1
                                    )
                            )
                            .shadow(
                                color: .black.opacity(0.035),
                                radius: 4,
                                y: 2
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
