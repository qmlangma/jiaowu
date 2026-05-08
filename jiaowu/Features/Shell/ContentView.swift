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

private struct AppShell: View {
    @Environment(AppStore.self) private var store
    @State private var isSidebarCollapsed = false

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.70, green: 0.74, blue: 0.95),
                        Color(red: 0.80, green: 0.82, blue: 0.95),
                        JWColor.appBackground,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(JWColor.primary.opacity(0.12))
                    .frame(width: 520, height: 520)
                    .offset(x: -420, y: -320)
                Circle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 600, height: 600)
                    .offset(x: 450, y: -260)
            }
            .ignoresSafeArea()

            HStack(spacing: 10) {
                SidebarView(isCollapsed: $isSidebarCollapsed)
                VStack(spacing: 0) {
                    TopBarView()
                    ScrollView {
                        routeView
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

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

            if store.shouldPresentCampusDialog {
                CampusPickDialog()
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

private struct CampusPickDialog: View {
    @Environment(AppStore.self) private var store
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("请选择工作校区")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Spacer()
                    Button {
                        store.shouldPresentCampusDialog = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(JWColor.textMuted)
                            .frame(width: 30, height: 30)
                            .background(JWColor.surfaceMuted)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(store.campuses) { campus in
                            CampusGridItem(
                                name: campus.name,
                                isSelected: store.pendingCampusSelectionID == campus.id
                            ) {
                                store.pendingCampusSelectionID = campus.id
                            }
                        }
                    }
                }
                .frame(maxHeight: 360)

                PrimaryButton(title: "确认选择", systemImage: "checkmark") {
                    store.confirmPendingCampusSelection()
                }
                .opacity(store.pendingCampusSelectionID == nil ? 0.55 : 1)
                .allowsHitTesting(store.pendingCampusSelectionID != nil)
            }
            .padding(20)
            .frame(width: 760)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(JWColor.divider))
            .shadow(color: .black.opacity(0.1), radius: 22, x: 0, y: 10)
        }
    }
}

