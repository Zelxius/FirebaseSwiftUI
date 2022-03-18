//
//  ContentView.swift
//  IphoneIpadFirebase
//
//  Created by Zelxius on 15/03/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var loginShow: FirebaseViewModel
    var body: some View {
        return Group{
            if loginShow.show{
                Home()
                    .edgesIgnoringSafeArea(.all)
            }else{
                Login()
            }
        }.onAppear{
            if (UserDefaults.standard.object(forKey: "sesion") != nil){
                loginShow.show = true
            }
        }
    }
}
