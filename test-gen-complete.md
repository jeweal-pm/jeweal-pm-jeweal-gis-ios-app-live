# Test generation progress

Tracks which feature areas (top-level folders under `GIS/`) have had unit
tests written against their reachable pure logic. Written on Windows
(AUTHOR-ONLY mode — no Xcode/simulator available), so every test below is
**unverified**: it has not been compiled or run. Build and run on a Mac (or
CI) before trusting it.

- [x] HelpersClass — `GISTests/HelpersClassTests.swift`
- [x] Pos — `GISTests/PosTests.swift`
- [x] CustomOrder — `GISTests/CustomOrderTests.swift`
- [x] Mix&Match — `GISTests/MixAndMatchTests.swift`
- [x] Reserve — `GISTests/ReserveTests.swift`
- [x] Diamond — `GISTests/DiamondTests.swift`
- [x] Inventory — `GISTests/InventoryTests.swift`
- [x] InventoryDetails — `GISTests/InventoryDetailsTests.swift`
- [x] Item Search — `GISTests/ItemSearchTests.swift` (note: `ItemSearchPage.isAvailableForReserve` is `private` and its call sites are currently commented out — untestable without a visibility/refactor change; documented in the test file)
- [x] Payment — `GISTests/PaymentTests.swift` (note: `CompletePayment.getPdfOrderType` is `private` — untestable as-is; documented in the test file)
- [x] Catalog — `GISTests/CatalogTests.swift`
- [x] QuickView — reviewed, no independently-testable pure logic found (all real branching lives in `private` methods that only ever write to `@IBOutlet`s — e.g. `QuickView.updateVariantControls`/`updateActionButtons`/`updateConfirmButton`); would need extraction to a pure function first. No test file created.
- [x] CommonModals — `GISTests/CommonModalsTests.swift`
- [x] Startup — `GISTests/StartupTests.swift`
- [x] Stock Take — `GISTests/StockTakeTests.swift`
- [x] R_900_5000 — `GISTests/R_900_5000Tests.swift`
- [x] Tracking — reviewed, no pure logic found (`Track.swift`/`TrackStocks.swift` are barcode-scan + network/table glue only). No test file created.
- [x] Extras — `GISTests/ExtrasTests.swift`
- [x] Home — reviewed. `HomePage.handleScanItem`/`mGetScannedData` have real branching (stock_id vs. SKU lookup, first-non-empty-line trim of a scan) but every path immediately touches `UIStoryboard(name: "catalog")` instantiation and/or an Alamofire call, so it isn't safely isolatable in AUTHOR-ONLY mode without risking a crash from missing storyboard/network context. Refactor needed: extract the trim/branch decision into a pure free function before it can be unit tested. No test file created.
- [x] DynamicViews — reviewed. Folder contains only `.xib` files and per-locale `.strings` — no Swift source at all, nothing to unit test. No test file created.

## Suspected bugs pinned down (not fixed — flagging for review)

Tests were written to document *current* behavior, not to fix production
code. A few of these look like real bugs worth a second look:

- `Validation.isblank(testString:)` (`GISTests/HelpersClassTests.swift`) — the
  name says "is blank" but the implementation returns `!trimstring.isEmpty`,
  i.e. it actually reports "is NOT blank". Any caller trusting the name is
  probably inverted.
- `String.hexToString()` (`GISTests/StockTakeTests.swift`, GIS/Stock Take/StockTakePage.swift:8590) —
  after decoding each hex byte to its ASCII character, it trims out every
  character that is *not* an ASCII digit, so decoded letters/spaces/punctuation
  are silently dropped. `"4142"` (hex for "AB") decodes to `""`, not `"AB"`.
- `String.base64Decoded()` (`GISTests/StockTakeTests.swift`, same file:8609) —
  uses `String(data:encoding: .init(rawValue: 0))`; rawValue 0 isn't one of
  Foundation's documented `String.Encoding` constants (`.ascii` starts at 1),
  so this likely never successfully decodes anything. Needs confirming on a
  real build.
- `LaybyInstallmentCheckout.mFormatOrdinal` and its duplicates across
  `GIS/Pos`/`GIS/Extras` build a `NumberFormatter` with `.ordinal` style but
  never pin `.locale`, so output follows `Locale.current`. Fine on the en_US
  CI default, but this app ships `ar`/`ja`/`th`/`zh-Hans`/`ru` too, and
  ordinal suffixes like "1st/2nd/3rd" are English-specific.
- Widespread copy-paste: `calculatePercentage`/`calculateInclusiveTax`/
  `calculateExclusiveTax` (tax math) and `uniqueElementsFrom` (dedup) are
  duplicated near-verbatim across a dozen+ view controllers in `GIS/Pos`,
  `GIS/CustomOrder`, `GIS/Mix&Match`, `GIS/Payment`, `GIS/Reserve`, and
  `GIS/Stock Take` — with small, easy-to-miss variations in what tax source
  each one reads (`mTaxP` ivar vs. `UserDefaults["taxValue"]` vs. `mTaxPercent`).
  A fix to one copy's bug will not propagate to the others.

## Next step

Every test file above is **unverified Swift** — written on Windows with no
Xcode/simulator to compile or run against. On a Mac:
1. Open `GIS.xcworkspace`, right-click the `GISTests` group → **Add Files to
   "GIS"…** → select all the new `*Tests.swift` files listed above → check
   only the `GISTests` target checkbox → Add.
2. Run `xcodebuild test -workspace GIS.xcworkspace -scheme GIS -destination
   'platform=iOS Simulator,name=<a device from `xcrun simctl list devices
   available`>'` (or just Cmd+U in Xcode) and fix any compile errors —
   several tests assume exact signatures/access levels read from source on
   9/4/26; if any file has changed since, the compiler will point at the
   mismatch directly.
