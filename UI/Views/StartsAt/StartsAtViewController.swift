//
//  ErrorViewController.swift
//  timetable
//
//  Created by Hoff Silva on 27/01/22.
//

import Combine
import UIKit
import Presentation

public protocol StartsAtViewControllerDelegate: AnyObject {
    func didTopOnCloseButton()
    func didTopOnSaveButton()
}

public class StartsAtViewController: UIViewController {
    
    var startsAtViewModel: StartsAtViewModel?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startsAtTitleLabel: UILabel!
    @IBOutlet weak var startsAtHourPickerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    private lazy var hourPickerView: HourPickerView = {
        let hourPickerView = HourPickerView()
        hourPickerView.prepareForConstraints()
        hourPickerView.clipsToBounds = false
        return hourPickerView
    }()
    
    public weak var delegate: StartsAtViewControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupBindings()
        setupViewHierarchy()
        setupConstraints()
        hourPickerView.delegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1) {
            self.view.alpha = 1
        }
//        startsAtViewModel?.lodaData()
    }
    
    private func setupViewHierarchy() {
        startsAtHourPickerView.addSubview(hourPickerView)
    }
    
    private func setupConstraints() {
        hourPickerView.centerVertically()
        hourPickerView.height(with: 116) // Exatamente 3 células (64+52)
        hourPickerView.pinLeft()
        hourPickerView.pinRight()
    }
    
    private func setupBindings() {
    
        //        errorViewModel?
        //            .didLoadWithErrorMessage = { errorDescription in
        //                self.errorDescriptionLabel.text = errorDescription
        //        }
        //
        //        errorViewModel?
        //            .shouldShowAllowCalendarAccessButton = { isAccessNotaGranted in
        //                self.allowCalendarAccessButton.isHidden = isAccessNotaGranted
        //            }
    }
    
    private func setupStyle() {
        setupLabelFont()
        setupLabelColor()
        setupCloseButton()
        hourPickerView.clipsToBounds = false
//        setupAllowCalendarAccessButton()
    }
    
    private func setupLabelFont() {
        startsAtTitleLabel.font = .rubikBold(80)
        startsAtTitleLabel.numberOfLines = 0
//        errorDescriptionLabel.font = .rubikBold(64)
    }
    
    private func setupLabelColor() {
        startsAtTitleLabel.textColor = .timetableText
    }
    
    private func setupCloseButton() {
        let font = UIFont.rubikBold(16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.timetableRed,
        ]
        let buttonTitle = NSAttributedString(string: Localizable.cancelButtonTitle(), attributes: attributes)
        closeButton.setAttributedTitle(buttonTitle, for: .normal)
        closeButton.addTarget(self, action: #selector(didTapOnCloseButton), for: .touchUpInside)
    }
    
    @objc private func didTapOnCloseButton() {
        UIView.animate(withDuration: 1) {
            self.view.alpha = 0
        } completion: { _ in
            self.delegate?.didTopOnCloseButton()
        }
    }
    
    private func setupHourPickerView() {
        let font = UIFont.rubikBold(16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.timetableRed,
        ]
        let buttonTitle = NSAttributedString(string: Localizable.allowCalendarAccessButtonTitle(), attributes: attributes)
//        allowCalendarAccessButton.setAttributedTitle(buttonTitle, for: .normal)
//        allowCalendarAccessButton.addTarget(self, action: #selector(didTapOnAllowCalendarAccessButton), for: .touchUpInside)
    }
    
    @objc private func didTapOnAllowCalendarAccessButton() {
        UIView.animate(withDuration: 1) {
            self.view.alpha = 0
        } completion: { _ in
//            self.delegate?.didTopOnAllowCalendarAccessButton()
        }
    }

}


extension StartsAtViewController: HourPickerViewDelegate {
    
    func hourPickerView(_ picker: HourPickerView, didSelectHour hour: String, period: String) {
        // Valor selecionado: hour = "1:30", period = "am"
        // Aqui você pode fazer o que quiser com o valor selecionado
        // Por exemplo, atualizar um ViewModel ou salvar o valor
    }
    
}
