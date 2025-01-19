//
//  ContentView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    enum StoreType: String {
        case customer
        case storeOwner
    }
    @AppStorage("isStoreType") var isStoreType: String = StoreType.storeOwner.rawValue
    @AppStorage("isLogin") var isLogin: Bool = false
    
        var colors = ["Red", "Green", "Blue", "Tartan"]
        @State private var selectedColor = "Red"

        var body: some View {
            VStack {
                Picker("Please choose a color", selection: $selectedColor) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
                Text("You selected: \(selectedColor)")
            }
        }
    }

//    var body: some View {
//        
//        
//        VStack {
//            Button("Customer") {
//                isStoreType = StoreType.customer.rawValue
//            }.padding(.top, 40)
//            
//            Button("StoreOwner") {
//                isStoreType = StoreType.storeOwner.rawValue
//            }.padding(.top, 40)
//            
//        }
//        .padding()
//    }
//}

#Preview {
    ContentView()
}
