//
//  GISOnScreenItem.swift
//  GIS
//
//  Tells Siri which item a detail screen is showing, so "this" can resolve to it.
//

import AppIntents
import Foundation

/// Owns the foreground `NSUserActivity` for an item detail screen.
/// Call `show` once the item is known, `resume` in viewDidAppear, `clear` in viewDidDisappear.
final class GISOnScreenItem {
    static let activityType = "com.gis247.viewItem"

    private var itemID: String?
    private var activity: NSUserActivity?

    func show(id: String) {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "--" else { return }
        itemID = trimmed
        resume()
    }

    func resume() {
        guard #available(iOS 18.2, *), let id = itemID else { return }
        activity?.invalidate()
        let newActivity = NSUserActivity(activityType: Self.activityType)
        newActivity.title = id
        newActivity.appEntityIdentifier = EntityIdentifier(for: GISItemEntity.self, identifier: id)
        newActivity.becomeCurrent()
        activity = newActivity
        GISRecentItems.record(id)
    }

    func clear() {
        activity?.invalidate()
        activity = nil
    }
}
