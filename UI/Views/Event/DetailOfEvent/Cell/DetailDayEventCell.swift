//
//  DetailDayEventCell.swift
//  UI
//
//  Created by Hoff Silva on 02/03/22.
//

import UIKit
import Domain

class DetailDayEventCell: UITableViewCell {
    
    private lazy var hourLabel: UILabel = {
        let label = UILabel()
        label.prepareForConstraints()
        label.font = .rubikRegular(16)
        label.textAlignment = .justified
        label.textColor = .timetableGray
        return label
    }()
    
    private lazy var hourEventsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.prepareForConstraints()
        return collectionView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.prepareForConstraints()
        view.backgroundColor = .timetableGray
        return view
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Event>?

    private func setupViewsHierarchy() {
        self.contentView.addSubview(hourLabel)
        self.contentView.addSubview(hourEventsCollectionView)
        self.contentView.addSubview(separatorView)
    }
    
    private func setupViewsConstraints() {
        hourLabel.centerVertically()
        hourLabel.pinLeft(24)
        hourLabel.width(with: 48)
        hourEventsCollectionView.pinLeftInRelation(to: hourLabel.rightAnchor)
        hourEventsCollectionView.pinRight(24)
        hourEventsCollectionView.pinTop()
        hourEventsCollectionView.pinBottomInRelation(to: separatorView.topAnchor)
        separatorView.pinLeft(24)
        separatorView.pinRight(24)
        separatorView.pinBottom()
        separatorView.height(with: 1)
    }
    
    public func setupData(_ data: Hour) {
        registerCell()
        self.backgroundColor = .clear
        self.hourEventsCollectionView.backgroundColor = .clear
        self.hourEventsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupViewsHierarchy()
        setupViewsConstraints()
        dataSource = makeDataSource()
        hourLabel.text = data.name.lowercased()
        updateDataSource(listOfHour: data.events)
    }
    
    private func updateDataSource(listOfHour: [Event]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Event>()
        snapshot.appendSections([1])
        snapshot.appendItems(listOfHour, toSection: 1)
        dataSource?.apply(snapshot)
    }
    
    private func registerCell() {
        hourEventsCollectionView.register(DetailEventCell.self, forCellWithReuseIdentifier: String(describing: DetailEventCell.self))
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Event> {
        
        let cellRegistration = UICollectionView.CellRegistration
        <DetailEventCell, Event> { (cell, indexPath, item) in
            cell.setupData(item)
        }
        
        return UICollectionViewDiffableDataSource(collectionView: hourEventsCollectionView) { tableView, indexPath, itemIdentifier in
            tableView
                .dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let spacing = CGFloat(8)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(32)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1)
            group.interItemSpacing = .flexible(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }
    
}
