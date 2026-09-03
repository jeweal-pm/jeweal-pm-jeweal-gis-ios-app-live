import SwiftUI

struct FaroProductCard: View {

    let product: NSMutableDictionary

    let quantity: Int

    var onImageTap: () -> Void

    var onTap: (NSDictionary, String, String, String) -> Void

    // MARK: - Card Size

//    private let collapsedCardHeight: CGFloat = 292

//    private let expandedCardHeight: CGFloat = 270

    private let collapsedCardHeight: CGFloat = 292

    private let expandedCardHeight: CGFloat = 318

    private let cardCornerRadius: CGFloat = 10

    // MARK: - State

    @State private var isExpanded = false

    @State private var selectedMetal = ""

    @State private var selectedStone = ""

    @State private var selectedSize = ""

    @State private var openDropdown: String? = nil

    @Binding private var parentScrollDisabled: Bool

    private let teal = Color(

        red: 82 / 255,

        green: 203 / 255,

        blue: 196 / 255

    )

    // MARK: - Init

    init(

        product: NSMutableDictionary,

        quantity: Int,

        onImageTap: @escaping () -> Void,

        parentScrollDisabled: Binding<Bool> = .constant(false),

        onTap: @escaping (NSDictionary, String, String, String) -> Void

    ) {

        self.product = product

        self.quantity = quantity

        self.onImageTap = onImageTap

        self.onTap = onTap

        self._parentScrollDisabled = parentScrollDisabled

    }

    // MARK: - Options

    private var metals: [NSDictionary] {

        if let list = product["metals"] as? [NSDictionary], !list.isEmpty {

            return list

        }

        if let metal = product["metal"] as? NSDictionary {

            return [metal]

        }

        return []

    }

    private var stones: [NSDictionary] {

        product["stones"] as? [NSDictionary] ?? []

    }

    private var sizes: [NSDictionary] {

        product["sizes"] as? [NSDictionary] ?? []

    }

    private func optionTitles(

        from array: [NSDictionary]

    ) -> [String] {

        array

            .compactMap {

                $0["label"] as? String

            }

            .filter {

                !$0.isEmpty

            }

    }

    // MARK: - Body

    var body: some View {

        ZStack(alignment: .topLeading) {

            if isExpanded {

                expandedContent

            } else {

                collapsedContent

            }

        }

        .frame(maxWidth: .infinity)

        .frame(

            height: isExpanded

                ? expandedCardHeight

                : collapsedCardHeight

        )

        .background(Color.white)

        .overlay(

            RoundedRectangle(

                cornerRadius: cardCornerRadius

            )

            .stroke(

                Color.gray.opacity(0.16),

                lineWidth: 1

            )

        )

        .contentShape(

            RoundedRectangle(

                cornerRadius: cardCornerRadius

            )

        )

        .zIndex(

            openDropdown == nil

                ? 0

                : 10_000

        )

        .onAppear {

            loadDefaultOption()

        }

        .onDisappear {

            parentScrollDisabled = false

        }

    }

    // MARK: - Normal Card

    private var collapsedContent: some View {

        VStack(

            alignment: .leading,

            spacing: 0

        ) {

            ZStack(alignment: .topLeading) {

                Button(

                    action: onImageTap

                ) {

                    productImage

                        .padding(10)

                        .frame(

                            maxWidth: .infinity,

                            maxHeight: .infinity

                        )

                }

                .buttonStyle(.plain)

                if quantity > 0 {

                    Text("\\(quantity)")

                        .font(

                            .system(

                                size: 12,

                                weight: .medium

                            )

                        )

                        .foregroundColor(.white)

                        .frame(

                            width: 24,

                            height: 24

                        )

                        .background(teal)

                        .clipShape(Circle())

                        .padding(8)

                }

            }

            .frame(maxWidth: .infinity)

            .frame(height: 158)

            Text(

                product["name"] as? String ?? ""

            )

            .font(

                .system(

                    size: 15,

                    weight: .regular

                )

            )

            .foregroundColor(.black)

            .lineLimit(2)

            .frame(

                maxWidth: .infinity,

                alignment: .leading

            )

            .fixedSize(

                horizontal: false,

                vertical: true

            )

            .padding(.horizontal, 10)

            .padding(.top, 7)

            Text(

                product["SKU"] as? String ?? ""

            )

            .font(.system(size: 12))

            .foregroundColor(.gray)

            .lineLimit(1)

            .padding(.horizontal, 10)

            .padding(.top, 2)

            Spacer(minLength: 0)

            HStack(

                alignment: .center,

                spacing: 6

            ) {

                Text(

                    product["price"] as? String ?? ""

                )

                .font(

                    .system(

                        size: 16,

                        weight: .semibold

                    )

                )

                .foregroundColor(.black)

                .lineLimit(1)

                .minimumScaleFactor(0.75)

                Spacer(minLength: 4)

                selectButton

            }

            .padding(.horizontal, 10)

            .padding(.bottom, 10)

        }

    }

    // MARK: - Expanded / Add Order Card

