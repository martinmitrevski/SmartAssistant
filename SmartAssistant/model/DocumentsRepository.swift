//
//  DocumentsRepository.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/17/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import Foundation

class DocumentsRepository: ObservableObject {
    
    @Published var documents = [Document]()
        
    func add(document: Document) {
        documents.append(document)
    }
    
}
