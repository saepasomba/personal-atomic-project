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
    
    @State var zoomFactor: CGFloat = 1
    //    @Binding var pinchScale: CGFloat
    //    @Binding var image: Image?
    //    @Binding var coordinator: Coordinator {
    //        didSet {
    //            coordinator = Coordinator(self)
    //        }
    //    }
    
//    private let videoOutput = AVCaptureVideoDataOutput()
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    //    var coordinator: Coordinator?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
        //        return coordinator
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CameraAVRepresentable
        
        init(_ parent: CameraAVRepresentable) {
            self.parent = parent
        }
        
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            // Handle the captured frame here
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let uiImage = UIImage(ciImage: ciImage)
//        }
        
//        func takePicture() {
//            let photoSettings = AVCapturePhotoSettings()
//            let photoOutput = AVCapturePhotoOutput()
//
//            // prepare output
//            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//                fatalError("No camera found")
//            }
//            do {
//                let input = try AVCaptureDeviceInput(device: camera)
//
//                let captureSession = AVCaptureSession()
//                captureSession.sessionPreset = AVCaptureSession.Preset.high
//                if captureSession.canAddInput(input) {
//                    captureSession.addInput(input)
//                    //
//                    //                        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_queue"))
//
//                    if captureSession.canAddOutput(photoOutput) {
//                        captureSession.addOutput(photoOutput)
//                        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
//
//                            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
//                            photoOutput.capturePhoto(with: photoSettings, delegate: self)
//                        }
//                    }
//                }
//            }
//            catch {
//                fatalError(error.localizedDescription)
//            }
//
//        }
        
        //        func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        //
        //            guard let pixelBuffer = CMSampleBufferGetImageBuffer(photoSampleBuffer!) else { return }
        //            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        //            let uiImage = UIImage(ciImage: ciImage)
        //            print(uiImage)
        //        }
        //
        //        func photoOutput(_ output: AVCaptureOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //            guard let imageData = photo.fileDataRepresentation() else { return }
        //            _ = UIImage(data: imageData)
        //
        //            print(imageData)
        //        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let videoOutput = AVCapturePhotoOutput()
        // Create a capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Find and configure the camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            fatalError("No camera found")
        }
        do {
            try camera.lockForConfiguration()
            let input = try AVCaptureDeviceInput(device: camera)
            
            // TODO: ADJUST ZOOM FACTOR
            //            camera.videoZoomFactor = 2
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                //
                //                    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_queue"))
                
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                    
                    // Create a preview layer
                    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
                    previewLayer.videoGravity = .resizeAspectFill
                    view.layer.addSublayer(previewLayer)
                    
                    // Start the capture session
                    DispatchQueue.global().async {
                        captureSession.startRunning()
                    }
                }
            }
            camera.unlockForConfiguration()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // If needed
    }
}
