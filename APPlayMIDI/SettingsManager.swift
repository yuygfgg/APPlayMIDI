import Foundation
import AVFoundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let soundbankPathKey = "SoundbankPath"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    /// Get current selected soundbank path
    var soundbankPath: String? {
        get {
            let path = userDefaults.string(forKey: soundbankPathKey)
            // Verify file exists
            if let path = path, FileManager.default.fileExists(atPath: path) {
                return path
            }
            return nil
        }
        set {
            userDefaults.set(newValue, forKey: soundbankPathKey)
        }
    }
    
    /// Get soundbank URL
    var soundbankURL: URL? {
        guard let path = soundbankPath else { return nil }
        return URL(fileURLWithPath: path)
    }
    
    /// Validate if soundbank file is valid
    func validateSoundbankFile(at url: URL) -> Bool {
        let path = url.path
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: path) else {
            return false
        }
        
        // Check file extension
        let fileExtension = url.pathExtension.lowercased()
        return fileExtension == "sf2" || fileExtension == "dls"
    }
    
    /// Reset soundbank settings
    func resetSoundbank() {
        userDefaults.removeObject(forKey: soundbankPathKey)
    }
} 