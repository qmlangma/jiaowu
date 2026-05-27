import Foundation
import Observation

enum UIFeedbackLevel {
    case success
    case warning
    case error
}

struct UIFeedback: Identifiable {
    let id = UUID()
    var message: String
    var level: UIFeedbackLevel
}

@Observable
final class AppStore {
    private let mockLoginPhone = "13067510619"

    var route: AppRoute = .workspace
    var isLoggedIn = false
    var campuses: [Campus] = []
    var currentCampus: Campus?
    var currentStaff: StaffUser?
    var students: [Student] = []
    var courses: [Course] = []
    var enrollments: [Enrollment] = []
    var orders: [Order] = []
    var refunds: [Refund] = []
    var attendanceRecords: [AttendanceRecord] = []
    var testSessions: [TestSession] = []
    var testAnswers: [TestAnswer] = []
    var creditRecords: [CreditRecord] = []
    var selectedStudentID: UUID?
    var selectedCourseID: UUID?
    var selectedClassID: UUID?
    var selectedTestSessionID: UUID?
    var selectedOrderID: UUID?
    var toast: String?
    var feedback: UIFeedback?
    var callDrawer: CallDrawerContext?
    var workspaceSelectedRosterSession: RoomSession?
    var workspaceSelectedTeacherProfile: TeacherProfile?
    var workspaceAlertDrawerFilter: WorkspaceAlertDrawerFilter = .all
    var workspaceAlertDrawerPresented = false
    var workspaceAlertDrawerVisible = false
    var workspaceAlerts: [WorkspaceAlert] = []
    var workspaceAlarmOn = false
    var shouldPresentAlarmConfirm = false
    var shouldPresentCampusDialog = false
    var pendingCampusSelectionID: UUID?
    var navigationState = NavigationState()
    var workspaceState = WorkspaceState()
    var enrollmentState = EnrollmentState()
    var sessionState = SessionState()
    var attendanceState = AttendanceState()
    var orderState = OrderState()

    init() {
        loadMockData()
    }

    var selectedStudent: Student? {
        get { students.first { $0.id == selectedStudentID } ?? students.first }
        set { selectedStudentID = newValue?.id }
    }

    var selectedCourse: Course? {
        courses.first { $0.id == selectedCourseID } ?? courses.first
    }

    var selectedClass: CourseClass? {
        selectedCourse?.classes.first { $0.id == selectedClassID } ?? selectedCourse?.classes.first
    }

    var selectedTestSession: TestSession? {
        testSessions.first { $0.id == selectedTestSessionID } ?? testSessions.first
    }

    var selectedOrder: Order? {
        orders.first { $0.id == selectedOrderID }
    }

    var pendingReviewCount: Int {
        Set(testAnswers.filter { $0.state == .review }.map(\.studentID)).count
    }

    var unpaidAttendanceCount: Int {
        attendanceRecords.filter { $0.status == "未打卡" }.count
    }

    var paidOrders: [Order] {
        orders.filter { $0.status == .paid }
    }

    private static let lastWorkCampusIDKey = "jw_last_work_campus_id"

    /// 上次在本设备确认过的「工作校区」，用于登录后默认选中。
    func lastPersistedWorkCampusID() -> UUID? {
        guard let s = UserDefaults.standard.string(forKey: Self.lastWorkCampusIDKey),
              let id = UUID(uuidString: s) else { return nil }
        return campuses.first(where: { $0.id == id })?.id
    }

    func login(campus: Campus) {
        currentCampus = campus
        UserDefaults.standard.set(campus.id.uuidString, forKey: Self.lastWorkCampusIDKey)
        currentStaff = StaffUser(name: "许艳博", campusName: campus.name, phone: mockLoginPhone)
        isLoggedIn = true
        route = .workspace
        navigationState.selectedRoute = .workspace
        shouldPresentCampusDialog = false
        pendingCampusSelectionID = campus.id
    }

