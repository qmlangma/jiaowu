import SwiftUI

struct AlertCardView: View {
    var alert: WorkspaceAlert
    var contactAction: () -> Void
    var markAction: () -> Void
    
    private var stateTint: Color {
        alert.isContacted ? JWColor.primary : alert.priority.tint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                PriorityIndicator(priority: alert.priority, isContacted: alert.isContacted)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(alert.category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(stateTint)
                        Text(alert.timeDetail)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(JWColor.textMuted)
                        if alert.isContacted {
                            Text("已联系")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(JWColor.primary)
                                .padding(.horizontal, 8)
                                .frame(height: 22)
                                .background(JWColor.primaryLight)
                                .clipShape(Capsule())
                        }
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
                WorkspaceTinyButton(title: alert.actionTitle, symbol: "phone.fill", tint: stateTint, action: contactAction)
                if alert.isContacted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("已联系")
                            .lineLimit(1)
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 40)
                    .background(JWColor.primaryLight)
                    .clipShape(Capsule())
                } else {
                    WorkspaceTinyButton(title: "标记已联系", symbol: "checkmark.circle.fill", tint: JWColor.success, action: markAction)
                }
            }
        }
        .padding(14)
        .background(stateTint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct PriorityIndicator: View {
    var priority: WorkspaceAlertPriority
    var isContacted: Bool

    var body: some View {
        VStack(spacing: 4) {
            if isContacted {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(priority.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 32, height: 32)
        .background(isContacted ? JWColor.primary : priority.tint)
        .clipShape(Circle())
    }
}
