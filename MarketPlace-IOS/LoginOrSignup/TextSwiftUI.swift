
import SwiftUI

struct AddProductView: View {
    @State private var productName: String = ""
    @State private var searchText: String = ""
    @State private var searchTags: [String] = [] // Stores selected tags
    @State private var tempSelectedTags: [String] = [] // Temporary selected tags

    let allTags = ["Electronics", "Fashion", "Shoes", "Mobile", "Laptop", "Grocery", "Clothing", "Gaming", "Accessories"]

    var filteredTags: [String] {
        if searchText.isEmpty {
            return allTags
        } else {
            return allTags.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ✅ Product Name Input
            TextField("Product Name", text: $productName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // ✅ Search Tags Input (Shows Saved Tags)
            TextField("Search Tags", text: .constant(searchTags.joined(separator: ", ")))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(true) // Read-only field

            // ✅ Search Field for Tags
            TextField("Search Tags", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // ✅ Search Results List (Selectable Tags)
            List(filteredTags, id: \.self) { tag in
                HStack {
                    Text(tag)
                    Spacer()
                    if tempSelectedTags.contains(tag) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if tempSelectedTags.contains(tag) {
                        tempSelectedTags.removeAll { $0 == tag }
                    } else {
                        tempSelectedTags.append(tag)
                    }
                }
            }
            .frame(height: 200) // Limit list height

            // ✅ Save Tags Button
            Button(action: {
                searchTags = tempSelectedTags
            }) {
                Text("Save Tags")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Add Product")
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
    }
}
