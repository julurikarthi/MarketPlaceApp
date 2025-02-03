
import SwiftUI


struct ProductCellItem: View {
    @State private var quantity = 1
    @State private var currentImageIndex = 0
    @StateObject var viewModel: ProductCellItemViewModel
    private var discount: Int? {
        return 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Carousel
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $currentImageIndex) {
                    ForEach(viewModel.productImages, id: \.self) { image in
                        Image(uiImage: image).resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Image Pagination Indicator
                HStack(spacing: 8) {
                    ForEach(viewModel.imageIds.indices, id: \.self) { index in
                        Circle()
                            .fill(currentImageIndex == index ? Color.white : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Product Name and Rating
                HStack {
                    Text(viewModel.productTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", 3))
                        Text("10")
                            .foregroundColor(.gray)
                    }
                    .font(.subheadline)
                }
                
                // Price Information
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(String(format: "%.2f", viewModel.productPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("$\(String(format: "%.2f", viewModel.productPrice))")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.gray)
                    
                    if let discount = discount {
                        Text("\(discount)% OFF")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                // Description
                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Stock Information
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(viewModel.stock) in stock")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Quantity Selector and Add to Cart Button
                HStack {
                    Stepper(value: $quantity, in: 1...viewModel.stockCount) {
                        Text("Qty: \(quantity)")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Add to cart logic here
                        print("Added \(quantity) of \(viewModel.productTitle) to cart")
                    }) {
                        Text("Add to Cart")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5).task {
            await viewModel.downloadproductImages()
        }
    }
}

//struct ProductCellItem: View {
//  
//    @StateObject var viewModel: ProductCellItemViewModel
//        
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            // Image Carousel
//            ZStack(alignment: .bottomTrailing) {
//                TabView {
//                    ForEach(viewModel.productImages, id: \.self) { image in
//                        Image(uiImage: image)
//                            .resizable()
//                            .clipped()
//                            .frame(width: 120, height: 200)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle())
//                .frame(height: 200)
//                if UserDetails.userType != .storeOwner {
//                    AddToCartView().padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
//                }
//            }
//            
//            HStack {
//                PriceView(price: viewModel.productPrice)
//                    .padding(EdgeInsets(top: 0, leading: -2, bottom: 0, trailing: 0))
//                if UserDetails.userType == .storeOwner {
//                    menuOptions()
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(viewModel.productTitle)
//                    .font(.subheadline)
//                    .foregroundColor(Color.subtitleGray)
//                    .lineLimit(2)
//                    .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
//
//                Text(viewModel.description)
//                    .font(.subheadline)
//                    .foregroundColor(Color.subtitleGray)
//                    .lineLimit(2)
//                    .padding(EdgeInsets(top: 0, leading: -5, bottom: 0, trailing: 0))
//
//                if UserDetails.store_type == nil {
//                    Text("In stock: \(viewModel.stock)")
//                        .font(.subheadline)
//                        .foregroundColor(Color.subtitleGray)
//                        .padding(EdgeInsets(top: 0, leading: -8, bottom: 0, trailing: 0))
//                }
//                if viewModel.stockCount > 50 {
//                    Text("Many in stock")
//                        .padding(5)
//                        .font(.system(size: 12, weight: .bold, design: .default))
//                        .foregroundColor(Color(hex: "#02832D"))
//                        .background(Color.green.opacity(0.1))
//                        .cornerRadius(2)
//                        .padding(EdgeInsets(top: 3, leading: -5, bottom: 0, trailing: 0))
//                }
//            }
//            .padding([.horizontal, .bottom])
//        }
//        .background(Color.white)
//        .task {
//            await viewModel.downloadproductImages()
//        }
//    }
//    
//    func menuOptions() -> some View {
//        Menu {
//            Button("Edit", action: viewModel.editProduct)
//            Button("Delete", action: viewModel.deleteProduct)
//        } label: {
//            Image(systemName: "ellipsis")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 20, height: 20)
//                .foregroundColor(.black)
//        }
//    }
//    
//  
//}


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
