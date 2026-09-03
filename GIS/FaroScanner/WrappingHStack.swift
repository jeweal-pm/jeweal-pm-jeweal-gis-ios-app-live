//
//  WrappingHStack.swift
//  GIS
//

import SwiftUI

//==================================================
// MARK: - WrappingHStack
//==================================================

struct WrappingHStack<Data, Content>: View
where
Data: RandomAccessCollection,
Data.Element: Hashable,
Content: View {

    //------------------------------------------------
    // MARK: Properties
    //------------------------------------------------

    let data: Data
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content

    //------------------------------------------------
    // MARK: Init
    //------------------------------------------------

    init(
        _ data: Data,
        spacing: CGFloat = 10,
        lineSpacing: CGFloat = 10,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {

        self.data = data
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content

    }

    //------------------------------------------------
    // MARK: Body
    //------------------------------------------------

    var body: some View {

        FlowLayout(
            spacing: spacing,
            lineSpacing: lineSpacing
        ) {

            ForEach(
                Array(data),
                id: \.self
            ) { item in

                content(item)

            }

        }

    }

    //==================================================
    // MARK: - FlowLayout
    //==================================================

    @available(iOS 16.0, *)
    struct FlowLayout: Layout {

        var spacing: CGFloat = 10
        var lineSpacing: CGFloat = 10

        func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) -> CGSize {

            let width = proposal.width ?? 0

            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {

                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > width {

                    currentX = 0
                    currentY += rowHeight + lineSpacing
                    rowHeight = 0

                }

                rowHeight = max(rowHeight, size.height)
                currentX += size.width + spacing

            }

            return CGSize(
                width: width,
                height: currentY + rowHeight
            )

        }

        func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) {

            var currentX = bounds.minX
            var currentY = bounds.minY
            var rowHeight: CGFloat = 0
            
            for subview in subviews {

                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > bounds.maxX {

                    currentX = bounds.minX
                    currentY += rowHeight + lineSpacing
                    rowHeight = 0

                }

                subview.place(
                    at: CGPoint(
                        x: currentX,
                        y: currentY
                    ),
                    proposal: ProposedViewSize(size)
                )

                currentX += size.width + spacing
                rowHeight = max(rowHeight, size.height)

            }

        }

    }
    
}

