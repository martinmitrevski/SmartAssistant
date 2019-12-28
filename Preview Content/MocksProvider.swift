//
//  MocksProvider.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/16/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import Foundation

class MocksProvider {
    
    static func document() -> Document {
        let document = Document(id: UUID().uuidString,
                                title: "This is a test document",
                                content: "This is a test content, that should be at least two lines long, so we can see how it looks like.")
        return document
    }
    
    static func documents() -> [Document] {
        return [document()]
    }
    
}
