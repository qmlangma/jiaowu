import SwiftUI

struct RoomCardView: View {
    var session: RoomSession
    var selectedPeriod: WorkspaceTimePeriod
    var viewClass: (RoomSession) -> Void
    var viewRoster: (RoomSession) -> Void
    var reserveRoom: (RoomSession) -> Void
    var callTeacher: (RoomSession) -> Void
    var callAssistant: (RoomSession) -> Void

    @State private var selectedPeriodIndex = 0

    private var periods: [RoomSessionPeriod] {
        session.periods.isEmpty ? [RoomSessionPeriod(session: session)] : session.periods
    }

    private var selectablePeriods: [RoomSessionPeriod] {
        Array(periods.prefix(2))
    }

    private var activePeriod: RoomSessionPeriod {
        selectablePeriods[min(selectedPeriodIndex, max(selectablePeriods.count - 1, 0))]
    }

    private var activeSession: RoomSession {
        session.resolved(with: activePeriod)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(session.roomName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Spacer()
                if session.status != .idle {
                    periodSelector
                }
            }

            if session.status == .idle {
                idleContent
            } else {
                sessionContent(activeSession)
            }
        }
        .padding(18)
        .frame(height: 238, alignment: .top)
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
                reserveRoom(activeSession)
            } else {
                viewClass(activeSession)
            }
        }
        .onAppear {
            selectedPeriodIndex = defaultPeriodIndex()
        }
        .onChange(of: session.id) { _, _ in
            selectedPeriodIndex = defaultPeriodIndex()
        }
    }

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最大容纳 \(session.capacity) 人")
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
            Label(idleAvailableTimeText, systemImage: "clock.badge.checkmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Spacer(minLength: 0)
        }
    }

    private func sessionContent(_ activeSession: RoomSession) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(activeSession.className ?? "临时预约")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(JWColor.text)
                .lineLimit(2)
                .frame(height: 40, alignment: .topLeading)
            attendanceButton(activeSession)
            Spacer(minLength: 4)
            HStack(spacing: 8) {
                staffStatusTile(
                    roleTitle: "老师",
                    roleIcon: "person.fill",
                    name: activeSession.teacher ?? "待安排",
                    signedIn: activeSession.teacherSignedIn,
                    callAction: { callTeacher(activeSession) }
                )
                staffStatusTile(
                    roleTitle: "助教",
                    roleIcon: "person.2.fill",
                    name: activeSession.assistant ?? "待安排",
                    signedIn: activeSession.assistantSignedIn,
                    callAction: { callAssistant(activeSession) }
                )
            }
            .padding(.bottom, 2)
        }
    }

    private var periodSelector: some View {
        Group {
            if selectablePeriods.count == 1 {
                singleTimeTag(selectablePeriods[0].time)
            } else {
                HStack(spacing: 4) {
                    ForEach(Array(selectablePeriods.enumerated()), id: \.offset) { index, period in
                        Button {
                            selectedPeriodIndex = index
                        } label: {
                            timePill(period.time, isSelected: selectedPeriodIndex == index)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(JWColor.appBackground)
                .overlay(
                    Capsule()
                        .stroke(JWColor.divider.opacity(0.85), lineWidth: 1)
                )
                .clipShape(Capsule())
            }
        }
    }

    private func singleTimeTag(_ time: String) -> some View {
        Text(time)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(JWColor.appBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(JWColor.divider.opacity(0.75), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func timePill(_ time: String, isSelected: Bool) -> some View {
        Text(time)
            .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
            .foregroundStyle(isSelected ? JWColor.text : JWColor.textMuted)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(isSelected ? JWColor.surface : Color.clear)
            .overlay(
                Capsule()
                    .stroke(isSelected ? JWColor.divider : Color.clear, lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    private func defaultPeriodIndex(now: Date = Date()) -> Int {
        guard selectablePeriods.count > 1 else { return 0 }
        let calendar = Calendar.current
        let nowMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        return selectablePeriods.firstIndex { period in
            guard let range = minuteRange(from: period.time) else { return false }
            if range.start <= range.end {
                return nowMinutes >= range.start && nowMinutes <= range.end
            }
            return nowMinutes >= range.start || nowMinutes <= range.end
        } ?? 0
    }

    private func minuteRange(from time: String) -> (start: Int, end: Int)? {
        let normalized = time
            .replacingOccurrences(of: "～", with: "-")
            .replacingOccurrences(of: "~", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "–", with: "-")
        let parts = normalized.split(separator: "-").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count >= 2,
              let start = minutes(from: parts[0]),
              let end = minutes(from: parts[1]) else {
            return nil
        }
        return (start, end)
    }

    private func minutes(from text: String) -> Int? {
        let timeText = text.split(separator: " ").first.map(String.init) ?? text
        let parts = timeText.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0...23).contains(hour),
              (0...59).contains(minute) else {
            return nil
        }
        return hour * 60 + minute
    }

    private var idleAvailableTimeText: String {
        let sourceTimes = session.availableTimes.isEmpty ? [session.time] : session.availableTimes
        let periodRange = minuteRange(for: selectedPeriod)
        let visibleRanges = sourceTimes.compactMap { time -> String? in
            guard let availableRange = minuteRange(from: time) else { return nil }
            let start = max(availableRange.start, periodRange.start)
            let end = min(availableRange.end, periodRange.end)
            guard start < end else { return nil }
            return "\(timeText(from: start))-\(timeText(from: end))"
        }

        if !visibleRanges.isEmpty {
            return "\(visibleRanges.joined(separator: "、")) 可预约"
        }

        if session.availableTimes.isEmpty {
            return session.time
        }
        return "\(selectedPeriod.title)暂无可预约时间"
    }

    private func minuteRange(for period: WorkspaceTimePeriod) -> (start: Int, end: Int) {
        switch period {
        case .morning:
            return (0, 13 * 60)
        case .afternoon:
            return (13 * 60, 17 * 60)
        case .evening:
            return (17 * 60, 24 * 60)
        }
    }

    private func timeText(from minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }

    private func attendanceButton(_ activeSession: RoomSession) -> some View {
        Button(action: { viewRoster(activeSession) }) {
            HStack(spacing: 6) {
                HStack(spacing: 0) {
                    Text("已到学员：")
                    Text("\(activeSession.arrived)")
                        .foregroundStyle(JWColor.primary)
                    Text("/\(activeSession.expected)")
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
