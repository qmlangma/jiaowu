import SwiftUI

struct SessionOpsPageView: View {
    @Environment(AppStore.self) private var store
    var initialTab: SessionOperationTab? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("场次运营中心")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Picker(
                    "",
                    selection: Binding(
                        get: { store.sessionState.activeTab },
                        set: { store.sessionState.activeTab = $0 }
                    )
                ) {
                    ForEach(SessionOperationTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 320)
            }

            HStack(spacing: 12) {
                MetricCard(title: "场次", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "calendar.badge.clock")
                MetricCard(title: "待判", value: "\(store.pendingReviewCount)", tint: JWColor.warning, systemImage: "doc.badge.clock")
                MetricCard(title: "未签", value: "\(store.unpaidAttendanceCount)", tint: JWColor.danger, systemImage: "person.crop.circle.badge.exclamationmark")
            }

            AppCard {
                if let session = store.selectedTestSession {
                    Text(session.title)
                        .font(.system(size: 18, weight: .bold))
                    Text("\(session.time) · \(session.room)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Divider()
                    tabContent(session: session)
                } else {
                    EmptyStateView(title: "暂无场次", systemImage: "calendar")
                }
            }
        }
        .onAppear {
            if let initialTab {
                store.setSessionTab(initialTab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(session: TestSession) -> some View {
        switch store.sessionState.activeTab {
        case .seats:
            ForEach(session.seats) { seat in
                HStack {
                    Text("座位 \(seat.seatNo)")
                    Text(store.studentName(seat.studentID))
                    Spacer()
                    SecondaryButton(title: "换序", systemImage: "arrow.up.arrow.down") {
                        store.reorderSeats(sessionID: session.id)
                    }
                }
            }
        case .attendance:
            ForEach(session.seats) { seat in
                HStack {
                    Text(store.studentName(seat.studentID))
                    Spacer()
                    CheckBoxChip(isOn: seat.studentCheckedIn, onTitle: "已签到", offTitle: "签到") {
                        store.toggleStudentCheckIn(sessionID: session.id, seatID: seat.id)
                    }
                    CheckBoxChip(isOn: seat.parentCheckedIn, onTitle: "家长已签", offTitle: "家长签到") {
                        store.toggleParentCheckIn(sessionID: session.id, seatID: seat.id)
                    }
                }
            }
        case .marking:
            ForEach(store.testAnswers.filter { $0.sessionID == session.id }.prefix(12)) { answer in
                HStack {
                    Text("第\(answer.questionNo)题")
                    Text(store.studentName(answer.studentID))
                    Spacer()
                    SecondaryButton(title: "正确", tint: JWColor.success) {
                        store.markAnswer(answer.id, as: .correct)
                    }
                    SecondaryButton(title: "错误", tint: JWColor.danger) {
                        store.markAnswer(answer.id, as: .wrong)
                    }
                }
            }
        }
    }
}

private struct CheckBoxChip: View {
    var isOn: Bool
    var onTitle: String
    var offTitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(isOn ? onTitle : offTitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isOn ? .white : JWColor.primary)
                .frame(height: 34)
                .padding(.horizontal, 12)
                .background(isOn ? JWColor.primary : JWColor.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
