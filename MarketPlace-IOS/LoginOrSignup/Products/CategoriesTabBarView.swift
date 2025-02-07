import SwiftUI
import Combine

class CategoriesTabBarViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var tabXPositions: [CGFloat] = []

}


struct CategoriesTabBarView: View {
    let tabs: [Category]
    @State private var selectedTab = 0
    @State private var tabXPositions: [CGFloat] = []
    var onTabSelection: ((Category) -> Void)
    @ObservedObject var viewModel: CategoriesTabBarViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(tabs.indices, id: \.self) { index in
                            TabItemView(
                                title: tabs[index].categoryName,
                                isSelected: viewModel.selectedTab == index,
                                action: {
                                    if viewModel.selectedTab != index { // Prevent unnecessary updates
                                        withAnimation(.spring()) {
                                            viewModel.selectedTab = index
                                            proxy.scrollTo(index, anchor: .center)
                                            onTabSelection(tabs[viewModel.selectedTab])
                                        }
                                    }
                                }
                            )
                            .id(index)
                            .simultaneousGesture(TapGesture())
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: XPositionPreferenceKey.self, value: geometry.frame(in: .global).origin.x)
                            })
                            .onPreferenceChange(XPositionPreferenceKey.self) { value in
                                if viewModel.tabXPositions.count <= index {
                                    viewModel.tabXPositions.append(value)
                                } else {
                                    viewModel.tabXPositions[index] = value
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                
                }
                .background(Color.white.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5))
                
            }
            
            // Underline
            GeometryReader { geometry in
                let underlineWidth = tabWidth(for: tabs[viewModel.selectedTab].categoryName)
                let underlineOffset = calculateUnderlineOffset(for: viewModel.selectedTab)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black)
                    .frame(width: underlineWidth, height: 2)
                    .offset(x: underlineOffset, y: -2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedTab)
            }
            .frame(height: 4)
        }
    }
    
    func tabWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width + 10
    }
    
    func calculateUnderlineOffset(for selectedTab: Int) -> CGFloat {
        guard viewModel.tabXPositions.count > selectedTab else { return 0 }
        return viewModel.tabXPositions[selectedTab]
    }
}

struct TabItemView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ?  Color.clear : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct XPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
