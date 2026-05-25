import SwiftUI

struct RoomMonitorView: View {
    @Binding var selectedPeriod: WorkspaceTimePeriod
    @Binding var selectedDate: Date
    var sessions: [RoomSession]
    @Binding var selectedFloor: RoomFloor
    @Binding var hideIdleRooms: Bool
    var previousDate: () -> Void
    var nextDate: () -> Void
    var viewClass: (RoomSession) -> Void
    var viewRoster: (RoomSession) -> Void
    var reserveRoom: (RoomSession) -> Void
    @State private var isDatePickerPresented = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.medium), count: 3)
    private var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .center, spacing: AppSpacing.medium) {
                Text("今日课程")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(JWColor.text)
                floorPicker
                hideIdleToggle
                Spacer(minLength: 0)
                dateStepper
                periodPicker
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                ForEach(filteredSessions) { session in
                    RoomCardView(
                        session: session,
                        viewClass: { viewClass(session) },
                        viewRoster: { viewRoster(session) },
                        reserveRoom: { reserveRoom(session) }
                    )
                }
            }
        }
        .padding(20)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var periodPicker: some View {
        HStack(spacing: 12) {
            ForEach(WorkspaceTimePeriod.allCases) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.title)
                        .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selectedPeriod == period ? .white : JWColor.textMuted)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(selectedPeriod == period ? JWColor.primary : JWColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var floorPicker: some View {
        HStack(spacing: 8) {
            ForEach(RoomFloor.allCases) { floor in
                Button {
                    selectedFloor = floor
                } label: {
                    Text(floor.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(selectedFloor == floor ? .white : JWColor.textMuted)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(selectedFloor == floor ? JWColor.primary : JWColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var hideIdleToggle: some View {
        HStack(spacing: 8) {
            Text("隐藏空教室")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Toggle("", isOn: $hideIdleRooms)
                .labelsHidden()
                .tint(JWColor.primary)
        }
        .padding(.horizontal, 10)
        .frame(height: 42)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var filteredSessions: [RoomSession] {
        sessions.filter { session in
            (selectedFloor == .all || session.floor == selectedFloor) && (!hideIdleRooms || session.status != .idle)
        }
    }

    private var dateStepper: some View {
        HStack(spacing: 2) {
            if !isToday {
                Button {
                    selectedDate = Date()
                } label: {
                    Text("今")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(JWColor.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(JWColor.primary.opacity(0.14))
                        )
                }
                .buttonStyle(.plain)
            }
            Button(action: previousDate) {
                Image(systemName: "chevron.left")
                    .frame(width: 40, height: 40)
            }
            Button {
                isDatePickerPresented = true
            } label: {
                Text(selectedDate.displayText)
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 94)
                    .frame(height: 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(
                isPresented: $isDatePickerPresented,
                attachmentAnchor: .rect(.bounds),
                arrowEdge: .top
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择日期")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Text("请选择要查看的日期")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    DatePicker(
                        "日期",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "zh_Hans_CN"))

                    HStack {
                        Spacer(minLength: 0)
                        Button("完成") {
                            isDatePickerPresented = false
                        }
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(JWColor.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .padding(16)
                .frame(width: 360)
            }
            Button(action: nextDate) {
                Image(systemName: "chevron.right")
                    .frame(width: 40, height: 40)
            }
        }
        .foregroundStyle(JWColor.text)
        .frame(height: 48)
        .padding(4)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

extension Date {
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: self)
    }
}
