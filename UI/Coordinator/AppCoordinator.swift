//
//  AppCoordinator.swift
//  timetable
//
//  Created by Hoff Silva on 04/12/21.
//

import Domain
import UIKit


public final class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private var customLaunchScreenCoordinator: CustomLaunchScreenCoordinator?
    private var eventListViewCoordinator: EventListViewCoordinator?
    private var detailDayViewCoordinator: DetailDayViewCoordinator?
    private var addEventViewCoordinator: AddEventViewCoordinator?
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func start() {
        window.makeKeyAndVisible()
        showLaunchScreen()
    }
    
    private func showLaunchScreen() {
        self.customLaunchScreenCoordinator = CustomLaunchScreenCoordinator(window: window)
        self.customLaunchScreenCoordinator?.customLaunchScreenCoordinatorDelegate = self
        self.customLaunchScreenCoordinator?.start()
    }
    
    private func showEventListView() {
        eventListViewCoordinator = EventListViewCoordinator(window: window)
        eventListViewCoordinator?.eventListViewCoordinatorDelegate = self
        eventListViewCoordinator?.start()
    }
    
    private func showDetailOf(day: Day, from viewController: UIViewController, navigationController: TimeTableNavigationController) {
        detailDayViewCoordinator = DetailDayViewCoordinator(window: window, from: viewController, navigationController: navigationController, day: day)
        detailDayViewCoordinator?.detailDayViewCoordinatorDelegate = self
        detailDayViewCoordinator?.start()
    }
    
    private func showAddEventOf(day: Day, from viewController: UIViewController, navigationController: TimeTableNavigationController) {
        addEventViewCoordinator = AddEventViewCoordinator(window: window, from: viewController, navigationController: navigationController, day: day)
        addEventViewCoordinator?.addEventViewCoordinatorDelegate = self
        addEventViewCoordinator?.start()
    }
    
}

extension AppCoordinator: CustomLaunchScreenCoordinatorDelegate {
    
    func didLoadEvents() {
        self.showEventListView()
    }
    
}

extension AppCoordinator: EventListViewCoordinatorDelegate {
    
    func showDetail(of day: Domain.Day, from viewController: UIViewController, navigationController: TimeTableNavigationController) {
        self.showDetailOf(day: day, from: viewController, navigationController: navigationController)
    }
    
}

extension AppCoordinator: DetailDayViewCoordinatorDelegate {
    
    func callAddEventView(of day: Domain.Day, from viewController: UIViewController, navigationController: TimeTableNavigationController) {
        self.showAddEventOf(day: day, from: viewController, navigationController: navigationController)
    }
    
}

extension AppCoordinator: AddEventViewCoordinatorDelegate {
    
    func cleanCoordinator() {
        self.addEventViewCoordinator = nil
    }
    
}
