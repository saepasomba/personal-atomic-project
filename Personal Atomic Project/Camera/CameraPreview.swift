import SwiftUI
import AVFoundation

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraCaptureView
        
        init(_ parent: CameraCaptureView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                
                parent.image = cropImageToSquare(uiImage)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func cropImageToSquare(_ image: UIImage) -> UIImage {
            let size = min(image.size.width, image.size.height)
            let originX = (image.size.width - size) / 2.0
            let originY = (image.size.height - size) / 2.0
            let rect = CGRect(x: originX, y: originY, width: size, height: size)
            
            if let imageRef = image.cgImage?.cropping(to: rect) {
                return UIImage(cgImage: imageRef)
            } else {
                return image
            }
        }
    }
    
}
