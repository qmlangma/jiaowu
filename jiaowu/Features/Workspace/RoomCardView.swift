import SwiftUI

struct RoomCardView: View {
    var session: RoomSession
    var viewClass: () -> Void
    var viewRoster: () -> Void
    var reserveRoom: () -> Void

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

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(minHeight: 238, alignment: .top)
        .background(session.status.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.65), lineWidth: 1))
        .shadow(color: Color.black.opacity(session.status == .idle ? 0.035 : 0.06), radius: 16, x: 0, y: 8)
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
            Label(session.time, systemImage: "clock.badge.checkmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
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
            Button(action: reserveRoom) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.plus")
                    Text("预约教室")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(JWColor.primary)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(JWColor.primary.opacity(0.10))
                .clipShape(Capsule())
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
            HStack(spacing: 8) {
                staffStatusTile(
                    roleTitle: "老师",
                    roleIcon: "person.fill",
                    name: session.teacher ?? "待安排",
                    signedIn: session.teacherSignedIn
                )
                staffStatusTile(
                    roleTitle: "助教",
                    roleIcon: "person.2.fill",
                    name: session.assistant ?? "待安排",
                    signedIn: session.assistantSignedIn
                )
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 7) {
            if session.status == .running {
                TimelineView(.animation(minimumInterval: 0.8, paused: false)) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.6)
                    Circle()
                        .fill(session.status.tint)
                        .frame(width: 8, height: 8)
                        .scaleEffect(phase < 0.8 ? 1 : 0.6)
                        .opacity(phase < 0.8 ? 1 : 0.45)
                }
                .frame(width: 8, height: 8)
            }
            Text(session.status == .running ? "进行中" : session.status.rawValue)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(session.status.tint)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(session.status.tint.opacity(0.13))
        .clipShape(Capsule())
    }

    private var attendanceButton: some View {
        Button(action: viewRoster) {
            HStack(spacing: 6) {
                Text("已到/总学员：\(session.arrived)/\(session.expected)")
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(JWColor.primary)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(JWColor.primary.opacity(0.10))
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

    private func staffStatusTile(roleTitle: String, roleIcon: String, name: String, signedIn: Bool) -> some View {
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
                Spacer(minLength: 0)
                Text(signedIn ? "已签到" : "未签到")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(signedIn ? JWColor.success : JWColor.danger)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(JWColor.textMuted.opacity(0.8))
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
