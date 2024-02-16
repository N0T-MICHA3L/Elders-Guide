//
// AuthenticationViewModel.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2021 Google LLC. All rights reserved.
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

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import GoogleAPIClientForREST_Calendar

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid: Bool  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var scopes = [kGTLRAuthScopeCalendar]
    @Published var service = GTLRCalendarService()
    @Published var evt_idx:Int = -1
    @Published var evt_title = [String]()
    @Published var evt_address = [String]()
    @Published var evt_start_time = [String]()
    @Published var evt_end_time = [String]()
    @Published var evt_contact = [String]()
    @Published var evt_phone = [String]()
    @Published var cal_ids = [String]()
    @Published var cal_names = [String]()
    @Published var cal_idx : Int = -1
    
    init() {
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
                self.email=user?.email ?? ""
                self.displayName = user?.displayName ?? ""
                //self.auth = auth
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch { }
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
}

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            return true
        }
        catch  {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do  {
            try await Auth.auth().createUser(withEmail: email, password: password)
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // ----
        //        GIDSignIn.sharedInstance.
        //        GIDSignIn.sharedInstance().clientID = "309902338624-ti2irtj3odnvnjrnqpc00etraremtol6.apps.googleusercontent.com"
        //        GIDSignIn.sharedInstance().delegate = self
        //        GIDSignIn.sharedInstance()?.presentingViewController = self
        // ---
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController , hint: "hint info" , additionalScopes: scopes)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            print("Viewmodel isValid:\(self.isValid)")
            print("Viewmodel displayname:\(self.displayName)")
            print("Viewmodel auth-status:\(String(describing: self.authenticationState ))")
            
            // connect calendar sevice
            
            service.authorizer = user.fetcherAuthorizer
            self.fetch_calendar_list()
            self.fetch_calendar_info()
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    public func fetch_calendar_list(){
        
        let query = GTLRCalendarQuery_CalendarListList.query()
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let calendarList = (result as? GTLRCalendar_CalendarList)?.items {
                print("==========================")
                for calendar in calendarList {
                    print("Calendar ID: \(calendar.identifier ?? "")")
                    print("Summary: \(calendar.summary ?? "")")
                    // Add more properties as needed
                    self.cal_ids.append(calendar.identifier ?? "")
                    self.cal_names.append(calendar.summary ?? "")
                }
                print("==========================")
            } else {
                print("No calendars found.")
            }
        }
    }
    
    public func fetch_calendar_info(){
        if (self.cal_idx < 0){
            return
        }
        
//        let calendar_id = "97e39d19ee70588288a8523f0236c9a4f83d0a8ead53ea202bd9f06c36461c86@group.calendar.google.com"
        
        let calendar_id = self.cal_ids[self.cal_idx]
        //let query_info = GTLRCalendarQuery_CalendarsGet.query(withCalendarId: calendar_id)
        //        {conferenceProperties:{allowedConferenceSolutionTypes} etag:""NLUb8QXNB2-6_ZNXIxBjjE7mY8c"" id:"97e39d19ee70588288a8523f0236c9a4f83d0a8ead53ea202bd9f06c36461c86@group.calendar.google.com" kind:"calendar#calendar" summary:"TestForOpenCal" timeZone:"Asia/Taipei"}
               
        
        
        
        let query_info = GTLRCalendarQuery_EventsList.query(withCalendarId: calendar_id)
        
        let today = Date()
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: today)
//        let day = calendar.component(.day, from: today)
//        let month = calendar.component(.month, from: today)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dstr = dateFormatter.string(from: today)
//        print( "target:---- ")
//        print(year)
//        print(month)
//        print(day)
//        print(dstr)
//        print( "target:---- ")
//        quer_info.timeMin=GTLRDateTime(rfc3339String: "2023-10-01T00:50:00+08:00")
//        query_info.timeMax=GTLRDateTime(rfc3339String: "2y023-10-23T23:50:00+08:00")
        
        
        query_info.timeMin=GTLRDateTime(rfc3339String: dstr+"T00:00:00+08:00")
        query_info.timeMax=GTLRDateTime(rfc3339String: dstr+"T23:59:00+08:00")
        
        
        service.executeQuery(query_info) { (ticket, response, error) in
            
//            print("-------------------")
//            print( response)
//            print("-------------------")
            
            guard let eventsList = response as? GTLRCalendar_Events else {
                print("Cannot cast response to GTLRCalendar_Events")
                return
            }
            
            guard let events = eventsList.items else {
                print("no events fetched")
                return
            }
            
            if events.isEmpty {
                print("GoogleCalendarManager - listEvents - calendar has no events")
                
                return
            } else {
                print("GoogleCalendarManager - listEvents - Start list \(events.count) events")
            }
            
            
            
            for event in events {
                self.evt_idx = 0
                //print( event )
//                print("------------------------------------")
                self.evt_title.append( event.summary ?? "Untitle" )
                self.evt_address.append( event.location?.replacing(",", with: "\n") ?? "")
                let str_start = event.start?.dateTime!.stringValue ?? ""
                let r = str_start.index(  str_start.startIndex , offsetBy: 11)..<str_start.index(str_start.endIndex , offsetBy: -9)
                self.evt_start_time.append(String(str_start[r]))
                
                let str_end = event.end?.dateTime!.stringValue ?? ""
                let r2 = str_end.index(  str_end.startIndex , offsetBy: 11)..<str_end.index(str_end.endIndex , offsetBy: -9)
                self.evt_end_time.append(String(str_end[r2]))
                
                let items = event.descriptionProperty!.split(separator: ",")
                var i=0
//                print("++++++++++++ DESC ++++++++++++")
//                print(event.descriptionProperty)
//                print("++++++++++++ ITEM ++++++++++++")
//                print( items)
//                print("++++++++++++ ITEM ++++++++++++")
                while i < items.count {
                    let s = items[i]
                    if s.starts(with:"聯絡人"){
                        let idx = s.index( s.startIndex,offsetBy: 4)
                        self.evt_contact.append(String(s[idx...]))
                        //self.evt_contact = s.substring(from: s.startIndex)
                    }
                    if s.starts(with: "電話"){
                        //self.evt_phone = s.substring(from: s.startIndex , offsetBy:3)
                        let idx = s.index( s.startIndex,offsetBy: 3)
                        self.evt_phone.append( String(s[idx...]) )
                    }
                    i = i + 1
                }
                        
                
//                print( event.summary ?? "no summary")
//                print( event.start?.dateTime ?? GTLRDateTime())
//                print( event.end?.dateTime ?? GTLRDateTime())
//                print("=====")
//                print( event )
            }
        }
    }
}
