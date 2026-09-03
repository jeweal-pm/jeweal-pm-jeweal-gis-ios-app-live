import SwiftUI

struct PromptChip: View {

    enum State {
        case normal
        case active
        case completed
    }

    let title: String
    let state: State
    var action: (() -> Void)? = nil

    private let teal = Color(
        red: 82 / 255,
        green: 203 / 255,
        blue: 196 / 255
    )

    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .lineLimit(1)
                .fixedSize()
                .font(FaroFont.semibold(14))
                .foregroundColor(
                    state == .active
                    ? .white
                    : .gray
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            state == .active
                            ? teal
                            : Color.white
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            state == .active
                            ? teal
                            : Color.gray.opacity(0.25),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 3,
                    y: 1
                )
        }
        .buttonStyle(.plain)
    }
}
