//
//  File.swift
//  
//
//  Created by G on 2023-01-18.
//

import Foundation
import MetricKit


class Logger: NSObject, MXMetricManagerSubscriber {
    
    // if we were to receive device metrics- power, aggregated, performance and others.
    func checkDeviceMetrics() {
        let logHandle = MXMetricManager.makeLogHandle(category: "G-device metrics")
        let metricManager = MXMetricManager.shared
        metricManager.add(self)
        mxSignpost(
          .event,
          log: logHandle,
          name: "Loading a application")
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
       guard let firstPayload = payloads.first else { return }
       print(firstPayload.dictionaryRepresentation())
     }

     func didReceive(_ payloads: [MXDiagnosticPayload]) {
       guard let firstPayload = payloads.first else { return }
       print(firstPayload.dictionaryRepresentation())
     }
}