    /// 扫码成功后直接进入首页，并沿用设备上次校区（若有）。
    func completeLoginAfterScan() {
        if let lastID = lastPersistedWorkCampusID(),
           let lastCampus = campuses.first(where: { $0.id == lastID }) {
            currentCampus = lastCampus
        } else if currentCampus == nil {
            currentCampus = campuses.first
        }
        isLoggedIn = true
        route = .workspace
        navigationState.selectedRoute = .workspace
        currentStaff = StaffUser(name: "许艳博", campusName: currentCampus?.name ?? "Campus", phone: mockLoginPhone)
        pendingCampusSelectionID = currentCampus?.id
        shouldPresentCampusDialog = false
    }

    func confirmPendingCampusSelection() {
        guard let id = pendingCampusSelectionID,
              let campus = campuses.first(where: { $0.id == id }) else { return }
        currentCampus = campus
        UserDefaults.standard.set(campus.id.uuidString, forKey: Self.lastWorkCampusIDKey)
        currentStaff = StaffUser(name: "许艳博", campusName: campus.name, phone: mockLoginPhone)
        shouldPresentCampusDialog = false
    }

    func navigate(_ route: AppRoute) {
        self.route = route
        navigationState.selectedRoute = route
    }

    func studentName(_ id: UUID) -> String {
        students.first { $0.id == id }?.name ?? "未知学员"
    }

    func studentByID(_ id: UUID) -> Student? {
        students.first { $0.id == id }
    }

    func enrollSelectedStudent() {
        guard let studentID = selectedStudentID ?? students.first?.id,
              let course = selectedCourse,
              let klass = selectedClass else { return }
        enrollments.append(Enrollment(studentID: studentID, courseID: course.id, classID: klass.id, createdAt: "2026-05-07"))
        orders.append(Order(studentID: studentID, courseTitle: course.title, classTitle: klass.title, amount: course.price, status: course.price == 0 ? .paid : .pending, paidAt: "2026-05-07 20:02:39", receiver: currentStaff?.name ?? "许艳博"))
        if let courseIndex = courses.firstIndex(where: { $0.id == course.id }),
           let classIndex = courses[courseIndex].classes.firstIndex(where: { $0.id == klass.id }) {
            courses[courseIndex].classes[classIndex].enrolled += 1
        }
        sendFeedback("报名成功：\(studentName(studentID))", level: .success)
    }

    func addStudent(name: String, phone: String, grade: String, gender: Gender) {
        let student = Student(name: name.isEmpty ? "新学员" : name, gender: gender, number: String(Int.random(in: 70000000...99999999)), grade: grade, phone: phone.isEmpty ? "138****0000" : phone, school: currentCampus?.name ?? "XiangShuW", creditScore: 10)
        students.insert(student, at: 0)
        selectedStudentID = student.id
        sendFeedback("已新增学员", level: .success)
    }

    func addLevel(to studentID: UUID, grade: String, subject: String, score: Int, level: String) {
        guard let index = students.firstIndex(where: { $0.id == studentID }) else { return }
        students[index].testLevels.append(TestLevel(grade: grade, subject: subject, score: score, level: level, source: "手动录入"))
        sendFeedback("已添加测试级别", level: .success)
    }

    func toggleStudentCheckIn(sessionID: UUID, seatID: UUID) {
        updateSeat(sessionID: sessionID, seatID: seatID) { $0.studentCheckedIn.toggle() }
    }

    func toggleParentCheckIn(sessionID: UUID, seatID: UUID) {
        updateSeat(sessionID: sessionID, seatID: seatID) { $0.parentCheckedIn.toggle() }
    }

    func updateAnswerMode(sessionID: UUID, seatID: UUID, mode: String) {
        updateSeat(sessionID: sessionID, seatID: seatID) { $0.answerMode = mode }
    }

    func updateSeatResult(sessionID: UUID, seatID: UUID, result: Int?) {
        updateSeat(sessionID: sessionID, seatID: seatID) { $0.result = result }
    }

