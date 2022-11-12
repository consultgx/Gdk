//
//import SwiftUI
//import Combine
//
//
//func timeChangingSubscribing() {
//
//    final class Num2Subscriber: Subscriber {
//    typealias Input = Int
//    typealias Failure = Never
//
//    func receive(subscription: Subscription) {
//      subscription.request(.max(2))
//    }
//
//    func receive(_ input: Int) -> Subscribers.Demand {
//
//      switch input {
//      case 1:
//        return .max(2) // 1
//      case 3:
//        return .max(1) // 2
//      default:
//        return .none // 3
//      }
//    }
//
//    func receive(completion: Subscribers.Completion<Never>) {
//
//    }
//  }
//
//  let subscriber = Num2Subscriber()
//
//  let subject = PassthroughSubject<Int, Never>()
//
//  subject.subscribe(subscriber)
//
//  subject.send(1)
//  subject.send(2)
//  subject.send(3)
//  subject.send(4)
//  subject.send(5)
//  subject.send(6)
//
//
//
//      // 1
//  let subject1 = PassthroughSubject<Int, Never>()
//
//  // 2
//  let publisher1 = subject1.eraseToAnyPublisher()
//
//  // 3
//  publisher1
//    .sink(receiveValue: { print($0) })
//    .store(in: &subscriptions)
//
//  // 4
//  subject1.send(0)
//}
//
//func currentThruTesting() {
//
//      // 1
//  var subscriptions = Set<AnyCancellable>()
//
//  // 2
//  let subject = CurrentValueSubject<Int, Never>(0)
//
//  // 3
//  subject
//    .sink(receiveValue: { print($0) })
//    .store(in: &subscriptions) // 4
//
//
//    subject
//        .sink(receiveValue: { print("Second subscription:", $0) })
//         .store(in: &subscriptions)
//
//
//}
//
//
//func passThroughTesting() {
//
//    // 5
//let subject = PassthroughSubject<String, CustomError>()
//
//// 6
//subject.subscribe(subscriber)
//
//    subject.send("Good")
//
//subject.send("Morning")
//
//
//
//// 7
//let subscription = subject
//  .sink(
//    receiveCompletion: { completion in
//
//    },
//    receiveValue: { value in
//
//    }
//  )
//
//        // 8
//subscription.cancel()
//
//// 9
//subject.send("will it go thru?")
//
//
//     enum CustomError: Error {
//         case test
//         }
//
//  // 2
//  final class StringSubscriber: Subscriber {
//    typealias Input = String
//    typealias Failure = CustomError
//
//    func receive(subscription: Subscription) {
//      subscription.request(.max(2))
//    }
//
//    func receive(_ input: String) -> Subscribers.Demand {
//      // 3
//      return input == "Morning" ? .max(1) : .none
//    }
//
//    func receive(completion: Subscribers.Completion<MyError>) {
//
//    }
//  }
//
//  // 4
//  let subscriber = StringSubscriber()
//}
//
//
//func futureTesting() {
//
//             // 1
//        let future = futureIncrement(integer: 1, afterDelay: 3)
//
//        // 2
//        future
//             .sink(receiveCompletion: { print($0) },
//               receiveValue: { print($0) })
//              .store(in: &subscriptions)
//
//
//     func futureIncrement(
//    integer: Int,
//    afterDelay delay: TimeInterval) -> Future<Int, Never> {
//
//     Future<Int, Never> { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                     promise(.success(integer + 1))
//                }
//        }
//
//  }
//
//
//}
//
//
//
//func pubSixthWay() {
//  // 1
//  let publisher = (1...100).publisher
//
//  // 2
//  final class NumSubscriber: Subscriber {
//    // 3
//    typealias Input = Int
//    typealias Failure = Never
//
//    // 4
//    func receive(subscription: Subscription) {
//      subscription.request(.max(2))
//
//    }
//
//    // 5
//    func receive(_ input: Int) -> Subscribers.Demand {
//        print("received... ")
//      return .none
//    }
//
//    // 6
//    func receive(completion: Subscribers.Completion<Never>) {
//        print("this is last thing that gets printed")
//    }
//  }
//
//    let subscriber = NumSubscriber()
//
//    publisher.subscribe(subscriber)
//}
//
//class MyObject1 {
//  @Published var str: String = ""
//  var subscriptions = Set<AnyCancellable>()
//
//  init() {
//    ["X", "Y", "Z"].publisher
//      .assign(to: \.str, on: self)
//      .store(in: &subscriptions)
//  }
//}
//
//
// class SomeObject {
//      @Published var value1 = 0
//
//    var value2: String = "" {
//      didSet {
//        print(value)
//      }
//    }
//  }
//
//  func pubSubFifthWay() {
//   let object = SomeObject()
//
//  // 3
//  let publisher = ["Good", "Morning!"].publisher
//
//  // 4
//  _ = publisher
//    .assign(to: \.value2, on: object)
//
//
//       object.$value1
//    .sink {
//      print($0)
//    }
//
//  // 3
//  (0..<10).publisher
//    .assign(to: &object.$value1)
//  }
//
////
////// Still TODO
////final class LoginViewModel: ObservableObject {
////    @Published var email: String = ""
////    @Published var password: String = ""
////     @Published var isSuccess: Bool = false
////     @Published var accountList: [String] = []
////    private var cancellable: AnyCancellable?
////    var account: String = ""
////    var accountInfo: String = ""
////    var accountRelated: [String] = []
////
////    func fetchZip() {
////        cancellable = Publishers.Zip( (),()
//////            service.fetch(account),
//////            service.fetchRelatedAccounts(for: account)
////        )
////        .sink(
////            receiveCompletion: { print($0) },
////            receiveValue: { [weak self] accountI, related in
////                self?.accountInfo = accountI
////                self?.accountRelated = related
////            }
////        )
////    }
////
////
////    func fetchMergeMany() {
////        Publishers.MergeMany(
//////            service.fetchCachedAccountList(),
//////            service.fetchAccountListRealTime()
////        )
////        .replaceError(with: [])
////        .assign(to: &$accountList)
////    }
////
////
////    var isValid: AnyPublisher<Bool, Never> {
////        Publishers
////            .CombineLatest2($email, $password)
////            .allSatisfy { email, password in
////                email.contains("@") &&
////                    password.count > 7
////            }.eraseToAnyPublisher()
////    }
////
////    func check() {
////        cancellable = Publishers.Zip(
////            service.validateCreds(email,password),
////            service.fetchAccountInfo(for: email)
////        )
////        .sink(
////            receiveCompletion: { print($0) },
////            receiveValue: { [weak self] isSuccess, accountInfo in
////                self?.isSuccess = isSuccess
////            }
////        )
////    }
////}
////
//struct Car {
//    var brand: String
//}
//
//class CarViewModel: ObservableObject {
//    @Published var car: Car
////    private var brandPublisher: CarBrandPublisher
//
//    var cancellables: Set<AnyCancellable> = []
//
//    init(car: Car) {
//        self.car = car
////        self.brandPublisher = CarBrandPublisher(viewModel: self)
//    }
//
//   // 1st way- basic
//    func updateBrand1(_ k: String) {
//        car.brand = k
//      // or below
//        objectWillChange.send()
//    }
//
//   // 2nd way - publisher
//    func updateBrand2(_ k: String) {
////        brandPublisher.send(brand: k)
//    }
//
//    // 3rd wayjust one value and be done with that
//    func publishingHouse() -> AnyPublisher<String, Error> {
//          Deferred { // to prevent immediate start w/o sink
//              Future { handler in
//                 // calling our apis / closures
//                 // those return success handler(.success("values"))
//                  // those with failure handler(.failure(error))
//                }
//         }.eraseToAnyPublisher()
//
//    }
//    func callingPubHouse() {
//        publishingHouse()
//             .retry(3)
//             .replaceError(with: "false")
//             .sink { print("received finally: \($0)") }
//             .store(in: &cancellables)
//
//        // 1
//         let just = Just("Hello world!")
//
//         // 2
//         _ = just
//           .sink(
//             receiveCompletion: {
//               print("Received completion", $0)
//             },
//             receiveValue: {
//               print("Received value", $0)
//           })
//
////        carSpeed()
////            .retry(3)
////            .flatMap { authorized -> AnyPublisher<[Double], Error> in
////
//////                      return [12.0,12.9].eraseToAnyPublisher()
//////                } else {
////                 return Empty().eraseToAnyPublisher()
//////                }
////            }
////            .replaceError(with: [])
////            .sink { print("received: \($0)") }
////            .store(in: &cancellables)
//    }
//
//    // 4th way passthriugh, // stream of values
//    enum dError: Error {case brandNotClear}
//    func carSpeed() -> AnyPublisher<[Double], dError> {
//    let subject = PassthroughSubject<[Double], dError>()
//
//        // call async ops and for failure
//        subject.send(completion: .failure(.brandNotClear))
//        // for success, collect values array
//        subject.send([12.4,23.0])
//
//    return subject.handleEvents(
//        receiveSubscription: { _ in // execute calls
//                                },
//        receiveCancel: { //
//            // if we want to cancel
//        }
//    ).eraseToAnyPublisher()
//}
//
//}
///*
//// Usage:
//let c = Car(brand: "Toyota")
//let viewModel = CarViewModel(person: person)
//let carView = CarView(viewModel: viewModel)
//
//viewModel.updateBrand1("VW")
//viewModel.updateBrand2("VW1")
//*/
//struct CarView: View {
//    @ObservedObject var viewModel: CarViewModel
//
//    var body: some View {
//        VStack {
//            Text("Name: \(viewModel.car.brand)")
//            TextField("Enter brand", text: Binding(get: {
//                self.viewModel.car.brand
//            }, set: { newName in
//                self.viewModel.updateBrand1(newName)
//            }))
//        }
//    }
//}
//
////class CarBrandPublisher: Publisher {
////    typealias Output = String
////    typealias Failure = Never
////
////    private let viewModel: CarViewModel
////    private var subscribers: [CarBrandSubscriber<S: Subscriber>]
////
////    init(viewModel: CarViewModel) {
////        self.viewModel = viewModel
////    }
////
////    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == Output {
////        let subscription = CarBrandSubscriber(subscriber: subscriber)
////        subscribers.append(subscription)
////        subscriber.receive(subscription: subscription)
////    }
////
////  func send(brand: String) {
////        subscribers.forEach { $0.receive(brand: brand) }
////    }
////}
////
////class CarBrandSubscriber<S: Subscriber>: Subscription where S.Input == String, S.Failure == Never {
////    private var subscriber: S?
////
////    init(subscriber: S) {
////        self.subscriber = subscriber
////    }
////
////    func request(_ demand: Subscribers.Demand) {}
////
////    func cancel() {
////        subscriber = nil
////    }
////
////   func receive(brand: String) {
////        _ = subscriber?.receive(brand)
////    }
////}
//
//protocol Coordinator: AnyObject {
//    associatedtype Output
//    var supportedType: Output {get}
//    func start(completion: (Output) -> Void )
//}
//
//extension Coordinator {
//    // a defsault
//    var supportedType: Output { "Coordinator" as! Self.Output }
//}
//
//protocol OutPut {}
//
//class ParentCoordinator: Coordinator {
//    var childCoordinators: [any Coordinator] = []
//
//    func start(completion: (OutPut) -> Void) {
//        var data = [DataModel]()
//        childCoordinators.forEach { child in
//            child.start { out in
//                data.append(out as! DataModel)
//            }
//        }
//    }
//}
//
//struct DataModel: OutPut {}
//
//
//class ExampleViewModel: ObservableObject {
//    @Published var output: OutPut
//
//    weak var coordinator: ParentCoordinator?
//
//    init(_ out: OutPut) {
//        output = DataModel()
//        coordinator?.start(completion: { out in
//
//        })
//    }
//}
