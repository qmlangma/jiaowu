import SwiftUI

struct RoomCardView: View {
    var session: RoomSession
    var viewClass: () -> Void
    var viewRoster: () -> Void
    var reserveRoom: () -> Void
    var callTeacher: () -> Void
    var callAssistant: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(session.roomName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Spacer()
                if session.status != .idle {
                    statusBadge
                }
            }

            if session.status == .idle {
                idleContent
            } else {
                sessionContent
            }
        }
        .padding(18)
        .frame(minHeight: 238, alignment: .top)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(JWColor.divider.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.025), radius: 10, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture {
            if session.status == .idle {
                reserveRoom()
            } else {
                viewClass()
            }
        }
    }

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("可容纳 \(session.capacity) 人")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(JWColor.text)
            HStack(spacing: 10) {
                if session.hasScreen {
                    idleDeviceTag(title: "电视", icon: "tv.fill")
                }
                if session.hasNetwork {
                    idleDeviceTag(title: "网络", icon: "wifi")
                }
                if !session.hasScreen && !session.hasNetwork {
                    idleDeviceTag(title: "无设备", icon: "exclamationmark.triangle.fill")
                }
            }
            Label(session.time, systemImage: "clock.badge.checkmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Spacer(minLength: 0)
            Button(action: reserveRoom) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("预约教室")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(JWColor.primary)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(JWColor.primary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var sessionContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(session.className ?? "临时预约")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(JWColor.text)
                .lineLimit(2)
            Label(session.time, systemImage: "clock.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            attendanceButton
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                staffStatusTile(
                    roleTitle: "老师",
                    roleIcon: "person.fill",
                    name: session.teacher ?? "待安排",
                    signedIn: session.teacherSignedIn,
                    callAction: callTeacher
                )
                staffStatusTile(
                    roleTitle: "助教",
                    roleIcon: "person.2.fill",
                    name: session.assistant ?? "待安排",
                    signedIn: session.assistantSignedIn,
                    callAction: callAssistant
                )
            }
        }
    }

    private var statusBadge: some View {
        let isIdle = session.status == .idle
        let tint = isIdle ? JWColor.primary : session.status.tint
        let title = isIdle ? "空闲可预约" : (session.status == .running ? "正在上课" : session.status.rawValue)

        return HStack(spacing: 7) {
            if isIdle {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(tint.opacity(isIdle ? 0.16 : 0.13))
        .clipShape(Capsule())
    }

    private var attendanceButton: some View {
        Button(action: viewRoster) {
            HStack(spacing: 6) {
                HStack(spacing: 0) {
                    Text("已到学员：")
                    Text("\(session.arrived)")
                        .foregroundStyle(JWColor.primary)
                    Text("/\(session.expected)")
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(JWColor.textMuted)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(JWColor.appBackground)
            .overlay(
                Capsule()
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func idleDeviceTag(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(JWColor.textMuted)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(JWColor.appBackground)
        .clipShape(Capsule())
    }

    private func staffStatusTile(
        roleTitle: String,
        roleIcon: String,
        name: String,
        signedIn: Bool,
        callAction: @escaping () -> Void
    ) -> some View {
        Button(action: callAction) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: roleIcon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                    Text(roleTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                }
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(JWColor.text)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(signedIn ? "已签到" : "未签到")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(signedIn ? JWColor.success : JWColor.danger)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(JWColor.primary)
                        .frame(width: 28, height: 28)
                        .background(JWColor.primaryLight)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(JWColor.surface.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct WorkspaceTinyButton: View {
    var title: String
    var symbol: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .frame(minHeight: 40)
            .background(tint.opacity(0.11))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
