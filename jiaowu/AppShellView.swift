import SwiftUI

struct AppShellView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ZStack(alignment: .top) {
            JWColor.appBackground.ignoresSafeArea()
            HStack(spacing: 16) {
                AppSidebarView()
                VStack(spacing: 14) {
                    AppTopBarView()
                    ScrollView {
                        routeView
                            .padding(.horizontal, 6)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(16)

            if let feedback = store.feedback {
                FeedbackToastView(feedback: feedback)
                    .padding(.top, 20)
                    .onTapGesture {
                        store.feedback = nil
                    }
            }
        }
        .onChange(of: store.feedback?.id) { _, newValue in
            guard newValue != nil else { return }
            Task {
                try? await Task.sleep(for: .seconds(2))
                store.feedback = nil
            }
        }
    }

    @ViewBuilder
    private var routeView: some View {
        switch store.route {
        case .workspace: WorkspacePageView()
        case .students: StudentsPageView()
        case .courseSelection: EnrollmentPageView()
        case .schedule: SessionOpsPageView()
        case .attendance: AttendancePageView()
        case .assessment: SessionOpsPageView(initialTab: .marking)
        case .orders: OrdersPageView()
        }
    }
}

private struct AppSidebarView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                Image(systemName: "rectangle.3.group.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 54, height: 54)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Text("任务导航")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(JWColor.textMuted)
            }
            .padding(.top, 16)

            ForEach(AppRoute.allCases) { route in
                Button {
                    store.navigate(route)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: route.symbol)
                            .font(.system(size: 18, weight: .bold))
                        Text(route.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                    }
                    .frame(width: 80, height: 56)
                    .foregroundStyle(store.route == route ? JWColor.primary : JWColor.textMuted)
                    .background(store.route == route ? .white : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                store.sendFeedback("已退出登录", level: .warning)
                store.isLoggedIn = false
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 64, height: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(JWColor.textMuted)
        }
        .frame(width: 98)
        .frame(maxHeight: .infinity)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(JWColor.divider))
    }
}

private struct AppTopBarView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.route.rawValue)
                    .font(.system(size: 24, weight: .bold))
                Text("\(store.currentCampus?.name ?? "-") · \(store.currentStaff?.name ?? "-")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            SearchField(
                placeholder: "搜索学员 / 班级 / 订单",
                text: Binding(
                    get: { store.navigationState.searchText },
                    set: { store.navigationState.searchText = $0 }
                )
            )
                .frame(width: 360)
            StatusBadge(title: "iPad 横屏", tint: JWColor.primary)
        }
        .padding(.horizontal, 20)
        .frame(height: 74)
        .background(.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(JWColor.divider))
    }
}
