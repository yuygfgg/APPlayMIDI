import Cocoa
import AVFoundation

class SettingsWindowController: NSWindowController {
    
    @IBOutlet weak var soundbankPathLabel: NSTextField!
    @IBOutlet weak var browseSoundbankButton: NSButton!
    @IBOutlet weak var resetSoundbankButton: NSButton!
    @IBOutlet weak var testSoundbankButton: NSButton!
    
    private let settingsManager = SettingsManager.shared
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Set window title
        window?.title = "Preferences"
        
        // Delay UI update to ensure outlets are connected
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    private func updateUI() {
        if let soundbankPath = settingsManager.soundbankPath {
            soundbankPathLabel.stringValue = soundbankPath
            resetSoundbankButton.isEnabled = true
            testSoundbankButton.isEnabled = true
        } else {
            soundbankPathLabel.stringValue = "No soundbank file selected (using system default)"
            resetSoundbankButton.isEnabled = false
            testSoundbankButton.isEnabled = false
        }
    }
    
    @IBAction func browseSoundbank(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Soundbank File"
        openPanel.message = "Please select an SF2 or DLS soundbank file"
        openPanel.allowedFileTypes = ["sf2", "dls"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            if settingsManager.validateSoundbankFile(at: url) {
                settingsManager.soundbankPath = url.path
                updateUI()
                
                // Show success alert
                let alert = NSAlert()
                alert.messageText = "Soundbank Set Successfully"
                alert.informativeText = "The soundbank file has been set. Please reopen MIDI files for changes to take effect."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            } else {
                // Show error alert
                let alert = NSAlert()
                alert.messageText = "Invalid Soundbank File"
                alert.informativeText = "Please select a valid SF2 or DLS soundbank file."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    @IBAction func resetSoundbank(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Reset Soundbank Settings"
        alert.informativeText = "Are you sure you want to reset soundbank settings and use the system default soundbank?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            settingsManager.resetSoundbank()
            updateUI()
            
            // Show reset success alert
            let successAlert = NSAlert()
            successAlert.messageText = "Reset Successful"
            successAlert.informativeText = "Reset to system default soundbank. Please reopen MIDI files for changes to take effect."
            successAlert.alertStyle = .informational
            successAlert.addButton(withTitle: "OK")
            successAlert.runModal()
        }
    }
    
    @IBAction func testSoundbank(_ sender: Any) {
        guard let soundbankURL = settingsManager.soundbankURL else {
            return
        }
        
        // Simple test to check if soundbank can be loaded
        do {
            // Create simple MIDI data for testing
            let testMIDIData = createTestMIDIData()
            let _ = try AVMIDIPlayer(data: testMIDIData, soundBankURL: soundbankURL)
            
            let alert = NSAlert()
            alert.messageText = "Soundbank Test Successful"
            alert.informativeText = "The current soundbank file can be used normally."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Soundbank Test Failed"
            alert.informativeText = "The soundbank file may be corrupted or incompatible: \(error.localizedDescription)"
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    // Create simple test MIDI data
    private func createTestMIDIData() -> Data {
        // Create a simple MIDI file header and a simple note
        let midiHeader: [UInt8] = [
            0x4D, 0x54, 0x68, 0x64, // "MThd"
            0x00, 0x00, 0x00, 0x06, // Header length
            0x00, 0x00, // Format type 0
            0x00, 0x01, // Number of tracks
            0x00, 0x60, // Time division (96 ticks per quarter note)
            0x4D, 0x54, 0x72, 0x6B, // "MTrk"
            0x00, 0x00, 0x00, 0x0B, // Track length
            0x00, 0x90, 0x3C, 0x40, // Note on: Middle C, velocity 64
            0x60, 0x80, 0x3C, 0x40, // Note off: Middle C
            0x00, 0xFF, 0x2F, 0x00  // End of track
        ]
        return Data(midiHeader)
    }
} 