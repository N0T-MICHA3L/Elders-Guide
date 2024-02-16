

import SwiftUI

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    private func signInWithGoogle() {
      Task {
        if await viewModel.signInWithGoogle() == true {
          dismiss()
        }
      }
    }
    
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }
    
    
    var body: some View {
        
        ZStack {
            
            Image("bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            if viewModel.displayName.isEmpty {
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
            
        }else{
            VStack {
                content().environmentObject(viewModel)
                Text("登入帳號： \(viewModel.displayName)")
                Button("檢視登入資訊") {
                    presentingProfileScreen.toggle()
                }
            }
            .sheet(isPresented: $presentingProfileScreen , onDismiss: {
                viewModel.fetch_calendar_info()
            }) {
                NavigationStack {
                    UserProfileView()
                        .environmentObject(viewModel)
                }
            }
        }
    }.onAppear{
         //self.presentingLoginScreen = viewModel.displayName.isEmpty
        
    }.fullScreenCover(isPresented: $presentingLoginScreen){
        NavigationStack{
//            AuthenticationView().environmentObject(viewModel)
            }
        }
        
        
    }
    
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView {
            Text("You're signed in.")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.yellow)
        }
    }
}
