//
//  File.swift
//  
//
//  Created by G on 2022-11-11.
//

import Foundation
import Speech
import NaturalLanguage


public class GNLP {
   
    public func dataTypeDetect(inp: String) {
        if let detector = try? NSDataDetector(
          types: NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.date.rawValue
          | NSTextCheckingResult.CheckingType.address.rawValue  | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
        ) {
            
            let range = NSRange(0..<inp.count)

            let foundContent = detector.matches(
              in: inp,
              options: [], range: range)
            
            foundContent.forEach { content in
              switch content.resultType {
              case NSTextCheckingResult.CheckingType.link:
                print("URL: \(content.url!)")
              case NSTextCheckingResult.CheckingType.date:
                print("DATE: \(content.date!)")
              default:
                break
              }
            }
        }
    }
    
    public func tokenize(inp: String) {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = inp
        tokenizer.setLanguage(.english)
        let fullStringRange = inp.startIndex..<inp.endIndex
        tokenizer.enumerateTokens(in: fullStringRange) { (range, attributes) -> Bool in
          print(inp[range])
          return true
        }
        
        
        let enSchemes = NLTagger.availableTagSchemes(for: .word, language: .english)
        print("English")
        print(enSchemes.map ({ $0.rawValue }))

        let jpSchemes = NLTagger.availableTagSchemes(for: .word, language: .japanese)
        print("Japanese")
        print(jpSchemes.map ({ $0.rawValue }))
        
        
        let embedding = NLEmbedding.wordEmbedding(for: .english)
        let foundWords = embedding!.neighbors(for: "family", maximumCount: 3)
        print(foundWords)
        print(embedding!.distance(between: "house", and: "home"))
        // [("life", 0.8834981918334961), ("child", 0.8971378207206726), ("parent", 0.8989249467849731)]

    }
    
    public static func printEmbeddings(for inputString: String)  {
        
        let embedding = NLEmbedding.wordEmbedding(for: .english)
        
        if let similarWords = embedding?.neighbors(for: inputString, maximumCount: 10) {
            for word in similarWords {
                

                print("\(word.0) distance \(word.1)")
            }
        }
    }
    
    public static func printLemmatization(for phrase: String) -> [String] {
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = phrase
        
        var result = [String]()
        
        tagger.enumerateTags(in: phrase.startIndex..<phrase.endIndex, unit: .word, scheme: .lemma, options: options) { tag, range in
            let stemForm = tag?.rawValue ?? String(phrase[range])
            result.append(stemForm)
            print(stemForm, terminator: "")
            return true
        }
        return result
    }
    
    public func printSentiments(from phrase: String) {
        
       

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = phrase
        
        // ask for the results
        let (sentiment, _) = tagger.tag(at: phrase.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        // read the sentiment back and print it
        let score = Double(sentiment?.rawValue ?? "0") ?? 0
        
        print(score)
        
    }
}



public class GAudioText: NSObject, AVAudioRecorderDelegate {
    
    public var audioRecorder: AVAudioRecorder? = nil
    
    public override init() {
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }

    
    /* if an error occurs while encoding it will be reported to the delegate. */
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    
    
    public func recordAndSynthesize() throws {
        let speechRecognizer = SFSpeechRecognizer()!
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let audioEngine = AVAudioEngine()
//        SFSpeechRecognizer.supportedLocales()
        try startRecording()
        
        func startRecording() throws {
          
          
          recognitionTask?.cancel()
          recognitionTask = nil
          
          
          let audioSession = AVAudioSession.sharedInstance()
          try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
          try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
          let inputNode = audioEngine.inputNode
          
         
          recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
          recognitionRequest!.shouldReportPartialResults = true
          
          
          if #available(iOS 13, *) {
            recognitionRequest!.requiresOnDeviceRecognition = true
          }
          
          
          recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            var isFinal = false
            
            if let result = result {
              isFinal = result.isFinal
              print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
              // Stop recognizing speech if there is a problem.
              audioEngine.stop()
              inputNode.removeTap(onBus: 0)
              
              recognitionRequest = nil
              recognitionTask = nil
            }
          }
          
         
          let recordingFormat = inputNode.outputFormat(forBus: 0)
            // The buffer size tells us how much data should the microphone record before dumping it into the recognition request.
          inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest?.append(buffer)
          }
          
          audioEngine.prepare()
          try audioEngine.start()
        }
    }
    
    
    public static let audioPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("recording.m4a")
    
    public func askRecordPermissioning( completion: @escaping (Bool) -> Void) {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                completion(allowed)
            }
        } catch { // failed to record }
            completion(false)
        }
    }
    
    public func recordAudio(_ start: Bool = false, completion: (Bool) -> Void) {
        if start {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                audioRecorder = try AVAudioRecorder(url: Self.audioPath, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            audioRecorder?.stop()
            audioRecorder = nil
            completion(true)
        }
    }
    
    
    public func requestTranscribePermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                    completion(true)
                } else {
                    print("Transcription permission was declined.")
                    completion(true)
                }
            }
        }
    }
    
    public func transcribeAudio(url: URL = GAudioText.audioPath, completion: @escaping (String?)-> Void) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        recognizer?.supportsOnDeviceRecognition = true
        let request = SFSpeechURLRecognitionRequest(url: url)

        // start recognition!
        recognizer?.recognitionTask(with: request) { (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                completion(nil)
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
                completion(result.bestTranscription.formattedString)
            }
        }
    }
}
