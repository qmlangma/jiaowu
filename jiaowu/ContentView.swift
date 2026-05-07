import SwiftUI

struct ContentView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Group {
            if store.isLoggedIn {
                AppShell()
            } else {
                LoginView()
            }
        }
        .foregroundStyle(JWColor.text)
    }
}

private struct LoginView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedCampusID: UUID?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                JWColor.appBackground
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.3.group.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(JWColor.primary)
                                Text("Jiaowu Desk")
                                    .font(.system(size: 28, weight: .bold))
                            }
                            Text("面向校区老师的横屏 iPad 高效工作台")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(JWColor.textMuted)
                        }
                        Spacer()
                        Text("Mock")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(JWColor.accent)
                            .padding(.horizontal, 12)
                            .frame(height: 30)
                            .background(JWColor.accent.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    HStack(alignment: .top, spacing: 24) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(JWColor.divider))
                            VStack(spacing: 12) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 120, weight: .regular))
                                    .foregroundStyle(JWColor.text)
                                Text("钉钉扫码占位")
                                    .font(.system(size: 18, weight: .bold))
                                Text("本地数据原型，点击进入即可开始")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(JWColor.textMuted)
                            }
                        }
                        .frame(width: 340, height: 340)

                        VStack(alignment: .leading, spacing: 18) {
                            Text("选择工作校区")
                                .font(.system(size: 22, weight: .bold))
                            VStack(spacing: 10) {
                                ForEach(store.campuses) { campus in
                                    Button {
                                        selectedCampusID = campus.id
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(campus.name)
                                                    .font(.system(size: 18, weight: .bold))
                                                Text("\(campus.rooms.count) 间教室 · 本地演示数据")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(JWColor.textMuted)
                                            }
                                            Spacer()
                                            Image(systemName: (selectedCampusID == campus.id || (selectedCampusID == nil && campus.id == store.campuses.first?.id)) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundStyle(JWColor.primary)
                                        }
                                        .padding(16)
                                        .background(.white)
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(JWColor.divider))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            PrimaryButton(title: "进入工作台", systemImage: "arrow.right") {
                                let campus = store.campuses.first { $0.id == selectedCampusID } ?? store.campuses[0]
                                store.login(campus: campus)
                            }
                            HStack(spacing: 12) {
                                LoginMetric(title: "待办", value: "18")
                                LoginMetric(title: "测试班", value: "1")
                                LoginMetric(title: "学员", value: "\(store.students.count)")
                            }
                        }
                    }
                }
                .padding(32)
                .frame(width: min(proxy.size.width - 120, 980))
                .background(.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white))
                .shadow(color: .black.opacity(0.08), radius: 34, x: 0, y: 20)
            }
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
                .monospacedDigit()
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct AppShell: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ZStack(alignment: .top) {
            JWColor.appBackground.ignoresSafeArea()
            HStack(spacing: 16) {
                SidebarView()
                VStack(spacing: 0) {
                    TopBarView()
                    ScrollView {
                        routeView
                            .padding(20)
                    }
                    .scrollIndicators(.hidden)
                }
                .background(JWColor.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .padding(16)

            if let toast = store.toast {
                Text(toast)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 44)
                    .background(JWColor.rail.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 18)
                    .onTapGesture { store.toast = nil }
            }
        }
        .onChange(of: store.toast) { _, newValue in
            guard newValue != nil else { return }
            Task {
                try? await Task.sleep(for: .seconds(2))
                store.toast = nil
            }
        }
    }

    @ViewBuilder
    var routeView: some View {
        switch store.route {
        case .workspace: WorkspaceView()
        case .students: StudentsView()
        case .courseSelection: CourseSelectionView()
        case .schedule: ScheduleView()
        case .attendance: AttendanceView()
        case .assessment: AssessmentView()
        case .orders: OrdersView()
        }
    }
}

