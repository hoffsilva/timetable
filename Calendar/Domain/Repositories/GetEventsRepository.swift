//
//  GetEventsRepository.swift
//  Calendar
//
//  Created by Hoff Silva on 03/06/21.
//

protocol GetEventsRepository {
    func getEvents(from: Int, completion: @escaping ((Result<[Event], Error>) -> Void))
}
