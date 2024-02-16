//
// LoginView.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Combine
import FirebaseAnalyticsSwift

private enum FocusableField: Hashable {
  case email
  case password
}

struct LoginView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  @FocusState private var focus: FocusableField?



  private func signInWithGoogle() {
    Task {
      if await viewModel.signInWithGoogle() == true {
        dismiss()
      }
    }
  }

    var body: some View {
        ZStack{
            Image("bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .edgesIgnoringSafeArea(.all)
            VStack (spacing: 30){
                
                Image("Logo_icon").resizable().scaledToFit().frame(width:250)
               
                
                if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                
               
                
                Button(action: signInWithGoogle) {
                    Text("Ｇoogle 帳號登入")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(alignment: .leading) {
                            Image("Google")
                                .frame(width: 30, alignment: .center)
                        }
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .buttonStyle(.bordered)
              
                
            }
            .listStyle(.plain)
            .padding()
            .analyticsScreen(name: "\(Self.self)")
        }}
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoginView()
      LoginView()
        .preferredColorScheme(.dark)
    }
    .environmentObject(AuthenticationViewModel())
  }
}