private struct SidebarView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
                Image(systemName: "rectangle.3.group.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 52, height: 52)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Text("教务")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(JWColor.textMuted)
            }
            .padding(.top, 18)

            VStack(spacing: 4) {
                ForEach(AppRoute.allCases) { route in
                    Button {
                        store.navigate(route)
                    } label: {
                        ZStack(alignment: .leading) {
                            if store.route == route {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(JWColor.primary)
                                    .frame(width: 4, height: 38)
                                    .offset(x: -10)
                            }
                            VStack(spacing: 5) {
                                Image(systemName: route.symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                Text(route.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .frame(width: 72, height: 58)
                            .foregroundStyle(store.route == route ? JWColor.primary : JWColor.textMuted)
                            .background(store.route == route ? .white : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Button {
                store.toast = "扫码页为前端占位"
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 26, weight: .semibold))
                    .frame(width: 64, height: 50)
            }
            .buttonStyle(.plain)
            Button {
                store.isLoggedIn = false
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 26, weight: .bold))
                    .frame(width: 64, height: 44)
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(JWColor.text)
        .frame(width: 96)
        .frame(maxHeight: .infinity)
        .background(.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(JWColor.divider))
        .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 10)
    }
}

private struct TopBarView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.route.rawValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Text("校区老师 · \(store.currentStaff?.name ?? "纵强强")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                Text("搜索学员 / 班级 / 订单")
                    .foregroundStyle(JWColor.textMuted)
                Spacer()
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 14)
            .frame(width: 360, height: 46)
            .background(JWColor.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(JWColor.divider))
            HStack(spacing: 12) {
                Label("2026-05-07 周四", systemImage: "calendar")
                Label(store.currentCampus?.name ?? "XiangShuW", systemImage: "mappin.and.ellipse")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(JWColor.textMuted)
        }
        .padding(.horizontal, 24)
        .frame(height: 78)
        .background(.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
        .padding(.horizontal, 6)
        .padding(.top, 2)
    }
}

private struct WorkspaceView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 18) {
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

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 14) {
                MetricCard(title: "今日测试班", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "doc.text")
                MetricCard(title: "未签到预警", value: "\(store.unpaidAttendanceCount)", tint: JWColor.danger, systemImage: "exclamationmark.triangle")
                MetricCard(title: "待批改", value: "\(store.pendingReviewCount)", tint: JWColor.warning, systemImage: "pencil.and.outline")
                MetricCard(title: "可退款订单", value: "\(store.paidOrders.count)", tint: JWColor.success, systemImage: "creditcard")
            }

            HStack(alignment: .top, spacing: 16) {
                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
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
                }
                .frame(maxWidth: .infinity)
                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "处理队列", actionTitle: "测评") { store.navigate(.assessment) }
                        VStack(spacing: 10) {
                            TaskRow(title: "试卷人工复核", detail: "\(store.pendingReviewCount) 名学员存在 OCR/AI 待判题", tint: JWColor.warning)
                            TaskRow(title: "未打卡提醒", detail: "\(store.unpaidAttendanceCount) 条考勤需要处理", tint: JWColor.danger)
                            TaskRow(title: "退款确认", detail: "\(store.paidOrders.count) 笔已付款订单可发起退款", tint: JWColor.success)
                        }
                    }
                }
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
        .padding(12)
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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

private struct StudentsView: View {
    @Environment(AppStore.self) private var store
    @State private var search = ""
    @State private var tab = "在读课程"
    @State private var showAddStudent = false
    @State private var showAddLevel = false
    @State private var showCredit = false

    var filteredStudents: [Student] {
        if search.isEmpty { return store.students }
        return store.students.filter { $0.name.localizedStandardContains(search) || $0.number.contains(search) || $0.phone.contains(search) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 14) {
                HStack {
                    Text("学员目录")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button {
                        showAddStudent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(JWColor.primary)
                }
                SearchField(placeholder: "搜索学员、编号、手机号", text: $search)
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(filteredStudents) { student in
                            StudentListRow(student: student, selected: store.selectedStudentID == student.id) {
                                store.selectedStudentID = student.id
                            }
                        }
                    }
                }
            }
            .padding(14)
            .background(.white)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .frame(width: 340)

            if let student = store.selectedStudent {
                VStack(spacing: 14) {
                    AppCard {
                        StudentProfileHeader(student: student, showCredit: { showCredit = true }, showAddLevel: { showAddLevel = true })
                    }
                    AppCard {
                        HStack {
                            ForEach(["在读课程", "订单", "测试级别", "信用分", "记录"], id: \.self) { item in
                                FilterChip(title: item, isSelected: tab == item) { tab = item }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        StudentDetailTab(tab: tab, student: student)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
            } else {
                EmptyStateView()
            }
        }
        .overlay {
            if showAddStudent {
                AddStudentModal(close: { showAddStudent = false })
            }
            if showAddLevel, let student = store.selectedStudent {
                AddLevelModal(student: student, close: { showAddLevel = false })
            }
            if showCredit, let student = store.selectedStudent {
                CreditModal(student: student, close: { showCredit = false })
            }
        }
    }
}

private struct StudentListRow: View {
    var student: Student
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(String(student.name.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(selected ? .white.opacity(0.18) : JWColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.name).font(.system(size: 16, weight: .bold))
                    Text("\(student.grade) · \(student.number)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selected ? .white.opacity(0.78) : JWColor.textMuted)
                }
                Spacer()
            }
            .foregroundStyle(selected ? .white : JWColor.text)
            .padding(12)
            .background(selected ? JWColor.rail : .white)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? Color.clear : JWColor.divider))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct StudentProfileHeader: View {
    var student: Student
    var showCredit: () -> Void
    var showAddLevel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(String(student.name.prefix(1)))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(JWColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(student.name)
                        .font(.system(size: 24, weight: .bold))
                    StatusBadge(title: student.grade, tint: JWColor.primary)
                    StatusBadge(title: student.gender.rawValue, tint: JWColor.textMuted)
                }
                HStack(spacing: 22) {
                    InfoPill(label: "NO", value: student.number)
                    InfoPill(label: "电话", value: student.phone)
                    InfoPill(label: "学校", value: student.school)
                    InfoPill(label: "信用", value: "\(student.creditScore)")
                }
            }
            Spacer()
            HStack(spacing: 10) {
                SecondaryButton(title: "信用明细", systemImage: "list.bullet.rectangle", action: showCredit)
                PrimaryButton(title: "添加成绩", systemImage: "plus", action: showAddLevel)
                    .frame(width: 130)
            }
        }
    }
}

private struct InfoPill: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(JWColor.textMuted)
            Text(value).font(.system(size: 15, weight: .bold)).foregroundStyle(JWColor.text)
        }
    }
}

