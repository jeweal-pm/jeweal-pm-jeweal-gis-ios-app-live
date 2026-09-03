//
//  FaroScannerView.swift
//  GIS
//
//  Created by Jeweal on 3/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI
import UIKit
import AVFoundation
import Speech


// MARK: - Faro Voice Input
//
// Uses AVAudioEngine for the live microphone level and SFSpeechRecognizer
// for partial/final speech transcription.
//
// IMPORTANT:
// Add these keys to Info.plist:
// - NSMicrophoneUsageDescription
// - NSSpeechRecognitionUsageDescription
//
final class FaroVoiceInputManager: NSObject, ObservableObject {

    @Published private(set) var isListening = false
    @Published private(set) var recognizedText = ""
    @Published private(set) var rmsLevel: CGFloat = 0
    // Start with a visible waveform immediately so the UI does not look frozen
    // while AVAudioEngine / Speech recognition are warming up.
    @Published private(set) var waveformLevels: [CGFloat] = [
        0.16, 0.24, 0.32, 0.22, 0.14, 0.28, 0.38, 0.20,
        0.12, 0.26, 0.34, 0.18, 0.24, 0.30, 0.16, 0.22,
        0.32, 0.20, 0.14, 0.28, 0.36, 0.18, 0.24, 0.30,
        0.16, 0.22, 0.34, 0.20, 0.14, 0.28, 0.36, 0.18,
        0.24, 0.30
    ]
    @Published private(set) var authorizationError: String?

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.current)

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private let audioSession = AVAudioSession.sharedInstance()
    private var smoothedRMS: CGFloat = 0

    deinit {
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
        try? audioSession.setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    func start() {
        guard !isListening else { return }

        authorizationError = nil

        requestPermissions { [weak self] granted in
            guard let self else { return }

            DispatchQueue.main.async {
                guard granted else {
                    self.authorizationError = "Microphone or speech recognition permission was denied."
                    return
                }

                self.startAudioAndSpeech()
            }
        }
    }

    func stop() {
        recognitionTask?.cancel()
        recognitionTask = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)

        try? audioSession.setActive(
            false,
            options: .notifyOthersOnDeactivation
        )

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.isListening = false
            self.rmsLevel = 0
            self.smoothedRMS = 0
            self.waveformLevels = [
                0.16, 0.24, 0.32, 0.22, 0.14, 0.28, 0.38, 0.20,
                0.12, 0.26, 0.34, 0.18, 0.24, 0.30, 0.16, 0.22,
                0.32, 0.20, 0.14, 0.28, 0.36, 0.18, 0.24, 0.30,
                0.16, 0.22, 0.34, 0.20, 0.14, 0.28, 0.36, 0.18,
                0.24, 0.30
            ]
        }
    }

    func cancel() {
        stop()

        DispatchQueue.main.async { [weak self] in
            self?.recognizedText = ""
            self?.authorizationError = nil
        }
    }

    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        var microphoneGranted = false
        var speechGranted = false

        group.enter()
        audioSession.requestRecordPermission { granted in
            microphoneGranted = granted
            group.leave()
        }

        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechGranted = status == .authorized
            group.leave()
        }

        group.notify(queue: .main) {
            completion(microphoneGranted && speechGranted)
        }
    }

    private func startAudioAndSpeech() {
        // Show the active voice state immediately. The waveform will be replaced
        // by real microphone samples as soon as the audio tap starts receiving data.
        isListening = true

        guard let speechRecognizer else {
            isListening = false
            authorizationError = "Speech recognition is not available."
            return
        }

        guard speechRecognizer.isAvailable else {
            authorizationError = "Speech recognition is currently unavailable."
            isListening = false
            return
        }

        do {
            recognitionTask?.cancel()
            recognitionTask = nil
            smoothedRMS = 0
            waveformLevels = [
                0.16, 0.24, 0.32, 0.22, 0.14, 0.28, 0.38, 0.20,
                0.12, 0.26, 0.34, 0.18, 0.24, 0.30, 0.16, 0.22,
                0.32, 0.20, 0.14, 0.28, 0.36, 0.18, 0.24, 0.30,
                0.16, 0.22, 0.34, 0.20, 0.14, 0.28, 0.36, 0.18,
                0.24, 0.30
            ]

            try audioSession.setCategory(
                .record,
                mode: .measurement,
                options: [.duckOthers, .allowBluetooth]
            )

            try audioSession.setActive(
                true,
                options: .notifyOthersOnDeactivation
            )

            let inputNode = audioEngine.inputNode

            let recordingFormat = inputNode.outputFormat(forBus: 0)

            guard recordingFormat.sampleRate > 0,
                  recordingFormat.channelCount > 0 else {
                authorizationError = "Microphone input is unavailable."
                try? audioSession.setActive(
                    false,
                    options: .notifyOthersOnDeactivation
                )
                return
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            request.taskHint = .search

            if #available(iOS 13.0, *) {
                request.requiresOnDeviceRecognition = false
            }

            recognitionRequest = request

            recognitionTask = speechRecognizer.recognitionTask(
                with: request
            ) { [weak self] result, error in

                guard let self else { return }

                if let result {
                    DispatchQueue.main.async {
                        guard self.isListening else { return }
                        self.recognizedText = result.bestTranscription.formattedString
                    }

                    if result.isFinal {
                        // Do NOT auto-stop here.
                        //
                        // The UI stays in voice mode until the user explicitly
                        // taps Cancel or Confirm.
                    }
                }

                if let error {
                    DispatchQueue.main.async {
                        // Explicit Cancel/Confirm can produce a normal cancellation
                        // error. Do not treat that as a UI failure.
                        guard self.isListening else { return }
                        print("FARO SPEECH ERROR:", error.localizedDescription)
                    }
                }
            }

            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { [weak self] buffer, _ in

                guard let self else { return }

                request.append(buffer)

                // Use the REAL microphone RMS for the newest waveform bar.
                // The newest bar is appended on the RIGHT and the older bars
                // shift toward the LEFT, matching the Faro voice design.
                let level = self.calculateRMSLevel(from: buffer)

                DispatchQueue.main.async {
                    guard self.isListening else { return }

                    self.rmsLevel = level

                    var nextLevels = self.waveformLevels
                    if nextLevels.count >= 34 {
                        nextLevels.removeFirst()
                    }
                    nextLevels.append(level)

                    self.waveformLevels = nextLevels
                }
            }

            audioEngine.prepare()
            try audioEngine.start()

            // isListening was enabled before the audio engine started, so the
            // voice UI is already visible while the first real samples arrive.

        } catch {
            print("FARO AUDIO START ERROR:", error.localizedDescription)

            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionTask?.cancel()
            recognitionTask = nil
            recognitionRequest = nil

            try? audioSession.setActive(
                false,
                options: .notifyOthersOnDeactivation
            )

            DispatchQueue.main.async {
                self.isListening = false
                self.authorizationError = error.localizedDescription
            }
        }
    }

    private func calculateRMSLevel(
        from buffer: AVAudioPCMBuffer
    ) -> CGFloat {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0.03
        }

        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else {
            return 0.03
        }

        var sum: Float = 0
        for index in 0..<frameLength {
            let sample = channelData[index]
            sum += sample * sample
        }

        let meanSquare = sum / Float(frameLength)
        let rawRMS = max(sqrt(meanSquare), 0.00001)

        // Convert RMS to dB and remap it to a much more useful visual range.
        // iPad microphone RMS values are often quite small, so the old linear
        // multiplier made normal speech look almost flat.
        let decibels = 20.0 * log10(rawRMS)
        let normalizedDB = CGFloat((decibels + 50.0) / 34.0)
        let boosted = pow(min(max(normalizedDB, 0), 1), 0.62)

        smoothedRMS = (smoothedRMS * 0.58) + (boosted * 0.42)

        return min(max(smoothedRMS, 0.04), 1)
    }
}

