

import SwiftUI
import FirebaseAnalyticsSwift

struct UserProfileView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @State var presentingConfirmationDialog = false
    
    
    // Your data source for the dropdown
    //let options = ["日曆1", "日曆2", "日曆3"]

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
//          Button(action: {}) {
//            Text("edit")
//          }
        }
      }
      .listRowBackground(Color(UIColor.systemGroupedBackground))
      Section("使用者 Google 帳號資訊") {
          
          Text(viewModel.displayName)
          Text(viewModel.email)
          
        
          // Picker for the dropdown
          Picker("使用日曆", selection: $viewModel.cal_idx) {
                ForEach(0 ..< viewModel.cal_names.count) {
                    Text(viewModel.cal_names[$0])
                }
            }
            .pickerStyle(MenuPickerStyle()) // Use MenuPickerStyle for a dropdown appearance

          
//          Button(action: viewModel.fetch_calendar_info) {
//            Text("Query")
//              .padding(.vertical, 8)
//              .frame(maxWidth: .infinity)
//              .background(alignment: .leading) {
//                Image("Google")
//                  .frame(width: 30, alignment: .center)
//              }
//          }
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
//      Section {
//        Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
//          HStack {
//            Spacer()
//            Text("Delete Account")
//            Spacer()
//          }
//        }
//      }
    }
    .navigationTitle("使用者資訊")
    .navigationBarTitleDisplayMode(.inline)
    .analyticsScreen(name: "\(Self.self)")
//    .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
//                        isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
//      Button("Delete Account", role: .destructive, action: deleteAccount)
//      Button("Cancel", role: .cancel, action: { })
//    }
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
