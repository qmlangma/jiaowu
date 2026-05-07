import SwiftUI

struct AttendancePageView: View {
    @Environment(AppStore.self) private var store
    @State private var search = ""

    private var filtered: [AttendanceRecord] {
        store.attendanceRecords.filter { record in
            (search.isEmpty || store.studentName(record.studentID).localizedStandardContains(search) || record.classTitle.localizedStandardContains(search))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("异常优先考勤")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Picker(
                    "",
                    selection: Binding(
                        get: { store.attendanceState.selectedFollowUp },
                        set: { store.attendanceState.selectedFollowUp = $0 }
                    )
                ) {
                    ForEach(FollowUpState.allCases) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 320)
            }
            SearchField(placeholder: "搜索学员或班级", text: $search)
            AppCard {
                ForEach(filtered) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.studentName(record.studentID))
                                .font(.system(size: 16, weight: .bold))
                            Text(record.classTitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(JWColor.textMuted)
                        }
                        Spacer()
                        StatusBadge(title: record.status, tint: record.status == "未打卡" ? JWColor.danger : JWColor.success)
                        SecondaryButton(title: "记录回访", systemImage: "phone") {
                            store.cycleFollowUpState()
                            store.sendFeedback("已记录回访并更新队列", level: .success)
                        }
                    }
                    Divider()
                }
            }
        }
    }
}