// MARK: - Voice Waveform

struct FaroVoiceWaveform: View {

    // Rolling RMS history.
    // New microphone data enters from the RIGHT; older values move LEFT.
    let levels: [CGFloat]

    private let barCount = 34

    var body: some View {
        GeometryReader { _ in
            HStack(alignment: .center, spacing: 8) {
                ForEach(0..<barCount, id: \.self) { index in
                    let level = index < levels.count ? levels[index] : 0.03

                    Capsule()
                        .fill(
                            Color(
                                red: 0.18,
                                green: 0.72,
                                blue: 0.68
                            )
                        )
                        .frame(
                            width: 3,
                            height: max(5, min(34, 5 + (level * 29)))
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        .frame(height: 34)
        .clipped()
        // Smoothly animate the REAL RMS samples as they shift right -> left.
        .animation(.linear(duration: 0.06), value: levels)
    }
}


struct FaroScannerView: View {
    
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isFocused: Bool
    @FocusState private var imageSearchFocused: Bool

    @State private var showLogo = false
    @State private var showContent = false
    @State private var showSearch = false

    @State private var showSend = false
    @State private var showMic = true
    @State private var searchScale: CGFloat = 1

    @StateObject private var voiceInput = FaroVoiceInputManager()

    // Remembers where Voice Search was opened from.
    // Home: keep the search card exactly where it was.
    // Discovery: keep the compact search card at the top.
    @State private var voiceStartedFromDiscovery = false

    // True only during the short Confirm transition.
    // The green pulsing circle must NOT be visible while listening.
    @State private var isSubmittingVoice = false
    @State private var voiceSubmitScale: CGFloat = 1.0
    
    @State private var showDiscovery = false
    
    @State private var selectedPrompt: String? = nil
    @State private var searchText = ""
    
    @State private var faroMode: FaroMode = .search

//    @State private var promptOpacity = 0.0
//    @State private var answerOpacity = 0.0

    @State private var searchExpanded = false

    @FocusState private var searchFocused: Bool

    @State
    private var products: [NSMutableDictionary] = []

    @State
    private var showResult = false

    @State
    private var isLoading = false
    
    @State private var inStockOnly = false

    // Keep the last successful image-search result so turning
    // "In stock only" OFF restores exactly the same items.
    @State private var cachedImageSearchProducts: [NSMutableDictionary] = []
    @State private var imageSearchRequestID = UUID()

    @State
    private var selectedProducts: [NSMutableDictionary] = []
    
    @State
    private var toastMessage = ""
    
    @State
    private var showToast = false
    
    
    let onSearch: (String) -> Void
    let onContinue: ([NSMutableDictionary]) -> Void
    let onClose: () -> Void
    
    // ----------------------------
    // Image Search
    // ----------------------------

    @State private var showImagePicker = false

    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var selectedImage: UIImage?

    // Image-search UI state:
    // true  = the large image preview is visible
    // false = only the small image thumbnail remains in the search row
    @State private var imagePreviewExpanded = false

    // After the user removes the image thumbnail, show an explicit X
    // on the search row so they can return to the real home screen.
    @State private var showCloseButton = false

    @State private var isImageSearch = false

    @State private var showImageSearch = false
    
    @State private var isSearchingImage = false
    
    @Namespace private var imageAnimation
    
    
    init(
        onSearch: @escaping (String) -> Void,
        onContinue: @escaping ([NSMutableDictionary]) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.onSearch = onSearch
        self.onContinue = onContinue
        self.onClose = onClose
    }

    private var isTyping: Bool {

        !searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

    }
    
    var body: some View {

        ZStack {

            //----------------------------------
            // Background
            //----------------------------------

            Color.white
                .ignoresSafeArea()
                .onTapGesture {

                    isFocused = false
                    hideKeyboard()

                }

            //----------------------------------
            // HOME LAYER
            //----------------------------------

            VStack(spacing:0){

                FaroHeader {

                    closeScannerToHome()

                }
                .padding(.bottom, 8)
                
                
                Spacer()
                    .frame(height: showDiscovery ? 12 : 72)

                HeroSection(
                    showLogo: showLogo,
                    showContent: showContent
                )
//                .frame(height: showDiscovery ? 0 : nil)
//                .opacity(showDiscovery ? 0 : 1)
                .scaleEffect(showDiscovery ? 0.96 : 1)
                .opacity(showDiscovery ? 0.15 : 1)
                .offset(y: showDiscovery ? -24 : 0)
//                .offset(y: showDiscovery ? -50 : 0)
                .frame(height: showDiscovery ? 0 : nil)
                .clipped()
                .allowsHitTesting(!showDiscovery)

                // This is intentionally mounted in both modes so that the
                // existing TextField keeps its text and keyboard focus.
                SearchCard()
                    

                if showDiscovery {
                    DiscoveryView(
                        searchText: $searchText,
                        selectedPrompt: $selectedPrompt,
                        faroMode: $faroMode,
                        onSearch: { text in
                            performSearch(
                                text,
                                inStockOnly: inStockOnly
                            )
                        },
                        onClose: {
                            closeDiscovery()
                        }
                    )
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
                    .zIndex(20)
                    .allowsHitTesting(showDiscovery)
                }

            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .top)
            .zIndex(0)


        }
//        .onChange(of: selectedImage) { image in
//
//            guard let image else {
//                return
//            }
//
//            print("Image Selected")
//
//        }
//        .confirmationDialog(
//            "Search by Image",
//            isPresented: $showImageSource,
//            titleVisibility: .visible
//        ) {
//
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//
//                Button("Take Photo") {
//
//                    sourceType = .camera
//                    showImagePicker = true
//
//                }
//
//            }
//
//            Button("Choose Photo") {
//
//                sourceType = .photoLibrary
//                showImagePicker = true
//
//            }
//
//            Button("Cancel", role: .cancel) {}
//
//        }
//        .sheet(isPresented: $showImagePicker) {
//
//            ImagePicker(
//                image: $selectedImage,
//                sourceType: sourceType
//            )
//
//        }
        .onAppear {

            withAnimation(.easeOut(duration:0.45)){

                showLogo = true

            }

            withAnimation(
                .spring(
                    response:0.65,
                    dampingFraction:0.82
                )
                .delay(0.15)
            ){

                showContent = true

            }

            withAnimation(
                .spring(
                    response:0.7,
                    dampingFraction:0.82
                )
                .delay(0.35)
            ){

                showSearch = true

            }


        }
        .onChange(of: searchText) { value in

            let typing = !value
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty

            withAnimation(
                .interactiveSpring(
                    response:0.42,
                    dampingFraction:0.82
                )
            ){

                showSend = typing
                showMic = !typing

            }

            if value.count == 1{

                UIImpactFeedbackGenerator(style:.light)
                    .impactOccurred()

            }

            // Typing belongs to Discovery as well.  Do not clear the text or
            // resign focus when the prompt UI appears.
//            if typing {
//                faroMode = .discover
//                if !showDiscovery {
//                    withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
//                        showDiscovery = true
//                        searchExpanded = true
//                    }
//                }
//            }

        }
        .onDisappear {
            voiceInput.stop()
        }

        .fullScreenCover(isPresented: $showResult) {
            
            FaroResultView(
                searchText: $searchText,
                selectedImage: selectedImage,
                products: $products,
                isLoading: $isLoading,
                inStockOnly: $inStockOnly,
                
                onRemoveImage: {
                    
                    selectedImage = nil
                    showImageSearch = false
                    
                },
                
                onSearchChanged: { value in
                    let keyword = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !keyword.isEmpty else { return }

                    // Keep the editable result search field as the source of truth.
                    searchText = keyword
                    selectedImage = nil
                    isImageSearch = false
                    showCloseButton = false
                    faroMode = .search

                    performSearch(
                        keyword,
                        inStockOnly: inStockOnly
                    )
                },

                onInStockChanged: { value in

                    // Update source of truth first.
                    inStockOnly = value

                    if selectedImage != nil {

                        // Image search must be executed again for BOTH states.
                        // Turning the filter OFF should reload the image-search
                        // result instead of only restoring the cached array.
                        // This keeps the behavior consistent with the ON state
                        // and guarantees the backend is queried again.
                        if let image = selectedImage {
                            performImageSearch(image)
                        }

                    } else {

                        // Normal text search
                        performSearch(
                            searchText,
                            inStockOnly: value
                        )
                    }
                },

                onReturnToFaroHome: {
                    showResult = false
                    resetFaroHomeState()
                },
                
                onContinue: { products in
                    
                    showResult = false
                    
                    onContinue(products)
                }
            )
        }.transaction { transaction in
            transaction.animation = .easeInOut(duration: 0.3)
        }
        .overlay {

            if isSearchingImage {

                ZStack {

                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()

                    ProgressView("Searching image...")
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)

                }

            }

        }

    }
    
    
    @ViewBuilder
    func SearchCard() -> some View {

        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white)

            .overlay {

                SearchCardContent()

            }

            .background {

                Image("faro_search_bg")
//                    .resizable()
//                    .scaledToFit()
                    .frame(width: 520)
                    .offset(y: 14)
                    .opacity(0.5)
                    .allowsHitTesting(false)

            }

            .overlay {
                if showDiscovery {
                    rainbowGradient()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(
                height:
                    voiceInput.isListening
                    ? 104
                    : (
                        selectedImage != nil
                        ? (imagePreviewExpanded ? 192 : 104)
                        : 104
                    )
            )
            .animation(
                .spring(
                    response: 0.48,
                    dampingFraction: 0.82
                ),
                value: selectedImage
            )
            .animation(
                .spring(
                    response:0.45,
                    dampingFraction:0.82
                ),
                value:searchExpanded
            )
            .padding(.horizontal,18)
            .padding(.top, showDiscovery ? 0 : 12)

            .shadow(
                color:.black.opacity(0.06),
                radius:18,
                x:0,
                y:10
            )

            .scaleEffect(isFocused ? 1.015 : 1)
//            .offset(
//                y: showDiscovery ? -18 : 0
//            )
    }
    
    @ViewBuilder
    func DiscoveryLayer() -> some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 24) {

                TrendingSection()

                Spacer(minLength: 120)

            }
            .padding(.horizontal, 18)
            .padding(.top, 26)

        }
        .frame(height:56)
        .background(.white)

    }
    
    struct TrendingSection: View {

        var body: some View {

            VStack(alignment: .leading, spacing: 22) {

                HStack {

                    Text("Trending")
                        .font(.system(size: 28, weight: .bold))

                    Spacer()

                    Button("See all") { }
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                }

                TrendingCard()

                ProductCarousel()

                CategorySection()

            }

        }

    }
    
    struct CategorySection: View {

        let items = [
            "Ring",
            "Necklace",
            "Bracelet",
            "Earrings",
            "Pendant",
            "Wedding"
        ]

        var body: some View {

            VStack(alignment: .leading, spacing: 14) {

                Text("Browse by category")
                    .font(.system(size: 22, weight: .bold))

                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 12) {

                        ForEach(items, id: \.self) { item in

                            CategoryChip(title: item)

                        }

                    }

                }

            }

        }

    }
    
    struct CategoryChip: View {

        let title: String

        var body: some View {

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(Color.gray.opacity(0.08))
                .clipShape(Capsule())

        }

    }
    
    struct ProductCarousel: View {

        var body: some View {

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 16) {

                    ForEach(0..<8,id:\.self){ _ in

                        ProductCard()

                    }

                }
                .padding(.horizontal,2)

            }

        }

    }
    
    struct ProductCard: View {

        var body: some View {

            VStack(alignment:.leading,spacing:10){

                RoundedRectangle(cornerRadius:20)
                    .fill(Color.gray.opacity(0.08))
                    .frame(width:170,height:170)
                    .overlay{

                        Image(systemName:"photo")
                            .font(.system(size:34))
                            .foregroundColor(.gray)

                    }

                Text("Diamond Ring")
                    .font(.system(size:15,weight:.regular))

                Text("$2,450")
                    .font(.system(size:14))
                    .foregroundColor(.gray)

            }
            .frame(width:170)

        }

    }
    
    struct TrendingCard: View {

        var body: some View {

            ZStack(alignment: .bottomLeading) {

                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.46, green: 0.43, blue: 1.00),
                                Color(red: 0.31, green: 0.83, blue: 0.94)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 10) {

                    Text("AI Picks")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))

                    Text("Discover jewelry\nselected for you")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Powered by faro AI")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))

                }
                .padding(24)

            }
            .frame(height: 200)

        }

    }
    
    @ViewBuilder
    func DiscoveryContainer() -> some View {

        VStack {

            Text("Discovery")
                .font(.title)

            Rectangle()
                .fill(.red.opacity(0.2))
                .frame(height: 300)

        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .opacity(showDiscovery ? 1 : 0)
        .offset(y: showDiscovery ? 0 : 80)
    }
    
    @ViewBuilder
    func DiscoveryHeader() -> some View {

        HStack {

            Text("Discovery")

                .font(
                    .system(
                        size: 24,
                        weight: .semibold
                    )
                )

            Spacer()

        }

    }
    
    @ViewBuilder
    func SearchCardContent() -> some View {

        VStack(spacing: 0) {

            // ---------------------------------------------
            // Search row
            // ---------------------------------------------

            if voiceInput.isListening {

                VoiceSearchRow()

            } else if isImageSearch {

                ImageSearchRow()

            } else {

                SearchRow()

            }

            // ---------------------------------------------
            // Large image preview
            //
            // IMPORTANT:
            // The image is NOT removed when the user taps "^".
            // "^" only collapses this preview.
            // ---------------------------------------------

            if let image = selectedImage,
               imagePreviewExpanded {

                Spacer()
                    .frame(height: 6)

                ImagePreview(
                    image: image
                ) {

                    withAnimation(
                        .spring(
                            response: 0.45,
                            dampingFraction: 0.82
                        )
                    ) {

                        imagePreviewExpanded = false

                    }

                }
                .transition(
                    .opacity
                    .combined(
                        with: .scale(scale: 0.97)
                    )
                )

            }

            Spacer()

            // ---------------------------------------------
            // Normal toolbar
            //
            // It must come back immediately after the image
            // thumbnail is removed.
            // ---------------------------------------------

            if selectedImage == nil && !voiceInput.isListening {

                BottomToolbar()
                    .padding(.top, 6)

            }

        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 10)

    }

    @ViewBuilder
    func LeftToolbar() -> some View {

        ZStack(alignment: .leading) {

            //--------------------------------
            // Camera
            //--------------------------------

            Button {
                showImageSearch=true
            } label: {

                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)

            }
            .fullScreenCover(isPresented: $showImageSearch) {

                ImageSearchView { image in
                    
                    products.removeAll()
                    
                    searchText = ""
                    
                    withAnimation(
                        .spring(
                            response: 0.5,
                            dampingFraction: 0.82
                        )
                    ) {

                        self.selectedImage = image
                        self.isImageSearch = true
                        self.imagePreviewExpanded = true
                        self.showCloseButton = false
                        
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 0.25
                        ) {

                            imageSearchFocused = true

                        }

                    }

                    hideKeyboard()

                    isFocused = false

                    print("IMAGE SELECTED")
                    
                    performImageSearch(image)
                }

            }
            .opacity(
                showMic && selectedImage == nil
                ? 1
                : 0
            )
            .offset(x: showMic ? 0 : -12)

            //--------------------------------
            // Mic
            //--------------------------------

            Button {

                startVoiceInput()

            } label: {

                Image(systemName: "mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)

            }
            .opacity(
                selectedImage == nil
                ? 1
                : 0
            )
            .offset(
                x: showMic ? 42 : 0
            )

        }
        .frame(width: 70, alignment: .leading)
        .animation(
            .interactiveSpring(
                response: 0.38,
                dampingFraction: 0.82
            ),
            value: showMic
        )
    }
    