    private var expandedContent: some View {

        VStack(

            alignment: .leading,

            spacing: 0

        ) {

            // Product header

            HStack(

                alignment: .top,

                spacing: 8

            ) {

                Button(

                    action: onImageTap

                ) {

                    productImage

                        .frame(

                            width: 40,

                            height: 40

                        )

                }

                .buttonStyle(.plain)

                Text(

                    product["name"] as? String ?? ""

                )

                .font(

                    .system(

                        size: 13,

                        weight: .medium

                    )

                )

                .foregroundColor(.black)

                .lineLimit(2)

                .frame(

                    maxWidth: .infinity,

                    alignment: .leading

                )

                Button {

                    closeDropdowns()

                    isExpanded = false

                } label: {

                    Image(

                        systemName: "xmark"

                    )

                    .font(

                        .system(

                            size: 11,

                            weight: .medium

                        )

                    )

                    .foregroundColor(

                        .gray

                    )

                    .frame(

                        width: 22,

                        height: 22

                    )

                }

                .buttonStyle(.plain)

            }

            .padding(.horizontal, 10)

            .padding(.top, 9)

            // SKU

            Text(

                product["SKU"] as? String ?? ""

            )

            .font(.system(size: 11))

            .foregroundColor(.gray)

            .lineLimit(1)

            .padding(.horizontal, 10)

            .padding(.top, 2)

            // MARK: Dropdowns

            VStack(spacing: 7) {

                FaroProductDropdownRow(

                    title: "Metal",

                    options: optionTitles(

                        from: metals

                    ),

                    selection: $selectedMetal,

                    isOpen: Binding(

                        get: {

                            openDropdown == "Metal"

                        },

                        set: { value in

                            openDropdown =

                                value

                                ? "Metal"

                                : nil

                            parentScrollDisabled =

                                value

                        }

                    ),

                    parentScrollDisabled:

                        $parentScrollDisabled,

                    closeOtherDropdowns: {

                        openDropdown = "Metal"

                        parentScrollDisabled = true

                    }

                )

                FaroProductDropdownRow(

                    title: "Stone",

                    options: optionTitles(

                        from: stones

                    ),

                    selection: $selectedStone,

                    isOpen: Binding(

                        get: {

                            openDropdown == "Stone"

                        },

                        set: { value in

                            openDropdown =

                                value

                                ? "Stone"

                                : nil

                            parentScrollDisabled =

                                value

                        }

                    ),

                    parentScrollDisabled:

                        $parentScrollDisabled,

                    closeOtherDropdowns: {

                        openDropdown = "Stone"

                        parentScrollDisabled = true

                    }

                )

                FaroProductDropdownRow(

                    title: "Size",

                    options: optionTitles(

                        from: sizes

                    ),

                    selection: $selectedSize,

                    isOpen: Binding(

                        get: {

                            openDropdown == "Size"

                        },

                        set: { value in

                            openDropdown =

                                value

                                ? "Size"

                                : nil

                            parentScrollDisabled =

                                value

                        }

                    ),

                    parentScrollDisabled:

                        $parentScrollDisabled,

                    closeOtherDropdowns: {

                        openDropdown = "Size"

                        parentScrollDisabled = true

                    }

                )

            }

            .padding(.horizontal, 10)

            .padding(.top, 8)

            // IMPORTANT:

            // ไม่มี Spacer ตรงนี้แล้ว

            // Add Order จะชิด dropdown ตัวที่ 3

            Button {

                closeDropdowns()

                onTap(

                    product,

                    selectedMetal,

                    selectedStone,

                    selectedSize

                )

                isExpanded = false

            } label: {

                Text("Add Order")

                    .font(

                        .system(

                            size: 14,

                            weight: .medium

                        )

                    )

                    .foregroundColor(.white)

                    .frame(

                        maxWidth: .infinity

                    )

                    .frame(height: 40)

                    .background(teal)

                    .clipShape(

                        RoundedRectangle(

                            cornerRadius: 8

                        )

                    )

            }

            .buttonStyle(.plain)

            .padding(.horizontal, 10)

            .padding(.top, 8)

            .padding(.bottom, 10)

        }

    }

    // MARK: - Default

    private func loadDefaultOption() {

        if selectedMetal.isEmpty {

            selectedMetal =

                metals.first?["label"] as? String

                ?? "--"

        }

        if selectedStone.isEmpty {

            selectedStone =

                stones.first?["label"] as? String

                ?? "--"

        }

        if selectedSize.isEmpty {

            selectedSize =

                sizes.first?["label"] as? String

                ?? "--"

        }

    }

    // MARK: - Close Dropdowns

    private func closeDropdowns() {

        openDropdown = nil

        parentScrollDisabled = false

    }

    // MARK: - Plus Button

    private var selectButton: some View {

        Button {

            closeDropdowns()

            isExpanded = true

        } label: {

            Circle()

                .fill(teal)

                .frame(

                    width: 42,

                    height: 42

                )

                .overlay {

                    Image(

                        systemName: "plus"

                    )

                    .foregroundColor(.white)

                    .font(

                        .system(

                            size: 18,

                            weight: .bold

                        )

                    )

                }

        }

        .buttonStyle(.plain)

    }

