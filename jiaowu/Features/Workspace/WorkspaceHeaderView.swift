import SwiftUI

struct WorkspaceHeaderView: View {
    var campusName: String
    var summaries: [WorkspaceSummary]
    var openCampus: () -> Void
    var openSearch: () -> Void
    var openAlerts: () -> Void
    var hasUnreadAlerts: Bool
    @Binding var alarmOn: Bool
    @Binding var lightOn: Bool
    @Binding var webOn: Bool
    @State private var showAlarmConfirm = false

    private let summaryColumns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .center, spacing: AppSpacing.medium) {
                HStack(spacing: 10) {
                    Text("工作台")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Button(action: openCampus) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                            Text(campusName)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(JWColor.primaryLight)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    HeaderToggleIcon(kind: .alarm, isOn: $alarmOn) {
                        showAlarmConfirm = true
                    }
                }

                Spacer(minLength: 0)

                WorkspaceSearchBar(action: openSearch)
                    .frame(width: 520)
                Button(action: openAlerts) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.yellow))
                        .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 1))
                        .overlay(alignment: .topTrailing) {
                            if hasUnreadAlerts {
                                Circle()
                                    .fill(JWColor.danger)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 1.5)
                                    )
                                    .offset(x: 1, y: -1)
                            }
                        }
                        .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: summaryColumns, spacing: AppSpacing.small) {
                ForEach(summaries) { summary in
                    WorkspaceSummaryTile(summary: summary)
                }
            }
        }
        .padding(22)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 22, x: 0, y: 10)
        .alert("确认开启警报", isPresented: $showAlarmConfirm) {
            Button("取消", role: .cancel) {}
            Button("确认开启", role: .destructive) {
                alarmOn = true
                lightOn = true
                webOn = true
            }
        } message: {
            Text("是否确认开启警报？开启后\(campusName)内所有教室的警报灯都会亮起、授课大屏会自动切换为素养版。")
        }
    }
}

private struct HeaderToggleIcon: View {
    enum Kind {
        case alarm
        case light
        case network
    }

    var kind: Kind
    @Binding var isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if kind == .alarm {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(iconTint)
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(iconTint)
                }
            }
            .frame(width: 38, height: 38)
            .background(iconBackground)
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch kind {
        case .alarm:
            return "exclamationmark.shield.fill"
        case .light:
            return "lightbulb.fill"
        case .network:
            return isOn ? "network.badge.shield.half.filled" : "network"
        }
    }

    private var iconTint: Color {
        if kind == .alarm {
            return isOn ? .white : JWColor.textMuted.opacity(0.85)
        }
        guard isOn else { return JWColor.textMuted.opacity(0.85) }
        switch kind {
        case .alarm: return JWColor.danger
        case .light: return JWColor.warning
        case .network: return JWColor.primary
        }
    }

    private var iconBackground: Color {
        if kind == .alarm { return isOn ? JWColor.danger : JWColor.appBackground }
        guard isOn else { return JWColor.appBackground }
        switch kind {
        case .alarm: return JWColor.danger.opacity(0.14)
        case .light: return JWColor.warning.opacity(0.18)
        case .network: return JWColor.primary.opacity(0.14)
        }
    }
}

private struct WorkspaceSummaryTile: View {
    var summary: WorkspaceSummary

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: summary.symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(summary.tint)
                .frame(width: 36, height: 36)
                .background(summary.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(summary.value)
                    .font(.system(size: 26, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(JWColor.text)
                Text(summary.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(minHeight: 76)
        .background(summary.tint.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
