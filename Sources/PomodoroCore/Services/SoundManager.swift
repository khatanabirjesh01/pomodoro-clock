import Foundation
import AppKit

public final class SoundManager: @unchecked Sendable {
    public static let shared = SoundManager()
    
    public static let availableSounds: [String] = [
        "Glass",
        "Ping",
        "Hero",
        "Blow",
        "Purr",
        "Submarine",
        "Sosumi",
        "Morse",
        "Tink",
        "Basso",
        "Pop"
    ]
    
    private init() {}
    
    public func playSound(named soundName: String) {
        DispatchQueue.main.async {
            if let sound = NSSound(named: NSSound.Name(soundName)) {
                sound.stop()
                sound.play()
            } else {
                NSSound.beep()
            }
        }
    }
    
    public func playBeep() {
        DispatchQueue.main.async {
            NSSound.beep()
        }
    }
}
