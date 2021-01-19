//
//  Diet.swift
//  00757039_HW4_CRUD
//
//  Created by User20 on 2021/1/20.
//

import Foundation
struct Diet: Identifiable, Codable{
    var id = UUID()
    var day: String
    var volume: Int
    var time: String
}
