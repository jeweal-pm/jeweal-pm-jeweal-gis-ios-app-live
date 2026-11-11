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

    /// The prompts in the order they were pressed (same rules as Android FaroPromptState). A prompt pressed but not yet
    /// answered keeps its starter sentence in the field with no answers.
    @State
    private var segments: [DiscoveryAnswer] = []

    /// Prompts that have at least one answer (shown as completed chips).
    private var selectedAnswers: [DiscoveryAnswer] {
        segments.filter { !$0.answers.isEmpty }
    }

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

            ScrollView(showsIndicators: false) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Spacer()
                        .frame(height: 16)

                                PromptChipSection(
                                    prompts: prompts,
                                    completed: selectedAnswers.map(\.questionId),
                                    answers: selectedAnswers,
                                    selected: $selectedPrompt,
                                    onSelect: { prompt, isSelected in
                                        if isSelected {
                                            pressPrompt(prompt)
                                        } else {
                                            closePrompt()
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

                }
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
                // The user edited the field: keep only the prompts whose words are still there
                // (editing an answer's word unselects that answer; editing a starter sentence unselects the prompt).
                guard !isApplyingPromptText else { return }
                onUserEdited(value)
            }

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
        // A child chip toggles its answer in the pressed prompt's sentence; the prompt stays open for more answers.
        if let index = segments.firstIndex(where: { $0.questionId == question }) {
            if let answerIndex = segments[index].answers.firstIndex(of: answer) {
                segments[index].answers.remove(at: answerIndex)
            } else {
                segments[index].answers.append(answer)
            }
        } else {
            segments.append(DiscoveryAnswer(questionId: question, answers: [answer]))
        }
        refreshSearchText()
    }

    /// A mother chip: its starter sentence goes into the field. A prompt still waiting for an answer is replaced.
    private func pressPrompt(_ prompt: String) {
        segments.removeAll { $0.answers.isEmpty }
        if !segments.contains(where: { $0.questionId == prompt }) {
            segments.append(DiscoveryAnswer(questionId: prompt, answers: []))
        }
        refreshSearchText()
    }

    /// Tapping the shown prompt again hides its answers; an unanswered prompt leaves the field.
    private func closePrompt() {
        segments.removeAll { $0.answers.isEmpty }
        refreshSearchText()
    }

    private func onUserEdited(_ value: String) {
        let lower = value.lowercased()
        segments = segments.compactMap { segment in
            if lower.contains(Self.sentence(segment).lowercased()) { return segment }
            guard lower.contains(Self.head(segment.questionId).lowercased()) else { return nil }
            var kept = segment
            kept.answers = segment.answers.filter { lower.contains(Self.word($0).lowercased()) }
            return kept
        }
        if let active = selectedPrompt, !segments.contains(where: { $0.questionId == active }) {
            selectedPrompt = nil
        }
        // Whatever is no longer a prompt sentence is the user's own keyword.
        let sentences = buildSearchText()
        if !sentences.isEmpty && value.contains(sentences) {
            baseKeyword = value.replacingOccurrences(of: sentences, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        } else if segments.isEmpty {
            baseKeyword = value
        }
        faroMode = value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .search : .discover
    }

    private func removeAnswer(
        question: String
    ) {

        segments.removeAll {

            $0.questionId == question

        }

        refreshSearchText()

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            onSearch(query)
        }

    }
    
    func removeLastAnswer() {

        if let last = segments.last {

            removeAnswer(question: last.questionId)

        } else {

            onClose()

        }

    }
    
    
    //-----------------------------------------
    // MARK: - Build Search Prompt
    //-----------------------------------------

    private func buildSearchText() -> String {
        segments.map { Self.sentence($0) }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    //-----------------------------------------
    // MARK: - Sentence rules (Figma handoff, same as Android FaroPromptState and the website)
    //-----------------------------------------

    /// Starter sentence of each prompt; "..." marks where the answers go.
    private static let placeholders: [String: String] = [
        "Who is it for?": "I'm shopping for",
        "Occasion": "This jewelry is for",
        "Jewelry Type": "I'm looking for a",
        "Metal": "I'd like it to be made of",
        "Gemstone": "I'd like it to be made of",
        "Style": "I prefer a... style.",
        "Budget": "My budget is",
        "Theme": "I'm looking for a design inspired by",
        "Color": "I'm looking for... tones.",
        "Size": "The size is",
        "Wear/Lifestyle": "It will mostly be worn",
        "Avoid": "I'd like to avoid"
    ]

    private static func placeholder(_ prompt: String) -> String { placeholders[prompt] ?? prompt }

    private static func head(_ prompt: String) -> String {
        placeholder(prompt).components(separatedBy: "...").first ?? placeholder(prompt)
    }

    /// Answers read as part of the sentence: lower case, except sizes, carats and prices (US 5, 18K, $500–1K).
    private static func word(_ answer: String) -> String {
        answer.contains(where: { $0.isNumber || $0 == "$" }) ? answer : answer.lowercased()
    }

    /// Two answers are joined with "and", three or more as "A, B and C".
    private static func join(_ words: [String]) -> String {
        switch words.count {
        case 0: return ""
        case 1: return words[0]
        default: return words.dropLast().joined(separator: ", ") + " and " + words[words.count - 1]
        }
    }

    private static func sentence(_ segment: DiscoveryAnswer) -> String {
        let p = placeholder(segment.questionId)
        let joined = join(segment.answers.map(word))
        let body: String
        if joined.isEmpty { body = p }
        else if p.contains("...") { body = p.replacingOccurrences(of: "...", with: " \(joined)") }
        else { body = "\(p) \(joined)" }
        // Sentences follow each other: "I'm shopping for myself. I prefer a modern and elegant style."
        return (body.hasSuffix(".") || joined.isEmpty) ? body : body + "."
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

        segments.removeAll()

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
            // The field shows what the user typed before choosing prompts, followed by the prompt sentences.
            searchText = "\(keyword) \(discovery)"
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

        segments.removeAll()

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
