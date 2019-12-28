/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Provides helper types for the BERT model's outputs.
*/

import CoreML

extension Array where Element: Comparable {
    /// Provides the indices of the largest elements.
    ///
    /// - parameters:
    ///     - count: The number of indicies to return, at most.
    /// - returns: An array of integers.
    func indicesOfLargest(_ count: Int = 10) -> [Int] {
        let count = Swift.min(count, self.count)
        let sortedSelf = enumerated().sorted { (arg0, arg1) in arg0.element > arg1.element }
        let topElements = sortedSelf[0..<count]
        let topIndices = topElements.map { (tuple) in tuple.offset }
        return topIndices
    }
}

extension MLMultiArray {
    /// Creates a copy of the multi-array's contents into a Doubles array.
    ///
    /// - returns: An array of Doubles.
    func doubleArray() -> [Double] {
        // Bind the underlying `dataPointer` memory to make a native swift `Array<Double>`
        let unsafeMutablePointer = dataPointer.bindMemory(to: Double.self, capacity: count)
        let unsafeBufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: count)
        return [Double](unsafeBufferPointer)
    }
}

extension BERT {
    /// Finds the indices of the best start logit and end logit given a prediction output and a range.
    ///
    /// - parameters:
    ///     - prediction: A feature provider that supplies the output MLMultiArrays from a BERT model.
    ///     - range: A range of the output tokens to search.
    /// - returns: Description.
    /// - Tag: BestLogitIndices
    func bestLogitsIndices(from prediction: BERTQAFP16Output, in range: Range<Int>) -> (start: Int, end: Int)? {
        // Convert the logits MLMultiArrays to [Double].
        let startLogits = prediction.startLogits.doubleArray()
        let endLogits = prediction.endLogits.doubleArray()
        
        // Isolate the logits for the document.
        let startLogitsOfDoc = [Double](startLogits[range])
        let endLogitsOfDoc = [Double](endLogits[range])
        
        // Only keep the top 20 (out of the possible ~380) indices for faster searching.
        let topStartIndices = startLogitsOfDoc.indicesOfLargest(20)
        let topEndIndices = endLogitsOfDoc.indicesOfLargest(20)
        
        // Search for the highest valued logit pairing.
        let bestPair = findBestLogitPair(startLogits: startLogitsOfDoc,
                                         bestStartIndices: topStartIndices,
                                         endLogits: endLogitsOfDoc,
                                         bestEndIndices: topEndIndices)
        
        guard bestPair.start >= 0 && bestPair.end >= 0 else {
            return nil
        }
        
        return bestPair
    }
    
    /// Searches the given indices for the highest valued start and end logits.
    ///
    /// - parameters:
    ///     - startLogits: An array of all the start logits.
    ///     - bestStartIndices: An array of the best start logit indices.
    ///     - endLogits: An array of all the end logits.
    ///     - bestEndIndices: An array of the best end logit indices.
    /// - returns: A tuple of the best start index and best end index.
    func findBestLogitPair(startLogits: [Double],
                           bestStartIndices: [Int],
                           endLogits: [Double],
                           bestEndIndices: [Int]) -> (start: Int, end: Int) {
        
        let logitsCount = startLogits.count
        var bestSum = -Double.infinity
        var bestStart = -1
        var bestEnd = -1
                
        for start in 0..<logitsCount where bestStartIndices.contains(start) {
            for end in start..<logitsCount where bestEndIndices.contains(end) {
                let logitSum = startLogits[start] + endLogits[end]
                
                if logitSum > bestSum {
                    bestSum = logitSum
                    bestStart = start
                    bestEnd = end
                }
            }
        }
        return (bestStart, bestEnd)
    }
}
