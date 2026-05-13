import Foundation
import SwiftUI

enum AppRoute: String, CaseIterable, Identifiable {
    case workspace = "工作台"
    case assessment = "入学测"
    case courseSelection = "选课"
    case schedule = "课表"
    case orders = "订单"
    case students = "优惠"
    case attendance = "审批"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .workspace: "house.fill"
        case .assessment: "doc.text.magnifyingglass"
        case .courseSelection: "graduationcap.fill"
        case .schedule: "building.2.fill"
        case .orders: "creditcard.fill"
        case .students: "tag.fill"
        case .attendance: "checkmark.seal.fill"
        }
    }
}

struct Campus: Identifiable, Hashable {
    let id: UUID
    var name: String
    var rooms: [Classroom]

    init(id: UUID = UUID(), name: String, rooms: [Classroom]) {
        self.id = id
        self.name = name
        self.rooms = rooms
    }
}

struct Classroom: Identifiable, Hashable {
    let id: UUID
    var name: String
    var webOn: Bool
    var screenOn: Bool
    var lightOn: Bool

    init(id: UUID = UUID(), name: String, webOn: Bool = false, screenOn: Bool = false, lightOn: Bool = false) {
        self.id = id
        self.name = name
        self.webOn = webOn
        self.screenOn = screenOn
        self.lightOn = lightOn
    }
}

struct StaffUser: Identifiable, Hashable {
    let id: UUID
    var name: String
    var campusName: String
    var avatarSymbol: String

    init(id: UUID = UUID(), name: String, campusName: String, avatarSymbol: String = "person.crop.circle.fill") {
        self.id = id
        self.name = name
        self.campusName = campusName
        self.avatarSymbol = avatarSymbol
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male = "男"
    case female = "女"
    case privateValue = "保密"
    var id: String { rawValue }
}

struct Student: Identifiable, Hashable {
    let id: UUID
    var name: String
    var gender: Gender
    var number: String
    var grade: String
    var phone: String
    var school: String
    var creditScore: Int
    var testLevels: [TestLevel]

    init(id: UUID = UUID(), name: String, gender: Gender, number: String, grade: String, phone: String, school: String, creditScore: Int, testLevels: [TestLevel] = []) {
        self.id = id
        self.name = name
        self.gender = gender
        self.number = number
        self.grade = grade
        self.phone = phone
        self.school = school
        self.creditScore = creditScore
        self.testLevels = testLevels
    }
}

struct TestLevel: Identifiable, Hashable {
    let id: UUID
    var grade: String
    var subject: String
    var score: Int
    var level: String
    var source: String

    init(id: UUID = UUID(), grade: String, subject: String, score: Int, level: String, source: String) {
        self.id = id
        self.grade = grade
        self.subject = subject
        self.score = score
        self.level = level
        self.source = source
    }
}

struct CreditRecord: Identifiable, Hashable {
    let id: UUID
    var studentID: UUID
    var delta: Int
    var title: String
    var dateText: String
    var canUndo: Bool

    init(id: UUID = UUID(), studentID: UUID, delta: Int, title: String, dateText: String, canUndo: Bool = false) {
        self.id = id
        self.studentID = studentID
        self.delta = delta
        self.title = title
        self.dateText = dateText
        self.canUndo = canUndo
    }
}

struct Course: Identifiable, Hashable {
    let id: UUID
    var title: String
    var grade: String
    var year: String
    var type: String
    var subject: String
    var dateRange: String
    var price: Int
    var classes: [CourseClass]

    init(id: UUID = UUID(), title: String, grade: String, year: String, type: String, subject: String, dateRange: String, price: Int, classes: [CourseClass]) {
        self.id = id
        self.title = title
        self.grade = grade
        self.year = year
        self.type = type
        self.subject = subject
        self.dateRange = dateRange
        self.price = price
        self.classes = classes
    }
}

struct CourseClass: Identifiable, Hashable {
    let id: UUID
    var title: String
    var campus: String
    var teacher: String
    var weekday: String
    var time: String
    var capacity: Int
    var enrolled: Int
    var isTest: Bool

    init(id: UUID = UUID(), title: String, campus: String, teacher: String, weekday: String, time: String, capacity: Int, enrolled: Int, isTest: Bool = false) {
        self.id = id
        self.title = title
        self.campus = campus
        self.teacher = teacher
        self.weekday = weekday
        self.time = time
        self.capacity = capacity
        self.enrolled = enrolled
        self.isTest = isTest
    }
}

struct Enrollment: Identifiable, Hashable {
    let id: UUID
    var studentID: UUID
    var courseID: UUID
    var classID: UUID
    var status: String
    var createdAt: String

    init(id: UUID = UUID(), studentID: UUID, courseID: UUID, classID: UUID, status: String = "在读", createdAt: String) {
        self.id = id
        self.studentID = studentID
        self.courseID = courseID
        self.classID = classID
        self.status = status
        self.createdAt = createdAt
    }
}

enum OrderStatus: String, CaseIterable, Identifiable {
    case pending = "待付款"
    case paid = "已付款"
    case refunded = "已退款"
    case recycled = "回收站"
    var id: String { rawValue }
}

struct Order: Identifiable, Hashable {
    let id: UUID
    var studentID: UUID
    var courseTitle: String
    var classTitle: String
    var amount: Int
    var status: OrderStatus
    var paidAt: String
    var receiver: String

    init(id: UUID = UUID(), studentID: UUID, courseTitle: String, classTitle: String, amount: Int, status: OrderStatus, paidAt: String, receiver: String) {
        self.id = id
        self.studentID = studentID
        self.courseTitle = courseTitle
        self.classTitle = classTitle
        self.amount = amount
        self.status = status
        self.paidAt = paidAt
        self.receiver = receiver
    }
}

struct Refund: Identifiable, Hashable {
    let id: UUID
    var orderID: UUID
    var reason: String
    var type: String
    var amount: Int
    var note: String
    var createdAt: String

