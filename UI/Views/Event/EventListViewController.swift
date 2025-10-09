//
//  EventListViewController.swift
//  timetable
//
//  Created by Hoff Silva on 25/12/21.
//

import UIKit
import Presentation
import Domain
import Data

public protocol EventListViewControllerDelegate: AnyObject {
    func didLoadDataWithAccessNotGranted()
    func didTapToDetail(day: Day, from viewController: UIViewController)
}

public class EventListViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @Injected private var viewModel: EventViewModel
    
    @IBOutlet weak var listViewTableView: UITableView!
    
    public weak var delegate: EventListViewControllerDelegate?
    
    private lazy var dataSource = makeDataSource()
    
    private let saltedTag = 1000
    
    var cell: EventCell?
    
    private lazy var addEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Event", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .rubikBold(20)
        return button
    }()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.requestAccess()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        listViewTableView.dataSource = dataSource
        listViewTableView.delegate = self
        listViewTableView.separatorColor = .clear
        setupBindings()
        setupViews()
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
            .sections = { [weak self] events in
                DispatchQueue.main.async {
                    self?.updateDataSource(listOfMonth: events)
                }
            }
        
        viewModel
            .didGetErrorMessage = { [weak self] errorMessage in
                DispatchQueue.main.async {
                    self?.delegate?.didLoadDataWithAccessNotGranted()
                }
            }
        
        addEventButton.addTarget(self, action: #selector(didTapToAddEvent), for: .touchUpInside)
    }
    
    func setupViews() {
        navigationController?.navigationBar.addSubview(addEventButton)
        addEventButton.centerVertically()
        addEventButton.pinRight(24)
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
        let nibName = UINib(nibName: String(describing: EventCell.self), bundle: Bundle(for: EventCell.self))
        listViewTableView.register(nibName, forCellReuseIdentifier: String(describing: EventCell.self))
    }
    
    private func createSectionHeaderView(with title: String?) -> UIView  {
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        backgroundView.backgroundColor = .systemBackground
        let label = UILabel()
        label.font = .rubikBold(40)
        label.text = title
        label.textColor = .timetableGray
        label.prepareForConstraints()
        backgroundView.addSubview(label)
        label.pinLeft(24)
        label.pinTop(16)
        label.pinBottom()
        return backgroundView
    }
    
    @objc private func didTapToAddEvent() {
        print("Add event")
    }
}

extension EventListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView =  createSectionHeaderView(
            with: viewModel.months?[section].name.capitalized
        )
        headerView.tag = section+saltedTag
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let day = viewModel.months?[indexPath.section].days[indexPath.row] else { return }
        self.cell = tableView.cellForRow(at: indexPath) as? EventCell
        
        if let view = tableView.subviews.filter({ view in
            return view.tag == indexPath.section+saltedTag
        }).first {
            self.scrollSectionTo(y: view.frame.minY) {
                self.delegate?.didTapToDetail(day: day, from: self)
            }
        }
        
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //        transition.startingPoint = cell!.eventDayLabel.center
        //        t
        guard let originView = cell?.eventDayLabel else { return nil }
        
        return ShowTransition()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //        transition.transitionMode = .dismiss
        //        transition.startingPoint = cell!.center
        return DismissTransition()
    }
    
    private func scrollSectionTo(y: CGFloat, completion: @escaping (()->Void)) {
        self.listViewTableView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
}
