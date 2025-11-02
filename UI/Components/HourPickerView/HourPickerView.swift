//
//  HourPickerViewController.swift
//  UI
//
//  Created by Hoff Silva on 2023-02-09.
//

import UIKit

protocol HourPickerViewDelegate: AnyObject {
    func hourPickerView(_ picker: HourPickerView, didSelectHour hour: String, period: String)
}

final class HourPickerView: UIView {
    
    private class Layout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            scrollDirection = .vertical
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            itemSize = CGSize(width: 150, height: 62)
        }
    }
    
    private var started = false
    weak var delegate: HourPickerViewDelegate?
    private var lastSelectedIndex: Int = -1
    private var lastPeriod: String = ""
    
    private lazy var collectionView: UICollectionView = {
        let scrollview = UICollectionView(frame: .zero, collectionViewLayout: Layout())
        scrollview.prepareForConstraints()
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.clipsToBounds = false
        scrollview.decelerationRate = .normal
        scrollview.register(HourPickerViewCell.self, forCellWithReuseIdentifier: String(describing: HourPickerViewCell.self))
        return scrollview
    }()
    
    private lazy var hourPeriodLabel: UILabel = {
        let label = UILabel()
        label.prepareForConstraints()
        label.textAlignment = .left
        label.textColor = .timetableText
        label.font = .rubikBold(52)
        return label
    }()
    
    private lazy var hoursList: [(String, String)] = {
        var hours: [(String, String)] = []
        
        for hour in 12...12 {
            hours.append(("\(hour):00", "am"))
            hours.append(("\(hour):30", "am"))
        }
        
        for hour in 1...11 {
            hours.append(("\(hour):00", "am"))
            hours.append(("\(hour):30", "am"))
        }
        
        for hour in 12...12 {
            hours.append(("\(hour):00", "pm"))
            hours.append(("\(hour):30", "pm"))
        }
        
        for hour in 1...11 {
            hours.append(("\(hour):00", "pm"))
            hours.append(("\(hour):30", "pm"))
        }
        
        return hours
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
        self.backgroundColor = .timetableSystemBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        setupCollectionViewInsets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViewHierarchy() {
        self.addSubview(collectionView)
        self.addSubview(hourPeriodLabel)
    }
    
    private func setupConstraints() {
        collectionView.pinTop()
        collectionView.pinLeft()
        collectionView.pinBottom(-15)
        collectionView.pinRightInRelation(to: hourPeriodLabel.leftAnchor)
        hourPeriodLabel.centerVertically()
        hourPeriodLabel.pinRight()
    }
    
    private func setupCollectionViewInsets() {
        let cellHeight: CGFloat = 62
        let viewHeight: CGFloat = 116
        let centerOffset = (viewHeight - cellHeight) / 2 + 6 // 22pt para centralizar melhor
        
        collectionView.contentInset = UIEdgeInsets(top: centerOffset, left: 0, bottom: centerOffset, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    func getCurrentSelectedValue() -> (hour: String, period: String)? {
        let centerPoint = CGPoint(
            x: collectionView.bounds.midX,
            y: collectionView.bounds.midY
        )
        
        let centerPointInContent = CGPoint(
            x: centerPoint.x,
            y: collectionView.contentOffset.y + centerPoint.y - collectionView.contentInset.top
        )
        
        if let indexPath = collectionView.indexPathForItem(at: centerPointInContent),
           indexPath.row < hoursList.count {
            let selectedHour = hoursList[indexPath.row]
            return (selectedHour.0, selectedHour.1)
        }
        return nil
    }

}

extension HourPickerView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HourPickerViewCell.self), for: indexPath)
        guard let hourPickerViewCell = cell as? HourPickerViewCell else { return cell }
        if indexPath.row == 0 && !started {
            hourPickerViewCell.updateZoom(scale: 1.0, alpha: 1.0)
            lastSelectedIndex = 0
            lastPeriod = hoursList[indexPath.row].1
            self.hourPeriodLabel.text = hoursList[indexPath.row].1
            started = true
            
            // Notifica que a primeira célula está selecionada
            DispatchQueue.main.async {
                let selectedHour = self.hoursList[0]
                self.delegate?.hourPickerView(self, didSelectHour: selectedHour.0, period: selectedHour.1)
            }
        }
        hourPickerViewCell.configure(with: hoursList[indexPath.row].0)
        return hourPickerViewCell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hoursList.count
    }
    
}

extension HourPickerView: UICollectionViewDelegate {
    
}