private struct StudentDetailTab: View {
    @Environment(AppStore.self) private var store
    var tab: String
    var student: Student

    var body: some View {
        VStack(spacing: 12) {
            switch tab {
            case "在读课程":
                let rows = store.enrollments.filter { $0.studentID == student.id }
                if rows.isEmpty { EmptyStateView(title: "暂无在读课程") } else {
                    ForEach(rows) { enrollment in
                        RecordRow(title: store.courses.first { $0.id == enrollment.courseID }?.title ?? "课程", detail: "状态：\(enrollment.status) · 报名日期：\(enrollment.createdAt)", trailing: "修改  转班  退课")
                    }
                }
            case "订单":
                ForEach(store.orders.filter { $0.studentID == student.id }) { order in
                    RecordRow(title: order.courseTitle, detail: "\(order.classTitle) · \(order.paidAt)", trailing: order.status.rawValue)
                }
            case "测试级别":
                if student.testLevels.isEmpty { EmptyStateView(title: "暂无测试级别") } else {
                    ForEach(student.testLevels) { level in
                        RecordRow(title: "\(level.grade) · \(level.subject)", detail: "分数 \(level.score) · 级别 \(level.level)", trailing: level.source)
                    }
                }
            case "信用分":
                ForEach(store.creditRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: "\(record.delta > 0 ? "+" : "")\(record.delta)  \(record.title)", detail: record.dateText, trailing: record.canUndo ? "撤销" : "")
                }
            default:
                ForEach(store.attendanceRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: record.classTitle, detail: "\(record.time) · \(record.status)", trailing: record.hasVisit ? "已回访" : "添加回访")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 440, alignment: .top)
    }
}

private struct RecordRow: View {
    var title: String
    var detail: String
    var trailing: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(detail).font(.system(size: 14, weight: .medium)).foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            if !trailing.isEmpty {
                Text(trailing)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.primary)
            }
        }
        .padding(14)
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct AddStudentModal: View {
    @Environment(AppStore.self) private var store
    @State private var name = ""
    @State private var phone = ""
    @State private var grade = "一年级"
    @State private var gender: Gender = .male
    var close: () -> Void

    var body: some View {
        ModalShell(title: "新增学员", close: close) {
            VStack(spacing: 14) {
                TextField("姓名", text: $name).textFieldStyle(.roundedBorder)
                TextField("电话", text: $phone).textFieldStyle(.roundedBorder)
                Picker("年级", selection: $grade) {
                    ForEach(["一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "初二", "初三", "高一", "高二", "高三"], id: \.self, content: Text.init)
                }
                Picker("性别", selection: $gender) {
                    ForEach(Gender.allCases) { Text($0.rawValue).tag($0) }
                }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "保存学员") {
                        store.addStudent(name: name, phone: phone, grade: grade, gender: gender)
                        close()
                    }
                }
            }
        }
    }
}

private struct AddLevelModal: View {
    @Environment(AppStore.self) private var store
    var student: Student
    var close: () -> Void
    @State private var grade = "二年级"
    @State private var subject = "信息学算法"
    @State private var score = 80
    @State private var level = "A"

    var body: some View {
        ModalShell(title: "新增学员级别", close: close) {
            VStack(spacing: 14) {
                Picker("年级", selection: $grade) { ForEach(["一年级", "二年级", "三年级", "四年级", "五年级", "六年级"], id: \.self, content: Text.init) }
                Picker("学科", selection: $subject) { ForEach(["信息学算法", "信息学实验P", "信息学实验C", "信息学语言传播"], id: \.self, content: Text.init) }
                Stepper("分数：\(score)", value: $score, in: 0...100)
                Picker("级别", selection: $level) { ForEach(["A", "B", "C", "无"], id: \.self, content: Text.init) }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "保存") {
                        store.addLevel(to: student.id, grade: grade, subject: subject, score: score, level: level)
                        close()
                    }
                }
            }
        }
    }
}

private struct CreditModal: View {
    @Environment(AppStore.self) private var store
    var student: Student
    var close: () -> Void

    var body: some View {
        ModalShell(title: "信用分明细", close: close) {
            VStack(alignment: .leading, spacing: 12) {
                StatusBadge(title: "当前信用分 \(student.creditScore) 分", tint: JWColor.success)
                ForEach(store.creditRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: "\(record.delta > 0 ? "+" : "")\(record.delta)", detail: "\(record.dateText)  \(record.title)", trailing: record.canUndo ? "撤销" : "")
                }
            }
        }
    }
}

