import SwiftUI

struct WorkspaceSearchBar: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                Text("搜索学员 / 手机号 / 班级 / 老师")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
                Spacer(minLength: 0)
            }
            .padding(.leading, 18)
            .padding(.trailing, 8)
            .frame(height: 62)
            .background(JWColor.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.clear, lineWidth: 0)
            )
        }
        .buttonStyle(.plain)
    }
}
