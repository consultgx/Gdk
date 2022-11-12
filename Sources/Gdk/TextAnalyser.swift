//
//  Image2Text.swift
//  GApp
//
//  Created by G on 2023-04-07.
//

import SwiftUI
import UIKit
import CoreML
import NaturalLanguage
import Vision


class VNTextAnalyzer {
    
    func start() {
        guard let cgImage = UIImage().cgImage else {return}
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
             guard let observations = request.results as? [VNRecognizedTextObservation],
             error == nil else {return}
             let text = observations.compactMap({
             $0.topCandidates(1).first?.string
             }).joined(separator: ", ")
             print(text) // text we get from image
        }
        //request.recognitionLanguages = ["Language code you need"]
        request.recognitionLevel = VNRequestTextRecognitionLevel.fast
        _ = try? handler.perform([request])
    }
}


class BertApplyier {
    
    func setup(rawString: String, searchTerm: String) {
        // Store the tokenized substrings into an array.
        var wordTokens = [Substring]()

        // Use Natural Language's NLTagger to tokenize the input by word.
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = rawString

        // Find all tokens in the string and append to the array.
        tagger.enumerateTags(in: rawString.startIndex..<rawString.endIndex,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.omitWhitespace]) { (_, range) -> Bool in
            wordTokens.append(rawString[range])
            return true
        }
//        let subTokenID = BERTVocabulary.tokenID(of: searchTerm)

    }
    
    
}