//    private func performImageSearch(_ image: UIImage) {
//
//        print("========== IMAGE SEARCH ==========")
//
//        guard let data = image.jpegData(compressionQuality: 0.9) else {
//            return
//        }
//
//        print("Image Size =", data.count)
//
//        isLoading = true
//        showResult = true
//
//        FaroService.shared.searchImage(image: image) { result in
//
//            DispatchQueue.main.async {
//
//                switch result {
//
//                case .success(let products):
//
//                    let raw = products.compactMap {
//                        $0 as? NSDictionary
//                    }
//
//                    self.products = raw.map(FaroMapper.mapProduct)
//
//                    self.isLoading = false
//
//                case .failure(let error):
//
//                    print(error)
//
//                    self.isLoading = false
//
//                }
//
//            }
//
//        }
//
//    }
    
    @ViewBuilder
    func BottomToolbar() -> some View {

        HStack {

            LeftToolbar()

            Spacer()

            RightActionView()

        }
        .frame(height: 36)
    }
    
    @ViewBuilder
    func SearchRow() -> some View {

        HStack(spacing: 10) {

            TextField(
                "Search (Product name, Color, Type,...)",
                text: $searchText
            )
            .focused($isFocused)
            .font(.system(size: 16))
            .tint(.gray.opacity(0.35))
            .foregroundColor(.black)
            .submitLabel(.search)
            .onSubmit {

                let keyword = searchText
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

                guard !keyword.isEmpty else {
                    return
                }

//                performSearch(keyword)
                performSearch(
                    keyword,
                    inStockOnly: inStockOnly
                )

            }

            // This X is deliberately the LAST item in the
            // text field row. It is shown after the image has
            // been removed so the user can leave Faro.
            if showCloseButton {

                Button {

                    closeScannerToHome()

                } label: {

                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 15,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.gray)
                        .frame(
                            width: 28,
                            height: 28
                        )

                }

            } else if isTyping || showDiscovery {

                Button {

                    if isTyping {

                        // First tap clears the entire query.
                        // Keep Discovery open so the user can continue typing.
                        searchText = ""

                    } else {

                        // Second X tap: leave Discovery, but stay inside Faro.
                        // The user should return to Faro's main search screen,
                        // not dismiss the Faro scanner/full-screen flow.
                        returnToFaroSearchHome()

                    }

                } label: {

                    Image(systemName: "xmark")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .frame(
                            width: 28,
                            height: 28
                        )

                }

            }

        }
        .frame(height: 30)
        // Keep the search text and clear button slightly lower inside
        // the expanded discovery/search card to match the reference UI.
        .offset(y: 7)

    }

    @ViewBuilder
    func VoiceSearchRow() -> some View {
        VStack(spacing: 0) {
            FaroVoiceWaveform(
                levels: voiceInput.waveformLevels
            )
            .frame(height: 34)
            .padding(.horizontal, 22)
            .padding(.top, 6)

            Spacer(minLength: 0)

            HStack(spacing: 0) {
                Button {
                    cancelVoiceInput()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                }
                .contentShape(Rectangle())

                Spacer()

                Spacer()

                // Normal state = checkmark. Recognition text is intentionally
                // not displayed here; it is kept internally for the confirm action.
                // Confirm state = teal pulsing ring.
                if isSubmittingVoice {
                    Circle()
                        .stroke(
                            Color(red: 0.20, green: 0.72, blue: 0.67),
                            lineWidth: 3
                        )
                        .frame(width: 32, height: 32)
                        .scaleEffect(voiceSubmitScale)
                        .opacity(0.85)
                } else {
                    Button {
                        confirmVoiceInput()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                    }
                    .contentShape(Rectangle())
                    .disabled(
                        voiceInput.recognizedText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                    .opacity(
                        voiceInput.recognizedText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty ? 0.45 : 1.0
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
    }
    @ViewBuilder
    func ImageSearchRow() -> some View {

        HStack(spacing: 8) {

            // Small image thumbnail stays visible after "^"
            // collapses the large preview.
            if let image = selectedImage {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: 22,
                        height: 22
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 5
                        )
                    )

                // X beside the thumbnail = remove image only.
                Button {

                    withAnimation(
                        .spring(
                            response: 0.45,
                            dampingFraction: 0.82
                        )
                    ) {

                        selectedImage = nil
                        isImageSearch = false
                        imagePreviewExpanded = false
                        searchText = ""

                        // Show the final X on the full search row.
                        showCloseButton = true

                        imageSearchFocused = false
                        isFocused = false
                        hideKeyboard()

                    }

                } label: {

                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 11,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.gray)
                        .frame(
                            width: 22,
                            height: 22
                        )

                }
                .transition(
                    .scale.combined(with: .opacity)
                )

            }

            TextField(
                "Add to your search",
                text: $searchText
            )
            .focused($imageSearchFocused)
            .font(
                .system(
                    size: 16,
                    weight: .regular
                )
            )
            .tint(.gray.opacity(0.35))
            .foregroundColor(.black)
            .submitLabel(.search)
            .onSubmit {

                guard let image = selectedImage else {
                    return
                }

                performImageSearch(image)

            }

            Spacer(minLength: 0)

            // "^" only collapses/expands the large image.
            // It NEVER clears selectedImage.
            Button {

                withAnimation(
                    .spring(
                        response: 0.45,
                        dampingFraction: 0.82
                    )
                ) {

                    imagePreviewExpanded.toggle()

                }

            } label: {

                Image(
                    systemName:
                        imagePreviewExpanded
                        ? "chevron.up"
                        : "chevron.down"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .medium
                    )
                )
                .foregroundColor(.gray)
                .frame(
                    width: 28,
                    height: 28
                )

            }

        }
        .frame(height: 30)

    }

    @ViewBuilder
    func ImageSearchHeader() -> some View {

        HStack(spacing:12) {

            Image(systemName:"sparkles")
                .foregroundColor(.gray)

            ImageSearchTextField()
                .focused($imageSearchFocused)

            Spacer()

            Button {

                withAnimation(.spring()) {

                    imagePreviewExpanded = false

                }

            } label: {

                Image(systemName:"chevron.up")
                    .foregroundColor(.gray)

            }

        }
        .frame(height:34)

    }
    
    @ViewBuilder
    func ImageSearchTextField() -> some View {

        TextField(
            isImageSearch
            ? "Add to your search"
            : "Search (Product name, Color, Type,...)",

            text: $searchText
        )
        .focused($imageSearchFocused)
        .font(.system(size: 17))
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .submitLabel(.search)
        .onSubmit {
            guard let image = selectedImage else {
                return
            }
            performImageSearch(image)
//            guard
//                let image = selectedImage,
//                !searchText.trimmingCharacters(in: .whitespaces).isEmpty
//            else {
//                return
//            }
//
//            performImageSearch(image)
//            performImageSearch(
//                image,
//                prompt: searchText
//            )

        }

    }
    
    @ViewBuilder
    func ImageSearchPreview(
        image: UIImage
    ) -> some View {

        HStack(spacing:14){

            Image(uiImage:image)
                .resizable()
                .scaledToFill()
                .frame(width:90,height:90)
                .clipShape(RoundedRectangle(cornerRadius:18))

            VStack(alignment:.leading,spacing:8){

                Text("Searching by image...")
                    .font(.headline)

                Text("AI is analyzing this image")
                    .font(.caption)
                    .foregroundColor(.gray)

            }

            Spacer()

            Button{

                withAnimation{

                    selectedImage=nil
                    isImageSearch=false
                    imagePreviewExpanded=false
                    showCloseButton=true
                    searchText=""

                }

            }label:{

                Image(systemName:"xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)

            }

        }
        .frame(height:92)

    }
    
    
    struct ImagePreview: View {

        let image: UIImage

        let onTap: () -> Void

        var body: some View {

            ZStack {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)

                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .padding(12)

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal,18)
                    .padding(.vertical,8)

            }
            .frame(height: 155)
            .scaleEffect(0.98)
            .animation(
                .spring(
                    response:0.45,
                    dampingFraction:0.82
                ),
                value:image
            )
            .shadow(
                color: .black.opacity(0.03),
                radius: 12,
                y: 3
            )
            .onTapGesture {

                onTap()

            }
            

        }

    }
