//
//  SwiftUIView.swift
//  
//
//  Created by G on 2023-01-03.
//

import SwiftUI
import UIKit
import AVKit
import StoreKit
import Charts

@available(iOS 16.0, *)
@propertyWrapper
struct PropWrapper1: DynamicProperty {
  @State private var value = 0

    var wrappedValue: Int {
        get {
            return value
        }

        nonmutating set {
            value = newValue
        }
    }

  func update() {
      
  }
}

class SettingKeys: ObservableObject {
    @AppStorage("RegistrationDone") var registrationDone = false
    @AppStorage("SystemAlertsPrompt") var systemAlertsPrompt = false
}

@propertyWrapper
struct Setting<T>: DynamicProperty {
    @StateObject private var keys = SettingKeys()
    private let key: ReferenceWritableKeyPath<SettingKeys, T>

    var wrappedValue: T {
        get {
            keys[keyPath: key]
        }

        nonmutating set {
            keys[keyPath: key] = newValue
        }
    }

    init(_ key: ReferenceWritableKeyPath<SettingKeys, T>) {
        self.key = key
    }
}

@available(iOS 16.0, *)
struct ContentView43: View {
    @Setting(\.registrationDone) var didRegister

    @PropWrapper1 var customProperty

    var body: some View {
        Text("Count: \(customProperty)")

        Button("Increment") {
            customProperty += 1
        }
        
        Text("Reg completed: \(didRegister ? "Yes" : "No")")

        Button("Complete reg") {
            didRegister = true
        }
    }
}

@available(iOS 16.0, *)
struct AppReview: View {
    @Environment(\.requestReview) var requestReview
    var body: some View {
        VStack {
            Button {
                requestReview()
            } label: {
                Text("Review App")
            }
        }
    }
}

class SharedData: ObservableObject {}
enum SomeBindable: String, CaseIterable {case one}
extension View {
    func embedInNavigation() -> some View {
        NavigationView { self }
    }
}
enum UIComponent: String, CaseIterable, Identifiable {
    case one
    var id: String {rawValue}
    
    var content: some View {
        switch self {case .one: return Text("hj") }
    }
    
}

struct MainView: View {
    @EnvironmentObject var store: SharedData
    
    var body: some View {
        Child1View()
            .embedInNavigation()
    }
}
// MainView().environmentObject(store)

struct Child1View: View {
    @EnvironmentObject var sharedStore: SharedData
    @State private var shownIt = false
    private var hasLogic: Bool {
        false
    }
    var body: some View {
        Text("one type of UI component")
            .navigationBarTitle("Type1")
            .navigationBarItems(
                trailing: hasLogic ? Button(action: { self.shownIt = true }) {
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .accessibility(label: Text("like"))
                } : nil
            ).sheet(isPresented: $shownIt) {
                Child2View()
                    .environmentObject(self.sharedStore)
                    .embedInNavigation()
                //                    .accentColor(.green)
            }
    }
}
struct Child2View: View {
    @EnvironmentObject var sharedStore: SharedData
    var components = UIComponent.allCases
    var body: some View {
        Text("second type of UI component")
        List(components) { com in
            NavigationLink(destination: com.content) {
                Text(com.id)
            }
        }
    }
}

struct Child3View: View {
    @Binding var somedata: SomeBindable
    var components = UIComponent.allCases
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(systemName: "heart.fill")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
            LinearGradient(
                gradient: .init(colors: [Color.clear, Color.black.opacity(0.35)]),
                startPoint: .center,
                endPoint: .bottom
            )
            Text("third type of UI component")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
        }
    }
}
let child3 = Child3View(somedata: .init(get: {.one}, set: {_ in}))

let child4 = Child4View(somedata: .init(get: {.one}, set: {_ in}))

struct Child4View: View {
    @Binding var somedata: SomeBindable
    var components = UIComponent.allCases
    @State var helpClicked = false
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("4th type of UI component")
                    .sheet(isPresented: $helpClicked) {
                        Text("sheet presented")
                    }
                Button(action: {helpClicked = !helpClicked}, label: {Text("click me")})
                Picker(selection: $somedata, label: Text("4th type of UI component")) {
                    ForEach(SomeBindable.allCases, id: \.self) { com in
                        Text(LocalizedStringKey(com.rawValue)).tag(com)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                UIKitController()
            }
        }.navigationBarTitle(Text("sd".capitalized), displayMode: .inline)
            .padding()
    }
}

struct UIKitController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
}

struct AButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .multilineTextAlignment(.center)
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .cornerRadius(8)
            .fixedSize()
            .padding()
        
    }
}



class ProgressViewModel: ObservableObject {
    
    @Published var currentStep: Double
    @Published var totalSteps: Double
    
    init?(currentStep: Int, total: Int) {
        guard currentStep < total else {return nil}
        self.currentStep = Double(currentStep)
        self.totalSteps = Double(total)
    }
}

struct CustomProgressView: View {
    @StateObject var vm: ProgressViewModel

