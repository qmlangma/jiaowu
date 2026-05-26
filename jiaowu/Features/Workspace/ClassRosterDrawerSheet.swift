import SwiftUI

private enum StudentSignInState {
    case notSigned
    case signed(time: String, late: Bool)
}

private enum StudentSignOutState {
    case notSignedOut
    case signedOut(time: String)
}

private extension StudentSignInState {
    var isSigned: Bool {
        if case .signed = self { return true }
        return false
    }
}

private struct RosterStudent: Identifiable {
    let id = UUID()
    var name: String
    var number: String
    var phone: String
    var transferredIn: Bool
    var transferOutTag: String?
    var transferTarget: String?
    var exited: Bool
    var exitTime: String?
    var signInState: StudentSignInState
    var signOutState: StudentSignOutState
}

struct ClassRosterDrawerSheet: View {
    @Environment(AppStore.self) private var store
    var session: RoomSession
    var classTimeSlot: String
    var openTeacherDetail: (TeacherProfile) -> Void
    var close: () -> Void

    @State private var activeTab = 0
    @State private var students: [RosterStudent] = []
    @State private var isDrawerVisible = false
    private let drawerAnimationDuration = 0.24

    private var teacherSignText: String { session.teacherSignedIn ? "已签到 18:21" : "未签到" }
    private var assistantSignText: String { session.assistantSignedIn ? "已签到 18:24" : "未签到" }

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .trailing) {
                Color.black.opacity(isDrawerVisible ? 0.30 : 0)
                    .ignoresSafeArea()
                    .onTapGesture(perform: dismissDrawer)

                VStack(spacing: 0) {
                    header
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 14, pinnedViews: [.sectionHeaders]) {
                            titleBar
                            classMetaCard
                            staffRow

                            Section {
                                studentList
                            } header: {
                                tabBar
                                    .padding(.top, 4)
                                    .background(JWColor.surface)
                            }
                        }
                        .padding(16)
                    }
                }
                .frame(width: 860)
                .frame(maxHeight: .infinity)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.16), radius: 30, x: -6, y: 0)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
                .offset(x: isDrawerVisible ? 0 : 420)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if students.isEmpty { students = makeStudents() }
            withAnimation(.easeOut(duration: drawerAnimationDuration)) {
                isDrawerVisible = true
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("班级详情")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(JWColor.text)
            Spacer(minLength: 0)
            Button(action: dismissDrawer) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
                    .accessibilityLabel("关闭")
            }
            .foregroundStyle(JWColor.text)
            .frame(width: 48, height: 48)
            .background(JWColor.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .frame(height: 72)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(JWColor.divider)
                .frame(height: 1)
        }
    }

    private var titleBar: some View {
        Text("2026年 · 春季 · \(session.className ?? "信息学算法") · \(classTimeSlot) · 小星星")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(JWColor.text)
    }

    private var classMetaCard: some View {
        HStack(spacing: 10) {
            metaCell("上课时间", session.time, "clock.fill")

            Button {
                store.toast = "打开校区教室设置"
            } label: {
                metaCell("校区教室", "\(store.currentCampus?.name ?? "合肥分校") · \(session.roomName)", "house.fill", trailingIcon: "square.and.pencil")
            }
            .buttonStyle(.plain)

            Button {
                store.toast = "打开课次明细"
            } label: {
                metaCell("课次明细", "第6讲 / 共15讲", "book.fill", trailingIcon: "chevron.right")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }

    private var staffRow: some View {
        HStack(spacing: 12) {
            staffCard(
                name: normalizedTeacherName(session.teacher ?? "待安排"),
                phone: maskedPhone(session.teacherPhone ?? "--"),
                signText: teacherSignText,
                signColor: session.teacherSignedIn ? JWColor.success : JWColor.danger,
                showsChevron: true,
                avatarView: AnyView(teacherAvatar)
            ) {
                store.openCallDrawer(role: .teacher, name: session.teacher ?? "老师", phone: session.teacherPhone ?? "--")
            } openDetail: {
                let teacher = TeacherProfile(
                    name: session.teacher ?? "老师",
                    phone: session.teacherPhone ?? "--",
                    campus: store.currentCampus?.name ?? "合肥分校",
                    department: "小低教学部",
                    onboardDate: "2021-08-16",
                    yearsOfTeaching: "6年",
                    graduateSchool: "华中师范大学",
                    subjects: "小学数学 / 思维训练",
                    tags: ["逻辑清晰", "善于激发思考", "课堂互动性强", "注重思维培养", "分层教学"],
                    motto: "让每个孩子都能找到理解知识的成就感。",
                    bio: "多年从事青少年信息学教学，擅长算法启蒙与竞赛基础训练，注重思维培养与学习习惯建立，深受学生和家长认可。"
                )
                openTeacherDetail(teacher)
            }

            staffCard(
                name: normalizedAssistantName(session.assistant ?? "待安排"),
                phone: maskedPhone(session.assistantPhone ?? "--"),
                signText: assistantSignText,
                signColor: session.assistantSignedIn ? JWColor.success : JWColor.danger,
                showsChevron: false,
                avatarView: AnyView(assistantAvatar(name: session.assistant ?? "助教"))
            ) {
                store.openCallDrawer(role: .assistant, name: session.assistant ?? "助教", phone: session.assistantPhone ?? "--")
            } openDetail: {
                let teacher = TeacherProfile(
                    name: session.assistant ?? "助教",
                    phone: session.assistantPhone ?? "--",
                    campus: store.currentCampus?.name ?? "合肥分校",
                    department: "小低教学部",
                    onboardDate: "2022-03-08",
                    yearsOfTeaching: "3年",
                    graduateSchool: "安徽大学",
                    subjects: "编程启蒙 / 课堂助教",
                    tags: ["课堂秩序稳定", "善于辅导答疑", "沟通耐心", "执行力强"],
                    motto: "把每一个课堂细节做到位，帮助孩子稳步成长。",
                    bio: "负责课堂助教与课后答疑，擅长课堂节奏管理和分层辅导，协助主讲老师提升课堂互动效率。"
                )
                openTeacherDetail(teacher)
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            tabBtn("本课次学员 \(students.count)", 0)
            tabBtn("调出 / 转出 \(students.filter { $0.transferOutTag != nil }.count)", 1)
            tabBtn("退出学员 \(students.filter { $0.exited }.count)", 2)
        }
        .padding(6)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var studentList: some View {
        VStack(spacing: 10) {
            ForEach(filteredStudents) { student in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(student.name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(JWColor.text)
                            if student.transferredIn && activeTab != 2 {
                                labelTag("调入")
                            }
                            if let outTag = student.transferOutTag, activeTab == 1 {
                                labelTag(outTag)
                            }
                            Button {
                                store.toast = "打开学员详情：\(student.name)"
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(JWColor.textMuted)
                            }
                            .buttonStyle(.plain)
                        }
                        Text(student.phone)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                    }
                    .frame(width: 260, alignment: .leading)

                    if activeTab == 0 {
                        signInArea(student: student)
                            .frame(width: 210, alignment: .leading)

                        signOutArea(student: student)
                            .frame(width: 180, alignment: .leading)
                    } else if activeTab == 1 {
                        transferDetailArea(student: student)
                            .frame(width: 410, alignment: .leading)
                    } else {
                        exitDetailArea(student: student)
                            .frame(width: 410, alignment: .leading)
                    }

                    Spacer(minLength: 0)

                    Button {
                        store.openCallDrawer(role: .student, name: student.name, phone: student.phone, studentNumber: student.number, grade: "二年级", creditScore: 98)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("打电话")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(JWColor.primary)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(JWColor.primaryLight)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .frame(height: 76)
                .background(JWColor.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            Text("— 已显示全部 \(filteredStudents.count) 名学员 —")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(JWColor.textMuted)
                .padding(.vertical, 8)
        }
    }

    private func labelTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(JWColor.primary)
            .padding(.horizontal, 7)
            .frame(height: 20)
            .background(JWColor.primaryLight)
            .clipShape(Capsule())
    }

    private var filteredStudents: [RosterStudent] {
        switch activeTab {
        case 1:
            return students.filter { $0.transferOutTag != nil }
        case 2:
            return students.filter { $0.exited }
        default:
            return students
        }
    }

    private func metaCell(_ title: String, _ value: String, _ icon: String, trailingIcon: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Label(title, systemImage: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
                Spacer(minLength: 0)
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                }
            }
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JWColor.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var teacherAvatar: some View {
        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=300&q=80")) { phase in
            switch phase {
            case let .success(image):
                image.resizable().scaledToFill()
            default:
                Color.gray.opacity(0.2)
                    .overlay(Image(systemName: "person.crop.circle.fill").font(.system(size: 28)).foregroundStyle(JWColor.primary))
            }
        }
        .frame(width: 54, height: 54)
        .clipShape(Circle())
    }

    private func assistantAvatar(name: String) -> some View {
        let first = String(name.prefix(1))
        return ZStack {
            Circle().fill(JWColor.primary.opacity(0.2))
            Text(first)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(JWColor.primary)
        }
        .frame(width: 54, height: 54)
    }

    private func staffCard(
        name: String,
        phone: String,
        signText: String,
        signColor: Color,
        showsChevron: Bool,
        avatarView: AnyView,
        callAction: @escaping () -> Void,
        openDetail: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            avatarView
            VStack(alignment: .leading, spacing: 4) {
                Button(action: openDetail) {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(JWColor.text)
                        if showsChevron {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(JWColor.textMuted)
                        }
                    }
                }
                .buttonStyle(.plain)
                Text(phone)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer(minLength: 0)
            Text(signText)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(signColor)
            Spacer(minLength: 0)
            Button(action: callAction) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 28, height: 28)
                    .background(JWColor.primaryLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .frame(height: 92)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func normalizedTeacherName(_ name: String) -> String {
        name.hasSuffix("老师") ? name : "\(name)老师"
    }

    private func normalizedAssistantName(_ name: String) -> String {
        name.hasSuffix("助教") ? name : "\(name)助教"
    }

    private func tabBtn(_ title: String, _ index: Int) -> some View {
        Button {
            activeTab = index
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(activeTab == index ? .white : JWColor.textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(activeTab == index ? JWColor.primary : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func signInArea(student: RosterStudent) -> some View {
        switch student.signInState {
        case .notSigned:
            return AnyView(
                Button("签到") {
                    updateStudent(student.id) { $0.signInState = .signed(time: "18:29", late: false) }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(JWColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            )
        case let .signed(time, late):
            return AnyView(
                HStack(spacing: 6) {
                    Text(late ? "迟到签到 \(time)" : "已签到 \(time)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(late ? JWColor.warning : JWColor.success)
                    Menu {
                        Button("取消签到", role: .destructive) {
                            updateStudent(student.id) { $0.signInState = .notSigned }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(JWColor.textMuted.opacity(0.55))
                            .frame(width: 24, height: 24)
                    }
                }
            )
        }
    }

    private func signOutArea(student: RosterStudent) -> some View {
        switch student.signOutState {
        case .notSignedOut:
            let canSignOut = student.signInState.isSigned
            return AnyView(
                Button("签退") {
                    if canSignOut {
                        updateStudent(student.id) { $0.signOutState = .signedOut(time: "20:06") }
                    } else {
                        store.toast = "未签到学员不支持签退"
                    }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(canSignOut ? JWColor.warning : JWColor.textMuted.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            )
        case let .signedOut(time):
            return AnyView(
                HStack(spacing: 6) {
                    Text("已签退 \(time)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(JWColor.success)
                    Menu {
                        Button("取消签退", role: .destructive) {
                            updateStudent(student.id) { $0.signOutState = .notSignedOut }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(JWColor.textMuted.opacity(0.55))
                            .frame(width: 24, height: 24)
                    }
                }
            )
        }
    }

    private func transferDetailArea(student: RosterStudent) -> some View {
        let prefix = student.transferOutTag == "转出" ? "转出至：" : "调出至："
        let rawTarget = student.transferTarget ?? "待分配班级（第0次）"
        let target = rawTarget
            .replacingOccurrences(of: "（第", with: "（从第")
            .replacingOccurrences(of: "次）", with: "课次开始）")
        return Text("\(prefix)\(target)")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(JWColor.text)
    }

    private func exitDetailArea(student: RosterStudent) -> some View {
        Text("退课时间：\(student.exitTime ?? "--")")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(JWColor.text)
    }

    private func updateStudent(_ id: UUID, _ mutate: (inout RosterStudent) -> Void) {
        guard let idx = students.firstIndex(where: { $0.id == id }) else { return }
        mutate(&students[idx])
    }

    private func maskedPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        guard digits.count == 11 else { return phone }
        let prefix = digits.prefix(3)
        let suffix = digits.suffix(4)
        return "\(prefix)****\(suffix)"
    }

    private func makeStudents() -> [RosterStudent] {
        [
            RosterStudent(name: "李梓轩", number: "FT20260501", phone: "138****5621", transferredIn: true, transferOutTag: nil, transferTarget: nil, exited: false, exitTime: nil, signInState: .signed(time: "18:21", late: false), signOutState: .notSignedOut),
            RosterStudent(name: "王可心", number: "FT20260508", phone: "139****1288", transferredIn: true, transferOutTag: nil, transferTarget: nil, exited: false, exitTime: nil, signInState: .signed(time: "18:26", late: false), signOutState: .notSignedOut),
            RosterStudent(name: "陈一诺", number: "FT20260512", phone: "137****7783", transferredIn: false, transferOutTag: nil, transferTarget: nil, exited: false, exitTime: nil, signInState: .signed(time: "18:19", late: false), signOutState: .notSignedOut),
            RosterStudent(name: "赵明泽", number: "FT20260516", phone: "136****4502", transferredIn: false, transferOutTag: nil, transferTarget: nil, exited: false, exitTime: nil, signInState: .notSigned, signOutState: .notSignedOut),
            RosterStudent(name: "周雨桐", number: "FT20260510", phone: "135****8916", transferredIn: true, transferOutTag: nil, transferTarget: nil, exited: false, exitTime: nil, signInState: .signed(time: "18:33", late: true), signOutState: .notSignedOut),
            RosterStudent(name: "黄晨然", number: "FT20260522", phone: "188****2301", transferredIn: false, transferOutTag: "调出", transferTarget: "创想编程B班（第7次）", exited: false, exitTime: nil, signInState: .signed(time: "18:20", late: false), signOutState: .signedOut(time: "20:10")),
            RosterStudent(name: "孙语晨", number: "FT20260525", phone: "139****6768", transferredIn: false, transferOutTag: "转出", transferTarget: "算法提高A班（第9次）", exited: false, exitTime: nil, signInState: .signed(time: "18:22", late: false), signOutState: .signedOut(time: "20:13")),
            RosterStudent(name: "何思远", number: "FT20260527", phone: "137****9959", transferredIn: false, transferOutTag: nil, transferTarget: nil, exited: true, exitTime: "2026-05-18 19:40", signInState: .notSigned, signOutState: .signedOut(time: "19:40")),
            RosterStudent(name: "张子航", number: "FT20260531", phone: "137****2218", transferredIn: false, transferOutTag: nil, transferTarget: nil, exited: true, exitTime: "2026-05-11 19:22", signInState: .signed(time: "18:11", late: false), signOutState: .signedOut(time: "19:22"))
        ]
    }

    private func dismissDrawer() {
        guard isDrawerVisible else {
            close()
            return
        }
        withAnimation(.easeIn(duration: drawerAnimationDuration)) {
            isDrawerVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + drawerAnimationDuration) {
            close()
        }
    }

}