//    @ViewBuilder
//    func ImagePreview() -> some View {
//
//        if let image = selectedImage {
//
//            ZStack {
//
//                RoundedRectangle(cornerRadius:18)
//                    .fill(Color.gray.opacity(0.05))
//
//                Image(uiImage:image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth:180)
//
//            }
//            .frame(height:140)
//            .transition(
//                .move(edge:.top)
//                .combined(with:.opacity)
//            )
//
//        }
//
//    }
    
//    private func performSearch(_ keyword: String) {
//
//        products.removeAll()
//        isLoading = true
//        withAnimation(
//            .interactiveSpring(
//                response: 0.45,
//                dampingFraction: 0.86
//            )
//        ) {
//            showResult = true
//        }
//
//        print("""
//        =====================
//        FARO SEARCH
//        Keyword : \(keyword)
//        Mode : \(faroMode)
//        =====================
//        """)
//
//
//        FaroService.shared.search(
//            query: keyword,
//            mode: faroMode
//        ) { result in
//
//            print("🔥 CALLBACK")
//
//            DispatchQueue.main.async {
//
//                switch result {
//
//                case .success(let products):
//                    print("========== FaroService.shared.search ==========")
//                    print("FaroService.shared.search \(result)")
//                    print("===============================================")
//                    print("SUCCESS \(products.count)")
//                    let rawProducts = products.compactMap {
//                        $0 as? NSDictionary
//                    }
//
//                    let mappedProducts = rawProducts.map(FaroMapper.mapProduct)
//                    print(
//                        "FARO UI PRODUCTS: raw=\(products.count), " +
//                        "mapped=\(self.products.count)"
//                    )
//                    withAnimation(.easeInOut(duration: 0.25)) {
//                        self.products = mappedProducts
//
//                        print("Before =", self.isLoading)
//                        self.isLoading = false
//                        print("After =", self.isLoading)
//                        //                    self.showResult = true
//
//                    }
//
//                case .failure(let error):
//                    print("FAIL \(error)")
//                    let nsError = error as NSError
//
//                    print(error)
//                    CommonClass.showSnackBar(
//                            message: "Error \(nsError.code): \(nsError.localizedDescription)"
//                        )
//
//                    print("failure Before =", self.isLoading)
//                    self.isLoading = false
//                    print("failure After =", self.isLoading)
//                    fallbackCatalog(keyword)
//
//                    // TODO:
//                    // Fallback ไป Catalog API
//
//                }
//
//            }
//
//        }
//
//    }
    
    private func performSearch(
        _ keyword: String,
        inStockOnly: Bool = false
    ) {
        
        let text = keyword.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !text.isEmpty else {
            return
        }
        
        
        // Keep the current state
        self.inStockOnly = inStockOnly
        
        
        products.removeAll()
        isLoading = true
        
        withAnimation(
            .interactiveSpring(
                response: 0.45,
                dampingFraction: 0.86
            )
        ) {
            showResult = true
        }
        
        
        print("""
        
        ==========================
        FARO SEARCH
        ==========================
        Keyword     : \(text)
        Mode        : \(faroMode)
        InStockOnly : \(inStockOnly)
        ==========================
        
        """)
        
        
        FaroService.shared.search(
            query: text,
            mode: faroMode,
            inStockOnly: inStockOnly
        ) { result in
            
            print("🔥 FARO CALLBACK")
            
            DispatchQueue.main.async {
                
                switch result {
                    
                case .success(let products):
                    
                    print("""
                    
                    ==========================
                    FARO SUCCESS
                    ==========================
                    Raw Products : \(products.count)
                    InStockOnly  : \(inStockOnly)
                    ==========================
                    
                    """)
                    
                    
                    let rawProducts = products.compactMap {
                        $0 as? NSDictionary
                    }
                    
                    
                    let mappedProducts =
                        rawProducts.map(FaroMapper.mapProduct)
                    
                    
                    self.products = mappedProducts
                    
                    withAnimation(
                        .easeInOut(duration: 0.25)
                    ) {
                        self.isLoading = false
                    }
                    
                    
                case .failure(let error):
                    
                    print("""
                    
                    ==========================
                    FARO FAILED
                    ==========================
                    \(error.localizedDescription)
                    ==========================
                    
                    """)
                    
                    self.isLoading = false
                    
                    
                    let nsError = error as NSError
                    
                    CommonClass.showSnackBar(
                        message:
                            "Error \(nsError.code): " +
                            "\(nsError.localizedDescription)"
                    )
                    
                    self.fallbackCatalog(text)
                }
            }
        }
    }
    
    // MARK: - Voice Search Actions

    private func startVoiceInput() {

        guard !voiceInput.isListening else {
            return
        }

        // Capture the current layout BEFORE changing anything.
        // Voice Search must not move the Home screen.
        voiceStartedFromDiscovery = showDiscovery

        searchText = ""
        showSend = false
        showMic = false

        if voiceStartedFromDiscovery {
            // Discovery already has the compact search card at the top.
            // Keep it there.
            faroMode = .discover
            showDiscovery = true
            searchExpanded = true
        } else {
            // Home screen: DO NOT collapse HeroSection and DO NOT turn on
            // Discovery. VoiceSearchRow replaces the normal SearchRow in the
            // same SearchCard, so the card stays exactly where it was.
            faroMode = .search
            showDiscovery = false
            searchExpanded = false
        }

        // Do not auto-stop. The user explicitly presses X or the green
        // submit circle.
        voiceInput.start()
    }

    private func cancelVoiceInput() {

        voiceInput.cancel()

        // Cancel always clears the voice/search text as requested.
        searchText = ""
        showSend = false
        showMic = true

        // Return to the exact layout from which Voice Search was opened.
        if voiceStartedFromDiscovery {
            showDiscovery = true
            searchExpanded = true
            faroMode = .discover
        } else {
            showDiscovery = false
            searchExpanded = false
            faroMode = .search
        }

        voiceStartedFromDiscovery = false
    }

    private func confirmVoiceInput() {
        let finalText = voiceInput.recognizedText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !finalText.isEmpty, !isSubmittingVoice else {
            return
        }

        // Stop the microphone first. The checkmark then becomes the
        // short teal "submitted" pulse shown in the design.
        voiceInput.stop()

        isSubmittingVoice = true
        voiceSubmitScale = 0.82

        withAnimation(
            .easeInOut(duration: 0.22)
                .repeatCount(3, autoreverses: true)
        ) {
            voiceSubmitScale = 1.12
        }

        // Let the pulse be visible briefly, then close Voice Mode.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
            searchText = finalText
            showMic = false
            showSend = true

            isSubmittingVoice = false
            voiceSubmitScale = 1.0

            // Restore exactly the layout from which Voice Search started.
            if voiceStartedFromDiscovery {
                showDiscovery = true
                searchExpanded = true
                faroMode = .discover
            } else {
                showDiscovery = false
                searchExpanded = false
                faroMode = .search
            }

            voiceStartedFromDiscovery = false
        }
    }
    private func performImageSearch(
        _ image: UIImage
    ) {

        print("""
        ==========================
        IMAGE SEARCH
        ==========================
        """)

        guard let data = image.pngData() else {
            return
        }

        let requestID = UUID()
        imageSearchRequestID = requestID

        print("Image Size =", data.count)

        products.removeAll()

        isSearchingImage = true
        isLoading = true
        showResult = true

        FaroService.shared.searchImage(
            image: image
        ) { result in

            DispatchQueue.main.async {

                // Ignore an older image-search response if the user has
                // already changed the stock filter again.
                guard self.imageSearchRequestID == requestID else {
                    return
                }

                switch result {

                case .success(let products):

                    print("IMAGE SEARCH SUCCESS")
                    print("Products =", products.count)

                    let rawProducts = products.compactMap {
                        $0 as? NSDictionary
                    }

                    let mappedProducts = rawProducts.map(
                        FaroMapper.mapProduct
                    )

                    // Save only the unfiltered image-search result. This is
                    // the list we restore when In stock only is turned OFF.
                    if !self.inStockOnly {
                        self.cachedImageSearchProducts = mappedProducts
                    }

                    self.products = mappedProducts

                    self.isLoading = false
                    self.isSearchingImage = false

                case .failure(let error):

                    print("IMAGE SEARCH FAILED")
                    print(error)

                    self.isLoading = false
                    self.isSearchingImage = false

                }

            }

        }

    }
    
    private func fallbackCatalog(
        _ keyword: String
    ) {

        NotificationCenter.default.post(
            name: .faroSearch,
            object: keyword
        )

//        dismiss()

    }
    
    @ViewBuilder
    func RightActionView() -> some View {

        ZStack(alignment:.trailing){

            //--------------------------------
            // Send
            //--------------------------------

            Button {
                print("RightActionView")
                let keyword = searchText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                guard !keyword.isEmpty else {
                    return
                }

//                faroMode = .discover
//                performSearch(keyword)
                if let image = selectedImage {

                        performImageSearch(image)

                } else {

                    let keyword = searchText
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !keyword.isEmpty else {
                        return
                    }

//                    performSearch(keyword)
                    performSearch(
                        keyword,
                        inStockOnly: inStockOnly
                    )
                }

            } label: {

                Image("faro_enter")
                    .resizable()
                    .scaledToFit()
                    .frame(width:34,height:34)

            }
            .opacity(showSend ? 1 : 0)
            .offset(x:showSend ? 0 : 52)

            if !showDiscovery && selectedImage == nil {//if !showDiscovery {
                //--------------------------------
                // Discovery
                //--------------------------------

                Button{
                print("Discovery")
                    
                    withAnimation(
                        .spring(
                            response:0.52,
                            dampingFraction:0.86
                        )
                    ) {

                        faroMode = .discover
                        showDiscovery = true
                        searchExpanded = true

                    }
                
            }label:{

                Image("faro_search")
                    .resizable()
                    .scaledToFit()
                    .frame(width:100)

            }
            .padding(.trailing, 4)
            .offset(x:showSend ? -44 : 0)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

        }
        .frame(width:108,alignment:.trailing)
        .animation(
            .interactiveSpring(
                response:0.38,
                dampingFraction:0.82
            ),
            value:showSend
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: showDiscovery
        )

    }

    private func resetFaroHomeState() {
        voiceInput.cancel()
        hideKeyboard()

        isFocused = false
        imageSearchFocused = false

        selectedImage = nil
        imagePreviewExpanded = false
        isImageSearch = false
        showCloseButton = false

        searchText = ""
        selectedPrompt = nil
        faroMode = .search

        showDiscovery = false
        searchExpanded = false

        showSend = false
        showMic = true

        isSearchingImage = false
        isLoading = false
        showImageSearch = false
        showImagePicker = false
        showToast = false
        products.removeAll()
        selectedProducts.removeAll()
    }

    private func returnToFaroSearchHome() {

        voiceInput.cancel()
        hideKeyboard()

        isFocused = false
        imageSearchFocused = false

        withAnimation(
            .spring(
                response: 0.45,
                dampingFraction: 0.86
            )
        ) {
            selectedImage = nil
            imagePreviewExpanded = false
            isImageSearch = false
            showCloseButton = false

            searchText = ""
            selectedPrompt = nil
            faroMode = .search

            // Stay inside Faro. Only close Discovery and restore
            // the normal Faro search screen.
            showDiscovery = false
            searchExpanded = false

            showSend = false
            showMic = true

            isSearchingImage = false
            isLoading = false
            showImageSearch = false
            showImagePicker = false
            showToast = false
        }
    }

    private func closeScannerToHome() {

        voiceInput.cancel()

        hideKeyboard()

        isFocused = false
        imageSearchFocused = false

        withAnimation(
            .spring(
                response: 0.45,
                dampingFraction: 0.86
            )
        ) {

            // Return Faro to exactly the first-open state.
            selectedImage = nil
            imagePreviewExpanded = false
            isImageSearch = false
            showCloseButton = false

            searchText = ""
            selectedPrompt = nil
            faroMode = .search

            showDiscovery = false
            searchExpanded = false

            showSend = false
            showMic = true

            isSearchingImage = false
            isLoading = false
            showImageSearch = false
            showImagePicker = false
            showToast = false
            showResult = false
            products.removeAll()
            selectedProducts.removeAll()

        }

        onClose()

    }

    private func closeDiscovery() {
//        // X on Discovery with an empty search field must return to
//        // Faro's first/home screen, but MUST NOT dismiss Faro itself.
//        hideKeyboard()
//        isFocused = false
//        imageSearchFocused = false
//
//        withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
//            showDiscovery = false
//            searchExpanded = false
//            selectedPrompt = nil
//            faroMode = .search
//
//            searchText = ""
//            showSend = false
//            showMic = true
//        }
        
        voiceInput.cancel()

        hideKeyboard()

        isFocused = false
        imageSearchFocused = false

        withAnimation(
            .spring(
                response: 0.45,
                dampingFraction: 0.86
            )
        ) {

            // Return Faro to exactly the first-open state.
            selectedImage = nil
            imagePreviewExpanded = false
            isImageSearch = false
            showCloseButton = false

            searchText = ""
            selectedPrompt = nil
            faroMode = .search

            showDiscovery = false
            searchExpanded = false

            showSend = false
            showMic = true

            isSearchingImage = false
            isLoading = false
            showImageSearch = false
            showImagePicker = false
            showToast = false
            showResult = false
            products.removeAll()
            selectedProducts.removeAll()

        }

        onClose()
        
        
    }
    
//    private func closeDiscovery() {
//        withAnimation(
//            .spring(
//                response: 0.5,
//                dampingFraction: 0.86
//            )
//        ) {
//            showDiscovery = false
//            searchExpanded = false
//            selectedPrompt = nil
//            faroMode = .search
//        }
//    }
    
    @ViewBuilder
    private func rainbowGradient() -> some View {
        let rainbowColors: [Color] = [Color(
                                            red: 0.36,
                                            green: 0.54,
                                            blue: 1.0
                                        ),
                                        Color(
                                            red: 0.24,
                                            green: 0.92,
                                            blue: 0.95
                                        ), Color(
                                            red: 0.36,
                                            green: 0.54,
                                            blue: 1.0
                                        )]
        let gradientColors: [Color] = Array(repeating: rainbowColors, count: 2)
            .flatMap { $0 }

//        if !isFocused {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        angle: .degrees(360)//.degrees(isHighlighted ? 360 : 0)
                    ),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                )
