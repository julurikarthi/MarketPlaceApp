//import SwiftUI
//
//struct ProductMockView: Identifiable {
//    let id: String
//    let name: String
//    let price: Double
//    let originalPrice: Double?
//    let stock: Int
//    let imageUrls: [String]
//    let description: String
//    let rating: Double
//    let reviewCount: Int
//}
//
//struct ProductCardView: View {
//    let product: ProductMockView
//    @State private var quantity = 1
//    @State private var currentImageIndex = 0
//    
//    private var discount: Int? {
//        guard let originalPrice = product.originalPrice else { return nil }
//        return Int(((originalPrice - product.price) / originalPrice) * 100)
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Image Carousel
//            ZStack(alignment: .bottomTrailing) {
//                TabView(selection: $currentImageIndex) {
//                    ForEach(product.imageUrls.indices, id: \.self) { index in
//                        AsyncImage(url: URL(string: product.imageUrls[index])) { image in
//                            image.resizable()
//                                 .aspectRatio(contentMode: .fill)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                        .tag(index)
//                    }
//                }
//                .frame(height: 250)
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                
//                // Image Pagination Indicator
//                HStack(spacing: 8) {
//                    ForEach(product.imageUrls.indices, id: \.self) { index in
//                        Circle()
//                            .fill(currentImageIndex == index ? Color.white : Color.gray.opacity(0.5))
//                            .frame(width: 8, height: 8)
//                    }
//                }
//                .padding(8)
//                .background(Color.black.opacity(0.6))
//                .cornerRadius(20)
//                .padding(8)
//            }
//            
//            VStack(alignment: .leading, spacing: 8) {
//                // Product Name and Rating
//                HStack {
//                    Text(product.name)
//                        .font(.title3)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    HStack(spacing: 4) {
//                        Image(systemName: "star.fill")
//                            .foregroundColor(.yellow)
//                        Text(String(format: "%.1f", product.rating))
//                        Text("(\(product.reviewCount))")
//                            .foregroundColor(.gray)
//                    }
//                    .font(.subheadline)
//                }
//                
//                // Price Information
//                HStack(alignment: .firstTextBaseline) {
//                    Text("$\(String(format: "%.2f", product.price))")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
//                    
//                    if let originalPrice = product.originalPrice {
//                        Text("$\(String(format: "%.2f", originalPrice))")
//                            .font(.subheadline)
//                            .strikethrough()
//                            .foregroundColor(.gray)
//                    }
//                    
//                    if let discount = discount {
//                        Text("\(discount)% OFF")
//                            .font(.caption)
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 6)
//                            .padding(.vertical, 2)
//                            .background(Color.red)
//                            .foregroundColor(.white)
//                            .cornerRadius(4)
//                    }
//                }
//                
//                // Description
//                Text(product.description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(2)
//                
//                // Stock Information
//                HStack {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.green)
//                    Text("\(product.stock) in stock")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                
//                // Quantity Selector and Add to Cart Button
//                HStack {
//                    Stepper(value: $quantity, in: 1...product.stock) {
//                        Text("Qty: \(quantity)")
//                            .font(.subheadline)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        // Add to cart logic here
//                        print("Added \(quantity) of \(product.name) to cart")
//                    }) {
//                        Text("Add to Cart")
//                            .fontWeight(.semibold)
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 10)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//        .background(Color.white)
//        .cornerRadius(15)
//        .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
//    }
//}
//
//// Preview
//struct ProductCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductCardView(product: ProductMockView(
//            id: "67a02ad5bd17d8b42651145f",
//            name: "Signature Hoodie",
//            price: 89.99,
//            originalPrice: 120.00,
//            stock: 231,
//            imageUrls: [
//                "https://example.com/image1.jpg",
//                "https://example.com/image2.jpg"
//            ],
//            description: "Comfortable and stylish signature hoodie for all seasons.",
//            rating: 4.5,
//            reviewCount: 128
//        ))
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
//
