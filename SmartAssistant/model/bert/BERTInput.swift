/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Provides helper types for the BERT model's inputs.
*/

import CoreML

struct BERTInput {
    /// The maximum number of tokens the BERT model can process.
    static let maxTokens = 384
    
    // There are 2 sentinel tokens before the document, 1 [CLS] token and 1 [SEP] token.
    static private let documentTokenOverhead = 2
    
    // There are 3 sentinel tokens total, 1 [CLS] token and 2 [SEP] tokens.
    static private let totalTokenOverhead = 3

    var modelInput: BERTQAFP16Input?

    let question: TokenizedString
    let document: TokenizedString

    private let documentOffset: Int

    var documentRange: Range<Int> {
        return documentOffset..<documentOffset + document.tokens.count
    }
    
    var totalTokenSize: Int {
        return BERTInput.totalTokenOverhead + document.tokens.count + question.tokens.count
    }
    
    /// - Tag: BERTInputInitializer
    init(documentString: String, questionString: String) {
        document = TokenizedString(documentString)
        question = TokenizedString(questionString)

        // Save the number of tokens before the document tokens for later.
        documentOffset = BERTInput.documentTokenOverhead + question.tokens.count
        
        guard totalTokenSize < BERTInput.maxTokens else {
            return
        }
        
        // Start the wordID array with the `classification start` token.
        var wordIDs = [BERTVocabulary.classifyStartTokenID]
        
        // Add the question tokens and a separator.
        wordIDs += question.tokenIDs
        wordIDs += [BERTVocabulary.separatorTokenID]
        
        // Add the document tokens and a separator.
        wordIDs += document.tokenIDs
        wordIDs += [BERTVocabulary.separatorTokenID]
        
        // Fill the remaining token slots with padding tokens.
        let tokenIDPadding = BERTInput.maxTokens - wordIDs.count
        wordIDs += Array(repeating: BERTVocabulary.paddingTokenID, count: tokenIDPadding)

        guard wordIDs.count == BERTInput.maxTokens else {
            fatalError("`wordIDs` array size isn't the right size.")
        }
        
        // Build the token types array in the same order.
        // The document tokens are type 1 and all others are type 0.
        
        // Set all of the token types before the document to 0.0.
        var wordTypes = Array(repeating: 0.0, count: documentOffset)
        
        // Set all of the document token types to 1.0
        wordTypes += Array(repeating: 1.0, count: document.tokens.count)
        
        // Set the remaining token types to 0.0.
        let tokenTypePadding = BERTInput.maxTokens - wordTypes.count
        wordTypes += Array(repeating: 0.0, count: tokenTypePadding)

        guard wordTypes.count == BERTInput.maxTokens else {
            fatalError("`wordTypes` array size isn't the right size.")
        }

        // The input shape of the BERT model is 1x384.
        let inputShape = [1, NSNumber(value: BERTInput.maxTokens)]
        
        // Create the MLMultiArray instances.
        let tokenIDMultiArray = try? MLMultiArray(shape: inputShape,
                                                  dataType: .double)
        
        let wordTypesMultiArray = try? MLMultiArray(shape: inputShape,
                                                    dataType: .double)
        
        // Unwrap the MLMultiArray optionals.
        guard let tokenIDInput = tokenIDMultiArray else {
            fatalError("Couldn't create wordID MLMultiArray input")
        }
        
        guard let tokenTypeInput = wordTypesMultiArray else {
            fatalError("Couldn't create wordType MLMultiArray input")
        }
        
        // Copy the Swift array contents to the MLMultiArrays.
        for (index, identifier) in wordIDs.enumerated() {
            tokenIDInput[index] = NSNumber(value: identifier)
        }

        for (index, type) in wordTypes.enumerated() {
            tokenTypeInput[index] = NSNumber(value: type)
        }

        // Create the BERT input MLFeatureProvider.
        let modelInput = BERTQAFP16Input(wordIDs: tokenIDInput,
                                         wordTypes: tokenTypeInput)
        self.modelInput = modelInput
    }
}
