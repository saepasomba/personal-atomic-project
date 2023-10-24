//
//  CameraAVView.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 19/10/23.
//

import SwiftUI
import AVFoundation

struct CameraAVView: View {
    @State var torchMode: Bool = false
    @State var image: Image?
    
    @State private var capturedImage: Image? = nil
    @State private var inputImage: UIImage? = nil
    @State private var pinchScale: CGFloat = 1.0
    @State private var zoomFactor: CGFloat = 1.0 // Initial zoom factor
    
    func toggleTorch() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    
                    device.torchMode = torchMode ? .off : .on
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
    
    var body: some View {
        let cameraView = CameraAVRepresentable(zoomFactor: $zoomFactor, pinchScale: $pinchScale, image: $capturedImage)
        
        VStack {
            Button {
                toggleTorch()
            } label: {
                Text("Torch!")
            }
            .buttonStyle(.borderedProminent)
            
            ZStack {
                if let image = capturedImage {
                    image
                } else {
                cameraView
                    .scaledToFit()
                    .background(.red)
                    
                }
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .fill(Color.white)
                    .frame(maxHeight: 1)
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .fill(Color.white)
                    .frame(maxHeight: 1)
                    .rotationEffect(Angle(degrees: 90))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Button {
                cameraView.makeCoordinator().takePicture()
            } label: {
                Text("Take a picture")
            }
            .buttonStyle(.borderedProminent)
        }
        
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct CameraAVView_Previews: PreviewProvider {
    static var previews: some View {
        CameraAVView()
    }
}