    func reorderSeats(sessionID: UUID) {
        guard let index = testSessions.firstIndex(where: { $0.id == sessionID }) else { return }
        testSessions[index].seats.shuffle()
        for seatIndex in testSessions[index].seats.indices {
            testSessions[index].seats[seatIndex].seatNo = seatIndex + 1
        }
        sendFeedback("已重新排座", level: .success)
    }

    func markAnswer(_ answerID: UUID, as state: AnswerState) {
        guard let index = testAnswers.firstIndex(where: { $0.id == answerID }) else { return }
        testAnswers[index].state = state
        testAnswers[index].issue = nil
    }

    func submitAssessment(for studentID: UUID, sessionID: UUID) {
        let score = testAnswers.filter { $0.studentID == studentID && $0.sessionID == sessionID && $0.state == .correct }.count * 3
        if let sessionIndex = testSessions.firstIndex(where: { $0.id == sessionID }),
           let seatIndex = testSessions[sessionIndex].seats.firstIndex(where: { $0.studentID == studentID }) {
            testSessions[sessionIndex].seats[seatIndex].result = score
        }
        sendFeedback("批改结果已提交，得分 \(score)", level: .success)
    }

    func refund(orderID: UUID, reason: String, type: String, amount: Int, note: String) {
        guard let index = orders.firstIndex(where: { $0.id == orderID }) else { return }
        refunds.append(Refund(orderID: orderID, reason: reason, type: type, amount: amount, note: note, createdAt: "2026-05-07 20:04:00"))
        orders[index].status = .refunded
        sendFeedback("退款已确认", level: .success)
    }

    func toggleRoom(campusID: UUID, roomID: UUID, keyPath: WritableKeyPath<Classroom, Bool>) {
        guard let campusIndex = campuses.firstIndex(where: { $0.id == campusID }),
              let roomIndex = campuses[campusIndex].rooms.firstIndex(where: { $0.id == roomID }) else { return }
        campuses[campusIndex].rooms[roomIndex][keyPath: keyPath].toggle()
        if currentCampus?.id == campusID {
            currentCampus = campuses[campusIndex]
        }
    }

    private func updateSeat(sessionID: UUID, seatID: UUID, mutation: (inout TestSeat) -> Void) {
        guard let sessionIndex = testSessions.firstIndex(where: { $0.id == sessionID }),
              let seatIndex = testSessions[sessionIndex].seats.firstIndex(where: { $0.id == seatID }) else { return }
        mutation(&testSessions[sessionIndex].seats[seatIndex])
    }

    func updateEnrollmentStep(_ step: EnrollmentStep) {
        enrollmentState.step = step
    }

    func evaluateQualification(studentID: UUID, course: Course?) -> EnrollmentQualification {
        guard let student = studentByID(studentID), let course else { return .unknown }
        let enough = student.testLevels.contains { $0.grade == course.grade && $0.subject == course.subject }
        let result: EnrollmentQualification = enough || course.type == "考试" ? .qualified : .needDiagnostic
        enrollmentState.qualification = result
        return result
    }

    func setSessionTab(_ tab: SessionOperationTab) {
        sessionState.activeTab = tab
    }

    func cycleFollowUpState() {
        switch attendanceState.selectedFollowUp {
        case .pending: attendanceState.selectedFollowUp = .done
        case .done: attendanceState.selectedFollowUp = .closed
        case .closed: attendanceState.selectedFollowUp = .pending
        }
    }

    func beginRefundFlow() {
        orderState.refundState = .draft
    }

    func validateRefundFlow() {
        orderState.refundState = .validating
    }

    func confirmRefundFlow() {
        orderState.refundState = .confirmed
    }

    func submitRefundFlow() {
        orderState.refundState = .submitted
    }

    func sendFeedback(_ message: String, level: UIFeedbackLevel) {
        toast = message
        feedback = UIFeedback(message: message, level: level)
    }

