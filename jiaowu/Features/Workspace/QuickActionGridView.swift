import SwiftUI

struct QuickActionGridView: View {
    var actions: [WorkspaceQuickAction]
    var handleAction: (WorkspaceQuickAction) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.medium), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
            ForEach(actions) { action in
                Button { handleAction(action) } label: {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(action.title)
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(JWColor.text)
                            Text(actionSubtitle(for: action.kind))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(JWColor.textMuted)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)

                        illustrationShape(for: action.kind)
                    }
                    .padding(18)
                    .frame(minHeight: 114)
                    .background(cardBackground(for: action.kind))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func actionSubtitle(for kind: WorkspaceQuickActionKind) -> String {
        switch kind {
        case .assessment: "新增测评，获取级别"
        case .enrollCourse: "课程规划 · 报名缴费"
        case .activityQRCode: "快速出示 · 家长扫码"
        case .newStudent: "录入档案 · 快速建档"
        }
    }

    private func cardBackground(for kind: WorkspaceQuickActionKind) -> LinearGradient {
        switch kind {
        case .assessment:
            return LinearGradient(
                colors: [Color(red: 0.90, green: 0.96, blue: 1.0), Color(red: 0.95, green: 0.98, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .enrollCourse:
            return LinearGradient(
                colors: [Color(red: 0.92, green: 0.97, blue: 0.91), Color(red: 0.97, green: 0.99, blue: 0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .activityQRCode:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.86), Color(red: 1.0, green: 0.98, blue: 0.93)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .newStudent:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.93, blue: 0.89), Color(red: 1.0, green: 0.97, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private func illustrationShape(for kind: WorkspaceQuickActionKind) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: 70, height: 70)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(shapeTint(for: kind).opacity(0.22))
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(18))
            Circle()
                .fill(shapeTint(for: kind))
                .frame(width: 20, height: 20)
                .offset(x: 16, y: -18)
            Capsule()
                .fill(shapeTint(for: kind).opacity(0.75))
                .frame(width: 34, height: 8)
                .offset(x: -12, y: 16)
        }
    }

    private func shapeTint(for kind: WorkspaceQuickActionKind) -> Color {
        switch kind {
        case .assessment: Color(red: 0.23, green: 0.55, blue: 1.0)
        case .enrollCourse: Color(red: 0.32, green: 0.71, blue: 0.42)
        case .activityQRCode: Color(red: 0.95, green: 0.66, blue: 0.20)
        case .newStudent: Color(red: 0.94, green: 0.54, blue: 0.34)
        }
    }
}
