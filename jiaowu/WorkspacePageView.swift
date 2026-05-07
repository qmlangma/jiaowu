import SwiftUI

struct WorkspacePageView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("今日任务编排")
                .font(.system(size: 22, weight: .bold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                TaskCard(title: "处理未打卡队列", detail: "当前 \(store.unpaidAttendanceCount) 条记录待跟进", priorityTint: JWColor.danger, actionTitle: "去处理") {
                    store.navigate(.attendance)
                }
                TaskCard(title: "完成试卷批改", detail: "\(store.pendingReviewCount) 名学员待人工复核", priorityTint: JWColor.warning, actionTitle: "去批改") {
                    store.navigate(.assessment)
                }
                TaskCard(title: "处理退款请求", detail: "\(store.paidOrders.count) 笔可退款订单", priorityTint: JWColor.primary, actionTitle: "去审核") {
                    store.navigate(.orders)
                }
            }

            HStack(spacing: 12) {
                MetricCard(title: "今日场次", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "calendar")
                MetricCard(title: "活跃学员", value: "\(store.students.count)", tint: JWColor.success, systemImage: "person.2")
                MetricCard(title: "在读报名", value: "\(store.enrollments.count)", tint: JWColor.accent, systemImage: "doc.text")
            }
        }
    }
}
