//
//  CameraAVRepresentable.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 19/10/23.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraAVRepresentable: UIViewRepresentable {
    
    @Binding var zoomFactor: CGFloat
    @Binding var pinchScale: CGFloat
    @Binding var image: Image?

    private let videoOutput = AVCaptureVideoDataOutput()
    let photoOutput = AVCapturePhotoOutput()
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CameraAVRepresentable
        
        init(_ parent: CameraAVRepresentable) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Handle the captured frame here
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = UIImage(ciImage: ciImage)
        }
        
        func takePicture() {
            let photoSettings = AVCapturePhotoSettings()
            if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
                photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }
        
        func photoOutput(_ output: AVCaptureOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let imageData = photo.fileDataRepresentation() else { return }
            let previewImage = UIImage(data: imageData)
            
            print(imageData)
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // Create a capture session
        let captureSession = AVCaptureSession()
        
        // Find and configure the camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No camera found")
        }
        do {
            try camera.lockForConfiguration()
            let input = try AVCaptureDeviceInput(device: camera)
            
            camera.videoZoomFactor = 2
            captureSession.addInput(input)
            camera.unlockForConfiguration()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "camera_frame_queue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Create a preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Start the capture session
        captureSession.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // If needed
    }
    
}
