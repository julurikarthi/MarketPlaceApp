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
                    }
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
            .ignoresSafeArea(edges: .all).navigationDestination(isPresented: $viewModel.movetoDashboard) {
                CreateStoreView()
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