extension HourPickerView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellsZoomEffect()
        updateHourPeriodLabel()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellHeight: CGFloat = 62.0
        let targetY = targetContentOffset.pointee.y + collectionView.contentInset.top
        let targetRow = round(targetY / cellHeight)
        let adjustedY = targetRow * cellHeight - collectionView.contentInset.top
        
        targetContentOffset.pointee.y = adjustedY
    }
    
    private func updateCellsZoomEffect() {
        let visibleCells = collectionView.visibleCells
        let collectionViewCenter = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
        
        for cell in visibleCells {
            guard let hourCell = cell as? HourPickerViewCell else { continue }
            
            let cellCenter = collectionView.convert(cell.center, to: collectionView)
            let distance = abs(cellCenter.y - collectionViewCenter.y)
            let cellHeight: CGFloat = 62.0
            let maxEffectDistance = cellHeight
            
            let normalizedDistance = min(distance / maxEffectDistance, 1.0)
            let scale = max(0.0, 1.0 - normalizedDistance)
            let alpha = 0.5 + (scale * 0.5)
            
            hourCell.updateZoom(scale: scale, alpha: alpha)
        }
    }
    
    private func updateHourPeriodLabel() {
        let cellHeight: CGFloat = 62.0
        let adjustedOffset = collectionView.contentOffset.y + collectionView.contentInset.top
        let centerRow = round(adjustedOffset / cellHeight)
        let selectedIndex = Int(centerRow)
        
        if selectedIndex >= 0 && selectedIndex < hoursList.count {
            let currentPeriod = hoursList[selectedIndex].1
            // Só atualiza se mudou o período
            if currentPeriod != lastPeriod {
                lastPeriod = currentPeriod
                hourPeriodLabel.text = currentPeriod
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifySelectedValue()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifySelectedValue()
        }
    }
    
    private func notifySelectedValue() {
        let cellHeight: CGFloat = 62.0
        let adjustedOffset = collectionView.contentOffset.y + collectionView.contentInset.top
        let centerRow = round(adjustedOffset / cellHeight)
        let selectedIndex = Int(centerRow)
        
        if selectedIndex >= 0 && selectedIndex < hoursList.count {
            if selectedIndex != lastSelectedIndex {
                lastSelectedIndex = selectedIndex
                let selectedHour = hoursList[selectedIndex]
                delegate?.hourPickerView(self, didSelectHour: selectedHour.0, period: selectedHour.1)
            }
        }
    }
}

final fileprivate class HourPickerViewCell: UICollectionViewCell {
    
    lazy var hourLabel: UILabel = {
        let label = UILabel()
        label.prepareForConstraints()
        label.textAlignment = .right
        label.textColor = .timetableText
        label.font = .rubikBold(32)
        label.alpha = 0.5
        return label
    }()
    
    private let baseFontSize: CGFloat = 32
    private let maxFontSize: CGFloat = 52
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Cell Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetLabel()
    }
    
    private func resetLabel() {
        hourLabel.text = nil
        hourLabel.font = .rubikBold(baseFontSize)
        hourLabel.alpha = 0.5
    }
    
    private func setupViewHierarchy() {
        contentView.addSubview(hourLabel)
    }
    
    private func setupConstraints() {
        hourLabel.pinRight()
        hourLabel.centerVertically()
        hourLabel.pinLeft()
    }
    
    func configure(with text: String) {
        hourLabel.text = text
    }
    
    func updateZoom(scale: CGFloat, alpha: CGFloat) {
        let fontSize = baseFontSize + (maxFontSize - baseFontSize) * scale
        let clampedFontSize = max(baseFontSize, min(maxFontSize, fontSize))
        let clampedAlpha = max(0.5, min(1.0, alpha))
        
        self.hourLabel.font = .rubikBold(clampedFontSize)
        self.hourLabel.alpha = clampedAlpha
    }
    
    func zoomingIn(offset: Double, alpha: CGFloat? = nil) {
        let size = self.hourLabel.font.pointSize + offset
        self.hourLabel.font = self.hourLabel.font.withSize(size < maxFontSize ? size : maxFontSize)
        if let alpha = alpha { self.hourLabel.alpha = alpha }
        self.hourLabel.alpha += 0.1
    }
    
    func zoomingOut(offset: Double) {
        let size = self.hourLabel.font.pointSize - offset
        self.hourLabel.font = self.hourLabel.font.withSize(size > baseFontSize ? size : baseFontSize)
        self.hourLabel.alpha -= self.hourLabel.alpha > 0.5 ? 0.1 : 0
    }
    
}