//                .padding(-2)
//                .blur(radius: 3)
//        }
    }
}



struct AnimatedDiscoveryBorder: View {

    let cornerRadius: CGFloat

    @State
    private var progress: CGFloat = -0.25

    var body: some View {

        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                Color.white.opacity(0.18),
                lineWidth: 1
            )

            .overlay {

                RoundedRectangle(cornerRadius: cornerRadius)
//                    .trim(from: progress,
//                          to: progress + 0.12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.cyan,
                                Color.blue,
                                Color.purple,
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 2.4,
                            lineCap: .round
                        )
                    )
                    .shadow(color: .cyan.opacity(0.7), radius: 6)
                    .shadow(color: .blue.opacity(0.4), radius: 12)

            }

//            .onAppear {
//
//                progress = -0.25
//
//                withAnimation(
//                    .linear(duration: 1.3)
//                    .repeatForever(autoreverses: false)
//                ) {
//
//                    progress = 1.15
//
//                }
//
//            }

    }

}

extension UIView {

    func applyAnimatedGradientBorder(
            colors: [UIColor],
            lineWidth: CGFloat = 4.0,
            cornerRadius: CGFloat = 12.0
        ) {
    
            layer.sublayers?.removeAll(where: { $0.name == "animatedGradientBorder" })

            let gradientLayer = CAGradientLayer()
            gradientLayer.name = "animatedGradientBorder"
            gradientLayer.frame = bounds
            gradientLayer.colors = colors.map { $0.cgColor }
            
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            
            gradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0].map { NSNumber(value: $0) }

