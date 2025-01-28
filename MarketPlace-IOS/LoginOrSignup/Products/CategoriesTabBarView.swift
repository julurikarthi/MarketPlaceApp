//
//  CategoriesTabBarView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/27/25.
//
import SwiftUI

struct CategoriesTabBarView: View {
    let tabs: [Category]
    @State private var selectedTab = 0
    @State private var tabXPositions: [CGFloat] = []
    var onTabSelection: ((Category) -> Void)
    var body: some View {
        VStack {
            // Tab bar (horizontal scrolling with underline)
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(tabs.indices, id: \.self) { index in
                            Text(tabs[index].categoryName)
                                .fontWeight(selectedTab == index ? .bold : .regular)
                                .foregroundColor(selectedTab == index ? .black : .gray)
                                .padding(.vertical, 8)
                                .id(index)
                                .background(GeometryReader { geometry in
                                    Color.clear.preference(key: XPositionPreferenceKey.self, value: geometry.frame(in: .global).origin.x)
                                })
                                .onPreferenceChange(XPositionPreferenceKey.self) { value in
                                    if tabXPositions.count <= index {
                                        tabXPositions.append(value)
                                    } else {
                                        tabXPositions[index] = value
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = index
                                        proxy.scrollTo(index, anchor: .center)
                                        onTabSelection(tabs[selectedTab])
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .overlay(
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 4)
                        .offset(y: 10)
                        .frame(width: tabWidth(for: tabs[selectedTab].categoryName), height: 2)
                        .offset(x: calculateUnderlineOffset(for: selectedTab))
                        .animation(.easeInOut, value: selectedTab),
                    alignment: .bottomLeading
                )
            }
        }
    }

    func tabWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
    
    func calculateUnderlineOffset(for selectedTab: Int) -> CGFloat {
          // Ensure there are enough positions stored
          guard tabXPositions.count > selectedTab else {
              return 0 // Return 0 if the X position for the selected tab isn't available
          }
          
          let selectedTabXPosition = tabXPositions[selectedTab]
          
          // Calculate the offset to center the underline under the selected tab
          return selectedTabXPosition
      }
}

struct XPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct DealsView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Deals Section")
                .font(.largeTitle)
                .padding()
            // Add other content for Deals view here
        }
    }
}


