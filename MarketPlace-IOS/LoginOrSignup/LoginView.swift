//
//  LoginView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/20/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Image("image")
                        .resizable()
                        .frame(height: 360)
                        .scaledToFit()

                    VStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            DropdownPicker()
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .padding(.bottom, 14)
                            
                            CustomTextField(
                                text: $viewModel.mobile,
                                placeholder: .empty,
                                isError: $viewModel.mobileError,
                                errorMessage: .mobileNumberRequired,
                                title: .mobile,
                                keyPadType: .numberPad,
                                isPhoneNumber: true
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.65)
                        }
                    }.loadingIndicator(isLoading: $viewModel.showProgressIndicator)
                    .padding(.top, 15)
                    .padding([.leading, .trailing], 15) // Added padding
                    .background(Color.white)
                    signupButton.padding(.top, -10).padding([.leading, .trailing], 10)
                    Text("By continuing with the Sign in Process, you Consent to receiving a one-time verification code via text message to this phone number. Message and data rates may apply")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                        .lineLimit(3)
                        .padding(.top, 5)
                        .padding([.leading, .trailing], 28)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    dismissKeyboard()
                }
            }
            .ignoresSafeArea(edges: .all)
            .navigationDestination(isPresented: $viewModel.movetoStore) {
                CreateStoreView()
            }.navigationDestination(isPresented: $viewModel.movetoStore) {
                
            }
        }
    }


    var signupButton: some View {
        Button(action: {
            viewModel.continueAction()
        }) {
            Text(String.singnUP)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 3)
                .padding()
                .background(Color.red)
                .cornerRadius(20)
        }.padding(15)
    }
    
}


#Preview {
    LoginView()
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct LoadingViewModifier: ViewModifier {
    @Binding var isLoading: Bool
    var indicatorSize: CGFloat = 50.0

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                DefaultIndicatorView(count: 8) // Your custom loader
                    .frame(width: indicatorSize, height: indicatorSize)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.7)) // Optional: Background dim
                    .cornerRadius(10)
                    .scaleEffect(1.5) // Optional: Scale the loader
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the screen
            }
        }
    }
}

extension View {
    func loadingIndicator(isLoading: Binding<Bool>, indicatorSize: CGFloat = 20.0) -> some View {
        self.modifier(LoadingViewModifier(isLoading: isLoading, indicatorSize: indicatorSize))
    }
}