    func openCallDrawer(
        role: CallTargetRole,
        name: String,
        phone: String,
        avatarURL: String? = nil,
        studentNumber: String? = nil,
        grade: String? = nil,
        creditScore: Int? = nil,
        workspaceAlertID: UUID? = nil,
        note: String? = nil
    ) {
        let contactPhones: [CallContactPhone]
        if role == .student {
            contactPhones = [
                CallContactPhone(relation: "爸爸", phone: "13012348789", isPrimary: true),
                CallContactPhone(relation: "妈妈", phone: "13012344567", isPrimary: false)
            ]
        } else {
            contactPhones = [CallContactPhone(relation: role.rawValue, phone: phone, isPrimary: true)]
        }

        callDrawer = CallDrawerContext(
            role: role,
            name: name,
            phone: phone,
            avatarURL: avatarURL,
            contactPhones: contactPhones,
            studentNumber: studentNumber,
            grade: grade,
            creditScore: creditScore,
            workspaceAlertID: workspaceAlertID,
            note: note ?? "已联系对象，沟通今日到课与课堂表现。家长对课程进度表示认可，后续继续跟进学习反馈。"
        )
    }

    func saveWorkspaceAlertContactNote(alertID: UUID?, name: String, note: String) {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNote.isEmpty else { return }

        if let alertID, let index = workspaceAlerts.firstIndex(where: { $0.id == alertID }) {
            workspaceAlerts[index].contactNote = trimmedNote
            workspaceAlerts[index].isContacted = true
            return
        }

        if let index = workspaceAlerts.firstIndex(where: { $0.contactName == name }) {
            workspaceAlerts[index].contactNote = trimmedNote
            workspaceAlerts[index].isContacted = true
        }
    }

    func closeCallDrawer() {
        callDrawer = nil
    }

