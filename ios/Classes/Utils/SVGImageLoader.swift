import UIKit
import SVGKit
import Flutter

/// Centralized SVG image loading utility with caching and error handling
final class SVGImageLoader {
    
    // MARK: - Singleton
    static let shared = SVGImageLoader()
    
    // MARK: - Properties
    private let cache = NSCache<NSString, UIImage>()
    private let preloadQueue = DispatchQueue(label: "svg.preload", qos: .userInitiated)
    private var isInitialized = false
    
    // MARK: - Initialization
    private init() {
        setupCache()
        preloadSVGKit()
    }
    
    // MARK: - Public API
    
    /// Load SVG image from Flutter asset path
    /// - Parameters:
    ///   - assetPath: Flutter asset path (e.g., "assets/icons/home.svg")
    ///   - size: Desired size for the SVG
    /// - Returns: Rendered UIImage or nil if failed
    func loadSVG(from assetPath: String, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        let cacheKey = "\(assetPath)_\(size.width)x\(size.height)" as NSString
        
        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from bundle
        guard let image = loadSVGFromBundle(assetPath: assetPath, size: size) else {
            return nil
        }
        
        // Cache successful result
        cache.setObject(image, forKey: cacheKey)
        return image
    }
    
    /// Load SVG image from raw data
    /// - Parameters:
    ///   - data: SVG data bytes
    ///   - size: Desired size for the SVG
    /// - Returns: Rendered UIImage or nil if failed
    func loadSVG(from data: Data, size: CGSize = CGSize(width: 24, height: 24)) -> UIImage? {
        let cacheKey = "data_\(data.hashValue)_\(size.width)x\(size.height)" as NSString
        
        // Check cache first
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from data
        guard let image = loadSVGFromData(data: data, size: size) else {
            return nil
        }
        
        // Cache successful result
        cache.setObject(image, forKey: cacheKey)
        return image
    }
    
    /// Preload SVG assets for better performance
    /// - Parameter assetPaths: Array of asset paths to preload
    func preloadAssets(_ assetPaths: [String]) {
        preloadQueue.async { [weak self] in
            for path in assetPaths {
                _ = self?.loadSVG(from: path)
            }
        }
    }
    
    /// Preload SVG assets from a list of paths (useful for dynamic preloading)
    /// - Parameter assetPaths: Array of asset paths to preload
    func preloadAssetsFromPaths(_ assetPaths: [String]) {
        guard !assetPaths.isEmpty else { return }
        preloadAssets(assetPaths)
    }
    
    /// Clear the image cache
    func clearCache() {
        cache.removeAllObjects()
    }
    
    // MARK: - Private Methods
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    private func preloadSVGKit() {
        guard !isInitialized else { return }
        
        preloadQueue.async { [weak self] in
            // Create a dummy SVG to initialize SVGKit
            let dummySVG = """
            <svg width="1" height="1" viewBox="0 0 1 1" xmlns="http://www.w3.org/2000/svg">
                <rect width="1" height="1" fill="transparent"/>
            </svg>
            """
            
            if let data = dummySVG.data(using: .utf8) {
                _ = SVGKImage(data: data)
                self?.isInitialized = true
            }
        }
    }
    
    private func loadSVGFromBundle(assetPath: String, size: CGSize) -> UIImage? {
        let flutterKey = FlutterDartProject.lookupKey(forAsset: assetPath)
        
        guard let path = Bundle.main.path(forResource: flutterKey, ofType: nil) else {
            return nil
        }
        
        return loadSVGFromFile(path: path, size: size)
    }
    
    private func loadSVGFromData(data: Data, size: CGSize) -> UIImage? {
        guard let svgImage = SVGKImage(data: data) else {
            return nil
        }
        
        return renderSVGImage(svgImage, size: size)
    }
    
    private func loadSVGFromFile(path: String, size: CGSize) -> UIImage? {
        guard let svgImage = SVGKImage(contentsOfFile: path) else {
            return nil
        }
        
        return renderSVGImage(svgImage, size: size)
    }
    
    private func renderSVGImage(_ svgImage: SVGKImage, size: CGSize) -> UIImage? {
        // Ensure we're on the main thread for SVG rendering
        if Thread.isMainThread {
            return performSVGRendering(svgImage, size: size)
        } else {
            var result: UIImage?
            DispatchQueue.main.sync {
                result = performSVGRendering(svgImage, size: size)
            }
            return result
        }
    }
    
    private func performSVGRendering(_ svgImage: SVGKImage, size: CGSize) -> UIImage? {
        // Set the desired size
        svgImage.size = size
        
        // Force immediate rendering
        let uiImage = svgImage.uiImage
        
        // If still nil, try alternative approach
        if uiImage == nil {
            // Sometimes SVGKit needs the size to be set again
            svgImage.size = size
            return svgImage.uiImage
        }
        
        return uiImage
    }
}

// MARK: - Convenience Extensions

extension SVGImageLoader {
    
    /// Load SVG with default 24x24 size
    func loadSVG(from assetPath: String) -> UIImage? {
        return loadSVG(from: assetPath, size: CGSize(width: 24, height: 24))
    }
    
    /// Load SVG with default 24x24 size from data
    func loadSVG(from data: Data) -> UIImage? {
        return loadSVG(from: data, size: CGSize(width: 24, height: 24))
    }
}
