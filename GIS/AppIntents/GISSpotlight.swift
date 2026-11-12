//
//  GISSpotlight.swift
//  GIS
//
//  Makes recently used stock items searchable from the iPhone's Spotlight search.
//  Only the recent items are indexed, not the whole catalog.
//

import AppIntents
import CoreSpotlight
import UniformTypeIdentifiers

@available(iOS 18.0, *)
extension GISItemEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
        let set = CSSearchableItemAttributeSet(contentType: .content)
        set.title = id
        set.displayName = id
        set.contentDescription = "Jewelry item \(id)"
        set.keywords = [id, "GIS", "stock"]
        return set
    }
}

enum GISSpotlightIndexer {
    /// Replaces the Spotlight entries with the current recent items.
    static func indexRecent() {
        // Lets Siri learn the recent item ids used in App Shortcut phrases.
        if #available(iOS 16.4, *) { GISAppShortcuts.updateAppShortcutParameters() }
        guard #available(iOS 18.0, *) else { return }
        let entities = GISRecentItems.ids.map { GISItemEntity(id: $0) }
        guard !entities.isEmpty else { return }
        Task.detached(priority: .utility) {
            do {
                try await CSSearchableIndex.default().indexAppEntities(entities)
            } catch {
                print("GIS Spotlight indexing failed: \(error)")
            }
        }
    }
}

/// Lets the system ask for a refresh of the Spotlight entries.
@available(iOS 27.0, *)
extension GISItemQuery: IndexedEntityQuery {
    func reindexEntities(
        for identifiers: [String],
        indexDescription: CSSearchableIndexDescription
    ) async throws {
        let known = Set(GISRecentItems.ids)
        let entities = identifiers.filter { known.contains($0) }.map { GISItemEntity(id: $0) }
        try await CSSearchableIndex.default().indexAppEntities(entities)
    }

    func reindexAllEntities(indexDescription: CSSearchableIndexDescription) async throws {
        let entities = GISRecentItems.ids.map { GISItemEntity(id: $0) }
        try await CSSearchableIndex.default().indexAppEntities(entities)
    }
}
