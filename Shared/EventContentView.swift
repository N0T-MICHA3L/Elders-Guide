

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import AVFoundation

struct EventContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    //  @StateObject var viewModel = FavouriteNumberViewModel()
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        HStack(spacing:5){
            Button(""){
                
            }
            Button(""){
                
            }
        }
        VStack (alignment: .leading,spacing: 20){
            Text("# \(viewModel.evt_idx<0 ? "":viewModel.evt_title[viewModel.evt_idx])")
                .font(.title)
                .foregroundColor(.cyan).bold().padding(.bottom)
            
            //      Spacer()
            HStack{
                Image(systemName: "deskclock")
                Text("活動時間：").font(.title2)
                Text("\(viewModel.evt_idx<0 ? "":viewModel.evt_start_time[viewModel.evt_idx]) ~ \( viewModel.evt_idx<0 ? "":viewModel.evt_end_time[viewModel.evt_idx])").foregroundColor(.brown).font(.title2)
            }
            HStack{
                Image(systemName: "person")
                Text("聯絡對象：").font(.title2)
                Text("\(viewModel.evt_idx<0 ? "":viewModel.evt_contact[viewModel.evt_idx])").foregroundColor(.brown).font(.title2)
            }
            HStack{
                Image(systemName: "phone")
                Text("聯絡電話：").font(.title2)
                Text("\(viewModel.evt_idx<0 ? "":viewModel.evt_phone[viewModel.evt_idx])").foregroundColor(.brown).font(.title2)
            }
            HStack{
                Image(systemName: "map")
                Text("活動地點：").font(.title2)
                Text(viewModel.evt_idx<0 ? "":viewModel.evt_address[viewModel.evt_idx]).foregroundColor(.brown).font(.body)
            }
            
            Button(action: {
                //print("Delete tapped!")
                
                
                let utterance = AVSpeechUtterance(string: "前往共學教室活動,台中市北屯區文心路四段123號")
                utterance.pitchMultiplier = 1.0
                utterance.rate = 0.5
                utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
                
                speechSynthesizer.speak(utterance)
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title)
                    Text("廣播")
                        .fontWeight(.semibold)
                        .font(.title)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(40)
                //          Stepper(value: $viewModel.favouriteNumber, in: 0...100) {
                //        Text("\(viewModel.favouriteNumber)")
            }
            HStack(){
                
                Button(action: {
                    viewModel.evt_idx = viewModel.evt_idx-1
                    if( viewModel.evt_idx<0 ){
                        viewModel.evt_idx=viewModel.evt_title.count-1
                    }
                        
                }) {
                    HStack {
                        Image(systemName: "arrowtriangle.left.square").font(.title)
                            
                    }
                    .foregroundColor(.blue)
                }
                Button(action: {
                    viewModel.evt_idx = viewModel.evt_idx+1
                    if( viewModel.evt_idx>=viewModel.evt_title.count ){
                        viewModel.evt_idx=0
                    }
                }) {
                    HStack {
                        Image(systemName: "arrowtriangle.right.square")
                            .font(.title)
                    }
                    .foregroundColor(.blue)
                }
                
            }
            
        }
        .frame(maxHeight: 400)
        .foregroundColor(.black)
        .padding()
#if os(iOS)
        .background(Color(UIColor(red: 216/255, green: 234/255, blue: 234/255, alpha: 1) ))
#endif
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .shadow(radius: 8)
//        .navigationTitle("今日行程")
        .analyticsScreen(name: "\(EventContentView.self)")
    }
}

struct FavouriteNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventContentView().environmentObject(AuthenticationViewModel())
        }
    }
}
