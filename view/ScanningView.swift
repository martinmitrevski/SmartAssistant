//  Created by Martin Mitrevski on 15.06.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import SwiftUI
import UIKit
import VisionKit
import Combine

struct ScanningView: UIViewControllerRepresentable {
    
    let documentsRepository: DocumentsRepository
    var modalShown: Binding<Bool>
    var loadingViewShown: Binding<Bool>
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(withDocumentsRepository: documentsRepository,
                           modalShown: modalShown,
                           loadingViewShown: loadingViewShown)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScanningView>) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScanningView>) {
        
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        let documentsRepository: DocumentsRepository
        var modalShown: Binding<Bool>
        var loadingViewShown: Binding<Bool>
        
        init(withDocumentsRepository documentsRepository: DocumentsRepository,
             modalShown: Binding<Bool>,
             loadingViewShown: Binding<Bool>) {
            self.documentsRepository = documentsRepository
            self.modalShown = modalShown
            self.loadingViewShown = loadingViewShown
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images = [CGImage]()
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    images.append(cgImage)
                }
            }
            self.loadingViewShown.wrappedValue = true
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                let text = TextRecognizer.recognizeText(from: images)
                let number = self.documentsRepository.documents.count + 1
                let title = "Document \(number)"
                let document = Document(id: UUID().uuidString, title: title, content: text)
                DispatchQueue.main.async {
                    self.documentsRepository.add(document: document)
                    self.loadingViewShown.wrappedValue = false
                    self.modalShown.wrappedValue = false
                }
            }
        }
        
    }

}
