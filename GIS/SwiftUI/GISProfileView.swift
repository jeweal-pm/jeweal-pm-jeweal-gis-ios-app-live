import Foundation
import Alamofire
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
private enum GISProfileTab: String, CaseIterable, Identifiable {
    case sales = "Sale Person"
    case customer = "Customer"
    var id: String { rawValue }
}

private struct GISSalesPerson: Identifiable, Equatable {
    let id: String
    let name: String
}

private struct GISSalesReport: Identifiable, Equatable {
    let id: String
    let month: String
    let quantity: String
    let amount: String
}

private final class GISProfileViewModel: ObservableObject {
    @Published private(set) var salesPeople: [GISSalesPerson] = []
    @Published private(set) var reports: [GISSalesReport] = []
    @Published var selectedSalesPersonID = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func load() {
        guard salesPeople.isEmpty else { return }
        isLoading = true
        GISProfileService.fetchSalesPeople { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let people):
                    self.salesPeople = people
                    self.selectedSalesPersonID = people.first?.id ?? ""
                    self.loadReports()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func selectSalesPerson(_ person: GISSalesPerson) {
        selectedSalesPersonID = person.id
        loadReports()
    }

    func dismissError() {
        errorMessage = nil
    }

    private func loadReports() {
        guard !selectedSalesPersonID.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        GISProfileService.fetchReports(salesPersonID: selectedSalesPersonID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let reports): self.reports = reports
                case .failure(let error): self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }
}

private enum GISProfileService {
    static func fetchSalesPeople(completion: @escaping (Result<[GISSalesPerson], Error>) -> Void) {
        let payload = ["location": UserDefaults.standard.string(forKey: "location") ?? ""]
        AF.request(mGetSalesPersonList, method: .post, parameters: payload, headers: sGisHeaders2)
            .responseData { response in
                completion(parseSalesPeople(response.data, error: response.error))
            }
    }

    static func fetchReports(salesPersonID: String, completion: @escaping (Result<[GISSalesReport], Error>) -> Void) {
        let payload = [
            "salesPerson_id": salesPersonID,
            "POS_Location_id": UserDefaults.standard.string(forKey: "location") ?? ""
        ]
        AF.request(mGetSalesReports, method: .post, parameters: payload, headers: sGisHeaders2)
            .responseData { response in
                completion(parseReports(response.data, error: response.error))
            }
    }

    private static func parseSalesPeople(_ data: Data?, error: Error?) -> Result<[GISSalesPerson], Error> {
        if let error { return .failure(error) }
        guard let data,
              let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        else { return .failure(GISCoreError.decoding) }
        guard (root["code"] as? Int ?? 200) == 200 else {
            return .failure(GISCoreError.server(root["error"] as? String ?? "Unable to load sales people"))
        }
        let people = (root["Salesperson"] as? [[String: Any]] ?? []).compactMap { row -> GISSalesPerson? in
            guard let id = row["id"] else { return nil }
            let first = row["name"] as? String ?? ""
            let last = row["lname"] as? String ?? ""
            return GISSalesPerson(id: "\(id)", name: "\(first) \(last)".trimmingCharacters(in: .whitespaces))
        }
        return .success(people)
    }

    private static func parseReports(_ data: Data?, error: Error?) -> Result<[GISSalesReport], Error> {
        if let error { return .failure(error) }
        guard let data,
              let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        else { return .failure(GISCoreError.decoding) }
        guard (root["code"] as? Int ?? 200) == 200 else {
            return .failure(GISCoreError.server(root["error"] as? String ?? "Unable to load report"))
        }
        let reports = (root["salesPerson_transaction"] as? [[String: Any]] ?? []).enumerated().map { index, row in
            GISSalesReport(
                id: "\(row["month"] ?? "")-\(index)",
                month: "\(row["month"] ?? "")",
                quantity: "\(row["total_qty"] ?? "")",
                amount: "\(row["total_amount"] ?? "")"
            )
        }
        return .success(reports)
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

    @StateObject private var viewModel = GISProfileViewModel()
    @State private var selectedTab: GISProfileTab = .sales

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                identityHeader
                Picker("Profile", selection: $selectedTab) {
                    ForEach(GISProfileTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                if selectedTab == .sales {
                    salesPersonContent
                } else {
                    customerActions
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) { Image(systemName: "chevron.left") }
            }
            ToolbarItem(placement: .principal) {
                Text("Profile").font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onSettings) { Image(systemName: "gearshape") }
            }
        }
        .task { viewModel.load() }
        .alert("Profile", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK", role: .cancel) { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var identityHeader: some View {
        VStack(spacing: 7) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Color.gisTeal)
            Text(profile.userName.isEmpty ? "—" : profile.userName)
                .font(.title3.weight(.semibold))
            if !profile.storeName.isEmpty {
                Text(profile.storeName).font(.subheadline).foregroundColor(.secondary)
            }
            Text(profile.dateText).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var salesPersonContent: some View {
        VStack(spacing: 14) {
            Menu {
                ForEach(viewModel.salesPeople) { person in
                    Button(person.name) { viewModel.selectSalesPerson(person) }
                }
            } label: {
                HStack {
                    Text(selectedSalesPersonName).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down").font(.caption.weight(.semibold))
                }
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            salesReportCard
        }
    }

    private var selectedSalesPersonName: String {
        viewModel.salesPeople.first(where: { $0.id == viewModel.selectedSalesPersonID })?.name ?? "Sale Person"
    }

    private var salesReportCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Month").frame(maxWidth: .infinity, alignment: .leading)
                Text("Qty").frame(width: 56, alignment: .trailing)
                Text("Amount").frame(width: 100, alignment: .trailing)
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.bottom, 8)

            if viewModel.isLoading {
                ProgressView().padding(.vertical, 28)
            } else if viewModel.reports.isEmpty {
                Text("No report data available").foregroundColor(.secondary).padding(.vertical, 28)
            } else {
                ForEach(viewModel.reports) { report in
                    Divider()
                    HStack {
                        Text(report.month).frame(maxWidth: .infinity, alignment: .leading)
                        Text(report.quantity).frame(width: 56, alignment: .trailing)
                        Text(report.amount).frame(width: 100, alignment: .trailing)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 11)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var customerActions: some View {
        VStack(spacing: 0) {
            profileRow(title: "Profile", icon: "person", action: onCustomerProfile)
            Divider().padding(.leading, 52)
            profileRow(title: "Purchase History", icon: "clock.arrow.circlepath", action: onPurchaseHistory)
            Divider().padding(.leading, 52)
            profileRow(title: "Payment", icon: "creditcard", action: onPayment)
            Divider().padding(.leading, 52)
            profileRow(title: "Wishlist", icon: "heart", action: onWishlist)
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func profileRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).foregroundColor(Color.gisTeal).frame(width: 22)
                Text(title).foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundColor(.secondary)
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
