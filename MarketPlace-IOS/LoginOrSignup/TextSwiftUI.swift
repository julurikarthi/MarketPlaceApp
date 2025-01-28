
import SwiftUI

struct ProductCellItemTest: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Carousel
            ZStack(alignment: .bottomTrailing) {
                TabView {
                    Image("image")
                        .resizable()
                        .clipped()
                        .frame(width: 150)
                }
                .tabViewStyle(PageTabViewStyle())

                AddToCartView().padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
            }
            
            PriceView(price: 40.0)
                .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 0))

            VStack(alignment: .leading, spacing: 4) {
                Text("productTitle")
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))

                Text("productTitle")
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))

                if UserDetails.store_type == nil {
                    Text("In stock: \(20)")
                        .font(.subheadline)
                        .foregroundColor(Color.subtitleGray)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                }
                Text("Many in stock")
                    .padding(5)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(Color(hex: "#02832D"))
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(2)
                    .padding(EdgeInsets(top: 3, leading: 23, bottom: 0, trailing: 0))
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.white)
        
    }
}

#Preview {
    ProductCellItemTest()
}