    private func loadMockData() {
        // 固定校区 ID，便于 UserDefaults 记住上次选择。
        let campusSeeds: [(code: String, name: String, region: String)] = [
            ("BaoheNanxunmenqiao", "南薰门桥", "包河区"),
            ("BaoheTaihulu", "太湖路", "包河区"),
            ("BinhuBalidushi", "巴黎都市", "滨湖区"),
            ("BinhuDongtinghulu", "洞庭湖路", "滨湖区"),
            ("BinhuWeilaihui", "未来荟", "滨湖区"),
            ("BinhuYizhong", "滨湖一中", "滨湖区"),
            ("LuyangBaishuiba", "白水坝", "庐阳区"),
            ("LuyangHaitang", "海棠", "庐阳区"),
            ("LuyangHuanchenglu", "环城路", "庐阳区"),
            ("LuyangSanxiaokou", "三孝口", "庐阳区"),
            ("LuyangSenlincheng", "森林城", "庐阳区"),
            ("LuyangShouchunlu", "寿春路", "庐阳区"),
            ("LuyangSilihe", "四里河", "庐阳区"),
            ("LuyangSipailou", "四牌楼", "庐阳区"),
            ("LuyangTianwangxiang", "天王巷", "庐阳区"),
            ("LuyangTongchenglu", "桐城路", "庐阳区"),
            ("LuyangXiangshuwan", "橡树湾", "庐阳区"),
            ("LuyangYijinglu", "义井路", "庐阳区"),
            ("LuyangYuanfang", "远方校区", "庐阳区"),
            ("ShushanAnnongda", "安农大", "蜀山区"),
            ("ShushanDaxidi", "大溪地", "蜀山区"),
            ("ShushanFanhuadadao", "繁华大道", "蜀山区"),
            ("ShushanHaiguanlu", "海关路", "蜀山区"),
            ("ShushanHonggang", "洪岗", "蜀山区"),
            ("ShushanHuangshanlu", "黄山路", "蜀山区"),
            ("ShushanJiulonglu", "九龙路", "蜀山区"),
            ("ShushanMeiguiyuan", "玫瑰园", "蜀山区"),
            ("ShushanQianshanlu", "潜山路", "蜀山区"),
            ("ShushanWanhelu", "皖河路", "蜀山区"),
            ("ShushanWulidun", "五里墩", "蜀山区"),
            ("YaohaiQuanjiaolu", "全椒路", "瑶海区"),
            ("YaohaiTonglinglu", "铜陵路", "瑶海区"),
            ("ZhengwuTianehu", "天鹅湖", "政务文化新区"),
            ("ZhengwuXiuninglu", "休宁路", "政务文化新区"),
            ("OtherBazhongKuanghe", "八中匡河", "其他"),
            ("OtherBazhongYunhe", "八中运河新城", "其他"),
            ("OtherHefeiQizhong", "合肥七中", "其他"),
            ("OtherWankeJinyu", "万科金域国际", "其他"),
            ("OtherShufaDasha", "中国书法大厦", "其他"),
        ]
        let orderedSeeds = campusSeeds.sorted { lhs, rhs in
            if lhs.region == rhs.region {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.region.localizedCaseInsensitiveCompare(rhs.region) == .orderedAscending
        }
        campuses = orderedSeeds.enumerated().map { index, seed in
            let id = UUID(uuidString: String(format: "550E8400-E29B-41D4-A716-44665544%04d", index + 1)) ?? UUID()
            return Campus(
                id: id,
                region: seed.region,
                name: seed.name,
                rooms: ["A01", "A02", "B01", "B02"].map { Classroom(name: $0) }
            )
        }
        currentCampus = campuses.first
        let s1 = Student(name: "许魏洲", gender: .female, number: "51061903", grade: "二年级", phone: "130****0619", school: "XiangShuW", creditScore: 10, testLevels: [TestLevel(grade: "二年级", subject: "信息学算法", score: 68, level: "A", source: "诊断测试")])
        let s2 = Student(name: "李泽宇 Q", gender: .male, number: "60530001", grade: "一年级", phone: "180****3001", school: "XiangShuW", creditScore: 9)
        let s3 = Student(name: "冯宇轩 Q", gender: .male, number: "85065801", grade: "一年级", phone: "186****5801", school: "XiangShuW", creditScore: 12)
        let s4 = Student(name: "许兰英 test", gender: .privateValue, number: "64752501", grade: "五年级", phone: "195****7525", school: "03", creditScore: 11)
        students = [s1, s2, s3, s4]
        selectedStudentID = s1.id

        let classA = CourseClass(title: "2026-03-31开课：初一信息学算法周日下午小太阳线上-auto-秋中海", campus: "线上", teacher: "auto-秋中海", weekday: "周日", time: "14:00-16:30", capacity: 18, enrolled: 14)
        let classB = CourseClass(title: "自动化测试班-XiangShuW-20260507", campus: "XiangShuW#现场安排", teacher: "监考老师", weekday: "周四", time: "23:00-23:30", capacity: 18, enrolled: 16, isTest: true)
        courses = [
            Course(title: "2026 初一信息学算法秋季课 (1023)", grade: "初一", year: "2026", type: "秋季课", subject: "信息学算法", dateRange: "03-31~07-07", price: 3150, classes: [classA]),
            Course(title: "2026 二年级信息学算法秋季课-月报 2new", grade: "二年级", year: "2026", type: "秋季课", subject: "信息学算法", dateRange: "04-21~08-03", price: 3150, classes: [CourseClass(title: "二年级信息学算法周五晚班", campus: "XiangShuW", teacher: "杨老师", weekday: "周五", time: "19:00-20:30", capacity: 18, enrolled: 15)]),
            Course(title: "自动化测试班-XiangShuW-20260507", grade: "高三", year: "2026", type: "考试", subject: "信息学算法", dateRange: "05-07", price: 0, classes: [classB])
        ]
        selectedCourseID = courses.first?.id
        selectedClassID = courses.first?.classes.first?.id

        enrollments = [Enrollment(studentID: s1.id, courseID: courses[2].id, classID: classB.id, createdAt: "2026-05-07")]
        orders = [
            Order(studentID: s1.id, courseTitle: courses[2].title, classTitle: classB.title, amount: 0, status: .paid, paidAt: "2026-05-07 20:02:39", receiver: "许艳博"),
            Order(studentID: s2.id, courseTitle: courses[0].title, classTitle: classA.title, amount: 3150, status: .pending, paidAt: "--", receiver: "许艳博")
        ]
        attendanceRecords = [
            AttendanceRecord(studentID: s1.id, classTitle: classB.title, time: "05-07 23:00-23:30", status: "未打卡"),
            AttendanceRecord(studentID: s2.id, classTitle: classA.title, time: "05-11 14:00-16:30", status: "已签到", hasVisit: true)
        ]

        let session = TestSession(title: "自动化测试班-XiangShuW-20260507", campus: "XiangShuW", room: "XiangShuW#现场安排", subject: "信息学算法", grade: "高三", time: "05月07日 23:00~23:30", status: "未开始", seats: [
            TestSeat(seatNo: 13, studentID: s1.id, subject: "信息学算法", subjects: [TestSeatSubject(title: "二年级·信息学算法"), TestSeatSubject(title: "三年级·信息学算法", isMakeup: true)], studentLoggedIn: true, studentCheckedIn: true, parentCheckedIn: false),
            TestSeat(seatNo: 14, studentID: s3.id, subject: "信息学算法", subjects: [TestSeatSubject(title: "三年级·信息学算法", isMakeup: true)], studentLoggedIn: false, studentCheckedIn: false, parentCheckedIn: false),
            TestSeat(seatNo: 15, studentID: s4.id, subject: "信息学语言传播", subjects: [TestSeatSubject(title: "二年级·信息学语言传播")], studentLoggedIn: true, studentCheckedIn: false, parentCheckedIn: false)
        ])
        testSessions = [session]
        selectedTestSessionID = session.id
        testAnswers = students.prefix(3).flatMap { student in
            (1...10).map { number in
                let issue: String?
                let studentAnswer: String
                let state: AnswerState

                switch number {
                case 1:
                    issue = "答题提交失败，请到学生答题pad内查看"
                    studentAnswer = "23+4"
                    state = .review
                case 2:
                    issue = "答案识别失败，请手动批改"
                    studentAnswer = "10+3"
                    state = .review
                case 3:
                    issue = "批改失败，请手动批改"
                    studentAnswer = "15+3"
                    state = .review
                case 4:
                    issue = nil
                    studentAnswer = "20+3"
                    state = .correct
                case 5:
                    issue = nil
                    studentAnswer = "25+8"
                    state = .wrong
                case 6:
                    issue = nil
                    studentAnswer = "学生未作答"
                    state = .review
                case 7:
                    issue = nil
                    studentAnswer = "35+3"
                    state = .correct
                case 8:
                    issue = nil
                    studentAnswer = "40+5"
                    state = .wrong
                case 9:
                    issue = nil
                    studentAnswer = "45+3"
                    state = .correct
                default:
                    issue = nil
                    studentAnswer = "50+1"
                    state = .wrong
                }

                return TestAnswer(
                    sessionID: session.id,
                    studentID: student.id,
                    questionNo: number,
                    officialAnswer: number == 2 ? "1 + 2√3x" : "AgNO3 + NaCl = AgCl↓ + NaNO3",
                    studentAnswer: studentAnswer,
                    state: state,
                    issue: issue
                )
            }
        }
        creditRecords = [
            CreditRecord(studentID: s1.id, delta: 10, title: "初始信用分 10 分", dateText: "2025-12-25 10:06"),
            CreditRecord(studentID: s1.id, delta: 1, title: "学习完暑假信息学算法课程，加 1 分", dateText: "2026-01-23 05:30", canUndo: true),
            CreditRecord(studentID: s4.id, delta: 10, title: "初始信用分 10 分", dateText: "2025-12-25 10:06"),
            CreditRecord(studentID: s4.id, delta: 1, title: "学习完课程，加 1 分", dateText: "2026-01-23 05:30", canUndo: true)
        ]
    }
}