            let shape = CAShapeLayer()
            
            shape.path = UIBezierPath(
                roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
                cornerRadius: cornerRadius
            ).cgPath
            shape.lineWidth = lineWidth
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.lineCap = .round

            gradientLayer.mask = shape

            let animationDuration: CFTimeInterval = 4.0

            let startPointValues: [CGPoint] = [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 1, y: 1),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 0, y: 0)
            ]

            let endPointValues: [CGPoint] = [
                CGPoint(x: 1, y: 0),
                CGPoint(x: 1, y: 1),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0)
            ]

            let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
            startPointAnimation.values = startPointValues
            startPointAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0].map { NSNumber(value: $0) }
            startPointAnimation.duration = animationDuration
            startPointAnimation.repeatCount = .infinity
            startPointAnimation.calculationMode = .linear

            let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
            endPointAnimation.values = endPointValues
            endPointAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0].map { NSNumber(value: $0) }
            endPointAnimation.duration = animationDuration
            endPointAnimation.repeatCount = .infinity
            endPointAnimation.calculationMode = .linear

            gradientLayer.add(startPointAnimation, forKey: "shimmerStartPoint")
            gradientLayer.add(endPointAnimation, forKey: "shimmerEndPoint")

            layer.addSublayer(gradientLayer)
        }
}


//#if canImport(UIKit)
extension View {

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

}
//#endif  canImport(UIKit)

//#Preview {
//
//    FaroScannerView()
//
//}
