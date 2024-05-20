//
//  ContentView.swift
//  ASL Alphabet Translator
//
//  Created by Beniamino Gentile on 19/05/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @StateObject var handPoseClassifier = CameraManager()
    
    var body: some View {
        CameraView(image: $viewModel.currentFrame)
        Text(handPoseClassifier.handPrediction ?? "Unknown")
            .padding()
        Text(handPoseClassifier.predictionResult ?? "Unknown")
            .padding()
        
        if let errorMessage = handPoseClassifier.errorMessage {
            Text(errorMessage)
                .padding()
        }
    }

}

#Preview {
    ContentView()
}
