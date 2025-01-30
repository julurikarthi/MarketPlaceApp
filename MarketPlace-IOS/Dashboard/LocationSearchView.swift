//
//  LocationSearch.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/29/25.
//



import MapKit
import Foundation
import Combine
import SwiftUI
import GooglePlaces

struct LocationSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var searchText = ""
    @State private var predictions: [GMSAutocompletePrediction] = []
    @State private var isSearching = false
    @StateObject private var viewModel: LocationSearchViewModel = .init()
    var onAddressSelected: (Address) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    AddressSearchBarView(searchText: $searchText)
                    ExploreNearbyView(viewModel: viewModel) { address in
                        onAddressSelected(address)
                        presentationMode.wrappedValue.dismiss()
                    }
                }.onChange(of: searchText) { newValue in
                    fetchAddressPredictions(query: newValue)
                }
                List(predictions, id: \.placeID) { prediction in
                    if let secondaryText = prediction.attributedSecondaryText?.string {
                        AddressSelectionView(street: prediction.attributedPrimaryText.string, cityStateZip: secondaryText)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear).onTapGesture {
                                fetchPlaceDetails(placeID: prediction.placeID) { address in
                                    if let address = address {
                                        onAddressSelected(address)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                    
                                }
                            }
                    }
                }.listStyle(PlainListStyle())
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }.navigationTitle("Addresses").navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark").bold()
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    private func fetchPlaceDetails(placeID: String, completion: @escaping (Address?) -> Void) {
        let fields: GMSPlaceField = [.addressComponents] // Request address details
        
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
            guard let place = place, let components = place.addressComponents else {
                print("Error fetching place details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            var address = Address(street: "", city: "", state: "", postalCode: "", country: "", countryCode: "")
            
            for component in components {
                if component.types.contains("street_number") || component.types.contains("route") {
                    address.street += (address.street.isEmpty ? "" : " ") + component.name
                }
                if component.types.contains("locality") {
                    address.city = component.name
                }
                if component.types.contains("administrative_area_level_1") {
                    address.state = component.name
                }
                if component.types.contains("postal_code") {
                    address.postalCode = component.name
                }
                if component.types.contains("country") {
                    address.country = component.name
                    address.countryCode = component.shortName ?? ""
                }
            }
            
            completion(address)
        }
    }
    
    
    private func fetchAddressPredictions(query: String) {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        
        GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (results, error) in
            if let results = results {
                predictions = results
            }
        }
    }
}

struct Address {
    var street: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var countryCode: String
}


struct AddressSearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        TextField("Search for an address", text: $searchText)
            .padding(10)
            .padding(.leading, 35)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    Spacer()
                }
            )
            .padding(.horizontal)
            .onAppear {
                UITextField.appearance().attributedPlaceholder = NSAttributedString(
                    string: "Search for an address",
                    attributes: [.foregroundColor: UIColor.gray]
                )
            }
    }
}





struct AddressSelectionView: View {
    let street: String
    let cityStateZip: String
    
    var body: some View {
        HStack {
            Image("whitelocation").resizable().frame(width: 25, height: 25)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(street)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(cityStateZip) // City, State, Zip
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray).lineLimit(2)
            }
            .padding(.leading, 5)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    LocationSearchView { address in
        
    }
}

struct ExploreNearbyView: View {
    var viewModel: LocationSearchViewModel
    @Environment(\.presentationMode) var presentationMode
    var onAddressSelected: (Address) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore Nearby")
                .font(.headline)
                .bold()

            HStack(spacing: 12) {
                Image(systemName: "location.circle")
                    .font(.title2)
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Use current location")
                        .font(.body)
                        .bold()
                    
                    Text("Add your address later")
                        .font(.subheadline)
                        .foregroundColor(.subtitleGray)
                }

                Spacer()
            }
            .padding(.vertical, 8)

            Divider()
                .background(Color.gray.opacity(0.4))
        }
        .padding().onTapGesture {
            viewModel.getCurrentLocation {
                onAddressSelected(.init(street: "", city: "view", state: viewModel.state ?? "", postalCode: viewModel.pincode ?? "", country: "", countryCode: ""))
            }
            
        }
    }
}


