import SwiftUI

struct LoginPageView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedCampusID: UUID?

    var body: some View {
        ZStack {
            JWColor.appBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("教务任务中心")
                    .font(.system(size: 34, weight: .bold))
                Text("选择校区并进入今日任务视图")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                AppCard {
                    VStack(spacing: 10) {
                        ForEach(store.campuses) { campus in
                            Button {
                                selectedCampusID = campus.id
                            } label: {
                                HStack {
                                    Text(campus.name)
                                        .font(.system(size: 18, weight: .bold))
                                    Spacer()
                                    Image(systemName: selectedCampusID == campus.id ? "checkmark.circle.fill" : "circle")
                                }
                                .foregroundStyle(JWColor.text)
                                .padding(14)
                                .background(JWColor.surfaceMuted)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                PrimaryButton(title: "进入任务中心", systemImage: "arrow.right.circle.fill") {
                    guard let target = store.campuses.first(where: { $0.id == selectedCampusID }) ?? store.campuses.first else { return }
                    store.login(campus: target)
                    store.sendFeedback("欢迎回来，\(target.name)", level: .success)
                }
                HStack(spacing: 12) {
                    LoginMetric(title: "待批改", value: "\(store.pendingReviewCount)")
                    LoginMetric(title: "未打卡", value: "\(store.unpaidAttendanceCount)")
                    LoginMetric(title: "可退款", value: "\(store.paidOrders.count)")
                }
            }
            .padding(28)
            .frame(width: 760)
            .background(.white.opacity(0.84))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(JWColor.divider))
        }
    }
}

private struct LoginMetric: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
