//
//  SoundService.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 21.12.2021.
//

import Foundation
import AVFoundation

protocol SoundServicing: AnyObject {
    func playRoll()
    func playBackground()
}

class SoundService: SoundServicing {
    private var audioPlayer: AVAudioPlayer?
    
    func playBackground() {
        playSound("background", "mp3")
    }
    
    func playRoll() {
        playSound("roll", "mp3")
    }

    private func playSound(_ name: String, _ ext: String) {
        let path = Bundle.main.path(forResource: name, ofType: ext)!
        let url = URL(fileURLWithPath: path)

        audioPlayer?.stop()
        audioPlayer = try! .init(contentsOf: url, fileTypeHint: ext)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
    }
}
