//
//  CameraView.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 18/10/23.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var isShowingCamera = false
    @State private var image: Image? = nil
    @State private var inputImage: UIImage? = nil
    @State private var isTorchOn: Bool = false


    var body: some View {
        VStack {
            
            Button("Open Camera") {
                            isShowingCamera.toggle()
                        }
                        Toggle(isOn: $isTorchOn, label: {
                            Text("Torch")
                        })
            
            Button("Open Camera") {
                isShowingCamera.toggle()
            }
            image?
                .resizable()
                .scaledToFit()
        }
        .sheet(isPresented: $isShowingCamera, onDismiss: loadImage) {
            VStack {
                CameraCaptureView(image: $inputImage)

            }
        }
    }

    func loadImage() {
        if let inputImage = inputImage {
            image = Image(uiImage: inputImage)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
