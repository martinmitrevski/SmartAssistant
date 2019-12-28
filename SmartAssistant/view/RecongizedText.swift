//  Created by Martin Mitrevski on 16.06.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import Combine
import SwiftUI

final class RecognizedText: ObservableObject, Identifiable {
    
    @Published var value: String = "Scan document to see its contents"
    
}
