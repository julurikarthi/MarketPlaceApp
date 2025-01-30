//
//  DashBoardViewViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//

import Foundation
import Combine
class DashBoardViewViewModel: ObservableObject {
    @Published var movetoSelectLocation: Bool = false
    @Published var address: Address?
}
