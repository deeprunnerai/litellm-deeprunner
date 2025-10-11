import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar with Edit menu
        setupMenuBar()

        // Create window
        let contentRect = NSRect(x: 0, y: 0, width: 1400, height: 900)
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "LiteLLM DeepRunner"
        window.center()

        // Create web view with enhanced configuration
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Enable persistent data store for credentials/cookies
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        // Use default process pool to enable credential sharing
        webConfiguration.processPool = WKProcessPool()

        // Enable data detector types for better interaction
        if #available(macOS 10.15, *) {
            webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        }

        webView = WKWebView(frame: contentRect, configuration: webConfiguration)

        // Allow magnification for better UX
        webView.allowsMagnification = true

        // Enable autofill
        if #available(macOS 13.3, *) {
            webView.configuration.preferences.isElementFullscreenEnabled = true
        }

        // Load URL
        if let url = URL(string: "https://prod.litellm.deeprunner.ai/ui") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        window.contentView = webView
        window.makeKeyAndOrderFront(nil)

        // Make web view first responder for autofill
        window.makeFirstResponder(webView)

        // Keep window on top at launch
        NSApp.activate(ignoringOtherApps: true)
    }

    func setupMenuBar() {
        let mainMenu = NSMenu()

        // App Menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(NSMenuItem(title: "Quit LiteLLM DeepRunner", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // Edit Menu
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu

        editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))

        NSApp.mainMenu = mainMenu
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// Create and run app
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
