//
//  ContentView.swift
//  SmartAssistant
//
//  Created by Martin Mitrevski on 12/16/19.
//  Copyright © 2019 Martin Mitrevski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var documentsRepository: DocumentsRepository
    @State var modalShown: Bool = false
    @State var loadingViewShown: Bool = false
    
    var body: some View {
        NavigationView {
            DocumentsList()
            .navigationBarTitle("Documents")
            .navigationBarItems(trailing:
                Button(action: {
                    self.modalShown = true
                }) {
                    Image(systemName: "plus")
                    .renderingMode(.original)
                }
            )
        }.sheet(isPresented: $modalShown) {
            LoadingView(isShowing: self.$loadingViewShown) {
                ScanningView(documentsRepository: self.documentsRepository,
                             modalShown: self.$modalShown,
                             loadingViewShown: self.$loadingViewShown)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
