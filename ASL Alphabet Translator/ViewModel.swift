//
//  ViewModel.swift
//  ASL Alphabet Translator
//
//  Created by Beniamino Gentile on 19/05/24.
//

import Foundation
import CoreImage
import Observation

@Observable
class ViewModel {
    var currentFrame: CGImage?
    private let cameraManager = CameraManager()
    
    init() {
        Task {
            await handleCameraPreviews()
        }
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task { @MainActor in
                currentFrame = image
            }
        }
    }
}
