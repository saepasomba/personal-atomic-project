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
//    @State var coordinatorDelegate: CameraAVRepresentable.Coordinator?
    @GestureState private var pinchScale: CGFloat = 1.0
    @State private var zoomSum: CGFloat = 1.0
    
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
        let cameraView = CameraAVRepresentable()
    
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        toggleTorch()
                    } label: {
                        Text("Torch!")
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
                    if let image = capturedImage {
                        image
                    } else {
                    cameraView
                        .scaledToFit()
                        .background(.red)
                        
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
                    
                    if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
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
//                    cameraView.makeCoordinator().takePicture()
//                    if let coordinator = cameraView.coordinator {
//                        coordinator.takePicture()
//                    } else {
//                        print("Coordinator is not detected")
//                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(maxWidth: 88)
                        Circle()
                            .stroke(lineWidth:4)
                            .fill(.black)
                            .frame(maxWidth: 77)
                    }
                }
                .buttonStyle(.plain)
            }
        }.onAppear() {
//            cameraView.makeCoordinator().prepareCamera()
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