private struct CourseSelectionView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedGrade = "全部"
    @State private var selectedYear = "2026"
    @State private var selectedType = "全部"
    @State private var selectedSubject = "全部"
    @State private var showStudentPicker = false
    @State private var showDiagnostic = false
    @State private var showSuccess = false

    var filteredCourses: [Course] {
        store.courses.filter { course in
            (selectedGrade == "全部" || course.grade == selectedGrade) &&
            (selectedYear == "全部" || course.year == selectedYear) &&
            (selectedType == "全部" || course.type == selectedType) &&
            (selectedSubject == "全部" || course.subject == selectedSubject)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            CourseFilters(selectedGrade: $selectedGrade, selectedYear: $selectedYear, selectedType: $selectedType, selectedSubject: $selectedSubject)
            HStack(alignment: .top, spacing: 16) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2), spacing: 14) {
                    ForEach(filteredCourses) { course in
                        CourseCard(course: course, selected: store.selectedCourseID == course.id) {
                            store.selectedCourseID = course.id
                            store.selectedClassID = course.classes.first?.id
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "班级选择")
                        if let course = store.selectedCourse {
                            Text(course.title).font(.system(size: 18, weight: .bold))
                            ForEach(course.classes) { klass in
                                Button {
                                    store.selectedClassID = klass.id
                                } label: {
                                    ClassChoiceRow(klass: klass, selected: store.selectedClassID == klass.id)
                                }
                                .buttonStyle(.plain)
                            }
                            PrimaryButton(title: "选择学员并报名", systemImage: "person.badge.plus") {
                                showStudentPicker = true
                            }
                        }
                    }
                }
                .frame(width: 430)
            }
        }
        .overlay {
            if showStudentPicker {
                StudentPickerModal(close: { showStudentPicker = false }, continueAction: {
                    showStudentPicker = false
                    let student = store.selectedStudent
                    let course = store.selectedCourse
                    let enough = student?.testLevels.contains { $0.grade == course?.grade && $0.subject == course?.subject } ?? false
                    if enough || course?.type == "考试" {
                        store.enrollSelectedStudent()
                        showSuccess = true
                    } else {
                        showDiagnostic = true
                    }
                })
            }
            if showDiagnostic {
                DiagnosticPromptModal(close: { showDiagnostic = false }, confirm: {
                    store.enrollSelectedStudent()
                    showDiagnostic = false
                    showSuccess = true
                })
            }
            if showSuccess {
                SignupSuccessModal(close: { showSuccess = false })
            }
        }
    }
}

private struct CourseFilters: View {
    @Binding var selectedGrade: String
    @Binding var selectedYear: String
    @Binding var selectedType: String
    @Binding var selectedSubject: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                FilterRow(title: "年级", options: ["全部", "一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "高三"], selection: $selectedGrade)
                FilterRow(title: "年度", options: ["全部", "2027", "2026", "2025", "2023"], selection: $selectedYear)
                FilterRow(title: "类型", options: ["全部", "寒假课", "春季课", "暑假课", "秋季课", "考试"], selection: $selectedType)
                FilterRow(title: "学科", options: ["全部", "信息学算法", "国文素养", "信息学实验P", "信息学实验C", "信息学语言传播"], selection: $selectedSubject)
            }
        }
    }
}

private struct FilterRow: View {
    var title: String
    var options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 44, alignment: .leading)
                .padding(.top, 10)
            FlexibleChipLayout(options: options, selection: $selection)
        }
    }
}

private struct FlexibleChipLayout: View {
    var options: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(options, id: \.self) { option in
                    FilterChip(title: option, isSelected: selection == option) { selection = option }
                }
            }
        }
    }
}

private struct CourseCard: View {
    var course: Course
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    StatusBadge(title: course.type, tint: course.type == "考试" ? JWColor.accent : JWColor.primary)
                    Spacer()
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(selected ? JWColor.primary : JWColor.textMuted)
                }
                Text(course.title)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(2)
                    .frame(minHeight: 48, alignment: .topLeading)
                VStack(alignment: .leading, spacing: 8) {
                    Label(course.grade, systemImage: "building.columns")
                    Label(course.subject, systemImage: "book.closed")
                    Label(course.dateRange, systemImage: "clock")
                }
                Spacer()
                HStack(alignment: .lastTextBaseline) {
                    Text("\(course.classes.count) 个班级")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                    Spacer()
                    Text(course.price == 0 ? "免费" : "¥ \(course.price)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(course.price == 0 ? JWColor.success : JWColor.accent)
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(JWColor.text)
            .padding(18)
            .frame(minHeight: 210, alignment: .topLeading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? JWColor.primary : JWColor.divider, lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

private struct ClassChoiceRow: View {
    var klass: CourseClass
    var selected: Bool

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(selected ? JWColor.primary : JWColor.divider)
                .frame(width: 6, height: 50)
            VStack(alignment: .leading, spacing: 6) {
                Text(klass.title).font(.system(size: 15, weight: .bold))
                Text("\(klass.weekday) \(klass.time) · \(klass.campus) · \(klass.teacher)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            Text("\(klass.capacity - klass.enrolled)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(JWColor.accent)
        }
        .padding(12)
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? JWColor.primary : JWColor.divider, lineWidth: selected ? 2 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct StudentPickerModal: View {
    @Environment(AppStore.self) private var store
    var close: () -> Void
    var continueAction: () -> Void

    var body: some View {
        ModalShell(title: "请选择学员", close: close) {
            VStack(spacing: 12) {
                ForEach(store.students.prefix(5)) { student in
                    StudentListRow(student: student, selected: store.selectedStudentID == student.id) {
                        store.selectedStudentID = student.id
                    }
                }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "确认报名", action: continueAction)
                }
            }
        }
    }
}

private struct DiagnosticPromptModal: View {
    var close: () -> Void
    var confirm: () -> Void

    var body: some View {
        ModalShell(title: "提示", close: close) {
            VStack(alignment: .leading, spacing: 16) {
                Text("测试级别不满足")
                    .font(.system(size: 18, weight: .bold))
                Text("当前学员无对应级别，可先预约诊断测试。首版原型会继续创建报名记录，便于验证流程闭环。")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "报名诊断测试", action: confirm)
                }
            }
        }
    }
}

private struct SignupSuccessModal: View {
    @Environment(AppStore.self) private var store
    var close: () -> Void

    var body: some View {
        ModalShell(title: "报名成功", close: close) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(JWColor.primary)
                Text("报名成功！")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                if let course = store.selectedCourse, let klass = store.selectedClass {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("报名班级：\(klass.title)")
                            Text("课程：\(course.title)")
                            Text("时间：\(klass.weekday) \(klass.time)")
                            Text("校区：\(klass.campus)")
                        }
                        .font(.system(size: 15, weight: .semibold))
                    }
                }
                PrimaryButton(title: "返回报名记录") {
                    close()
                    store.navigate(.students)
                }
            }
        }
    }
}

