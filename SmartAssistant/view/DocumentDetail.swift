//
//  DocumentDetail.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/16/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import SwiftUI

struct DocumentDetail: View {
    let document: Document
    let bert = BERT()
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var loadingViewShown = false
    
    var body: some View {
        LoadingView(isShowing: $loadingViewShown) {
            VStack {
                HStack {
                    TextField("Insert your question here...", text: self.$question)
                    Button(action: {
                        self.findAnswer()
                    }) {
                        Text("Answer")
                    }
                }.padding()
                Text(self.answer).padding()
                ScrollView(.vertical) {
                    Text(self.document.content).padding()
                }
            }
            .navigationBarTitle(self.document.title)
        }
    }
    
    private func findAnswer() {
        self.loadingViewShown = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.answer = String(self.bert.findAnswer(for: self.question, in: self.document.content))
            self.loadingViewShown = false
        }
    }
    
}
