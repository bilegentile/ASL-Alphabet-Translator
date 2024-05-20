//
//  CameraManager.swift
//  ASL Alphabet Translator
//
//  Created by Beniamino Gentile on 19/05/24.
//

import Foundation
import AVFoundation
import Vision

class CameraManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(for: .video)
    private var sessionQueue = DispatchQueue(label: "video.preview.session")
    
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let handPoseClassifier : ASLHandClassifier
    
    @Published var handPrediction: String?
    @Published var predictionResult: String?
    @Published var errorMessage: String?
    
    
    
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
    
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    
    override init() {
        do {
            handPoseClassifier = try ASLHandClassifier(configuration: MLModelConfiguration())
            
            super.init()
            
            Task {
                await configureSession()
                await startSession()
            }
        } catch {
            fatalError("Failed to load MLModel")
        }
    }

    private func configureSession() async {
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
        else { return }
        
        captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        guard captureSession.canAddInput(deviceInput) else {
            print("Unable to add device input to capture session.")
            return
        }
        
        guard captureSession.canAddOutput(videoOutput) else {
            print("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
    }
    
    private func startSession() async {
        /// Checking authorization
        guard await isAuthorized else { return }
        /// Start the capture session flow of data
        captureSession.startRunning()
    }

}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Hand Pose Request failed: \(error)")
        }
        
        guard let handObservation = handPoseRequest.results?.first else {
            return
        }
        
        guard let keypointsMultiArray = try? handObservation.keypointsMultiArray()
        else { fatalError() }
        
        do {
            let handPosePrediction = try handPoseClassifier.prediction(poses: keypointsMultiArray)
            let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]!
            
            DispatchQueue.main.async{
                self.handPrediction = handPosePrediction.label
                self.predictionResult = confidence.description
            }
            
        } catch {
            captureSession.stopRunning()
            print("Error")
        }
        
        guard let currentFrame = sampleBuffer.cgImage else {
            print("Can't translate to CGImage")
            return
        }
        addToPreviewStream?(currentFrame)
        
    }
}
