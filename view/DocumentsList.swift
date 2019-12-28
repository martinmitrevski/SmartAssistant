//
//  DocumentsList.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/16/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import SwiftUI

struct DocumentsList: View {
    
    @EnvironmentObject var documentsRepository: DocumentsRepository
    
    var body: some View {
        List(documentsRepository.documents) { document in
            NavigationLink(destination: DocumentDetail(document: document)) {
                DocumentRow(document: document)
            }
        }
    }
    
}
