//
//  Camera4RootView.swift
//  Personal Atomic Project
//
//  Created by Sae Pasomba on 14/11/23.
//

import SwiftUI

class RootViewModel: ObservableObject {
    @Published var captureModel: CaptureModel = CaptureModel()
    
    @Published var capturedImage: Image?
}

struct Camera4RootView: View {
    @State var cameraCoverIsPresented: Bool = false
    @StateObject var rootViewModel = RootViewModel()
    
    var body: some View {
        VStack {
            if let safeImage = rootViewModel.capturedImage {
                VStack {
                    safeImage
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                    
                    Button("Reset!") {
                        rootViewModel.capturedImage = nil
                    }
                }
            } else {
                Button("Open camera!") {
                    cameraCoverIsPresented.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $cameraCoverIsPresented) {
            Camera4(imageOutput: $rootViewModel.capturedImage)
        }
    }
    
//    func setCapturedImage(_ capturedImage: Image)
}

struct Camera4RootView_Previews: PreviewProvider {
    static var previews: some View {
        Camera4RootView()
    }
}