private struct CampusGridItem: View {
    var name: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(JWColor.primary)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(isSelected ? JWColor.primaryLight : JWColor.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SidebarView: View {
    @Environment(AppStore.self) private var store
    @Binding var isCollapsed: Bool

    var body: some View {
        VStack(spacing: 10) {
            Group {
                if isCollapsed {
                    VStack(spacing: 6) {
                        Image("DefaultAvatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Image("DefaultAvatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            Text(store.currentStaff?.name ?? "教务老师")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(JWColor.text)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.top, 12)

            VStack(spacing: 4) {
                ForEach(AppRoute.allCases) { route in
                    Button {
                        store.navigate(route)
                    } label: {
                        HStack(spacing: 10) {
                            VStack(spacing: 5) {
                                Image(systemName: route.symbol)
                                    .font(.system(size: 17, weight: .medium))
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .frame(width: 44, height: 44)
                            .foregroundStyle(store.route == route ? JWColor.primary : JWColor.textMuted)
                            .background(store.route == route ? JWColor.primaryLight : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            if !isCollapsed {
                                Text(route.rawValue)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(store.route == route ? JWColor.primary : JWColor.text)
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.horizontal, isCollapsed ? 0 : 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Button {
                store.toast = "扫码页为前端占位"
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 44, height: 44)
                    if !isCollapsed {
                        Text("扫码")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, isCollapsed ? 0 : 6)
            }
            .buttonStyle(.plain)
            Button {
                store.isLoggedIn = false
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 44, height: 40)
                    if !isCollapsed {
                        Text("退出登录")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, isCollapsed ? 0 : 6)
            }
            .buttonStyle(.plain)
            Button {
                isCollapsed.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isCollapsed ? "sidebar.leading" : "sidebar.left")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 44, height: 40)
                    if !isCollapsed {
                        Text(isCollapsed ? "展开侧栏" : "收起侧栏")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, isCollapsed ? 0 : 6)
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(JWColor.text)
        .frame(width: isCollapsed ? 72 : 188)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.62), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}

private struct TopBarView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.route.rawValue)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Text("校区老师 · \(store.currentStaff?.name ?? "许艳博")")
                    .font(.system(size: 14, weight: .semibold))
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
            .frame(width: 350, height: 46)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.58)))
            HStack(spacing: 12) {
                Label("2026-05-07 周四", systemImage: "calendar")
                Label(store.currentCampus?.name ?? "XiangShuW", systemImage: "mappin.and.ellipse")
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(JWColor.textMuted)
        }
        .padding(.horizontal, 12)
        .frame(height: 78)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.58), lineWidth: 1))
        .padding(.bottom, 6)
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
        VStack(alignment: .leading, spacing: 14) {
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

                VStack(alignment: .leading, spacing: 14) {
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
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
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
        VStack(alignment: .leading, spacing: 14) {
            FilterRow(title: "年级", options: ["全部", "一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "高三"], selection: $selectedGrade)
            FilterRow(title: "年度", options: ["全部", "2027", "2026", "2025", "2023"], selection: $selectedYear)
            FilterRow(title: "类型", options: ["全部", "寒假课", "春季课", "暑假课", "秋季课", "考试"], selection: $selectedType)
            FilterRow(title: "学科", options: ["全部", "信息学算法", "国文素养", "信息学实验P", "信息学实验C", "信息学语言传播"], selection: $selectedSubject)
        }
        .padding(16)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
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
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? JWColor.primary : JWColor.divider, lineWidth: selected ? 1.5 : 1))
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
        .background(JWColor.surfaceMuted.opacity(selected ? 0.55 : 0.28))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? JWColor.primary : JWColor.divider, lineWidth: selected ? 1.5 : 1))
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
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                MetricCard(title: "今日场次", value: "\(store.testSessions.count)", tint: JWColor.primary, systemImage: "number")
                MetricCard(title: "已报", value: "\(store.selectedTestSession?.seats.count ?? 0)", tint: JWColor.accent, systemImage: "person.3")
                MetricCard(title: "已到", value: "\(store.selectedTestSession?.seats.filter(\.studentCheckedIn).count ?? 0)", tint: JWColor.success, systemImage: "checkmark.circle")
            }
            if let session = store.selectedTestSession {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        SectionTitle(title: session.title)
                        Spacer()
                        SecondaryButton(title: "重新排座", systemImage: "arrow.up.arrow.down") { showReorder = true }
                        SecondaryButton(title: "试卷批改", systemImage: "doc.text.magnifyingglass") { store.navigate(.assessment) }
                    }
                    ScheduleTable(session: session)
                }
                .padding(16)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
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
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.clear)
            ForEach(session.seats) { seat in
                HStack {
                    Text("\(seat.seatNo)").frame(width: 80)
                    VStack(alignment: .leading) {
                        let student = store.studentByID(seat.studentID)
                        HStack(spacing: 6) {
                            if seat.studentLoggedIn {
                                Image(systemName: "wifi")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(JWColor.success)
                            }
                            Text(student?.name ?? store.studentName(seat.studentID))
                                .font(.system(size: 15, weight: .bold))
                        }
                        if let number = student?.number {
                            Text(number)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(JWColor.text)
                        }
                        Text(student?.phone ?? "")
                            .font(.system(size: 12))
                            .foregroundStyle(JWColor.textMuted)
                        HStack(spacing: 8) {
                            InlineActionButton(title: "打电话", systemImage: "phone.fill") {
                                let phone = store.studentByID(seat.studentID)?.phone ?? "--"
                                store.toast = "拨号占位：\(phone)"
                            }
                            InlineActionButton(title: "扫码登录", systemImage: "qrcode.viewfinder") {
                                store.toast = "扫码登录占位"
                            }
                        }
                    }
                    .frame(width: 180, alignment: .leading)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(seat.subjects) { subjectItem in
                            HStack(spacing: 8) {
                                Text(subjectItem.title)
                                    .lineLimit(1)
                                if subjectItem.isMakeup {
                                    Text("补")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .frame(height: 20)
                                        .background(JWColor.accent)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(seat.subjects) { _ in
                            Text(seat.result.map(String.init) ?? "录入")
                                .foregroundStyle(JWColor.primary)
                        }
                    }
                    .frame(width: 80, alignment: .leading)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(seat.subjects) { _ in
                            Picker("", selection: Binding(get: { seat.answerMode }, set: { store.updateAnswerMode(sessionID: session.id, seatID: seat.id, mode: $0) })) {
                                Text("纸笔").tag("纸笔")
                                Text("PAD").tag("PAD")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .frame(width: 120, alignment: .leading)
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
                .padding(.vertical, 16)
                .padding(.horizontal, 12)
                .background(JWColor.surface)
                .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
            }
        }
    }
}

private struct InlineActionButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .medium))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(JWColor.primary)
            .padding(.horizontal, 2)
            .frame(height: 24)
        }
        .buttonStyle(.plain)
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
            .font(.system(size: 13, weight: .semibold))
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isOn ? .white : JWColor.primary)
                .frame(width: 72, height: 36)
                .background(isOn ? JWColor.primary : JWColor.primaryLight.opacity(0.55))
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
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                MetricCard(title: "未打卡", value: "\(store.attendanceRecords.filter { $0.status == "未打卡" }.count)", tint: JWColor.danger, systemImage: "person.crop.circle.badge.exclamationmark")
                MetricCard(title: "已回访", value: "\(store.attendanceRecords.filter(\.hasVisit).count)", tint: JWColor.success, systemImage: "phone.fill")
                MetricCard(title: "待处理", value: "\(store.attendanceRecords.count)", tint: JWColor.primary, systemImage: "list.bullet.rectangle")
            }

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
                .padding(.bottom, 12)

                AttendanceTable(records: filteredRecords)
            }
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
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
            .background(Color.clear)

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
                    .padding(14)
                    .background(JWColor.surfaceMuted.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            VStack(spacing: 0) {
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
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
            .frame(width: 360)

            VStack(alignment: .leading, spacing: 0) {
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
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
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
            .background(selected ? JWColor.primary : JWColor.surfaceMuted.opacity(0.35))
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
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
            .frame(maxWidth: .infinity)
            .layoutPriority(1)

            RefundSummaryPanel()
                .frame(width: 260)
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
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    DataTableHeader("订单", width: 280)
                    DataTableHeader("学员", width: 110)
                    DataTableHeader("金额", width: 90)
                    DataTableHeader("收款", width: 150)
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
            .frame(minWidth: 760, minHeight: 500, alignment: .topLeading)
        }
        .frame(minHeight: 500, alignment: .topLeading)
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
            .frame(width: 280, alignment: .leading)
            Text(store.studentName(order.studentID))
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 110, alignment: .leading)
            Text("¥ \(order.amount)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(order.amount == 0 ? JWColor.danger : JWColor.text)
                .monospacedDigit()
                .frame(width: 90, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(order.receiver)
                    .font(.system(size: 14, weight: .bold))
                Text(order.paidAt)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            .frame(width: 150, alignment: .leading)
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
                        .padding(.vertical, 8)
                        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
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
                VStack(alignment: .leading, spacing: 10) {
                    InfoLine(label: "课程", value: order.courseTitle)
                    InfoLine(label: "班级", value: order.classTitle)
                    InfoLine(label: "原单", value: "¥ \(order.amount)")
                }
                .padding(14)
                .background(JWColor.surfaceMuted.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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
