import SwiftUI

struct ProductCellItemTest: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer() // Pushes the Menu to the right
                Menu {
                    Button("Order Now", action: placeOrder)
                    Button("Adjust Order", action: adjustOrder)
                    Menu("Advanced") {
                        Button("Rename", action: rename)
                        Button("Delay", action: delay)
                    }
                    Button("Cancel", action: cancelOrder)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30) // Adjust the size of the icon
                        .foregroundColor(.black)  // Set the icon color
                }
            }
            .padding() // Adds padding to ensure the button isn't hidden
        }
        .padding() // Adds extra padding around the whole VStack
    }
    
    func placeOrder() { print("Order Now") }
    func adjustOrder() { print("Adjust Order") }
    func rename() { print("Rename") }
    func delay() { print("Delay") }
    func cancelOrder() { print("Cancel Order") }
}

#Preview {
    ProductCellItemTest()
}
