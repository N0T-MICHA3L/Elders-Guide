

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
            if (viewModel.cal_ids.isEmpty) {
                VStack (spacing: 10){

                    VStack (spacing: 0){
                        Image("mtitle2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
             
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width:140)
                        //Spacer()
                    }
                    if #available(iOS 17.0, *) {
                        
                        Image("elder_road").resizable().scaledToFit()
//                            .overlay(
//                            Text("本服務行程資訊整合自 Google 日曆，請以 Google 帳戶登入，並選擇檢視日曆")
//                                .font(.system(size:14, design:.rounded))
//                                .padding()
//                                .background(Color(white: 1, opacity: 0.7)),
//                            alignment: .bottom
//                        )
                    } else {
                        Image("elder_road")
                            .resizable()
                            .scaledToFit()
//                            .overlay(
//                                Text("本服務行程資訊整合自 Google 日曆，請以 Google 帳戶登入，並選擇檢視日曆")
//                                    .font(.system(size:14, design:.rounded))
//                                    .padding()
//                                    .background(Color(white: 1, opacity: 0.7)),
//                                alignment: .bottom
//                                )
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        VStack {
                            Text(viewModel.errorMessage)
                                .foregroundColor(Color(UIColor.systemRed))
                        }
                    }
                    VStack {
                        Text("本服務行程資訊整合自 Google 日曆，請以 Google 帳戶登入，並選擇檢視日曆")
                            .font(.system(size:14, design:.rounded))
                            .foregroundColor(Color(UIColor.gray))
                            .frame(width: 280).padding(.vertical,3)
                    }
                    Button(action: signInWithGoogle) {
                        Text("Ｇoogle 帳號登入")
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(alignment: .leading) {
                                Image("Google")
                                    .frame(width: 50, alignment: .center)
                            }
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .buttonStyle(.bordered)
                    .cornerRadius(0)
                    .padding(.vertical,30)
                    Text("設計者：Michael")
                    Text("https://github.com/N0T-MICHA3L/Elders-Reminder")
                        .font(.system(size: 14))
                        .frame(width:340)
                }
                .listStyle(.plain)
                .padding()
            
        }else{
            VStack {
                content().environmentObject(viewModel)
                Text("登入帳號： \(viewModel.displayName)")
                Button("日曆設定") {
//                    viewModel.fetch_calendar_list()
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
