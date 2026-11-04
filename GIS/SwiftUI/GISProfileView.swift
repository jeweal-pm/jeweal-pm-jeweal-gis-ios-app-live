import SwiftUI

struct GISProfileSummary: Equatable {
    let userName: String
    let storeName: String
    let dateText: String

    init(
        userName: String,
        storeName: String = "",
        dateText: String = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
    ) {
        self.userName = userName
        self.storeName = storeName
        self.dateText = dateText
    }
}

struct GISProfileView: View {
    let profile: GISProfileSummary
    let onBack: () -> Void
    let onCustomerProfile: () -> Void
    let onPurchaseHistory: () -> Void
    let onPayment: () -> Void
    let onWishlist: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                identityCard
                quickActions
                customerActions
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 76))
                .foregroundColor(Color.gisTeal)
            Text(profile.userName)
                .font(.title2.weight(.semibold))
            if !profile.storeName.isEmpty {
                Text(profile.storeName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(profile.dateText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    private var identityCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.text.rectangle")
                .font(.title2)
                .foregroundColor(Color.gisTeal)
                .frame(width: 44, height: 44)
                .background(Color.gisTeal.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text("Sales Person")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(profile.userName)
                    .font(.headline)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            profileAction(title: "Profile", icon: "person", action: onCustomerProfile)
            profileAction(title: "Purchase History", icon: "clock.arrow.circlepath", action: onPurchaseHistory)
        }
    }

    private var customerActions: some View {
        VStack(spacing: 0) {
            profileRow(title: "Payment", icon: "creditcard", action: onPayment)
            Divider().padding(.leading, 52)
            profileRow(title: "Wishlist", icon: "heart", action: onWishlist)
            Divider().padding(.leading, 52)
            profileRow(title: "Settings", icon: "gearshape", action: onSettings)
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func profileAction(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.footnote.weight(.medium))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(Color.gisTeal)
            .frame(maxWidth: .infinity, minHeight: 92)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func profileRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .foregroundColor(Color.gisTeal)
                    .frame(width: 22)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
        }
    }
}

struct GISSettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true
    let onBack: () -> Void

    var body: some View {
        List {
            Section("Preferences") {
                Picker("Language", selection: $selectedLanguage) {
                    Text("English").tag("English")
                    Text("Thai").tag("Thai")
                }
                Toggle("Haptic feedback", isOn: $isHapticFeedbackEnabled)
            }
            Section("App") {
                LabeledContent("Version", value: Bundle.main.shortVersion)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

private extension Color {
    static let gisTeal = Color(red: 0.0, green: 0.66, blue: 0.66)
}

private extension Bundle {
    var shortVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }
}
