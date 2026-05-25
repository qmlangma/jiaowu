import SwiftUI

struct ClassSessionDetailSheet: View {
    @Environment(AppStore.self) private var store
    var session: RoomSession
    var close: () -> Void
    var openSchedule: () -> Void
    var openAttendance: () -> Void

    var body: some View {
        SideSheetShell(title: session.className ?? session.roomName, subtitle: "\(session.roomName) · \(session.time)", close: close) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack(spacing: 12) {
                    StatusBadge(title: session.status.rawValue, tint: session.status.tint)
                    StatusBadge(title: "\(session.arrived)/\(session.expected) 已到", tint: JWColor.primary)
                    if session.absent > 0 {
                        StatusBadge(title: "\(session.absent) 未到", tint: JWColor.danger)
                    }
                }

                detailRow(title: "老师", value: session.teacher ?? "待安排", symbol: "person.fill", callAction: {
                    guard let name = session.teacher else { return }
                    store.openCallDrawer(role: .teacher, name: name, phone: session.teacherPhone ?? "--")
                })
                detailRow(title: "助教", value: session.assistant ?? "无助教", symbol: "person.2.fill", callAction: {
                    guard let name = session.assistant else { return }
                    store.openCallDrawer(role: .assistant, name: name, phone: session.assistantPhone ?? "--")
                })
                detailRow(title: "迟到/未到", value: "\(session.late) 迟到 · \(session.absent) 未到", symbol: "exclamationmark.circle.fill")

                HStack(spacing: 12) {
                    PrimaryButton(title: "查看课表", systemImage: "calendar", action: openSchedule)
                    SecondaryButton(title: "考勤处理", systemImage: "checkmark.seal.fill", action: openAttendance)
                }
                .frame(height: 52)
            }
        }
    }

    private func detailRow(title: String, value: String, symbol: String, callAction: (() -> Void)? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(JWColor.primary)
                .frame(width: 44, height: 44)
                .background(JWColor.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.textMuted)
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(JWColor.text)
            }
            Spacer()
            if let callAction {
                SecondaryButton(title: "拨打电话", systemImage: "phone.fill", action: callAction)
                    .frame(width: 120)
            }
        }
        .padding(14)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
