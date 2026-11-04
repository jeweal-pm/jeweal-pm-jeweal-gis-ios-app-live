// Incremental SwiftUI migration foundation. This module intentionally has no UIKit imports.
import Foundation
import Alamofire

struct GISSession: Equatable {
    var accessToken: String
    var posToken: String
    var organizationID: String
    var locationID: String
    var voucherID: String

    init(
        accessToken: String = "",
        posToken: String = "",
        organizationID: String = "",
        locationID: String = "",
        voucherID: String = ""
    ) {
        self.accessToken = accessToken
        self.posToken = posToken
        self.organizationID = organizationID
        self.locationID = locationID
        self.voucherID = voucherID
    }

    init(defaults: UserDefaults = .standard) {
        self.init(
            accessToken: defaults.string(forKey: "token") ?? "",
            posToken: defaults.string(forKey: "token_pos") ?? "",
            organizationID: defaults.string(forKey: "organization_id") ?? "",
            locationID: defaults.string(forKey: "location") ?? "",
            voucherID: defaults.string(forKey: "voucher_id") ?? ""
        )
    }
}

enum GISCoreError: LocalizedError {
    case server(String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .server(let message):
            return message
        case .decoding:
            return "Unable to read the server response"
        }
    }
}

struct GISAPIEnvelope<Payload: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let data: Payload?
}

final class GISAPIClient {
    static let shared = GISAPIClient()

    private let baseURL: URL
    private let session: Session

    init(
        baseURL: URL = URL(string: "https://api2uat.gis247.net/api/v1/")!,
        session: Session = .default
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func post<Response: Decodable>(
        _ path: String,
        payload: [String: Any],
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent(path)

        session.request(
            url,
            method: .post,
            parameters: payload,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: 200...299)
        .responseData { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                do {
                    completion(.success(try JSONDecoder().decode(Response.self, from: data)))
                } catch {
                    completion(.failure(GISCoreError.decoding))
                }
            }
        }
    }
}

struct GISOrganizationDTO: Decodable, Identifiable, Equatable {
    let id: String
    let name: String
    let domain: String

    enum CodingKeys: String, CodingKey {
        case id = "organization_id"
        case name = "organization"
        case domain
    }
}

struct GISLoginDTO: Decodable {
    let loginToken: String
    let requiresOTP: Bool

    enum CodingKeys: String, CodingKey {
        case loginToken = "login_token"
        case requiresOTP = "twofactorauth"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        loginToken = try container.decodeIfPresent(String.self, forKey: .loginToken) ?? ""

        if let value = try? container.decode(Bool.self, forKey: .requiresOTP) {
            requiresOTP = value
        } else if let value = try? container.decode(Int.self, forKey: .requiresOTP) {
            requiresOTP = value != 0
        } else if let value = try? container.decode(String.self, forKey: .requiresOTP) {
            requiresOTP = ["1", "true", "yes"].contains(value.lowercased())
        } else {
            requiresOTP = false
        }
    }
}

final class GISLoginService {
    private let client: GISAPIClient

    init(client: GISAPIClient = .shared) {
        self.client = client
    }

    func fetchOrganizations(
        username: String,
        completion: @escaping (Result<[GISOrganizationDTO], Error>) -> Void
    ) {
        client.post("Auth/Mobile/login", payload: ["username": username]) {
            (result: Result<GISAPIEnvelope<OrganizationContainer>, Error>) in
            completion(result.flatMap { envelope in
                guard envelope.code == nil || envelope.code == 200 else {
                    return .failure(GISCoreError.server(
                        envelope.message ?? "Unable to load organizations"
                    ))
                }
                return .success(envelope.data?.organizations ?? [])
            })
        }
    }

    func login(
        username: String,
        password: String,
        organizationID: String,
        platform: String,
        appAgent: String,
        completion: @escaping (Result<GISLoginDTO, Error>) -> Void
    ) {
        let payload: [String: Any] = [
            "username": username,
            "password": password,
            "organization_id": organizationID,
            "platform": platform,
            "agent": appAgent
        ]

        client.post("Auth/Mobile/login", payload: payload) {
            (result: Result<GISAPIEnvelope<GISLoginDTO>, Error>) in
            completion(result.flatMap { envelope in
                guard let data = envelope.data, envelope.code == nil || envelope.code == 200 else {
                    return .failure(GISCoreError.server(envelope.message ?? "Login failed"))
                }
                return .success(data)
            })
        }
    }

    private struct OrganizationContainer: Decodable {
        let organizations: [GISOrganizationDTO]

        enum CodingKeys: String, CodingKey {
            case organizations = "org_data"
        }
    }
}
