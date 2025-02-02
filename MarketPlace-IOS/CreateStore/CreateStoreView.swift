//
//  LoginView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI
import PhotosUI
import Combine

extension String {
    
    static let signupText = "By tapping creating Store"
    static let selectSericeText = "Select Service Type"
    static let selectStoreText = "Select Store Type"
    static let pickup = "Pickup"
    static let payAtPickup = "Pay at Pickup"
    static let delivery = "Delivery"
    static let firstNameRequired = "First name is required"
    static let lastNameRequired = "Last name is required"
    static let firstName = "First Name"
    static let lastName = "Last Name"
    static let emailRequired = "Email is required"
    static let storeNameError = "Store name required"
    static let pincodeRequired = "Pincode is required"
    static let taxPercentageRequired = "Tax Percentage"
    static let addressRequired = "Address Required"
    static let cityRequired = "city is Required"
    static let email = "Email"
    static let mobile = "Mobile"
    static let storeType = "Store type"
    static let state = "State"
    static let singnUP = "Continue"
    static let createStoreText = "Create Store"
    static let address = "Store Address"
    static let city = "City"
    static let pincode = "Pincode"
    static let mobileNumberRequired = "Mobile Number Required"
    static let storeName = "Store Name"
}

struct CreateStoreView: View {
    @StateObject var viewModel = CreateStoreViewModel()
    @State private var dropdownServiceSelection: String = "Select Service type"
    @State private var dropdownSelectState: String = "Select State"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    UploadImageView(selectedImage: $viewModel.selectedImage,
                                    image_id: $viewModel.image_id,
                                    imageUploadError: $viewModel.imageUploadError,
                                    isProgress: $viewModel.showProgressIndicator)
                    VStack {
                        CustomTextField(text: $viewModel.storeName, placeholder: .empty, isError: $viewModel.storeNameError, errorMessage: .storeNameError, title: .storeName)
                            .frame(width: .infinity).padding([.trailing, .leading], 20)
                        
                        ZStack {
                            CustomTextField(
                                text: $viewModel.address,
                                placeholder: .empty,
                                isError: $viewModel.addressError,
                                errorMessage: .addressRequired,
                                title: .address
                            )
                            .disabled(true)
                            
                        }.frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        .onTapGesture {
                            viewModel.loadLocationView = true
                        }
                        
                        CustomTextField(text: $viewModel.city, placeholder: .empty, isError: $viewModel.cityError, errorMessage: .cityRequired, title: .city)
                            .frame(width: .infinity).padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.pincode, placeholder: .empty, isError: $viewModel.pincodeError, errorMessage: .pincodeRequired, title: .pincode)
                            .frame(width: .infinity).padding([.trailing, .leading], 20)
                        
                        
                        HStack(spacing: 10) {
                            CustomTextField(text: $viewModel.selectStateText, placeholder: .empty, isError: $viewModel.selectStatError, errorMessage: .selectStoreText, title: .state).frame(width:100)
                            CustomTextField(text: $viewModel.selectedStoreType, placeholder: .empty, isError: $viewModel.selectStoreTypeError, errorMessage: .selectStoreText, title: .storeType, isDropdown: true, dropdownOptions: $viewModel.storeTypes.wrappedValue)
                        }.padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.taxPercentageRequired, placeholder: .empty, isError: $viewModel.taxPercentageRequiredError, errorMessage: .taxPercentageRequired, title: .taxPercentageRequired, keyPadType: .numberPad)
                            .frame(width: .infinity).padding([.trailing, .leading], 20)
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(String.selectSericeText).font(.system(size: 15)).bold()
                            CheckboxView(isChecked: $viewModel.isPickup, label: String.pickup)
                            CheckboxView(isChecked: $viewModel.isPayAtPickup, label: String.payAtPickup)
                            CheckboxView(isChecked: $viewModel.isDelivery, label: String.delivery)
                            if $viewModel.selectServiceTypeError.wrappedValue {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(Color(hex: "#B70F01"))
                                    Text("Select at least one Service Type")
                                        .font(.footnote)
                                        .foregroundColor(Color(hex: "#BB1B0D"))
                                }
                                .transition(.opacity)
                            }
                        
                            Text(String.signupText)
                                .foregroundColor(.gray)
                                .font(.system(size: 10))
                                .lineLimit(3)
                                .padding([.top], 5)
                           
                        }.frame(maxWidth: .infinity, alignment: .leading).padding([.trailing, .leading], 20)
                        
                        signupButton
                    }
                }
            }.navigationTitle("Create Store").task {
                viewModel.getStoreDetailsData()
            }.loadingIndicator(isLoading: $viewModel.showProgressIndicator)
                .onTapGesture {
                dismissKeyboard()
            }.onAppear {
                UserDetails.requestCameraPermission()
                UserDetails.requestPhotoLibraryPermission()
                UserDetails.requestLocationPermission()
            }.sheet(isPresented: $viewModel.loadLocationView) {
                LocationSearchView { address in
                    viewModel.address = address.street
                    viewModel.city = address.city
                    viewModel.pincode = address.postalCode
                    viewModel.selectStateText = address.state
                }
            }
        }
    }
    
    var signupButton: some View {
        Button(action: {
            // Add your button action here
            print("Create Store")
            viewModel.createStore()
        }) {
            Text(String.createStoreText) // Correct placement of the text
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 3)
                .padding()
                .background(Color.themeRed)
                .cornerRadius(20)
        }.padding(15)
    }

    
}


struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    @Binding var isError: Bool
    var errorMessage: String
    var title: String
    var erroriconrequired = true
    @State private var isFocused: Bool = false
    var isDropdown: Bool = false
    var dropdownOptions: [String] = []
    var keyPadType = UIKeyboardType.default
    var isPhoneNumber = false
    /// segment controller
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.system(size: 15)).bold()
            
            if isDropdown {
                Picker(selection: $text, label: Text(String.selectSericeText)) {
                    ForEach(dropdownOptions, id: \.self) { option in
                        Text(option).font(.system(size: 10)).tag(option).lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 3)
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(isFocused ? Color.white : Color(hex: "#F7F7F7"))
                .cornerRadius(10.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(isFocused ? Color.black : (isError ? Color(hex: "#B70F01") : Color.clear),
                                      style: StrokeStyle(lineWidth: 2.0))
                )
                .accentColor(.black)
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { isEditing in
                    self.isFocused = isEditing
                }).keyboardType(keyPadType)
                .onChange(of: text) { newValue in
                        if keyPadType == .numberPad && isPhoneNumber {
                            text = formatPhoneNumber(text)
                        }
                }
                .padding()
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isFocused ? Color.white : Color(hex: "#F7F7F7"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.black : (isError ? Color(hex: "#B70F01") : Color.clear), lineWidth: 2)
                )
                .accentColor(.black)
                .foregroundColor(.black)
            }
            
            if isError && erroriconrequired {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color(hex: "#B70F01"))
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#BB1B0D"))
                }
                .transition(.opacity) 
            } else {
                HStack {
                    Spacer()
                }
                .frame(height: 10) // Fixed height
            }
        }.animation(.easeInOut, value: isFocused)
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        let numbersOnly = input.filter { $0.isNumber }
        var formatted = ""
        
        if numbersOnly.count > 0 {
            formatted += "("
            formatted += numbersOnly.prefix(3)
            if numbersOnly.count > 3 {
                formatted += ") "
                formatted += numbersOnly.dropFirst(3).prefix(3)
            }
            if numbersOnly.count > 6 {
                formatted += "-"
                formatted += numbersOnly.dropFirst(6).prefix(4)
            }
        }
        
        return formatted
    }
}


#Preview {
    CreateStoreView()
}


extension Color {
    init(hex: String) {
        // Remove '#' if present
        let cleanedHex = hex.replacingOccurrences(of: "#", with: "")
        
        // Ensure the hex code is 6 characters long
        let scanner = Scanner(string: cleanedHex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension String {
    static let empty = ""
}


struct RoundedButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeRed)
                .cornerRadius(10)
        }
        .frame(maxWidth: 200) // Set a fixed width if needed
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var label: String

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isChecked ? .green : .gray)

                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button styling from affecting appearance
    }
}

struct UploadImageView: View {
    @Binding var selectedImage: [UIImage]
    @Binding var image_id: [String]
    @State private var isPickerPresented = false
    @Binding var imageUploadError: Bool
    @Binding var isProgress: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Image")
                .font(.headline)

            // Display selected image or placeholder
            if let image = selectedImage.first {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                           RoundedRectangle(cornerRadius: 10)
                            .stroke(imageUploadError ? .red : Color.clear, lineWidth: 2)
                       )
                    .overlay(
                        Text("No Image Selected")
                            .foregroundColor(.gray)
                    )
            }

            // Upload button
            Button(action: {
                isPickerPresented = true
            }) {
                Text("Select Image")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(image: $selectedImage,
                        image_id: $image_id, isProgress: $isProgress)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    @Binding var image_id: [String]
    @Binding var isProgress: Bool
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        var cancellables = Set<AnyCancellable>()

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image.append(uiImage)
            }
            picker.dismiss(animated: true)
            
            guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
                print("No image found")
                return
            }
            
            // Convert UIImage to Data for upload
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to JPEG")
                return
            }
            let originalFileName = "appicon.png"
            let uniqueFileName = String.generateUniqueFileName(originalFileName: originalFileName)
            self.parent.isProgress = true
            
            let uploadPublisher: AnyPublisher<UploadResponse, Error> = NetworkManager.shared.uploadImage(
                url: .uploadImage(),
                imageData: imageData,
                fileName: uniqueFileName,
                responseType: UploadResponse.self
            )
            
            uploadPublisher
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Upload successful")
                    case .failure(let error):
                        print("Upload failed with error: \(error)")
                    }
                }, receiveValue: { response in
                    print("Server response: \(response)")
                    self.parent.isProgress = false
                    self.parent.image_id.append(response.fileName)
                })
                .store(in: &cancellables)
            
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
