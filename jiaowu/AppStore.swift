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

    func login(campus: Campus) {
        currentCampus = campus
        currentStaff = StaffUser(name: "纵强强", campusName: campus.name)
        isLoggedIn = true
        route = .workspace
        navigationState.selectedRoute = .workspace
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
        orders.append(Order(studentID: studentID, courseTitle: course.title, classTitle: klass.title, amount: course.price, status: course.price == 0 ? .paid : .pending, paidAt: "2026-05-07 20:02:39", receiver: currentStaff?.name ?? "纵强强"))
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

    private func loadMockData() {
        campuses = [
            Campus(name: "XiangShuW", rooms: ["现场安排", "A01", "A02", "B01", "B02", "B03"].map { Classroom(name: $0) }),
            Campus(name: "AnNongD", rooms: ["校区教室", "待定2", "待定3", "A01", "A02", "B04", "B05"].map { Classroom(name: $0) })
        ]
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
            Order(studentID: s1.id, courseTitle: courses[2].title, classTitle: classB.title, amount: 0, status: .paid, paidAt: "2026-05-07 20:02:39", receiver: "纵强强"),
            Order(studentID: s2.id, courseTitle: courses[0].title, classTitle: classA.title, amount: 3150, status: .pending, paidAt: "--", receiver: "纵强强")
        ]
        attendanceRecords = [
            AttendanceRecord(studentID: s1.id, classTitle: classB.title, time: "05-07 23:00-23:30", status: "未打卡"),
            AttendanceRecord(studentID: s2.id, classTitle: classA.title, time: "05-11 14:00-16:30", status: "已签到", hasVisit: true)
        ]

        let session = TestSession(title: "自动化测试班-XiangShuW-20260507", campus: "XiangShuW", room: "XiangShuW#现场安排", subject: "信息学算法", grade: "高三", time: "05月07日 23:00~23:30", status: "未开始", seats: [
            TestSeat(seatNo: 13, studentID: s1.id, subject: "信息学算法", studentCheckedIn: true, parentCheckedIn: false),
            TestSeat(seatNo: 14, studentID: s3.id, subject: "信息学算法", studentCheckedIn: false, parentCheckedIn: false),
            TestSeat(seatNo: 15, studentID: s4.id, subject: "信息学语言传播", studentCheckedIn: false, parentCheckedIn: false)
        ])
        testSessions = [session]
        selectedTestSessionID = session.id
        testAnswers = students.prefix(3).flatMap { student in
            (1...8).map { number in
                TestAnswer(sessionID: session.id, studentID: student.id, questionNo: number, officialAnswer: number == 2 ? "1 + 2√3x" : "AgNO3 + NaCl = AgCl↓ + NaNO3", studentAnswer: number == 6 ? "学生未作答" : "\(number * 5)+3", state: number == 6 ? .correct : (number <= 3 ? .review : .wrong), issue: number <= 3 ? "OCR识别失败，请人工判断" : nil)
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
