//
//  Media.swift
//  GApp
//
//  Created by G on 2023-05-05.
//

import Foundation
import Gdk
import CoreAudio
import MediaPlayer
import CoreMedia
import CoreVideo

class MediaController {
    
    func startMedia() {
        //        let recorder = GAudioText()
        //        _ = try? recorder.recordAndSynthesize()
                
        //        record(for: 20.0) { text in
        //            if let txt = text {
        //                GML.printLemmatization(for: txt)
        //
        //                GML.printEmbeddings(for: txt)
        //
        //                GNLP().printSentiments(from: txt)
        //
        //
        //            }
        //        }
    }
    
    func record(for period: Double, completion: @escaping (String?) -> Void) {
        let recorder = GAudioText()
        recorder.askRecordPermissioning { status in
            if status {
                recorder.recordAudio(true) { sta in
                    DispatchQueue.main.asyncAfter(deadline: .now() + period) {
                        recorder.recordAudio { stt in
                            recorder.transcribeAudio { tt in
                                completion(tt)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
