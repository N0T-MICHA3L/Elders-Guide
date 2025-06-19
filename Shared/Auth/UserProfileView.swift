

import SwiftUI
import FirebaseAnalyticsSwift

struct UserProfileView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @State var presentingConfirmationDialog = false
    

    // State variable to track the selected option
    @State private var selectedOption = 0

  private func deleteAccount() {
    Task {
      if await viewModel.deleteAccount() == true {
        dismiss()
      }
    }
  }

  private func signOut() {
    viewModel.signOut()
      dismiss()
  }
    
    private func retrive_calendar(){
        //viewModel.user.
    }

  var body: some View {
      
    Form {

      Section {
        VStack {
          HStack {
            Spacer()
            Image(systemName: "person.fill")
              .resizable()
              .frame(width: 100 , height: 100)
              .aspectRatio(contentMode: .fit)
              .clipShape(Circle())
              .clipped()
              .padding(4)
              .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
            Spacer()
          }

        }
      }
      .listRowBackground(Color(UIColor.systemGroupedBackground))
      Section("使用者 Google 帳號資訊") {
          
          Text(viewModel.displayName)
          Text(viewModel.email)
          
        
          // Picker for the dropdown
          Picker("使用日曆", selection: $viewModel.cal_idx) {
              if !viewModel.cal_names.isEmpty {
                  
                  ForEach(0 ..< viewModel.cal_names.count , id: \.self ) { (index) in
                        Text(viewModel.cal_names[index])
                    }
              }
            }
            .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for a dropdown appearance

          
      }
       
      Section {
        Button(role: .cancel, action: signOut) {
          HStack {
            Spacer()
            Text("登 出")
            Spacer()
          }
        }
      }

    }
    .navigationTitle("使用者資訊")
    .navigationBarTitleDisplayMode(.inline)
    .analyticsScreen(name: "\(Self.self)")

  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      UserProfileView()
        .environmentObject(AuthenticationViewModel())
    }
  }
}