    // MARK: - Product Image

    private var productImage: some View {

        AsyncImage(

            url: URL(

                string:

                    product["main_image"]

                    as? String ?? ""

            )

        ) { image in

            image

                .resizable()

                .scaledToFit()

        } placeholder: {

            Color.clear

        }

    }

}

// MARK: - Dropdown

private struct FaroProductDropdownRow: View {

    let title: String

    let options: [String]

    @Binding var selection: String

    @Binding var isOpen: Bool

    @Binding var parentScrollDisabled: Bool

    let closeOtherDropdowns: () -> Void

    private let teal = Color(

        red: 82 / 255,

        green: 203 / 255,

        blue: 196 / 255

    )

    var body: some View {

        ZStack(

            alignment: .topLeading

        ) {

            // Dropdown button

            Button {

                guard !options.isEmpty

                else {

                    return

                }

                if isOpen {

                    isOpen = false

                    parentScrollDisabled = false

                } else {

                    closeOtherDropdowns()

                }

            } label: {

                HStack(spacing: 6) {

                    Text(

                        selection.isEmpty

                            ? (

                                options.isEmpty

                                ? "--"

                                : "Select \\(title)"

                            )

                            : selection

                    )

                    .font(

                        .system(size: 13)

                    )

                    .foregroundColor(

                        selection.isEmpty

                            ? .gray

                            : .black

                    )

                    .lineLimit(1)

                    .minimumScaleFactor(0.72)

                    .truncationMode(.tail)

                    Spacer(minLength: 4)

                    if !options.isEmpty {

                        Image(

                            systemName:

                                isOpen

                                ? "chevron.up"

                                : "chevron.down"

                        )

                        .font(

                            .system(

                                size: 9,

                                weight: .medium

                            )

                        )

                        .foregroundColor(.gray)

                    }

                }

                .padding(.horizontal, 10)

                .frame(

                    maxWidth: .infinity

                )

                .frame(height: 36)

                .background(Color.white)

                .overlay {

                    RoundedRectangle(

                        cornerRadius: 7

                    )

                    .stroke(

                        Color.gray.opacity(0.20),

                        lineWidth: 1

                    )

                }

            }

            .buttonStyle(.plain)

            // IMPORTANT:

            // Menu is an overlay.

            // It does NOT change the card layout.

            if isOpen && !options.isEmpty {

                dropdownMenu

                    .offset(

                        y: 40

                    )

                    .zIndex(50_000)

            }

        }

        .zIndex(

            isOpen

                ? 50_000

                : 0

        )

    }

    // MARK: - Menu Height

    private var rowHeight: CGFloat {

        42

    }

    private var maxMenuHeight: CGFloat {

        // จำกัดความสูงเพื่อให้ menu มี scroll ของตัวเอง

        // ไม่ดัน Add Order และไม่ดัน card อื่น

        168

    }

    private var menuHeight: CGFloat {

        min(

            CGFloat(options.count) * rowHeight,

            maxMenuHeight

        )

    }

    // MARK: - Dropdown Menu

    private var dropdownMenu: some View {

        ScrollView(

            .vertical,

            showsIndicators: true

        ) {

            LazyVStack(

                spacing: 0

            ) {

                ForEach(

                    Array(

                        options.enumerated()

                    ),

                    id: \.offset

                ) { index, option in

                    Button {

                        selection = option

                        isOpen = false

                        parentScrollDisabled = false

                    } label: {

                        HStack(spacing: 8) {

                            Text(option)

                                .font(

                                    .system(

                                        size: 15

                                    )

                                )

                                .foregroundColor(

                                    .black

                                )

                                .lineLimit(1)

                            Spacer(minLength: 8)

                            if selection == option {

                                Image(

                                    systemName:

                                        "checkmark"

                                )

                                .font(

                                    .system(

                                        size: 12,

                                        weight: .semibold

                                    )

                                )

                                .foregroundColor(

                                    teal

                                )

                            }

                        }

                        .padding(

                            .horizontal,

                            12

                        )

                        .frame(

                            maxWidth: .infinity,

                            alignment: .leading

                        )

                        .frame(

                            height: rowHeight

                        )

                        .background(

                            selection == option

                                ? Color(red: 242 / 255, green: 251 / 255, blue: 250 / 255)

                                : Color.white

                        )

                    }

                    .buttonStyle(.plain)

                    if index <

                        options.count - 1 {

                        Divider()

                            .opacity(0.25)

                    }

                }

            }

        }

        // สำคัญ: ใช้ความกว้างเต็ม card

        .frame(

            maxWidth: .infinity

        )

        .frame(

            height: menuHeight

        )

        .background(Color.white)

        .clipShape(

            RoundedRectangle(

                cornerRadius: 8

            )

        )

        .overlay {

            RoundedRectangle(

                cornerRadius: 8

            )

            .stroke(

                Color.gray.opacity(0.20),

                lineWidth: 1

            )

        }

        .shadow(

            color: .black.opacity(0.12),

            radius: 9,

            x: 0,

            y: 4

        )

        .scrollBounceBehavior(

            .basedOnSize

        )

    }

}
