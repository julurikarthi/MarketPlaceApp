import SwiftUI

struct OrderView: View {
    @StateObject private var viewModel = OrdersOperations()
    var body: some View {
         VStack {
             if let orders = viewModel.ordersdata {
                 ScrollView {
                     VStack(spacing: 16) {
                         ForEach(orders) { order in
                             OrderCard(order: order)
                         }
                     }
                     .padding()
                 }
                 .background(
                     LinearGradient(
                         gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing
                     )
                     .edgesIgnoringSafeArea(.all)
                 )
                 .navigationTitle("Orders")
                 .navigationBarTitleDisplayMode(.inline)
             } else {
                 ShimmeringStoreCardPlaceholder()
             }
         }.onAppear(perform: viewModel.fetchAllProductsByCustomer)
       
    }
}

// MARK: - Order Card
struct OrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Store Info
            HStack {
                if let storeImage = order.storeImage {
                    VStack {
                        AsyncImageView(imageId: storeImage)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    } .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "storefront.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.storeName)
                        .font(.headline)
                    Text(order.storeAddress)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Divider()

            // Order Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Order #\(order.id)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Total:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(order.totalPriceWithTax, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.green)
                }

                HStack {
                    Text("Status:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(order.status)
                        .font(.subheadline)
                        .foregroundColor(order.status == "Pending" ? .orange : .green)
                }

                HStack {
                    Text("Payment:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(order.paymentType)
                        .font(.subheadline)
                }

                HStack {
                    Text("Date:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(order.createdAt)
                        .font(.subheadline)
                }
            }

            Divider()

            // Products List
            VStack(alignment: .leading, spacing: 8) {
                Text("Products")
                    .font(.headline)
                    .padding(.bottom, 4)

                ForEach(order.products) { product in
                    HStack {
                        if let imageId = product.imageIds?.first {
                            VStack {
                                AsyncImageView(imageId: imageId)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } .frame(width: 50, height: 50)
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .cornerRadius(6)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.productName)
                                .font(.subheadline)
                            Text("$\(product.price, specifier: "%.2f") x \(product.quantity)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("$\(product.price * Double(product.quantity), specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Models


// MARK: - Preview
struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        let mockOrders = [
            Order(
                id: "67b0a2170f1056112884bde5",
                storeId: "67a01a9a8a1d9a880834e652",
                storeName: "Little loves",
                storeAddress: "125 Queens Road, Charlotte, NC 28204",
                storeImage: "https://example.com/store_image.jpg",
                products: [
                    OrderProduct(
                        id: "67a40fde783e27b744d66429",
                        productName: "Ball-Gown/Princess High Neck Knee-Length Tulle Flower Girl Dress With Beading",
                        quantity: 2,
                        price: 34.7,
                        imageIds: nil
                    ),
                    OrderProduct(
                        id: "67a40ffd783e27b744d6642c",
                        productName: "Raspberry Pink Organza Frilly Top With Colourful Shaded Lehenga",
                        quantity: 3,
                        price: 32.7,
                        imageIds: nil
                    )
                ],
                totalPrice: 167.5,
                taxAmount: 8.38,
                totalPriceWithTax: 175.88,
                status: "Pending",
                paymentType: "Pay at Pickup",
                createdAt: "2025-02-15T14:17:59.062000"
            )
        ]

        NavigationView {
//            OrderView(orders: mockOrders)
        }
    }
}
