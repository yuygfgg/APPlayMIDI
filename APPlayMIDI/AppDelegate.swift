//
//  AppDelegate.swift
//  APPlayMIDI
//
//  Created by Ben on 20/08/2019.
//  Copyright © 2019 Ben. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var settingsWindowController: SettingsWindowController?

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        setupMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func setupMenu() {
        // Get main menu
        guard let mainMenu = NSApplication.shared.mainMenu else { return }
        
        // Find application menu (first menu item)
        guard let appMenuItem = mainMenu.items.first,
              let appMenu = appMenuItem.submenu else { return }
        
        // Add separator and preferences menu item after "About" menu item
        let aboutIndex = appMenu.indexOfItem(withTitle: "About APPlayMIDI")
        if aboutIndex != -1 {
            // Add separator
            let separator = NSMenuItem.separator()
            appMenu.insertItem(separator, at: aboutIndex + 1)
            
            // Add preferences menu item
            let settingsItem = NSMenuItem(title: "Preferences...", action: #selector(showSettings), keyEquivalent: ",")
            settingsItem.target = self
            appMenu.insertItem(settingsItem, at: aboutIndex + 2)
        }
    }
    
    @objc private func showSettings() {
        if settingsWindowController == nil {
            // Create settings window
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
                                styleMask: [.titled, .closable],
                                backing: .buffered,
                                defer: false)
            window.title = "Preferences"
            window.center()
            
            settingsWindowController = SettingsWindowController(window: window)
            
            // Create settings view and set outlets
            let settingsView = createSettingsView(for: settingsWindowController!)
            window.contentView = settingsView
        }
        
        settingsWindowController?.showWindow(self)
        settingsWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    private func createSettingsView(for controller: SettingsWindowController) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
        
        // Create title label
        let titleLabel = NSTextField(labelWithString: "Soundbank Settings")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.frame = NSRect(x: 20, y: 240, width: 460, height: 25)
        view.addSubview(titleLabel)
        
        // Create description label
        let descriptionLabel = NSTextField(labelWithString: "Select a custom SF2 or DLS soundbank file to improve MIDI playback quality:")
        descriptionLabel.font = NSFont.systemFont(ofSize: 12)
        descriptionLabel.frame = NSRect(x: 20, y: 210, width: 460, height: 20)
        view.addSubview(descriptionLabel)
        
        // Create current path label
        let pathLabel = NSTextField(labelWithString: "Current soundbank:")
        pathLabel.font = NSFont.systemFont(ofSize: 12)
        pathLabel.frame = NSRect(x: 20, y: 180, width: 120, height: 20)
        view.addSubview(pathLabel)
        
        // Create path display label
        let soundbankPathLabel = NSTextField(labelWithString: "No soundbank file selected (using system default)")
        soundbankPathLabel.font = NSFont.systemFont(ofSize: 11)
        soundbankPathLabel.textColor = .secondaryLabelColor
        soundbankPathLabel.isEditable = false
        soundbankPathLabel.isBordered = false
        soundbankPathLabel.backgroundColor = .clear
        soundbankPathLabel.frame = NSRect(x: 20, y: 150, width: 460, height: 40)
        soundbankPathLabel.cell?.wraps = true
        view.addSubview(soundbankPathLabel)
        
        // Create buttons
        let browseButton = NSButton(title: "Browse...", target: controller, action: #selector(SettingsWindowController.browseSoundbank(_:)))
        browseButton.frame = NSRect(x: 20, y: 80, width: 100, height: 32)
        browseButton.bezelStyle = .rounded
        view.addSubview(browseButton)
        
        let testButton = NSButton(title: "Test", target: controller, action: #selector(SettingsWindowController.testSoundbank(_:)))
        testButton.frame = NSRect(x: 130, y: 80, width: 100, height: 32)
        testButton.bezelStyle = .rounded
        view.addSubview(testButton)
        
        let resetButton = NSButton(title: "Reset", target: controller, action: #selector(SettingsWindowController.resetSoundbank(_:)))
        resetButton.frame = NSRect(x: 240, y: 80, width: 100, height: 32)
        resetButton.bezelStyle = .rounded
        view.addSubview(resetButton)
        
        // Create note label
        let noteLabel = NSTextField(labelWithString: "Note: MIDI files need to be reopened after changing soundbank settings.")
        noteLabel.font = NSFont.systemFont(ofSize: 10)
        noteLabel.textColor = .tertiaryLabelColor
        noteLabel.frame = NSRect(x: 20, y: 40, width: 460, height: 20)
        view.addSubview(noteLabel)
        
        // Connect outlets
        controller.soundbankPathLabel = soundbankPathLabel
        controller.browseSoundbankButton = browseButton
        controller.resetSoundbankButton = resetButton
        controller.testSoundbankButton = testButton
        
        return view
    }
}

