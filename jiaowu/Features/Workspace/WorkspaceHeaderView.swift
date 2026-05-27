import SwiftUI

struct WorkspaceHeaderView: View {
    var campusName: String
    var summaries: [WorkspaceSummary]
    var openCampus: () -> Void
    var openSearch: () -> Void
    var openSummary: (WorkspaceSummary) -> Void
    var requestAlarmConfirm: () -> Void
    @Binding var alarmOn: Bool

    private var summaryColumns: [GridItem] {
        let count = max(1, summaries.count)
        return Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: count)
    }

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
                        requestAlarmConfirm()
                    }
                }

                Spacer(minLength: 0)

                WorkspaceSearchBar(action: openSearch)
                    .frame(width: 520)
            }

            LazyVGrid(columns: summaryColumns, spacing: AppSpacing.small) {
                ForEach(summaries) { summary in
                    WorkspaceSummaryTile(summary: summary) {
                        openSummary(summary)
                    }
                }
            }
        }
        .padding(22)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 22, x: 0, y: 10)
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
            return "lightbulb.fill"
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
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }
}
