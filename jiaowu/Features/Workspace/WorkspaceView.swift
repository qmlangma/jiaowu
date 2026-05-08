import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("今日运营概览")
                        .font(.system(size: 20, weight: .bold))
                    Text("面向校区老师的待办队列，优先处理异常、签到和批改。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                }
                Spacer()
                HStack(spacing: 10) {
                    SecondaryButton(title: "扫码", systemImage: "qrcode.viewfinder") { store.toast = "扫码页为前端占位" }
                    PrimaryButton(title: "快速报名", systemImage: "plus") { store.navigate(.courseSelection) }
                        .frame(width: 150)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                MetricCard(title: "今日测试班", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "doc.text")
                MetricCard(title: "未签到预警", value: "\(store.unpaidAttendanceCount)", tint: JWColor.danger, systemImage: "exclamationmark.triangle")
                MetricCard(title: "待批改", value: "\(store.pendingReviewCount)", tint: JWColor.warning, systemImage: "pencil.and.outline")
                MetricCard(title: "可退款订单", value: "\(store.paidOrders.count)", tint: JWColor.success, systemImage: "creditcard")
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "实时场次", actionTitle: "课表") { store.navigate(.schedule) }
                    ForEach(store.testSessions) { session in
                        Button {
                            store.selectedTestSessionID = session.id
                            store.navigate(.schedule)
                        } label: {
                            TestSessionRow(session: session)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "处理队列", actionTitle: "测评") { store.navigate(.assessment) }
                    VStack(spacing: 2) {
                        TaskRow(title: "试卷人工复核", detail: "\(store.pendingReviewCount) 名学员存在 OCR/AI 待判题", tint: JWColor.warning)
                        TaskRow(title: "未打卡提醒", detail: "\(store.unpaidAttendanceCount) 条考勤需要处理", tint: JWColor.danger)
                        TaskRow(title: "退款确认", detail: "\(store.paidOrders.count) 笔已付款订单可发起退款", tint: JWColor.success)
                    }
                }
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
                .frame(width: 430)
            }
        }
    }
}

private struct TaskRow: View {
    var title: String
    var detail: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3).fill(tint).frame(width: 6, height: 42)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: .bold))
                Text(detail).font(.system(size: 14, weight: .medium)).foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(JWColor.textMuted)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
    }
}

private struct TestSessionRow: View {
    var session: TestSession

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        StatusBadge(title: "测试", tint: JWColor.accent)
                        Text(session.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(JWColor.text)
                            .lineLimit(1)
                    }
                    HStack(spacing: 16) {
                        Label(session.time, systemImage: "clock")
                        Label(session.grade, systemImage: "graduationcap")
                        Label(session.room, systemImage: "building.2")
                        Label(session.subject, systemImage: "book")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(JWColor.textMuted)
            }
            HStack(spacing: 10) {
                InlineMetric(label: "已报", value: "\(session.seats.count)")
                InlineMetric(label: "已到", value: "\(session.seats.filter(\.studentCheckedIn).count)")
                InlineMetric(label: "家长", value: "\(session.seats.filter(\.parentCheckedIn).count)")
                StatusBadge(title: session.status, tint: JWColor.warning)
            }
        }
        .padding(16)
        .background(JWColor.surfaceMuted.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct InlineMetric: View {
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

