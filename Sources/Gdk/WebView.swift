import SafariServices
import SwiftUI
import WebKit

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    let url: URL
    let readerMode: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = readerMode
        return SFSafariViewController(url: url, configuration: configuration)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

class WebViewController: UIViewController, WKScriptMessageHandler {
    
    var wkWebView: WKWebView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.wkWebView = WKWebView(frame: self.view.bounds, configuration: getWKWebViewConfiguration())
        self.view.addSubview(self.wkWebView)
        if let url = URL(string: "http://localhost:someport") {
            //Bundle.main.url(forResource: "form", withExtension: "html") {
            self.wkWebView.load(URLRequest(url: url))
        }
    }
    
    private func getWKWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let data = message.body as? [String : String], let name = data["name"], let email = data["email"] {
            print("\(email) and  \(name)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        webView = WKWebView(frame: .zero)
        ////        webView.uiDelegate = self
        ////        webView.navigationDelegate = self
        //        webView.frame = view.frame
        ////        if let url = Bundle.main.url(
        ////            forResource: "form", withExtension: "html"
        ////        ) {
        ////            webView.load(URLRequest(url: URL(string: "https://google.com")!))
        ////        }
        //        webView.backgroundColor = .yellow
    }
}
     
struct WebkitView: View {
    @StateObject var viewModel = WebViewModel()
    var body: some View {
        VStack {
            HStack {
                Button(action: { viewModel.back() }) {
                    Image(systemName: "arrow.backward")
                }
                Button(action: { viewModel.forward() }) {
                    Image(systemName: "arrow.forward")
                }
                TextField("Enter url", text: $viewModel.urlString)
                    .textFieldStyle(.roundedBorder)
                Button("Go") {
                    viewModel.start()
                }
            }
            WkView(webView: viewModel.webView)
            // alternatively
            //            .onAppear{
            //                viewModel.start()
            //            }
        }.padding()
    }
}


struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        // within app
        WebkitView()
        // to leave app
      // Link("apple", destination: URL(string: "https://apple.com")!)
    }
}

final class WebViewModel: ObservableObject {
    @Published var urlString = "https://google.com"
    
    var webView: WKWebView
    init() {
        webView = WKWebView(frame: .zero)
//        webView.uiDelegate = self
//        webView.navigationDelegate = self
    }
    
    func start() {
        webView.load(URLRequest(url: URL(string: urlString)!))
    }
    
    func back() {
      webView.goBack()
    }
    func forward() {
      webView.goForward()
    }

}

// UIView example into SwiftUI View
struct WkView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    let webView: WKWebView

    func makeUIView(context: UIViewRepresentableContext<WkView>) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WkView>) {
        
    }

}

class WebController1: UIViewController,WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setup()
        // Do any additional setup after loading the view.
    }
    // window.webkit.messageHandlers.observer
    func setup() {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "observer")
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.frame = view.frame
        if let url = Bundle.main.url(
            forResource: "form", withExtension: "html"
        ) {
//            webView.load(URLRequest(url: url))
        }
        webView.backgroundColor = .yellow
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if let data = message.body as? [String : String],
           let name = data["name"], let email = data["email"] {
            //showUser(email: email, name: name)
            print(name); print(email)
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
