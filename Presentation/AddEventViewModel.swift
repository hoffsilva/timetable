//
//  AddEventViewModel.swift
//  Presentation
//
//  Created by Hoff Henry Pereira da Silva on 2022-10-12.
//


import Foundation
import Domain
import Data

public final class AddEventViewModel: ObservableObject {
    
    private let addEventUseCase: AddEventUseCase
    private let currentDate: Date
    
    public var didGetErrorMessage: ((String)->Void)?
    public var didSaveEventSuccessfully: ((String)->Void)?
    public var numberOfDay: ((String)->Void)?
    public var nameOfMonth: ((String)->Void)?
    public var nameOfDay: ((String)->Void)?
    public var selectedDate: ((Date)->Void)?
    
    public init(
        addEventUseCase: AddEventUseCase,
        currentDate: Date
    ) {
        self.addEventUseCase = addEventUseCase
        self.currentDate = currentDate
    }
    
    public func loadCurrentDate() {
        numberOfDay?(currentDate.getDay())
        nameOfMonth?(currentDate.getLongMonth())
        nameOfDay?(currentDate.getDayOfWeek())
        selectedDate?(currentDate)
    }
    
    public func saveEvent(title: String, isAllDay: Bool, startDate: String?, endDate: String?, location: String? = nil, note: String? = nil) {
        let calendar = Calendar.current
        let startDateTime = parseDate(from: startDate) ?? currentDate
        let endDateTime = parseDate(from: endDate) ?? calendar.date(byAdding: .hour, value: 1, to: startDateTime) ?? currentDate
        
        let event = Event(
            startDate: startDateTime,
            endDate: endDateTime,
            isAllDay: isAllDay,
            location: location,
            title: title,
            year: calendar.component(.year, from: currentDate),
            day: calendar.component(.day, from: currentDate),
            acceptanceAnswer: .notAnswered,
            note: note
        )
        
        addEventUseCase.addEvent(event) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let eventIdentifier):
                    self?.didSaveEventSuccessfully?(eventIdentifier)
                case .failure(let error):
                    self?.didGetErrorMessage?(error.localizedDescription)
                }
            }
        }
    }
    
    private func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString, !dateString.isEmpty else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let time = formatter.date(from: dateString) {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: currentDate)
        }
        
        return nil
    }
    
    deinit {
        print("Bye \(#file)")
    }
    
}

