//
//  DocumentRow.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/16/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import SwiftUI

struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        Text(document.title)
    }
}

struct DocumentRow_Previews: PreviewProvider {
    static var previews: some View {
        return DocumentRow(document: MocksProvider.document())
    }
}
