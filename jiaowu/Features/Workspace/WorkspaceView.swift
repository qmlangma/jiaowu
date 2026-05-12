import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store
    private let metricsColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let quickEntryColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            WorkspaceHero(
                campusName: store.currentCampus?.name ?? "请选择校区",
                openCampus: {
                    store.pendingCampusSelectionID = store.currentCampus?.id
                    store.shouldPresentCampusDialog = true
                },
                scanAction: { store.toast = "扫码页为前端占位" },
                quickRegisterAction: { store.navigate(.courseSelection) }
            )

            LazyVGrid(columns: metricsColumns, spacing: 12) {
                MetricCard(title: "今日测试班", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "calendar.badge.clock")
                MetricCard(title: "待跟进学员", value: "\(store.unpaidAttendanceCount)", tint: JWColor.danger, systemImage: "person.2.badge.gearshape")
                MetricCard(title: "待批改", value: "\(store.pendingReviewCount)", tint: JWColor.warning, systemImage: "checklist.unchecked")
                MetricCard(title: "待处理订单", value: "\(store.paidOrders.count)", tint: JWColor.accent, systemImage: "creditcard.and.123")
            }

            HStack(alignment: .top, spacing: 16) {
                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("今日测试班")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(JWColor.text)
                            Spacer()
                            Button("查看课表") { store.navigate(.schedule) }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(JWColor.primary)
                                .buttonStyle(.plain)
                        }
                        .frame(minHeight: 32, alignment: .leading)
                        if store.testSessions.isEmpty {
                            EmptyStateView(title: "今日暂无测试班", systemImage: "calendar.badge.exclamationmark")
                                .frame(height: 180)
                        } else {
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
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("提醒事项")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(JWColor.text)
                            .frame(minHeight: 32, alignment: .leading)
                        ReminderRow(title: "试卷人工复核", detail: "\(store.pendingReviewCount) 名学员存在 OCR/AI 待判题", symbol: "doc.text.magnifyingglass", tint: JWColor.warning)
                        ReminderRow(title: "未打卡提醒", detail: "\(store.unpaidAttendanceCount) 条考勤需要处理", symbol: "person.crop.circle.badge.exclamationmark", tint: JWColor.danger)
                        ReminderRow(title: "退款确认", detail: "\(store.paidOrders.count) 笔订单可发起退款", symbol: "arrow.uturn.backward.circle", tint: JWColor.success)
                    }
                }
                .frame(width: 420)
            }

            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("常用功能")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(JWColor.text)
                        .frame(minHeight: 32, alignment: .leading)
                    LazyVGrid(columns: quickEntryColumns, spacing: 12) {
                        QuickEntryButton(title: "学员检索", symbol: "person.text.rectangle") { store.navigate(.students) }
                        QuickEntryButton(title: "选课报名", symbol: "list.bullet.clipboard") { store.navigate(.courseSelection) }
                        QuickEntryButton(title: "课表登记", symbol: "calendar.badge.plus") { store.navigate(.schedule) }
                        QuickEntryButton(title: "考勤管理", symbol: "checkmark.circle.badge.clock") { store.navigate(.attendance) }
                        QuickEntryButton(title: "订单中心", symbol: "wallet.pass") { store.navigate(.orders) }
                        QuickEntryButton(title: "校区设置", symbol: "building.2.crop.circle") { store.toast = "校区设置为前端占位" }
                    }
                }
            }
        }
    }
}

private struct WorkspaceHero: View {
    var campusName: String
    var openCampus: () -> Void
    var scanAction: () -> Void
    var quickRegisterAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Text("工作台")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Button(action: openCampus) {
                    HStack(spacing: 6) {
                        Image(systemName: "location.circle")
                        Text(campusName)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(JWColor.primaryLight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
            HStack(spacing: 10) {
                SecondaryButton(title: "扫码", systemImage: "qrcode.viewfinder", action: scanAction)
                    .frame(height: 44)
                PrimaryButton(title: "快速报名", systemImage: "plus.circle.fill", action: quickRegisterAction)
                    .frame(width: 150, height: 44)
            }
        }
        .padding(18)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct QuickEntryButton: View {
    var title: String
    var symbol: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 28, height: 28)
                    .background(JWColor.primary.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 54)
            .background(JWColor.surfaceMuted.opacity(0.20))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(JWColor.divider.opacity(0.75), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ReminderRow: View {
    var title: String
    var detail: String
    var symbol: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                Text(detail)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
    }
}

private struct TestSessionRow: View {
    var session: TestSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        StatusBadge(title: "测试", tint: JWColor.accent)
                        Text(session.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(JWColor.text)
                            .lineLimit(1)
                    }
                    HStack(spacing: 14) {
                        Label(session.time, systemImage: "clock")
                        Label(session.grade, systemImage: "graduationcap")
                        Label(session.room, systemImage: "building.2")
                        Label(session.subject, systemImage: "book.closed")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            HStack(spacing: 10) {
                InlineMetric(label: "已报", value: "\(session.seats.count)")
                InlineMetric(label: "已到", value: "\(session.seats.filter(\.studentCheckedIn).count)")
                InlineMetric(label: "家长", value: "\(session.seats.filter(\.parentCheckedIn).count)")
                StatusBadge(title: session.status, tint: JWColor.warning)
            }
        }
        .padding(14)
        .background(JWColor.surfaceMuted.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct InlineMetric: View {
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