private struct ScheduleView: View {
    @Environment(AppStore.self) private var store
    @State private var showReorder = false
    @State private var consultCount = ""

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 14) {
                MetricCard(title: "今日场次", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "number")
                MetricCard(title: "已报", value: "\(store.selectedTestSession?.seats.count ?? 0)", tint: JWColor.accent, systemImage: "person.3")
                MetricCard(title: "已到", value: "\(store.selectedTestSession?.seats.filter(\.studentCheckedIn).count ?? 0)", tint: JWColor.success, systemImage: "checkmark.circle")
            }
            if let session = store.selectedTestSession {
                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionTitle(title: session.title)
                            Spacer()
                            SecondaryButton(title: "重新排座", systemImage: "arrow.up.arrow.down") { showReorder = true }
                            SecondaryButton(title: "试卷批改", systemImage: "doc.text.magnifyingglass") { store.navigate(.assessment) }
                        }
                        ScheduleTable(session: session)
                    }
                }
            }
        }
        .overlay {
            if showReorder, let session = store.selectedTestSession {
                ModalShell(title: "重新排序", close: { showReorder = false }) {
                    Text("重新排序会改变当前座位号顺序，请谨慎操作。")
                        .font(.system(size: 16, weight: .medium))
                    HStack {
                        SecondaryButton(title: "取消") { showReorder = false }
                        PrimaryButton(title: "确定") {
                            store.reorderSeats(sessionID: session.id)
                            showReorder = false
                        }
                    }
                }
            }
        }
    }
}

private struct ScheduleTable: View {
    @Environment(AppStore.self) private var store
    var session: TestSession

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TableHeader("座位号", width: 80)
                TableHeader("学员", width: 180)
                TableHeader("测试科目")
                TableHeader("结果", width: 80)
                TableHeader("答题方式", width: 120)
                TableHeader("学员签到", width: 120)
                TableHeader("家长签到", width: 120)
                TableHeader("操作", width: 180)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(JWColor.surfaceMuted)
            ForEach(session.seats) { seat in
                HStack {
                    Text("\(seat.seatNo)").frame(width: 80)
                    VStack(alignment: .leading) {
                        Text(store.studentName(seat.studentID)).font(.system(size: 15, weight: .bold))
                        Text(store.studentByID(seat.studentID)?.phone ?? "").font(.system(size: 12)).foregroundStyle(JWColor.textMuted)
                    }
                    .frame(width: 180, alignment: .leading)
                    Text(seat.subject).frame(maxWidth: .infinity, alignment: .leading)
                    Text(seat.result.map(String.init) ?? "录入").foregroundStyle(JWColor.primary).frame(width: 80)
                    Picker("", selection: Binding(get: { seat.answerMode }, set: { store.updateAnswerMode(sessionID: session.id, seatID: seat.id, mode: $0) })) {
                        Text("纸笔").tag("纸笔")
                        Text("PAD").tag("PAD")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    CheckButton(isOn: seat.studentCheckedIn) { store.toggleStudentCheckIn(sessionID: session.id, seatID: seat.id) }
                        .frame(width: 120)
                    CheckButton(isOn: seat.parentCheckedIn) { store.toggleParentCheckIn(sessionID: session.id, seatID: seat.id) }
                        .frame(width: 120)
                    HStack {
                        Button("退费") { store.navigate(.orders) }
                        Button("换场次") { store.toast = "换场次入口占位" }
                        Button("换科目") { store.toast = "换科目入口占位" }
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 180)
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(.white)
                .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(JWColor.divider))
    }
}

private struct TableHeader: View {
    var title: String
    var width: CGFloat?
    init(_ title: String, width: CGFloat? = nil) {
        self.title = title
        self.width = width
    }
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(JWColor.textMuted)
            .frame(width: width, alignment: .leading)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

private struct CheckButton: View {
    var isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(isOn ? "已签" : "签到")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isOn ? .white : JWColor.primary)
                .frame(width: 72, height: 36)
                .background(isOn ? JWColor.primary : .white)
                .overlay(RoundedRectangle(cornerRadius: 9).stroke(isOn ? Color.clear : JWColor.divider))
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
    }
}

private struct AttendanceView: View {
    @Environment(AppStore.self) private var store
    @State private var tab = "未打卡"
    @State private var search = ""
    @State private var showRooms = false

