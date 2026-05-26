//
//  jiaowuApp.swift
//  jiaowu
//
//  Created by YB.X on 2026/5/7.
//

import SwiftUI

@main
struct jiaowuApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
