//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Tsz-Lung on 13/10/2023.
//

#if DEBUG
import UIKit
import EssentialFeedPractice

final class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        
        return super.makeRemoteClient()
    }
}

private final class DebuggingHTTPClient: HTTPClient {
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeSuccessfulResponse(for: url)))
        default:
            completion(.failure(NSError(domain: "offline", code: 0)))
        }
        return Task()
    }
    
    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case imageURL():
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            UIColor.red.setFill()
            rendererContext.fill(rect)
        }.pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": imageURL()],
            ["id": UUID().uuidString, "image": imageURL()]
        ]])
    }
    
    private func imageURL() -> String {
        "http://image.com"
    }
}
#endif
