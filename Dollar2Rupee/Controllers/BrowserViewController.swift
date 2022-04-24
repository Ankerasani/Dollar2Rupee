//
//  DetailsViewCOntroller.swift
//  Dollar2Rupee
//
//  Created by Ankerasani on 4/6/19.
//  Copyright © 2019 Ankersani. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {
    
    // MARK: - class properties
    
    fileprivate let keyLoading = "loading"
    fileprivate let keyEstimateProgress = "estimatedProgress"
    
    
    open var URLToLoad: String = ""
    open var progressTintColor : UIColor?
    open var trackTintColor : UIColor?
    fileprivate var webView: WKWebView
    
    @IBOutlet fileprivate weak var loadingProgress: UIProgressView!
    @IBOutlet fileprivate weak var webViewContainer: UIView!
    
    // MARK: - life cycle
    
    required init?(coder aDecoder: NSCoder) {
        webView = WKWebView()
        super.init(coder: aDecoder)
        webView.navigationDelegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        webView = WKWebView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = false
        viewConfigurations()
        registerObservers()
    }
    
    deinit {
        removeObservers()
        visibleActivityIndicator(false)
    }
    
    // MARK: - private functions
    fileprivate func viewConfigurations() {
        //These are the changes for UnderTopBars & UnderBottomBars
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        loadingProgress.trackTintColor = trackTintColor
        loadingProgress.progressTintColor = progressTintColor
        
        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: webView, attribute: $0, relatedBy: .equal, toItem: webViewContainer, attribute: $0, multiplier: 1, constant: 0)
        })
        guard let url = URL(string: URLToLoad) else {
            print("Couldn't load create NSURL from: " + URLToLoad)
            return
        }
        webView.load(URLRequest(url: url))
        
    }
    
    fileprivate func registerObservers() {
        webView.addObserver(self, forKeyPath: keyLoading, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: keyEstimateProgress, options: .new, context: nil)
    }
    
    fileprivate func removeObservers() {
        webView.removeObserver(self, forKeyPath: keyLoading)
        webView.removeObserver(self, forKeyPath: keyEstimateProgress)
    }
    
    fileprivate func visibleActivityIndicator(_ visible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = visible
    }
    
    fileprivate func showAlert(_ title: String, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title,
                                                                   message: message,
                                                                   preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - Overridden Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == keyEstimateProgress) {
            loadingProgress.isHidden = webView.estimatedProgress == 1
            loadingProgress.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        visibleActivityIndicator(true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        visibleActivityIndicator(false)
        showAlert("", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        visibleActivityIndicator(false)
        loadingProgress.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
            self.webView.load(URLRequest(url: url))
            decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
        }
    }
}
