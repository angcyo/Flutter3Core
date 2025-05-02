# receive_sharing_intent_plus

https://pub.dev/packages/receive_sharing_intent_plus

# Setup (iOS)

共`7`步;

https://pub.dev/packages/receive_sharing_intent_plus#setup-ios

## 1. Update `Info.plist`

Add following inside `ios/Runner/info.plist`, 注意`CUSTOM_GROUP_ID`变量, 第`4`步中需要配置.

```xml
<key>AppGroupId</key>
<string>$(CUSTOM_GROUP_ID)</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>ShareMedia-$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    </array>
  </dict>
</array>
<key>NSPhotoLibraryUsageDescription</key>
<string>To upload photos, please allow permission to access your photo library.</string>
```

## 2. Create Share Extension Target

- 2.1 Using XCode, go to `File` -> `New` -> `Target` -> and Choose `Share Extension`
- 2.2 Give it a name i.e. `Share Extension`
- 2.3 Choose language as `Swift`

> Note: Make sure the `iOS Deployment Target` is SAME for both the `Runner` and `Share Extension` targets.

## 3. Add `Runner` and `Share Extension` in the same group
 
- 3.1 Select the `Runner target` and go to the `Signing & Capabilities` tab.
- 3.2 `Click` on the `+ Capability` button and add the `App Groups` capability.
- 3.3 Add a new group `App Groups` and name it as you want. For example `group.YOUR_HOST_APP_BUNDLE_IDENTIFIER` in my case `group.rocks.outdatedguy.receiveSharingIntentPlusExample`.
- 3.4 Do the same for the `Share Extension` target.

## 4. Add User-Defined Settings 

- 4.1 Select the `Runner` target and go to the `Build Settings` tab.
- 4.2 Click on the `+` button and add a new `User-Defined Setting`.
- 4.3 Name it as `CUSTOM_GROUP_ID` and set the value defined in `Step 3` (Above Step).
- 4.4 Do the same for the `Share Extension` target.

## 5. Configure `Share Extension` Target `Info.plist`

Update the `ios/Share Extension/info.plist` with the code below.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AppGroupId</key>
  <string>$(CUSTOM_GROUP_ID)</string>
  <key>NSExtension</key>
  <dict>
    <key>NSExtensionAttributes</key>
    <dict>
      <key>PHSupportedMediaTypes</key>
      <array>
        <!-- TODO: Add this flag, if you want to support sharing video into your app -->
        <string>Video</string>
        <!-- TODO: Add this flag, if you want to support sharing images into your app -->
        <string>Image</string>
      </array>
      <key>NSExtensionActivationRule</key>
      <dict>
        <!-- TODO: Add this flag, if you want to support sharing text into your app -->
        <key>NSExtensionActivationSupportsText</key>
        <true/>
        <!-- TODO: Add this tag, if you want to support sharing urls into your app -->
        <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
        <integer>1</integer>
        <!-- TODO: Add this flag, if you want to support sharing images into your app -->
        <key>NSExtensionActivationSupportsImageWithMaxCount</key>
        <integer>100</integer>
        <!-- TODO: Add this flag, if you want to support sharing video into your app -->
        <key>NSExtensionActivationSupportsMovieWithMaxCount</key>
        <integer>100</integer>
        <!-- TODO: Add this flag, if you want to support sharing other files into your app -->
        <!-- TODO: Change the integer to however many files you want to be able to share at a time -->
        <key>NSExtensionActivationSupportsFileWithMaxCount</key>
        <integer>1</integer>
      </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
  </dict>
</dict>
</plist>
```

If you wish to support `opening urls` into your app, add the following to the `ios/Runner/Runner.entitlements` file.

```xml
<!--TODO:  Add this tag, if you want support opening urls into your app-->
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:example.com</string>
</array>
```

上述配置需要`Apple ID`开启了`Associated Domains`功能, 才能使用.否则报错:

> Provisioning profile "iOS Team Provisioning Profile: com.laser.abc.beeb" doesn't support the Associated Domains capability.

## 6. Configure `Share Extension` Target `Working`

Update the whole `ios/Share Extension/ShareViewController.swift` file with the code below.

```swift
import UIKit
import Social
import MobileCoreServices
import Photos

