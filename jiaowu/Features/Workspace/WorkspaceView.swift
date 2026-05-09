import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 10) {
                    Text("工作台")
                        .font(.system(size: 46, weight: .bold))
                    Button {
                        store.pendingCampusSelectionID = store.currentCampus?.id
                        store.shouldPresentCampusDialog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(store.currentCampus?.name ?? "请选择校区")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(JWColor.primaryLight)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: 10) {
                    SecondaryButton(title: "扫码", systemImage: "qrcode.viewfinder") { store.toast = "扫码页为前端占位" }
                        .frame(height: 44)
                    PrimaryButton(title: "快速报名", systemImage: "plus") { store.navigate(.courseSelection) }
                        .frame(width: 140, height: 44)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                MetricCard(title: "今日测试班", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "doc.text")
                MetricCard(title: "待跟进学员", value: "\(store.unpaidAttendanceCount)", tint: JWColor.danger, systemImage: "person.crop.circle.badge.exclamationmark")
                MetricCard(title: "待批改", value: "\(store.pendingReviewCount)", tint: JWColor.warning, systemImage: "pencil.and.outline")
                MetricCard(title: "待处理订单", value: "\(store.paidOrders.count)", tint: JWColor.accent, systemImage: "creditcard")
                MetricCard(title: "未考勤预警", value: "\(store.unpaidAttendanceCount)", tint: JWColor.warning, systemImage: "bell.badge")
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "今日测试班", actionTitle: "课表") { store.navigate(.schedule) }
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "待办提醒", actionTitle: nil)
                    VStack(spacing: 2) {
                        TaskRow(title: "试卷人工复核", detail: "\(store.pendingReviewCount) 名学员存在 OCR/AI 待判题", tint: JWColor.warning)
                        TaskRow(title: "未打卡提醒", detail: "\(store.unpaidAttendanceCount) 条考勤需要处理", tint: JWColor.danger)
                        TaskRow(title: "退款确认", detail: "\(store.paidOrders.count) 笔已付款订单可发起退款", tint: JWColor.success)
                    }
                }
                .frame(width: 430)
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
            }

            AppCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(title: "快捷入口", actionTitle: nil)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                        QuickEntryButton(title: "学员检索", symbol: "magnifyingglass") { store.navigate(.students) }
                        QuickEntryButton(title: "选课报名", symbol: "checkmark.seal") { store.navigate(.courseSelection) }
                        QuickEntryButton(title: "课表登记", symbol: "calendar.badge.plus") { store.navigate(.schedule) }
                        QuickEntryButton(title: "考勤管理", symbol: "checkmark.circle") { store.navigate(.attendance) }
                    }
                }
            }
        }
    }
}

private struct QuickEntryButton: View {
    var title: String
    var symbol: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.text)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
            .background(JWColor.surfaceMuted.opacity(0.58))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
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

