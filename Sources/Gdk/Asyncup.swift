//
//  Asyncup.swift
//  GApp
//
//  Created by G on 2023-05-03.
//

import Foundation
import Combine
import _Concurrency

enum GenError: Error {
    case general
}
struct DataModel: Codable {}
func pubSub() {
    // pub.sink
    
    // sub  = aClass.pub.sink
    
    let d = PassthroughSubject<DataModel, GenError>()
    // could be done multiple times
    d.send(DataModel())
    d.send(completion: .failure(.general))
    // vs currentValSub which always have to have a initial value
    let dd = CurrentValueSubject<DataModel, GenError>(DataModel())
    
    // OR
    _ = d.sink(receiveCompletion: {
        if case let .failure(error) = $0 {
          print(error)
        }
      }, receiveValue: { hand in
        print(hand)
      })
    
    _ = Just(DataModel())
        .sink { da in
        print(da)
    }
    
}

func subscriber() {
    class SomeObject {
       var value: String = "" {
         didSet {
           print(value)
         }
       }
     }
     
     // 2
     let object = SomeObject()
     
     // 3
     let publisher = ["Hello", "world!"].publisher
     
     // 4
     _ = publisher
       .assign(to: \.value, on: object)
}
func subscriber1() {
    // 1
    class SomeObject {
      @Published var value = 0
    }
    
    let object = SomeObject()
    
    // 2
    object.$value
      .sink {
        print($0)
      }.store(in: &cancellables)
    
    // 3
    (0..<10).publisher
      .assign(to: &object.$value)
}


class MyObject {
  @Published var word: String = ""
  var subscriptions = Set<AnyCancellable>()

  init() {
    ["A", "B", "C"].publisher
      .assign(to: \.word, on: self)
      .store(in: &subscriptions)
  }
}

func subs3() {
    // 1
     let publisher = (1...6).publisher
     
     // 2
     final class IntSubscriber: Subscriber {
       // 3
       typealias Input = Int
       typealias Failure = Never

       // 4
       func receive(subscription: Subscription) {
         subscription.request(.max(3))
       }
       
       // 5
       func receive(_ input: Int) -> Subscribers.Demand {
         print("Received value", input)
         return .none
       }
       
       // 6
       func receive(completion: Subscribers.Completion<Never>) {
         print("Received completion", completion)
       }
     }
    let subscriber = IntSubscriber()

    publisher.subscribe(subscriber)
    
    // future
    // 1
    let future = futureIncrement(integer: 1, afterDelay: 3)

    // 2
    future
      .sink(receiveCompletion: { print($0) },
            receiveValue: { print($0) })
      .store(in: &cancellables)
    
}

func futureIncrement(
   integer: Int,
   afterDelay delay: TimeInterval) -> Future<Int, Never> {
       Future<Int, Never> { promise in
         DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
           promise(.success(integer + 1))
         }
       }
 }

func passThru() {
    // 1
     enum MyError: Error {
       case test
     }
     
     // 2
     final class StringSubscriber: Subscriber {
       typealias Input = String
       typealias Failure = MyError
       
       func receive(subscription: Subscription) {
         subscription.request(.max(2))
       }
       
       func receive(_ input: String) -> Subscribers.Demand {
         print("Received value", input)
         // 3
         return input == "World" ? .max(1) : .none
       }
       
       func receive(completion: Subscribers.Completion<MyError>) {
         print("Received completion", completion)
       }
     }
     
     // 4
     let subscriber = StringSubscriber()
    
    // 5
    let subject = PassthroughSubject<String, MyError>()

    // 6
    subject.subscribe(subscriber)

    // 7
    let subscription = subject
      .sink(
        receiveCompletion: { completion in
          print("Received completion (sink)", completion)
        },
        receiveValue: { value in
          print("Received value (sink)", value)
        }
      )
    
    subject.send("Hello")
    subject.send("World")
}
