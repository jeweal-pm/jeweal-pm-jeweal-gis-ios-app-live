//
//  GISItemEntity.swift
//  GIS
//
//  Jewelry item exposed to Siri, Shortcuts and Spotlight as an App Intents entity.
//

import AppIntents
import Foundation

/// Remembers the most recently opened stock ids so Siri/Shortcuts can suggest them.
enum GISRecentItems {
    private static let key = "GISRecentItemIDs"
    private static let limit = 10

    static var ids: [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func record(_ id: String) {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var list = ids.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        list.insert(trimmed, at: 0)
        UserDefaults.standard.set(Array(list.prefix(limit)), forKey: key)
    }
}

/// A stock item identified by its stock id / SKU. The id is the SKU itself, so it stays
/// stable across launches and devices (saved shortcuts depend on it; never change the scheme).
@available(iOS 16.0, *)
struct GISItemEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Jewelry Item"
    static var defaultQuery = GISItemQuery()

    var id: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

@available(iOS 16.0, *)
struct GISItemQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [GISItemEntity] {
        identifiers.map { GISItemEntity(id: $0) }
    }

    /// The screens resolve the typed id themselves (same as the legacy Siri flow),
    /// so a typed or spoken value is accepted as an item id.
    func entities(matching string: String) async throws -> [GISItemEntity] {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return [GISItemEntity(id: trimmed)]
    }

    func suggestedEntities() async throws -> [GISItemEntity] {
        GISRecentItems.ids.map { GISItemEntity(id: $0) }
    }
}