    var body: some View {
        ProgressView("", value: vm.currentStep, total: vm.totalSteps)
//            .frame(width: 200, height: 200)
            .accentColor(.yellow)
//            .scaleEffect(x: 1, y: 4, anchor: .center)
//            .padding([.leading, .trailing], 10)
//            .clipShape(RoundedRectangle(cornerRadius: 1))
            .padding(.horizontal)
//            .cornerRadius(1)
//            .clipShape(Capsule())
            .onAppear {
                if vm.currentStep < vm.totalSteps {
                    vm.currentStep += 2
                }
            }
            .progressViewStyle(RoundProgressViewStyle())
//            .progressViewStyle(CircularProgressViewStyle())
//            .onReceive(vm.currentStep) { _ in
//                if vm.currentStep < vm.totalSteps {
//                    vm.currentStep += 2
//                }
//            }
    }
}
struct ShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
//            .cornerRadius(1)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6), radius: 4.0, x: 1.0, y: 2.0)
    }
}

struct RoundProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .frame(width: 250, height: 28)
                .foregroundColor(.gray)
                .overlay(Color.black.opacity(0.5)).cornerRadius(14)
            
            RoundedRectangle(cornerRadius: 14)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 250, height: 28)
                .foregroundColor(.yellow)
        }
        .padding()
    }
}
 


struct ContentView_Previews: PreviewProvider {
    static let localization = Bundle.main.localizations.map(Locale.init).first
    static let dynamicTypeSizes: [ContentSizeCategory] = [.extraSmall, .small, .medium, .large, .extraExtraExtraLarge]
//    static var str = "String"
    static var previews: some View {
//        BarChart()
        if #available(iOS 16.0, *) {
            Chart(generateData()) { item in
                BarMark(
                    x: .value("day", item.day),
                    y: .value("Amount", item.amount)
                )
            }
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 16.0, *) {
            Gauge(value: 40, in: 0...100) {
                Text("")
            }.foregroundColor(.yellow)
                .tint(.yellow)
            
            Gauge(value: 40, in: 0...100) {
                Text("")
            }.foregroundColor(.yellow)
                .tint(.yellow)
                .gaugeStyle(.accessoryCircular)
            
        } else {
            // Fallback on earlier versions
        }
        
            
        VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: "movie", withExtension: "mp4")!))
        VideoPlayer(player: AVPlayer(url: URL(string: "https://apple.com")!))
        CustomProgressView(vm: ProgressViewModel(currentStep: 3, total: 10)!)
        child3
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")

        if let loc = localization {
            child4
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .environment(\.locale, loc)
                .previewDisplayName(Locale.current.localizedString(forIdentifier: loc.identifier))
        }
        ForEach(dynamicTypeSizes, id: \.self) { sizeCategory in
            MainView()
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
                .environment(\.sizeCategory, sizeCategory)
                .previewDisplayName("\(sizeCategory)")
        }
    }
}

struct ActivityView: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView

    func makeUIView(context: UIViewRepresentableContext<ActivityView>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: .medium)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityView>) {
        uiView.startAnimating()
    }

}



struct CalorieBurnt: Identifiable {
    var day: String
    var amount: Double
    var id = UUID()
    var color: String = "red"
}

struct BarChart: View {
    
    var data: [CalorieBurnt] = [
        .init(day: "Monday", amount: 2100.00),
        .init(day: "Wed", amount: 2000.00),
        .init(day: "Fri", amount: 1800.00)
    ]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
//                ForEach(data) { item in
//                    BarMark(
//                        x: .value("Day", item.day),
//                        y: .value("Total", item.amount)
//                    )
//                    .foregroundStyle(by: .value("day Color", item.color))
//                }
                ForEach(generateData()) { item in
                           PointMark(
                               x: .value("Month", item.day),
                               y: .value("Amount", item.amount)
                           )
                       }
            }
        } else {
            // Fallback on earlier versions
            Capsule(style: .continuous)
                .frame(width: 10,height: 200)
        }
    }
}


struct BarChart2: View {
    
    var data: [CalorieBurnt] = [
        .init(day: "Monday", amount: 1500.00),
        .init(day: "Wed", amount: 2000.00),
        .init(day: "Fri", amount: 1200.00)
    ]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(data) { item in
                    PointMark(
                        x: .value("Month", item.day),
                        y: .value("Amount", item.amount)
                    )
                }
            }
            
        } else {
            // Fallback on earlier versions
            Capsule(style: .continuous)
                .frame(width: 10,height: 200)
        }
    }
}

enum Day: String, CaseIterable {
    case Monday
    case Tuesday
    case Wed
    case Thurs
    case Fri
    case Sat
    case Sun
}
   
func randomday() -> String {
    return Day.allCases.randomElement()?.rawValue ?? ""
}

func generateData() -> [CalorieBurnt] {
    var array: [CalorieBurnt] = []
    for _ in 0...50 {
        array.append(CalorieBurnt(day: randomday(), amount: Double.random(in: 1...1000)))
    }
    return array
}