    var filteredRecords: [AttendanceRecord] {
        store.attendanceRecords.filter { record in
            let matchesTab = tab == "全部" || record.status == tab || (tab == "已回访" && record.hasVisit)
            let matchesSearch = search.isEmpty || store.studentName(record.studentID).localizedStandardContains(search) || record.classTitle.localizedStandardContains(search)
            return matchesTab && matchesSearch
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                MetricCard(title: "未打卡", value: "\(store.attendanceRecords.filter { $0.status == "未打卡" }.count)", tint: JWColor.danger, systemImage: "person.crop.circle.badge.exclamationmark")
                MetricCard(title: "已回访", value: "\(store.attendanceRecords.filter(\.hasVisit).count)", tint: JWColor.success, systemImage: "phone.fill")
                MetricCard(title: "待处理", value: "\(store.attendanceRecords.count)", tint: JWColor.primary, systemImage: "list.bullet.rectangle")
            }

            AppCard(padding: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        SearchField(placeholder: "搜索学员或班级", text: $search)
                        SecondaryButton(title: "教室管理", systemImage: "building.2") { showRooms = true }
                    }
                    .padding(16)

                    HStack {
                        ForEach(["未打卡", "已回访", "全部"], id: \.self) { item in
                            FilterChip(title: item, isSelected: tab == item) { tab = item }
                        }
                        Spacer()
                        Text("按紧急程度排序")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                    AttendanceTable(records: filteredRecords)
                }
            }
        }
        .overlay {
            if showRooms {
                ClassroomModal(close: { showRooms = false })
            }
        }
    }
}

private struct AttendanceTable: View {
    @Environment(AppStore.self) private var store
    var records: [AttendanceRecord]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DataTableHeader("学员", width: 170)
                DataTableHeader("班级", width: 260)
                DataTableHeader("时间", width: 120)
                DataTableHeader("状态", width: 120)
                DataTableHeader("回访", width: 100)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(JWColor.surfaceMuted)

            if records.isEmpty {
                EmptyStateView(title: "没有符合条件的考勤记录", systemImage: "checkmark.seal")
                    .frame(minHeight: 360)
            } else {
                ForEach(records) { record in
                    HStack {
                        Text(store.studentName(record.studentID))
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 170, alignment: .leading)
                        Text(record.classTitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(JWColor.textMuted)
                            .frame(width: 260, alignment: .leading)
                        Text(record.time)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 120, alignment: .leading)
                        StatusBadge(title: record.status, tint: record.status == "未打卡" ? JWColor.danger : JWColor.success)
                            .frame(width: 120, alignment: .leading)
                        StatusBadge(title: record.hasVisit ? "已回访" : "待回访", tint: record.hasVisit ? JWColor.success : JWColor.warning)
                            .frame(width: 100, alignment: .leading)
                        Spacer()
                        SecondaryButton(title: "联系", systemImage: "phone", tint: JWColor.primary) {
                            store.toast = "已复制家长联系方式"
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 64)
                    .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
                }
            }
        }
        .frame(minHeight: 430, alignment: .top)
    }
}

private struct DataTableHeader: View {
    var title: String
    var width: CGFloat

    init(_ title: String, width: CGFloat) {
        self.title = title
        self.width = width
    }

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(JWColor.textMuted)
            .frame(width: width, alignment: .leading)
    }
}

private struct ClassroomModal: View {
    @Environment(AppStore.self) private var store
    var close: () -> Void

    var body: some View {
        SideSheetShell(title: "教室管理", subtitle: store.currentCampus?.name, close: close) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    StatusBadge(title: "本地模拟控制", tint: JWColor.primary)
                    Spacer()
                    SecondaryButton(title: "一键保护", systemImage: "shield") { store.toast = "已执行一键保护" }
                }

