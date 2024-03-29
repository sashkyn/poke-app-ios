//
//  PokemonProfileViewController.swift
//  PokeApp
//
//  Created by marcenuk on 09/07/2019.
//  Copyright © 2019 marcenyuk. All rights reserved.
//

import UIKit

private struct Constants {
    static let title: String = "Pokemon profile"
}

final class PokemonProfileViewController: UIViewController {
    
    var viewModel: PokemonProfileViewModel!
    
    private let tableViewController: UITableViewController
    
    private let tableAdapter: TableAdapter
    
    // MARK: Views
    private var tableView: UITableView {
        return self.tableViewController.tableView
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view 
    }()
    
    init() {
        self.tableViewController = UITableViewController(style: .grouped)
        self.tableAdapter = TableAdapter(tableView: self.tableViewController.tableView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.viewModel.fetchProfile()
    }
    
    func setup() {
        self.view.backgroundColor = UIColor.white
        
        self.setupTable()
        self.setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = Constants.title
    }
    
    func setupTable() {
        self.tableViewController.willMove(toParent: self)
        self.addChild(self.tableViewController)
        self.view.addSubview(self.tableView)        
        self.tableViewController.didMove(toParent: self)
        
        self.tableViewController.refreshControl = self.refreshControl
        
        self.tableView.backgroundColor = nil
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        self.tableView.register(cellClass: PokemonDetailTableViewCell.self)
        self.tableView.register(cellClass: SpriteViewerTableViewCell.self)
    }
    
    func setupBindings() {
        self.viewModel.onStartLoading = { [weak self] in
            self?.refreshControl.beginRefreshing()
        }
        self.viewModel.onStopLoading = { [weak self] in
            self?.refreshControl.endRefreshing()
        }
        self.viewModel.onProfileData = { [weak self] sectionsModels in
            self?.tableAdapter.update(viewModels: sectionsModels)
        }
        self.viewModel.onUpdateSpriteModel = { [unowned self] cellModel in
            self.tableAdapter.update(cellModel, for: 0, in: 1, reload: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.frame = CGRect(x: 0.0, 
                                      y: self.view.safeAreaInsets.top, 
                                      width: self.view.safeAreaLayoutGuide.layoutFrame.width, 
                                      height: self.view.safeAreaLayoutGuide.layoutFrame.height)
    }
}

// MARK: Actions
private extension PokemonProfileViewController {
    
    @objc
    func refresh(sender: UIRefreshControl) {
        self.viewModel.fetchProfile()
    }
}
