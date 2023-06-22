//
//  String+Extensions.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/21/23.
//

import Foundation

extension String {
    var isEmptyOrWithWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