                ForEach(store.currentCampus?.rooms ?? []) { room in
                    AppCard(padding: 14) {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(room.name)
                                    .font(.system(size: 18, weight: .bold))
                                Text(room.webOn || room.screenOn || room.lightOn ? "设备运行中" : "空闲")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(JWColor.textMuted)
                            }
                            Spacer()
                            if let campusID = store.currentCampus?.id {
                                RoomToggle(label: "网页", systemImage: "safari", isOn: room.webOn) {
                                    store.toggleRoom(campusID: campusID, roomID: room.id, keyPath: \.webOn)
                                }
                                RoomToggle(label: "屏幕", systemImage: "display", isOn: room.screenOn) {
                                    store.toggleRoom(campusID: campusID, roomID: room.id, keyPath: \.screenOn)
                                }
                                RoomToggle(label: "灯光", systemImage: "lightbulb", isOn: room.lightOn) {
                                    store.toggleRoom(campusID: campusID, roomID: room.id, keyPath: \.lightOn)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct RoomToggle: View {
    var label: String
    var systemImage: String
    var isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .bold))
                Text(label).font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isOn ? .white : JWColor.textMuted)
            .frame(width: 62, height: 54)
            .background(isOn ? JWColor.primary : JWColor.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AssessmentView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedStudentID: UUID?

    var activeStudentID: UUID? {
        selectedStudentID ?? store.selectedTestSession?.seats.first?.studentID
    }

    var answers: [TestAnswer] {
        guard let sessionID = store.selectedTestSessionID, let studentID = activeStudentID else { return [] }
        return store.testAnswers.filter { $0.sessionID == sessionID && $0.studentID == studentID }.sorted { $0.questionNo < $1.questionNo }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AppCard(padding: 0) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: "批改队列", actionTitle: nil)
                        HStack {
                            StatusBadge(title: "待判 \(store.pendingReviewCount)", tint: JWColor.warning)
                            StatusBadge(title: store.selectedTestSession?.subject ?? "测评", tint: JWColor.primary)
                        }
                    }
                    .padding(16)
                    .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }

                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(store.selectedTestSession?.seats ?? []) { seat in
                                ReviewQueueRow(seat: seat, selected: activeStudentID == seat.studentID) {
                                    selectedStudentID = seat.studentID
                                }
                            }
                        }
                        .padding(12)
                    }
                }
            }
            .frame(width: 360)

            AppCard(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    if let studentID = activeStudentID {
                        HStack(alignment: .center, spacing: 18) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(store.studentName(studentID))
                                    .font(.system(size: 24, weight: .bold))
                                Text("\(store.selectedTestSession?.title ?? "") · \(store.selectedTestSession?.subject ?? "")")
                                    .foregroundStyle(JWColor.textMuted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("当前得分")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(JWColor.textMuted)
                                Text("\(answers.filter { $0.state == .correct }.count * 3)")
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundStyle(JWColor.primary)
                                    .monospacedDigit()
                            }
                            PrimaryButton(title: "提交", systemImage: "checkmark.seal") {
                                if let sessionID = store.selectedTestSessionID {
                                    store.submitAssessment(for: studentID, sessionID: sessionID)
                                }
                            }
                            .frame(width: 140)
                        }
                        .padding(18)
                        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }

                        QuestionStrip(answers: answers)
                            .padding(16)

                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                                ForEach(answers) { answer in
                                    AnswerCard(answer: answer)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    } else {
                        EmptyStateView(title: "请选择需要批改的学员", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }
        }
    }
}

private struct ReviewQueueRow: View {
    @Environment(AppStore.self) private var store
    var seat: TestSeat
    var selected: Bool
    var action: () -> Void

    var pendingCount: Int {
        guard let sessionID = store.selectedTestSessionID else { return 0 }
        return store.testAnswers.filter { $0.sessionID == sessionID && $0.studentID == seat.studentID && $0.state == .review }.count
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text("\(seat.seatNo)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(selected ? .white : JWColor.primary)
                    .frame(width: 38, height: 38)
                    .background(selected ? JWColor.primary : JWColor.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    Text(store.studentName(seat.studentID))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(selected ? .white : JWColor.text)
                    Text(seat.result.map { "已提交 \($0) 分" } ?? "待批改")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selected ? .white.opacity(0.72) : JWColor.textMuted)
                }
                Spacer()
                if pendingCount > 0 {
                    StatusBadge(title: "\(pendingCount) 待判", tint: selected ? .white : JWColor.warning)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(selected ? .white : JWColor.success)
                }
            }
            .padding(12)
            .background(selected ? JWColor.rail : JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(selected ? Color.clear : JWColor.divider))
        }
        .buttonStyle(.plain)
    }
}

private struct QuestionStrip: View {
    var answers: [TestAnswer]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(answers) { answer in
                HStack(spacing: 6) {
                    Text("\(answer.questionNo)")
                        .font(.system(size: 13, weight: .bold))
                    Image(systemName: answer.state == .correct ? "checkmark.circle" : (answer.state == .wrong ? "xmark.circle" : "questionmark.circle"))
                        .foregroundStyle(answer.state == .correct ? JWColor.success : (answer.state == .wrong ? .red : JWColor.warning))
                }
                .frame(height: 36)
                .frame(maxWidth: .infinity)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(JWColor.divider))
            }
        }
        .padding(12)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct AnswerCard: View {
    @Environment(AppStore.self) private var store
    var answer: TestAnswer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadge(title: "第 \(answer.questionNo) 题", tint: answer.state == .review ? JWColor.warning : JWColor.primary)
                Spacer()
                HStack(spacing: 8) {
                    MarkButton(systemImage: "checkmark", tint: JWColor.success, selected: answer.state == .correct) {
                        store.markAnswer(answer.id, as: .correct)
                    }
                    MarkButton(systemImage: "xmark", tint: JWColor.danger, selected: answer.state == .wrong) {
                        store.markAnswer(answer.id, as: .wrong)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                AnswerLine(label: "标准答案", value: answer.officialAnswer)
                AnswerLine(label: "学员答案", value: answer.studentAnswer, muted: answer.studentAnswer == "学生未作答")
                if let issue = answer.issue {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(issue)
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.danger)
                }
            }
        }
        .padding(14)
        .background(answer.state == .review ? JWColor.warning.opacity(0.08) : JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(answer.state == .review ? JWColor.warning.opacity(0.4) : JWColor.divider))
    }
}

private struct MarkButton: View {
    var systemImage: String
    var tint: Color
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selected ? .white : tint)
                .frame(width: 40, height: 40)
                .background(selected ? tint : tint.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct AnswerLine: View {
    var label: String
    var value: String
    var muted = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(JWColor.textMuted)
                .frame(width: 58, alignment: .leading)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(muted ? JWColor.textMuted : JWColor.text)
        }
    }
}

private struct OrdersView: View {
    @Environment(AppStore.self) private var store
    @State private var tab: OrderStatus = .paid
    @State private var search = ""
    @State private var showRefund = false

