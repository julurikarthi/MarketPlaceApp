
import SwiftUI

struct ProductCellItem: View {
  
    @StateObject var viewModel: ProductCellItemViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Carousel
            ZStack(alignment: .bottomTrailing) {
                TabView {
                    ForEach(viewModel.productImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .clipped()
                            .frame(width: 120, height: 200)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 200)
                if UserDetails.userType != .storeOwner {
                    AddToCartView().padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                }
            }
            
            HStack {
                PriceView(price: viewModel.productPrice)
                    .padding(EdgeInsets(top: 0, leading: -2, bottom: 0, trailing: 0))
                if UserDetails.userType == .storeOwner {
                    menuOptions()
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.productTitle)
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))

                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))

                if UserDetails.store_type == nil {
                    Text("In stock: \(viewModel.stock)")
                        .font(.subheadline)
                        .foregroundColor(Color.subtitleGray)
                        .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: 0))
                }
                if viewModel.stockCount > 50 {
                    Text("Many in stock")
                        .padding(5)
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(Color(hex: "#02832D"))
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(2)
                        .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
                }
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.white)
        .task {
            await viewModel.downloadproductImages()
        }
    }
    
    func menuOptions() -> some View {
        Menu {
            Button("Edit", action: viewModel.editProduct)
            Button("Delete", action: viewModel.deleteProduct)
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
    }
    
  
}


#Preview(body: {
//    ProductCellItem(viewModel: .init(product: []))
})

struct AddToCartView: View {
    @State var itemCount: Int = 0

    var body: some View {
        if itemCount == 0 {
            // Initial "Add" button when item count is 0
            addButton(action: { itemCount += 1 })
        } else {
            // Counter view when items are added
            HStack(spacing: 12) {
                // Minus Button
                counterButton(
                    systemImage: "minus",
                    action: { if itemCount > 0 { itemCount -= 1 } }
                )
                
                // Item Count
                Text("\(itemCount)")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // Plus Button
                counterButton(
                    systemImage: "plus",
                    action: { itemCount += 1 }
                )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }

    // MARK: - Reusable Components

    /// Button for "+" and "-" actions in the counter
    private func counterButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white))
        }
    }

    /// Initial "Add to Cart" button
    private func addButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct PriceView: View {
    var price: Double = 0

    var body: some View {
        HStack(alignment: .center) {
            Text("$")
                .foregroundColor(.black)
                .offset(x: 8, y: -2)
                .font(.system(size: 12, weight: .bold, design: .default))

            Text(String(format: "%.0f", price))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .bold, design: .default))

            let cents = (price * 100).truncatingRemainder(dividingBy: 100)
            if cents > 0 {
                Text(String(format: "%02d", Int(cents)))
                    .offset(x: -8, y: -2)
                    .font(.system(size: 12, weight: .bold, design: .default))
                
            }
        }
    }
}
