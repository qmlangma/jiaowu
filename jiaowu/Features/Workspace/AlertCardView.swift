import SwiftUI

struct AlertCardView: View {
    var alert: WorkspaceAlert
    var contactAction: () -> Void
    var markAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                PriorityIndicator(priority: alert.priority)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(alert.category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(alert.priority.tint)
                        Text(alert.timeDetail)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(JWColor.textMuted)
                    }
                    Text(alert.contactName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Text(alert.detail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Text(alert.phone)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                WorkspaceTinyButton(title: alert.actionTitle, symbol: "phone.fill", tint: alert.priority.tint, action: contactAction)
                WorkspaceTinyButton(title: "标记已联系", symbol: "checkmark.circle.fill", tint: JWColor.success, action: markAction)
            }
        }
        .padding(14)
        .background(alert.priority.tint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PriorityIndicator: View {
    var priority: WorkspaceAlertPriority

    var body: some View {
        VStack(spacing: 4) {
            Text(priority.rawValue)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 32, height: 32)
        .background(priority.tint)
        .clipShape(Circle())
    }
}
