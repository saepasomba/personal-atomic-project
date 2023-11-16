//
//  Camera4.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 08/11/23.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CaptureModel: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var currentCamera: AVCaptureDevice?
    @Published var capturedImage: UIImage?
    @Published var isTakingPicture: Bool = false

    override init() {
        super.init()
        setupCaptureSession()
        setupDevices()
        setupInputOutput()
    }

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }//setupCaptureSession

    func setupDevices() {

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .unspecified)

        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }//if else
        }//for in

        currentCamera = backCamera

    }//setupDevices

    func setupInputOutput() {

        do {
            //you only get here if there is a camera ( ! ok )
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: {(success, error) in
            })
            captureSession.addOutput(photoOutput!)
            captureSession.commitConfiguration()

        } catch {
            print("Error creating AVCaptureDeviceInput:", error)
        }

    }//setupInputOutput

    func startRunningCaptureSession() {
        let settings = AVCapturePhotoSettings()

        captureSession.startRunning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            self.photoOutput?.capturePhoto(with: settings, delegate: self)
            
            self.isTakingPicture = false
        })
    }//startRunningCaptureSession

    func stopRunningCaptureSession() {
        captureSession.stopRunning()
    }//startRunningCaptureSession
}

extension CaptureModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        capturedImage = image
    }
}

struct Camera4Representable: UIViewRepresentable {
    @EnvironmentObject var model: CaptureModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
        let parent: Camera4Representable
        
        init(_ parent: Camera4Representable) {
            self.parent = parent
        }
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let photoOutput = AVCapturePhotoOutput()
        // Create a capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        // Find and configure the camera
        guard let camera = model.currentCamera else {
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
                //                    photoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_queue"))
                
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                    
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
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // If needed
    }
}

struct Camera4: View {
    @Environment (\.dismiss) var dismiss
    @StateObject var model = CaptureModel()
    @Binding var imageOutput: Image?
    
    @GestureState private var pinchScale: CGFloat = 1.0
    @State var torchMode: Bool = false
    @State private var zoomSum: CGFloat = 1.0

    var body: some View {
        let cameraView = Camera4Representable().environmentObject(model)
//        let cameraView = CameraAVRepresentable()

        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        model.capturedImage = nil
                    } label: {
                        Text("Reset!")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                    
                    Button {
                        toggleTorch()
                    } label: {
                        Text("Torch!")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                ZStack {
                    if let capturedImage = model.capturedImage {
                        if let croppedImage = cropImageToSquare(image: capturedImage) {
                            Image(uiImage: croppedImage)
                                .resizable()
                                .scaledToFit()
                                .onAppear {
                                    imageOutput = Image(uiImage: croppedImage)
                                    dismiss()
                                }
                        }
                    } else {
//                        Rectangle()
                        cameraView
                            .scaledToFit()
                            .background(.thinMaterial)
                    }
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4], dashPhase: 6))
                        .fill(Color.white)
                        .frame(maxHeight: 1)
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .fill(Color.white)
                        .frame(maxHeight: 1)
                        .rotationEffect(Angle(degrees: 90))
                    Circle()
                        .stroke(lineWidth: 1)
                        .fill(Color.white)
                        .scaledToFit()
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .gesture(MagnificationGesture()
                    .updating($pinchScale) { value, gestureState, transaction in
                        gestureState = value.magnitude
                    }
                )
                .onChange(of: pinchScale) { newValue in
                    print("\(newValue)")
                    
                    if newValue == 1 {
                        return
                    } else if newValue > 1 {
                        zoomSum += newValue * 0.05
                    } else {
                        zoomSum -= newValue * 0.05
                    }
                    
                    if zoomSum < 1 {
                        zoomSum = 1
                    } else if zoomSum > 3 {
                        zoomSum = 3
                    }
                    
                    if let device = model.currentCamera {
                        do {
                            try device.lockForConfiguration()

                            device.videoZoomFactor = zoomSum

                            device.unlockForConfiguration()
                        } catch {
                            print("Torch could not be used")
                        }
                    }
                }
                         
                Button {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        model.isTakingPicture = true
                        model.startRunningCaptureSession()
                    } else {
                        print("No Camera is Available")
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(maxWidth: 88)
                        Circle()
                            .stroke(lineWidth:4)
                            .fill(.black)
                            .frame(maxWidth: 77)
                        if model.isTakingPicture {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.capturedImage)
//        .if(model.capturedImage != nil) { view in
//            view
//                .onChange(of: model.capturedImage!) { newValue in
//                    imageOutput = Image(uiImage: newValue)
//                    dismiss()
//                }
//        }
    }
    
    func toggleTorch() {
        if let device = model.currentCamera {
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    
                    device.torchMode = torchMode ? .on : .off
                    torchMode.toggle()
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
            } else {
                print("Torch is not available")
            }
        }
    }
    
    func cropImageToSquare(image: UIImage) -> UIImage? {
        var imageHeight = image.size.height
        var imageWidth = image.size.width

        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }

        let size = CGSize(width: imageWidth, height: imageHeight)

        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }

        return nil
    }
}//struct




