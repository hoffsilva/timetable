//
//  EventListViewController.swift
//  timetable
//
//  Created by Hoff Silva on 25/12/21.
//

import UIKit
import Combine
import Resolver

class EventListViewController: UIViewController {
    
    @Injected private var viewModel: EventViewModel
    
    @IBOutlet weak var listViewTableView: UITableView!
    
    private lazy var dataSource = makeDataSource()
    private var bag = Set<AnyCancellable>()
    
    let appearence = AppearenceToggle()
    private lazy var userInterfaceStyleNameLabel: UILabel = {
        let label = UILabel()
        label.prepareForConstraints()
        label.font = .rubikRegular(12)
        label.addCharacterSpacing(kernValue: 50)
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(animateUserInterfaceStyle))
        appearence.addGestureRecognizer(tap)
        navigationController?.view.addSubview(appearence)
        navigationController?.view.addSubview(userInterfaceStyleNameLabel)
        appearence.height(with: 18)
        appearence.width(with: 27)
        appearence.pinTop(60)
        appearence.pinLeft(24)
        
        userInterfaceStyleNameLabel.centerVertically(inRelationTo: appearence)
        userInterfaceStyleNameLabel.pinLeftInRelation(to: appearence.rightAnchor, 8)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.requestAccess()
        registerCell()
        listViewTableView.dataSource = dataSource
        listViewTableView.delegate = self
        listViewTableView.separatorColor = .clear
        setAppearenceToggleTitle()
        setupBindings()
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<Month, Day> {
        UITableViewDiffableDataSource(tableView: listViewTableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventCell.self), for: indexPath) as? EventCell else { return UITableViewCell() }
            cell.setupData(itemIdentifier)
            return cell
        }
    }
    
    func setupBindings() {
        viewModel
            .$sections
            .sink { [weak self] events in
                self?.updateDataSource(listOfMonth: events)
            }.store(in: &bag)
    }
    
    private func updateDataSource(listOfMonth: [Month]) {
        var snapshot = NSDiffableDataSourceSnapshot<Month, Day>()
        
        dataSource.defaultRowAnimation = UITableView.RowAnimation.top
        
        snapshot.appendSections(listOfMonth)
        
        for month in listOfMonth {
            snapshot.appendItems(month.days, toSection: month)
        }
        
        dataSource.apply(snapshot)
    }
    
    private func registerCell() {
        let nibName = UINib(nibName: String(describing: EventCell.self), bundle: nil)
        listViewTableView.register(nibName, forCellReuseIdentifier: String(describing: EventCell.self))
    }
    
    @objc func animateUserInterfaceStyle() {
        UIView.animate(withDuration: 0.2) {
            self.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle == .dark ? .light : .dark
            self.view.layoutIfNeeded()
        }
        appearence.changeUserInterfaceStyleAnimated()
        setAppearenceToggleTitle()
    }
    
    func setAppearenceToggleTitle() {
        userInterfaceStyleNameLabel.text = self.overrideUserInterfaceStyle == .dark ? "LIGHT MODE" : "DARK MODE"
        userInterfaceStyleNameLabel.textColor = self.overrideUserInterfaceStyle == .dark ? .white : .black
    }
    
    private func createSectionHeaderView(with title: String?) -> UIView  {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        backgroundView.backgroundColor = .systemBackground
        let label = UILabel()
        label.font = .rubikBold(40)
        label.text = title
        label.addCharacterSpacing(kernValue: -2)
        label.textColor = .timetableGray
        label.prepareForConstraints()
        backgroundView.addSubview(label)
        label.pinLeft(24)
        label.centerHorizontally()
        return backgroundView
    }
    
    
}

extension EventListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionHeaderView(
            with: dataSource.sectionIdentifier(for: section)?.name
        )
    }
    
}
