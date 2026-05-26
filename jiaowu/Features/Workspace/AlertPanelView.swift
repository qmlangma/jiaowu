import SwiftUI

struct AlertPanelView: View {
    var title: String = "异常提醒"
    var alerts: [WorkspaceAlert]
    var collapse: () -> Void
    var contactAction: (WorkspaceAlert) -> Void
    var markAction: (WorkspaceAlert) -> Void
    var quickSignAction: (WorkspaceAlert) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(JWColor.warning)
                        .clipShape(Circle())
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(JWColor.text)
                }
                Spacer()
                Button(action: collapse) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(JWColor.textMuted)
                        .frame(width: 34, height: 34)
                        .background(JWColor.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(JWColor.divider)
                    .frame(height: 1)
            }

            ScrollView(showsIndicators: false) {
                if alerts.isEmpty {
                    Text("暂无相关提醒")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                        .frame(maxWidth: .infinity, minHeight: 220, alignment: .center)
                } else {
                    VStack(spacing: AppSpacing.small) {
                        ForEach(alerts) { alert in
                            AlertCardView(
                                alert: alert,
                                contactAction: { contactAction(alert) },
                                markAction: { markAction(alert) },
                                quickSignAction: { quickSignAction(alert) }
                            )
                        }
                    }
                }
            }
        }
        .padding(18)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.045), radius: 20, x: 0, y: 10)
    }
}
