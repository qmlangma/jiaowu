import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if store.isLoggedIn {
                AppShellView()
            } else {
                LoginPageView()
            }
        }
        .foregroundStyle(JWColor.text)
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
