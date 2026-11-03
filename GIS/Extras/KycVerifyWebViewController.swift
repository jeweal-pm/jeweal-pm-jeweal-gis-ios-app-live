//
//  KycVerifyWebViewController.swift
//  GIS
//
//  In-app web view for the Ondato KYC verification opened from the customer profile.
//

import UIKit
import WebKit

final class KycVerifyWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private let startURL: URL
    private let webView: WKWebView
    private let loader = UIActivityIndicatorView(style: .large)
    
    /// The same user agent Mobile Safari sends on this device and iOS version.
    static func safariUserAgent(
        systemVersion: String = UIDevice.current.systemVersion,
        isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    ) -> String {
        let osVersion = systemVersion.replacingOccurrences(of: ".", with: "_")
        let device = isPad ? "iPad; CPU OS \(osVersion)" : "iPhone; CPU iPhone OS \(osVersion)"
        return "Mozilla/5.0 (\(device) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) "
            + "Version/\(systemVersion) Mobile/15E148 Safari/604.1"
    }
    
    /// Ondato page for one verification: `<base>?id=<verification id>`.
    static func verifyURL(id: String, base: String = mOndatoVerifyUrl) -> URL? {
        let verificationId = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !verificationId.isEmpty, var components = URLComponents(string: base) else { return nil }
        components.queryItems = [URLQueryItem(name: "id", value: verificationId)]
        return components.url
    }
    
    /// Page to open from the `create-kyc` response `data`: its `url`, or one built from its `id`.
    static func verifyURL(from data: NSDictionary) -> URL? {
        if let urlString = data["url"] as? String,
           let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
           url.scheme?.lowercased() == "https" {
            return url
        }
        if let id = data["id"] as? String {
            return verifyURL(id: id)
        }
        return nil
    }
    
    init(url: URL) {
        startURL = url
        
        let configuration = WKWebViewConfiguration()
        // Identity verification needs the camera inside the page.
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: .zero, configuration: configuration)
        // Ondato checks the browser name, and the default web view user agent has no
        // "Version/x Safari/x" part, so it answers "your browser is not supported".
        webView.customUserAgent = Self.safariUserAgent()
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Verify".localizedString
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        view.addSubview(loader)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        webView.load(URLRequest(url: startURL))
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loader.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoadError(error)
    }
    
    private func showLoadError(_ error: Error) {
        loader.stopAnimating()
        // A cancelled load (e.g. a redirect) is not a failure.
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        CommonClass.showSnackBar(message: "OOP's something went wrong!")
    }
    
    // MARK: - WKUIDelegate
    
    /// Links that ask for a new window are opened in the same web view.
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    /// Lets the verification page use the camera (and microphone) once the
    /// system permission has been granted to the app.
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
}
