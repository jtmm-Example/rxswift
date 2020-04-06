//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by yiens on 2020/4/3.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit
import RxSwift



class ViewController: UIViewController {
    
    @IBOutlet weak var accTf: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    
    let loginViewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "list", style: .plain, target: self, action: #selector(listAction))
       bindViewModel()
    }
    
    func bindViewModel() {
        
        //TODO: .retry() 不起作用，待研究。。。
        loginViewModel.resultCommond
        .asObserver()
        .retry()
           .subscribe(onNext: { [weak self] (result) in
                self?.responseTextView.text = result
                if result == "200" {
                    self?.listAction()
                }
           }, onError: { (error) in
               self.view.makeToast(error.localizedDescription)
           }).disposed(by: disposeBag)
    }
    
   
    @IBAction func loginaction(_ sender: UIButton) {
        
        let username = accTf.text
        let password = passTF.text
        
        let par: [String : Any] = ["loginname":username ?? "", "loginpwd":password ?? "", "userFlage":"1","terminalType": "1"]
        loginViewModel.loginCommond.onNext(par)
        
//        loginViewModel.rxMoyaParvider(parameter: par) { (success) in
//            print(success)
//        }
    }
    
    
    @objc func listAction() {
        navigationController?.pushViewController(TableviewViewController(), animated: true)
    }
    
}