    init(id: UUID = UUID(), orderID: UUID, reason: String, type: String, amount: Int, note: String, createdAt: String) {
        self.id = id
        self.orderID = orderID
        self.reason = reason
        self.type = type
        self.amount = amount
        self.note = note
        self.createdAt = createdAt
    }
}

struct AttendanceRecord: Identifiable, Hashable {
    let id: UUID
    var studentID: UUID
    var classTitle: String
    var time: String
    var status: String
    var hasVisit: Bool

    init(id: UUID = UUID(), studentID: UUID, classTitle: String, time: String, status: String, hasVisit: Bool = false) {
        self.id = id
        self.studentID = studentID
        self.classTitle = classTitle
        self.time = time
        self.status = status
        self.hasVisit = hasVisit
    }
}

struct TestSession: Identifiable, Hashable {
    let id: UUID
    var title: String
    var campus: String
    var room: String
    var subject: String
    var grade: String
    var time: String
    var status: String
    var seats: [TestSeat]

    init(id: UUID = UUID(), title: String, campus: String, room: String, subject: String, grade: String, time: String, status: String, seats: [TestSeat]) {
        self.id = id
        self.title = title
        self.campus = campus
        self.room = room
        self.subject = subject
        self.grade = grade
        self.time = time
        self.status = status
        self.seats = seats
    }
}

struct TestSeatSubject: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isMakeup: Bool

    init(id: UUID = UUID(), title: String, isMakeup: Bool = false) {
        self.id = id
        self.title = title
        self.isMakeup = isMakeup
    }
}

struct TestSeat: Identifiable, Hashable {
    let id: UUID
    var seatNo: Int
    var studentID: UUID
    var subject: String
    var subjects: [TestSeatSubject]
    var studentLoggedIn: Bool
    var result: Int?
    var answerMode: String
    var studentCheckedIn: Bool
    var parentCheckedIn: Bool
    var note: String

    init(id: UUID = UUID(), seatNo: Int, studentID: UUID, subject: String, subjects: [TestSeatSubject]? = nil, studentLoggedIn: Bool = false, result: Int? = nil, answerMode: String = "纸笔", studentCheckedIn: Bool = false, parentCheckedIn: Bool = false, note: String = "") {
        self.id = id
        self.seatNo = seatNo
        self.studentID = studentID
        self.subject = subject
        self.subjects = subjects ?? [TestSeatSubject(title: subject)]
        self.studentLoggedIn = studentLoggedIn
        self.result = result
        self.answerMode = answerMode
        self.studentCheckedIn = studentCheckedIn
        self.parentCheckedIn = parentCheckedIn
        self.note = note
    }
}

enum AnswerState: String, CaseIterable, Identifiable {
    case correct = "正确"
    case wrong = "错误"
    case review = "待判"
    var id: String { rawValue }
}

enum EnrollmentStep: String, CaseIterable, Identifiable {
    case filterCourse = "筛选课程"
    case chooseClass = "选择班级"
    case chooseStudent = "选择学员"
    case confirm = "确认报名"
    var id: String { rawValue }
}

enum EnrollmentQualification: String {
    case unknown
    case qualified
    case needDiagnostic
}

enum SessionLifecycle: String, CaseIterable, Identifiable {
    case upcoming = "未开始"
    case running = "进行中"
    case done = "已完成"
    var id: String { rawValue }
}

enum SessionOperationTab: String, CaseIterable, Identifiable {
    case seats = "座位编排"
    case attendance = "签到管理"
    case marking = "试卷批改"
    var id: String { rawValue }
}

enum FollowUpState: String, CaseIterable, Identifiable {
    case pending = "待回访"
    case done = "已回访"
    case closed = "已闭环"
    var id: String { rawValue }
}

enum RefundFlowState: String, CaseIterable, Identifiable {
    case draft = "待填写"
    case validating = "待校验"
    case confirmed = "待审核"
    case submitted = "已提交"
    var id: String { rawValue }
}

struct NavigationState {
    var searchText = ""
    var selectedRoute: AppRoute = .workspace
}

struct WorkspaceState {
    var pinnedTasks: [String] = ["处理未签到", "完成待批改", "检查退款请求"]
}

struct EnrollmentState {
    var step: EnrollmentStep = .filterCourse
    var qualification: EnrollmentQualification = .unknown
}

struct SessionState {
    var activeTab: SessionOperationTab = .seats
    var lifecycle: SessionLifecycle = .upcoming
}

struct AttendanceState {
    var selectedFollowUp: FollowUpState = .pending
}

struct OrderState {
    var refundState: RefundFlowState = .draft
}

struct TestAnswer: Identifiable, Hashable {
    let id: UUID
    var sessionID: UUID
    var studentID: UUID
    var questionNo: Int
    var officialAnswer: String
    var studentAnswer: String
    var state: AnswerState
    var issue: String?

    init(id: UUID = UUID(), sessionID: UUID, studentID: UUID, questionNo: Int, officialAnswer: String, studentAnswer: String, state: AnswerState, issue: String? = nil) {
        self.id = id
        self.sessionID = sessionID
        self.studentID = studentID
        self.questionNo = questionNo
        self.officialAnswer = officialAnswer
        self.studentAnswer = studentAnswer
        self.state = state
        self.issue = issue
    }

    /// 上传/提交失败类异常：不展示学员作答文本。
    var shouldHideStudentAnswer: Bool {
        guard let issue else { return false }
        return issue.contains("答题提交失败")
    }
}