    var rows: [Order] {
        store.orders.filter { $0.status == tab && (search.isEmpty || $0.courseTitle.localizedStandardContains(search) || store.studentName($0.studentID).localizedStandardContains(search)) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AppCard(padding: 0) {
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        SearchField(placeholder: "搜索班级或学员", text: $search)
                        HStack {
                            ForEach(OrderStatus.allCases) { status in
                                FilterChip(title: status.rawValue, isSelected: tab == status) { tab = status }
                            }
                            Spacer()
                        }
                    }
                    .padding(16)
                    .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }

                    OrderTable(rows: rows) { order in
                        store.selectedOrderID = order.id
                        showRefund = true
                    }
                }
            }

            RefundSummaryPanel()
                .frame(width: 300)
        }
        .overlay {
            if showRefund, let order = store.selectedOrder {
                RefundModal(order: order, close: { showRefund = false })
            }
        }
    }
}

private struct OrderTable: View {
    var rows: [Order]
    var refund: (Order) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                DataTableHeader("订单", width: 320)
                DataTableHeader("学员", width: 130)
                DataTableHeader("金额", width: 100)
                DataTableHeader("收款", width: 160)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(JWColor.surfaceMuted)

            if rows.isEmpty {
                EmptyStateView(title: "当前暂无订单", systemImage: "creditcard")
                    .frame(minHeight: 440)
            } else {
                ForEach(rows) { order in
                    OrderRow(order: order) { refund(order) }
                }
            }
        }
        .frame(minHeight: 500, alignment: .top)
    }
}

private struct OrderRow: View {
    @Environment(AppStore.self) private var store
    var order: Order
    var refund: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StatusBadge(title: order.status.rawValue, tint: order.status == .paid ? JWColor.primary : (order.status == .refunded ? JWColor.success : JWColor.warning))
                    Text(order.courseTitle)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                }
                Text(order.classTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            .frame(width: 320, alignment: .leading)
            Text(store.studentName(order.studentID))
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 130, alignment: .leading)
            Text("¥ \(order.amount)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(order.amount == 0 ? JWColor.danger : JWColor.text)
                .monospacedDigit()
                .frame(width: 100, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(order.receiver)
                    .font(.system(size: 14, weight: .bold))
                Text(order.paidAt)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            .frame(width: 160, alignment: .leading)
            Spacer()
            if order.status == .paid {
                SecondaryButton(title: "退款", systemImage: "arrow.uturn.backward", tint: JWColor.danger, action: refund)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 76)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
    }
}

private struct RefundSummaryPanel: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "退款概览", actionTitle: nil)
                VStack(spacing: 10) {
                    MetricLine(label: "可退款订单", value: "\(store.paidOrders.count)")
                    MetricLine(label: "已退款", value: "\(store.refunds.count)")
                    MetricLine(label: "退款金额", value: "¥ \(store.refunds.reduce(0) { $0 + $1.amount })")
                }
                Divider()
                Text("最近退款")
                    .font(.system(size: 15, weight: .bold))
                if store.refunds.isEmpty {
                    Text("暂无退款记录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                } else {
                    ForEach(store.refunds.prefix(4)) { refund in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(refund.reason)
                                .font(.system(size: 14, weight: .bold))
                            Text("¥ \(refund.amount) · \(refund.createdAt)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(JWColor.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(JWColor.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}

private struct MetricLine: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(JWColor.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .monospacedDigit()
        }
    }
}

private struct RefundModal: View {
    @Environment(AppStore.self) private var store
    var order: Order
    var close: () -> Void
    @State private var reason = "课程退款"
    @State private var type = "退课-课前退"
    @State private var amount = "0"
    @State private var note = ""

    var body: some View {
        SideSheetShell(title: "发起退款", subtitle: "\(store.studentName(order.studentID)) · ¥ \(order.amount)", close: close) {
            VStack(alignment: .leading, spacing: 18) {
                AppCard(padding: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoLine(label: "课程", value: order.courseTitle)
                        InfoLine(label: "班级", value: order.classTitle)
                        InfoLine(label: "原单", value: "¥ \(order.amount)")
                    }
                }

                FormBlock(title: "退款信息") {
                    Picker("退款原因", selection: $reason) {
                        ForEach(["课程退款", "线上课返利", "其他"], id: \.self, content: Text.init)
                    }
                    .pickerStyle(.segmented)

                    Picker("退款类型", selection: $type) {
                        ForEach(["退课-课前退", "仅退款", "特殊退款"], id: \.self, content: Text.init)
                    }
                    .pickerStyle(.menu)

                    TextField("退款金额", text: $amount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    TextField("备注", text: $note, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4)
                }

                HStack(spacing: 12) {
                    SecondaryButton(title: "取消", systemImage: "xmark", tint: JWColor.textMuted, action: close)
                    PrimaryButton(title: "确认退款", systemImage: "checkmark") {
                        store.refund(orderID: order.id, reason: reason, type: type, amount: Int(amount) ?? 0, note: note)
                        close()
                    }
                }
            }
        }
    }
}

private struct FormBlock<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
            content
        }
    }
}

private struct InfoLine: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(JWColor.textMuted)
                .frame(width: 48, alignment: .leading)
            Text(value)
                .font(.system(size: 15, weight: .bold))
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
}
