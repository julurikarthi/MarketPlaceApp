import SwiftUI
//import GoogleMapsUtils

struct DashBoardViewTest: View {
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView()
                Text("Hello, World!h")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Add a button on the right side
                    Button(action: {
                        // Action to add a product
                    }) {
                        Image("shopping-cart").resizable().frame(width: 20, height: 20).padding(.trailing, 4)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    // Add a button on the right side
                    Button(action: {
                        // Action to add a product
                    }) {
                        Image("pin").resizable().frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                        Text("1231 Lilles Way").bold().foregroundColor(.black)
                        Image("arrow-down").resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color.black)
                    }
                }
            }
        }.tint(.black)
    }
}

//#Preview {
//    DashBoardViewTest()
//}




struct SearchBarView: View {
    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard Content")
                    .font(.largeTitle)
                    .padding()
            }
            .searchable(
                text: $searchText,
                isPresented: $isSearching,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search products"
            )
        }
    }
}




import MapKit

struct LocationSearchView: View {
    @StateObject private var viewModel = LocationSearchViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack {
                    
                    }
                    .searchable(
                        text: $viewModel.searchText,
                        placement: .automatic,
                        prompt: "Search products"
                    )
                }
                .padding()

                List(viewModel.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        viewModel.selectLocation(suggestion)
                    }) {
                        Text(suggestion.title)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    LocationSearchView()
}
import Foundation
import MapKit
import Combine

class LocationSearchViewModel: NSObject, ObservableObject {
    @Published var searchText = ""
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private var searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = self
    }

    func performSearch() {
        searchCompleter.queryFragment = searchText
    }

    func selectLocation(_ suggestion: MKLocalSearchCompletion) {
        searchText = suggestion.title
        suggestions.removeAll()
    }
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
