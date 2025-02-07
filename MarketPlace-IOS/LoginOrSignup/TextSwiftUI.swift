//import SwiftUI
//
//struct ImageItem: Identifiable, Decodable {
//    let id: Int
//    let url: String
//}
//
//class ImageListViewModel: ObservableObject {
//    @Published var images: [ImageItem] = []
//
//    func fetchImages() {
//        guard let url = URL(string: "https://example.com/api/images") else { return }
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else { return }
//            if let decodedResponse = try? JSONDecoder().decode([ImageItem].self, from: data) {
//                DispatchQueue.main.async {
//                    self.images = decodedResponse
//                }
//            }
//        }.resume()
//    }
//}
//
//struct ImageRowView: View {
//    let imageUrl: String
//
//    var body: some View {
//        AsyncImage(url: URL(string: imageUrl)) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//            case .success(let image):
//                image.resizable().scaledToFit()
//            case .failure:
//                Image(systemName: "photo").resizable().scaledToFit()
//            @unknown default:
//                EmptyView()
//            }
//        }
//        .frame(height: 150)
//    }
//}
//
//struct ImageListView: View {
//    @StateObject private var viewModel = ImageListViewModel()
//
//    var body: some View {
//        List(viewModel.images) { item in
//            ImageRowView(imageUrl: item.url)
//        }
//        .onAppear {
//            viewModel.fetchImages()
//        }
//    }
//}
//
//struct ContentView: View {
//    var body: some View {
//        ImageListView()
//    }
//}
//
