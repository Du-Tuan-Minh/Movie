//
//  Extension + Date.swift
//  Movies
//
//  Created by DuTuanMinh on 2/4/25.
//

import UIKit

extension Date {
  func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
  }
  
  func toHoursAndMinutes(time: Int) -> String {
    let hours = time / 60
    let minutes = time % 60
    return "\(hours)h \(minutes)m"
  }
  
  func getYear(date: Date) -> Int {
    let calendar = Calendar.current
    return calendar.component(.year, from: date)
  }
}
