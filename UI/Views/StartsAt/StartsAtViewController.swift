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
    func didSelectTime(_ time: String, isStartTime: Bool)
}

public enum TimeSelectionFlow {
    case startOnly
    case startThenEnd
    case endOnly
}

public class StartsAtViewController: UIViewController {
    
    var startsAtViewModel: StartsAtViewModel?
    var isStartTime: Bool = true
    var selectionFlow: TimeSelectionFlow = .startOnly
    private var selectedTime: String?
    private var startTime: String?
    private var endTime: String?
    private var currentStep: Int = 1 // 1 = start, 2 = end
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startsAtTitleLabel: UILabel!
    @IBOutlet weak var startsAtHourPickerView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    private lazy var previousTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .rubikRegular(16)
        label.textColor = .timetableGray
        label.isHidden = true
        label.prepareForConstraints()
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .rubikBold(16)
        button.setTitleColor(.timetableRed, for: .normal)
        button.isHidden = true
        button.prepareForConstraints()
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
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
        updateTitleForTimeType()
        updateButtonText()
        nextButton.isHidden = false // Mostrar o botão
    }
    
    private func updateTitleForTimeType() {
        if selectionFlow == .startThenEnd {
            startsAtTitleLabel.text = currentStep == 1 ? "starts at" : "ends at"
        } else {
            startsAtTitleLabel.text = isStartTime ? "starts at" : "ends at"
        }
    }
    
    private func updateButtonText() {
        let font = UIFont.rubikBold(16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.timetableRed,
        ]
        
        var buttonText = "Confirmar"
        
        if selectionFlow == .startThenEnd {
            if currentStep == 1 {
                buttonText = "Next"
            } else {
                buttonText = "Salvar"
            }
        } else {
            buttonText = "Confirmar"
        }
        
        let buttonTitle = NSAttributedString(string: buttonText, attributes: attributes)
        nextButton.setAttributedTitle(buttonTitle, for: .normal)
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
        view.addSubview(previousTimeLabel)
        view.addSubview(backButton)
    }
    
    private func setupConstraints() {
        hourPickerView.centerVertically()
        hourPickerView.height(with: 116) // Exatamente 3 células (64+52)
        hourPickerView.pinLeft()
        hourPickerView.pinRight()
        
        // Constraints para previousTimeLabel
        previousTimeLabel.pinTop(160)
        previousTimeLabel.pinLeft(48)
        
        // Constraints para backButton - alinhar com nextButton
        backButton.pinLeft(48)
        backButton.centerVertically(inRelationTo: nextButton)
        backButton.height(with: 44)
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
        
        // Configurar botão de confirmar
        let confirmAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.timetableRed,
        ]
        let confirmButtonTitle = NSAttributedString(string: "Confirmar", attributes: confirmAttributes)
        nextButton.setAttributedTitle(confirmButtonTitle, for: .normal)
        nextButton.addTarget(self, action: #selector(didTapOnConfirmButton), for: .touchUpInside)
    }
    
    @objc private func didTapOnCloseButton() {
        UIView.animate(withDuration: 1) {
            self.view.alpha = 0
        } completion: { _ in
            self.delegate?.didTopOnCloseButton()
        }
    }
    
    @objc private func didTapOnConfirmButton() {
        guard let selectedTime = selectedTime else {
            return
        }
        
        if selectionFlow == .startThenEnd {
            if currentStep == 1 {
                // Primeira etapa: salvar start time e ir para end time
                startTime = selectedTime
                currentStep = 2
                self.selectedTime = nil // Reset selection para próxima etapa
                updateTitleForTimeType()
                updateButtonText()
                showPreviousTime()
                // Resetar picker para uma hora padrão (1 hora após start)
                resetPickerForEndTime()
            } else {
                // Segunda etapa: salvar end time e finalizar
                endTime = selectedTime
                UIView.animate(withDuration: 1) {
                    self.view.alpha = 0
                } completion: { _ in
                    self.delegate?.didSelectTime(self.startTime ?? "", isStartTime: true)
                    self.delegate?.didSelectTime(self.endTime ?? "", isStartTime: false)
                }
            }
        } else {
            // Fluxo normal (individual)
            UIView.animate(withDuration: 1) {
                self.view.alpha = 0
            } completion: { _ in
                self.delegate?.didSelectTime(selectedTime, isStartTime: self.isStartTime)
            }
        }
    }
    
    private func showPreviousTime() {
        if let startTime = startTime {
            let displayTime = convertTo12HourFormat(startTime)
            previousTimeLabel.text = "starts at \(displayTime)"
            previousTimeLabel.isHidden = false
            backButton.isHidden = false // Mostrar botão voltar na segunda etapa
        }
    }
    
    @objc private func didTapBackButton() {
        // Voltar para a primeira etapa
        currentStep = 1
        startTime = nil
        selectedTime = nil
        previousTimeLabel.isHidden = true
        backButton.isHidden = true
        updateTitleForTimeType()
        updateButtonText()
    }
    
    private func convertTo12HourFormat(_ time24: String) -> String {
        let formatter24 = DateFormatter()
        formatter24.dateFormat = "HH:mm"
        
        let formatter12 = DateFormatter()
        formatter12.dateFormat = "h:mm a"
        
        if let date = formatter24.date(from: time24) {
            return formatter12.string(from: date).lowercased()
        }
        
        return time24
    }
    
    private func resetPickerForEndTime() {
        // Reset picker aqui se necessário
        // O picker deve automaticamente mostrar uma hora padrão para fim
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
        // Combinar hora e período (am/pm) em formato 24h para armazenar
        selectedTime = convertTo24HourFormat(hour: hour, period: period)
        
        // Se estamos na tela "ends at", mostrar formato 12h na label do picker
        if selectionFlow == .startThenEnd && currentStep == 2 {
            // Atualizar exibição do picker para mostrar formato 12h
            // Isso será feito automaticamente pelo HourPickerView
        }
    }
    
    private func convertTo24HourFormat(hour: String, period: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let timeString = "\(hour) \(period)"
        
        if let date = formatter.date(from: timeString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "HH:mm"
            return outputFormatter.string(from: date)
        }
        
        return hour // fallback
    }
    
}