class ShareViewController: SLComposeServiceViewController {
    var hostAppBundleIdentifier = ""
    var appGroupId = ""
    let sharedKey = "ShareKey"
    var sharedMedia: [SharedMediaFile] = []
    var sharedText: [String] = []
    let imageContentType = kUTTypeImage as String
    let videoContentType = kUTTypeMovie as String
    let textContentType = kUTTypeText as String
    let urlContentType = kUTTypeURL as String
    let fileURLType = kUTTypeFileURL as String

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    private func loadIds() {
        // loading Share extension App Id
        let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!

        // convert ShareExtension id to host app id
        // By default it is removed the last part of id after the last point
        // For example: com.test.ShareExtension -> com.test
        if let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".") {
            hostAppBundleIdentifier = String(shareExtensionAppBundleIdentifier[..<lastIndexOfPoint])
        }

        // loading custom AppGroupId from Build Settings or use group.<hostAppBundleIdentifier>
        appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(hostAppBundleIdentifier)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // load group and app id from build info
        loadIds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        if let content = extensionContext?.inputItems[0] as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in contents.enumerated() {
                    if attachment.hasItemConformingToTypeIdentifier(imageContentType) {
                        handleImages(content: content, attachment: attachment, index: index)
                    } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                        handleText(content: content, attachment: attachment, index: index)
                    } else if attachment.hasItemConformingToTypeIdentifier(fileURLType) {
                        handleFiles(content: content, attachment: attachment, index: index)
                    } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                        handleUrl(content: content, attachment: attachment, index: index)
                    } else if attachment.hasItemConformingToTypeIdentifier(videoContentType) {
                        handleVideos(content: content, attachment: attachment, index: index)
                    }
                }
            }
        }
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.

        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

    private func handleText(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in

            if error == nil, let item = data as? String, let this = self {

                this.sharedText.append(item)

                // If this is the last item, save imagesData in userDefaults and redirect to the host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .text)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleUrl(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: urlContentType, options: nil) { [weak self] data, error in

            if error == nil, let item = data as? URL, let this = self {

                this.sharedText.append(item.absoluteString)

                // If this is the last item, save imagesData in userDefaults and redirect to the host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.sharedText, forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .text)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleImages(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: imageContentType, options: nil) { [weak self] data, error in

            if error == nil, let url = data as? URL, let this = self {

                // Always copy
                let fileName = this.getFileName(from: url, type: .image)
                let newPath = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                    .appendingPathComponent(fileName)
                let copied = this.copyFile(at: url, to: newPath)
                if copied {
                    this.sharedMedia.append(SharedMediaFile(path: newPath.absoluteString, thumbnail: nil, duration: nil, type: .image))
                }

                // If this is the last item, save imagesData in userDefaults and redirect to the host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .media)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleVideos(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: videoContentType, options: nil) { [weak self] data, error in

            if error == nil, let url = data as? URL, let this = self {

                // Always copy
                let fileName = this.getFileName(from: url, type: .video)
                let newPath = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                    .appendingPathComponent(fileName)
                let copied = this.copyFile(at: url, to: newPath)
                if copied {
                    guard let sharedFile = this.getSharedMediaFile(forVideo: newPath) else {
                        return
                    }
                    this.sharedMedia.append(sharedFile)
                }

                // If this is the last item, save imagesData in userDefaults and redirect to the host app
                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .media)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func handleFiles(content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: fileURLType, options: nil) { [weak self] data, error in

            if error == nil, let url = data as? URL, let this = self {

                // Always copy
                let fileName = this.getFileName(from: url, type: .file)
                let newPath = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: this.appGroupId)!
                    .appendingPathComponent(fileName)
                let copied = this.copyFile(at: url, to: newPath)
                if copied {
                    this.sharedMedia.append(SharedMediaFile(path: newPath.absoluteString, thumbnail: nil, duration: nil, type: .file))
                }

                if index == (content.attachments?.count)! - 1 {
                    let userDefaults = UserDefaults(suiteName: this.appGroupId)
                    userDefaults?.set(this.toData(data: this.sharedMedia), forKey: this.sharedKey)
                    userDefaults?.synchronize()
                    this.redirectToHostApp(type: .file)
                }

            } else {
                self?.dismissWithError()
            }
        }
    }

    private func dismissWithError() {
        print("[ERROR] Error loading data!")
        let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func redirectToHostApp(type: RedirectType) {
        // ids may not be loaded yet so we need loadIds here too
        loadIds()
        let url = URL(string: "ShareMedia-\(hostAppBundleIdentifier)://dataUrl=\(sharedKey)#\(type)")
        var responder = self as UIResponder?

        while (responder != nil) {
            if let application = responder as? UIApplication {
                application.open(url!, options: [:], completionHandler: nil)
            }
            responder = responder?.next
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    enum RedirectType {
        case media
        case text
        case file
    }

    func getExtension(from url: URL, type: SharedMediaType) -> String {
        let parts = url.lastPathComponent.components(separatedBy: ".")
        var ex: String? = nil
        if (parts.count > 1) {
            ex = parts.last
        }

        if (ex == nil) {
            switch type {
            case .image:
                ex = "PNG"
            case .video:
                ex = "MP4"
            case .file:
                ex = "TXT"
            }
        }
        return ex ?? "Unknown"
    }

    func getFileName(from url: URL, type: SharedMediaType) -> String {
        var name = url.lastPathComponent

        if (name.isEmpty) {
            name = UUID().uuidString + "." + getExtension(from: url, type: type)
        }

        return name
    }

    func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }

    private func getSharedMediaFile(forVideo: URL) -> SharedMediaFile? {
        let asset = AVAsset(url: forVideo)
        let duration = (CMTimeGetSeconds(asset.duration) * 1000).rounded()
        let thumbnailPath = getThumbnailPath(for: forVideo)

        if FileManager.default.fileExists(atPath: thumbnailPath.path) {
            return SharedMediaFile(path: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video)
        }

        var saved = false
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize =  CGSize(width: 360, height: 360)
        do {
            let img = try assetImgGenerate.copyCGImage(at: CMTimeMakeWithSeconds(600, preferredTimescale: Int32(1.0)), actualTime: nil)
            try UIImage.pngData(UIImage(cgImage: img))()?.write(to: thumbnailPath)
            saved = true
        } catch {
            saved = false
        }

        return saved ? SharedMediaFile(path: forVideo.absoluteString, thumbnail: thumbnailPath.absoluteString, duration: duration, type: .video) : nil
    }

    private func getThumbnailPath(for url: URL) -> URL {
        let fileName = Data(url.lastPathComponent.utf8).base64EncodedString().replacingOccurrences(of: "==", with: "")
        let path = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupId)!
            .appendingPathComponent("\(fileName).jpg")
        return path
    }

    class SharedMediaFile: Codable {
        var path: String
        var thumbnail: String?
        var duration: Double?
        var type: SharedMediaType

        init(path: String, thumbnail: String?, duration: Double?, type: SharedMediaType) {
            self.path = path
            self.thumbnail = thumbnail
            self.duration = duration
            self.type = type
        }

        func toString() {
            print("[SharedMediaFile] \n\tpath: \(self.path)\n\tthumbnail: \(self.thumbnail)\n\tduration: \(self.duration)\n\ttype: \(self.type)")
        }
    }

    enum SharedMediaType: Int, Codable {
        case image
        case video
        case file
    }

    func toData(data: [SharedMediaFile]) -> Data {
        let encodedData = try? JSONEncoder().encode(data)
        return encodedData ?? Data()
    }
}

extension Array {
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
```

## 7. Update `Build Phases`

> 这一步很重要.

To avoid below error, select the `Runner` target and go to the `Build Phases` tab. 
Then drag and move the `Embed Foundation Extensions` phase above the `Thin Binary` phase.

**Error**

```
Error (Xcode): Cycle inside Runner; building could produce unreliable results.
Cycle details:
→ Target 'Runner': ExtractAppIntentsMetadata
○ Target 'Runner' has copy command from 'receive_sharing_intent_plus/example/build/ios/Debug-iphonesimulator/Share Extension.appex' to 'receive_sharing_intent_plus/example/build/ios/Debug-iphonesimulator/Runner.app/PlugIns/Share Extension.appex'
○ That command depends on command in Target 'Runner': script phase “Thin Binary”
○ Target 'Runner' has process command with output 'receive_sharing_intent_plus/example/build/ios/Debug-iphonesimulator/Runner.app/Info.plist'
○ Target 'Runner' has copy command from 'receive_sharing_intent_plus/example/build/ios/Debug-iphonesimulator/Share Extension.appex' to 'receive_sharing_intent_plus/example/build/ios/Debug-iphonesimulator/Runner.app/PlugIns/Share Extension.appex'
```

