//
//  TableviewViewController.swift
//  RxSwiftDemo
//
//  Created by yjk on 2020/4/4.
//  Copyright © 2020 tiens. All rights reserved.
//

import UIKit

fileprivate let cellID = "cellID"

class TableviewViewController: UIViewController {
    
    let viewModel = TableviewViewModel()
    
    let disposeBag = DisposeBag()
    
    var dataSource: [cellModel] = []
    
    deinit {
        print("销毁list")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        addsubviews()
        bindViewModel()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "list", style: .plain, target: self, action: #selector(reloadAction))
    }
    
    @objc func reloadAction() {
        let parameters = ["page":2, "pageSize":12]
        viewModel.requestCommond
            .onNext(parameters)
    }
    
    func addsubviews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        let parameters = ["page":1, "pageSize":15]
        viewModel.requestCommond
            .onNext(parameters)
        
        viewModel.reloadCommond.subscribe(onNext: { [weak self] (source) in
            self?.dataSource = source
            self?.tableView.reloadData()
            print("请求结果：\(source)")
        }).disposed(by: disposeBag)
    }
    

    //MARK:Getter
    lazy var tableView: UITableView = {
        let tableV = UITableView.init(frame: CGRect.zero, style: .plain)
        tableV.backgroundColor = UIColor.clear
        tableV.delegate = self
        tableV.dataSource = self
        tableV.rowHeight = 50
        tableV.separatorColor = UIColor.clear
        tableV.separatorInset = UIEdgeInsets.zero
        tableV.showsVerticalScrollIndicator = false
        
        tableV.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        return tableV
    }()

}

extension TableviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TableViewCell
        cell.selectionStyle = .none
        cell.model = self.dataSource[indexPath.row]
        return cell
    }
}
