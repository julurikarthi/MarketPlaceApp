import SwiftUI

struct NewCategoriesResponse: Codable {
    let categories: [CategoryModel]
}

// MARK: - Category
struct CategoryModel: Codable {
    let catID, name: String
    let subcategories: [Subcategory]

    enum CodingKeys: String, CodingKey {
        case catID = "cat_id"
        case name, subcategories
    }
}

// MARK: - Subcategory
struct Subcategory: Codable {
    let catID, name: String
    let childCategories: [ChildCategory]

    enum CodingKeys: String, CodingKey {
        case catID = "cat_id"
        case name
        case childCategories = "child_categories"
    }
}

// MARK: - ChildCategory
struct ChildCategory: Codable, Equatable {
    let catID, name: String

    enum CodingKeys: String, CodingKey {
        case catID = "cat_id"
        case name
    }
}

import SwiftUI

struct NewCategorySelectionView: View {
    let categories: [CategoryModel]
    @Binding var selectedCategory: ChildCategory?

    var body: some View {
        NavigationView {
            List(categories, id: \.catID) { category in
                NavigationLink(destination: SubcategoryView(subcategories: category.subcategories, selectedCategory: $selectedCategory)) {
                    Text(category.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Select Category")
        }
    }
}

struct SubcategoryView: View {
    let subcategories: [Subcategory]
    @Binding var selectedCategory: ChildCategory?

    var body: some View {
        List(subcategories, id: \.catID) { subcategory in
            NavigationLink(destination: ChildCategoryView(childCategories: subcategory.childCategories, selectedCategory: $selectedCategory)) {
                Text(subcategory.name)
                    .font(.subheadline)
            }
        }
        .navigationTitle("Subcategories")
    }
}

struct ChildCategoryView: View {
    let childCategories: [ChildCategory]
    @Binding var selectedCategory: ChildCategory?

    var body: some View {
        List(childCategories, id: \.catID) { childCategory in
            Button(action: {
                selectedCategory = childCategory
            }) {
                Text(childCategory.name)
                    .font(.body)
            }
        }
        .navigationTitle("Child Categories")
    }
}

// MARK: - Mock Data for Preview
struct TestContentView: View {
    @State private var selectedCategory: ChildCategory?

    var sampleCategories: [CategoryModel] = []
    @Environment(\.presentationMode) var presentationMode
    var completion: ((ChildCategory) -> Void)?
    
    var body: some View {
        VStack {
            NewCategorySelectionView(categories: sampleCategories, selectedCategory: $selectedCategory)
        }.onChange(of: selectedCategory) { newCategory in
            if let category = newCategory {
                completion?(category)
                presentationMode.wrappedValue.dismiss() // Dismiss the view after selection
            }
        }
    }
}

// MARK: - SwiftUI Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestContentView()
    }
}
