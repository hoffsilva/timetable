//
//  Section.swift
//  timetable
//
//  Created by Hoff Silva on 06/06/21.
//

struct SectionForEvents: Hashable {
    var month: String
    var days: [Day]
    var stringDays: [String]
    var events: [Event]
}