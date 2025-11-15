//
//  AddEventViewCoordinator.swift
//  UI
//
//  Created by Hoff Henry Pereira da Silva on 2022-10-12.
//


import UIKit
import Presentation
import Domain
import Data

enum TimeSelectionType {
    case startTime
    case endTime
}

protocol AddEventViewCoordinatorDelegate: AnyObject {
    func cleanCoordinator()
}

public final class AddEventViewCoordinator: Coordinator {
 
    private let window: UIWindow
    private var navigationController: TimeTableNavigationController
    private var transitionOrigin: DetailDayViewController?
    private var addEventViewController: AddEventViewController?
    private var addEventViewModel: AddEventViewModel?
    private var startsAtViewController: StartsAtViewController?
    private var day: Day
    
    weak var addEventViewCoordinatorDelegate: AddEventViewCoordinatorDelegate?
    
    public init(window: UIWindow,
                from transitionOrigin: UIViewController,
                navigationController: TimeTableNavigationController,
                day: Day) {
        self.window = window
        self.navigationController = navigationController
        self.transitionOrigin = transitionOrigin as? DetailDayViewController
        self.day = day
    }
    
    public func start() {
        let calendarManager = CalendarManagerImpl()
        let addEventRepository = AddEventRepositoryImp(calendarManager: calendarManager)
        let addEventUseCase = AddEventUseCaseImp(addEventRepository: addEventRepository)
        addEventViewModel = AddEventViewModel(addEventUseCase: addEventUseCase, currentDate: day.date)
        addEventViewController = AddEventViewController.loadFromNib()
        addEventViewController?.addEventViewModel = self.addEventViewModel
        addEventViewController?.overrideUserInterfaceStyle = window.overrideUserInterfaceStyle
        addEventViewController?.transitioningDelegate = addEventViewController
        addEventViewController?.modalPresentationStyle = .overFullScreen
        addEventViewController?.addEventViewControllerDelegate = self
        navigationController.presentedViewController?.present(addEventViewController!, animated: true, completion: nil)
    }
    
    private func dismissAddEventViewController() {
        self.addEventViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.addEventViewCoordinatorDelegate?.cleanCoordinator()
        })
    }
    
    private func showStartsAtScreen(for timeType: TimeSelectionType) {
        let startsAtViewModel = StartsAtViewModel()
        startsAtViewController = StartsAtViewController.loadFromNib()
        startsAtViewController?.startsAtViewModel = startsAtViewModel
        startsAtViewController?.delegate = self
        startsAtViewController?.overrideUserInterfaceStyle = window.overrideUserInterfaceStyle
        startsAtViewController?.modalPresentationStyle = .overFullScreen
        
        // Configurar o tipo de seleção
        startsAtViewController?.isStartTime = (timeType == .startTime)
        
        addEventViewController?.present(startsAtViewController!, animated: true)
    }
    
    deinit {
        print("Bye \(#file)")
    }

}

extension AddEventViewCoordinator: AddEventViewControllerDelegate {
    func didTapOnCancelButton() {
        dismissAddEventViewController()
    }
    
    func didTapOnStartField() {
        showStartsAtScreenWithFlow()
    }
    
    func didTapOnEndField() {
        showStartsAtScreen(for: .endTime)
    }
    
    private func showStartsAtScreenWithFlow() {
        let startsAtViewModel = StartsAtViewModel()
        startsAtViewController = StartsAtViewController.loadFromNib()
        startsAtViewController?.startsAtViewModel = startsAtViewModel
        startsAtViewController?.delegate = self
        startsAtViewController?.overrideUserInterfaceStyle = window.overrideUserInterfaceStyle
        startsAtViewController?.modalPresentationStyle = .overFullScreen
        
        // Configurar para fluxo start → end
        startsAtViewController?.selectionFlow = .startThenEnd
        startsAtViewController?.isStartTime = true
        
        addEventViewController?.present(startsAtViewController!, animated: true)
    }
}

extension AddEventViewCoordinator: StartsAtViewControllerDelegate {
    public func didTopOnCloseButton() {
        startsAtViewController?.dismiss(animated: true) {
            self.startsAtViewController = nil
        }
    }
    
    public func didTopOnSaveButton() {
        // Implementaremos depois
    }
    
    public func didSelectTime(_ time: String, isStartTime: Bool) {
        if isStartTime {
            addEventViewController?.startDateTextField.text = time
        } else {
            addEventViewController?.endDateTextField.text = time
        }
        
        // Só dismiss se não estamos no fluxo startThenEnd ou se acabamos de setar o endTime
        if startsAtViewController?.selectionFlow != .startThenEnd || !isStartTime {
            startsAtViewController?.dismiss(animated: true) {
                self.startsAtViewController = nil
            }
        }
    }
}
