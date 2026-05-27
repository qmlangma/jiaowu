import Foundation
import SwiftUI

enum WorkspaceMockData {
    static let today = Date()

    static let summaries: [WorkspaceSummary] = [
        WorkspaceSummary(title: "今日缺勤学员", value: "15", tint: JWColor.warning, symbol: "person.fill.xmark"),
        WorkspaceSummary(title: "今日缺勤老师", value: "1", tint: JWColor.danger, symbol: "exclamationmark.triangle.fill"),
        WorkspaceSummary(title: "今日缺勤助教", value: "2", tint: JWColor.caution, symbol: "person.2.fill"),
        WorkspaceSummary(title: "近期新增学员", value: "8", tint: JWColor.primary, symbol: "person.crop.badge.plus")
    ]

    static let quickActions: [WorkspaceQuickAction] = [
        WorkspaceQuickAction(kind: .assessment, title: "预约入学诊断", symbol: "doc.text.magnifyingglass", illustrationSymbol: "pencil.and.ruler.fill"),
        WorkspaceQuickAction(kind: .enrollCourse, title: "选课报名", symbol: "graduationcap.fill", illustrationSymbol: "books.vertical.fill"),
        WorkspaceQuickAction(kind: .activityQRCode, title: "活动报名", symbol: "qrcode", illustrationSymbol: "qrcode.viewfinder")
    ]

    static let studentResults: [WorkspaceStudentResult] = [
        WorkspaceStudentResult(name: "许魏洲", grade: "二年级", phone: "130****0619", courseState: "14:30 已到", className: "二年级信息学算法"),
        WorkspaceStudentResult(name: "李泽宇", grade: "一年级", phone: "180****3001", courseState: "迟到 12 分钟", className: "Scratch 启蒙 A 班"),
        WorkspaceStudentResult(name: "冯宇轩", grade: "一年级", phone: "186****5801", courseState: "未到", className: "图形化编程 B 班")
    ]

    static let teacherResults: [WorkspaceTeacherResult] = [
        WorkspaceTeacherResult(name: "杨老师", todayClasses: "4 个班", checkState: "已签到"),
        WorkspaceTeacherResult(name: "陈老师", todayClasses: "3 个班", checkState: "未签到"),
        WorkspaceTeacherResult(name: "林助教", todayClasses: "2 个班", checkState: "缺勤待确认")
    ]

    static var classResults: [WorkspaceClassResult] {
        [
            WorkspaceClassResult(name: "【暑假】四年级 · 算法 · 探索", teacher: "张明明", room: "A101", time: "18:30-21:30", session: roomSessions[0]),
            WorkspaceClassResult(name: "把握三年级思维关键期，赢在启蒙起跑线公益讲座", teacher: "陈明明", room: "A102", time: "18:30-20:00", session: roomSessions[1]),
            WorkspaceClassResult(name: "【暑假】二年级 · 实验C · 探索", teacher: "周老师", room: "B201", time: "14:00-16:00", session: roomSessions[5])
        ]
    }

    static let roomSessions: [RoomSession] = [
        RoomSession(floor: .first, roomName: "A101", status: .running, sessionType: .course, className: "【暑假】四年级 · 算法 · 探索", time: "18:30-21:30", teacher: "张明明", teacherPhone: "13800138001", teacherSignedIn: true, assistant: "刘三副", assistantPhone: "13900139001", assistantSignedIn: true, arrived: 16, expected: 18, late: 1, absent: 1, capacity: 20, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A102", status: .running, sessionType: .parentsMeeting, className: "把握三年级思维关键期，赢在启蒙起跑线公益讲座", time: "18:30-20:00", teacher: "陈明明", teacherPhone: "13800138002", teacherSignedIn: true, assistant: "王恩赐", assistantPhone: "13900139002", assistantSignedIn: true, arrived: 34, expected: 38, late: 2, absent: 2, capacity: 40, hasScreen: true, hasNetwork: true, periods: [
            RoomSessionPeriod(status: .running, sessionType: .parentsMeeting, className: "把握三年级思维关键期，赢在启蒙起跑线公益讲座", time: "18:30-20:00", teacher: "陈明明", teacherPhone: "13800138002", teacherSignedIn: true, assistant: "王恩赐", assistantPhone: "13900139002", assistantSignedIn: true, arrived: 34, expected: 38, late: 2, absent: 2),
            RoomSessionPeriod(status: .notStarted, sessionType: .assessment, className: "幼大班计算摸底诊断", time: "20:10-21:30", teacher: "罗老师", teacherPhone: "13800138003", teacherSignedIn: false, assistant: "周助教", assistantPhone: "13900139003", assistantSignedIn: false, arrived: 0, expected: 12, late: 0, absent: 0)
        ]),
        RoomSession(floor: .first, roomName: "A103", status: .upcoming, sessionType: .activity, className: "晚上18:30初高中森林探秘", time: "18:30-21:30", teacher: "罗老师", teacherPhone: "13800138003", teacherSignedIn: false, assistant: "周助教", assistantPhone: "13900139003", assistantSignedIn: false, arrived: 0, expected: 24, late: 0, absent: 0, capacity: 24, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A104", status: .notStarted, sessionType: .course, className: "【暑假】三年级 · 语言传播 · 探索", time: "08:00-10:30", teacher: "顾老师", teacherPhone: "13800138004", teacherSignedIn: false, assistant: "徐助教", assistantPhone: "13900139004", assistantSignedIn: false, arrived: 0, expected: 16, late: 0, absent: 0, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A105", status: .idle, sessionType: .none, className: nil, time: "19:00-21:00 可预约", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 18, hasScreen: true, hasNetwork: true, availableTimes: ["09:00-10:20", "11:00-12:30", "14:10-16:00", "19:00-21:00"]),
        RoomSession(floor: .second, roomName: "B201", status: .running, sessionType: .course, className: "【暑假】二年级 · 实验C · 探索", time: "14:00-16:00", teacher: "周老师", teacherPhone: "13800138005", teacherSignedIn: true, assistant: "刘助教", assistantPhone: "13900139005", assistantSignedIn: true, arrived: 13, expected: 16, late: 0, absent: 3, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B202", status: .idle, sessionType: .none, className: nil, time: "18:30-21:00 可预约", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 14, hasScreen: false, hasNetwork: true, availableTimes: ["13:30-15:00", "15:40-16:50", "18:30-21:00"]),
        RoomSession(floor: .second, roomName: "B203", status: .ended, sessionType: .course, className: "【暑假】二年级 · 实验P · 探索", time: "14:00-16:00", teacher: "刘老师", teacherPhone: "13800138006", teacherSignedIn: true, assistant: "唐助教", assistantPhone: "13900139006", assistantSignedIn: true, arrived: 12, expected: 12, late: 0, absent: 0, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B204", status: .running, sessionType: .course, className: "【暑假】二年级 · 国文素养 · 探索", time: "18:30-21:30", teacher: "朱老师", teacherPhone: "13800138007", teacherSignedIn: true, assistant: "韩助教", assistantPhone: "13900139007", assistantSignedIn: false, arrived: 9, expected: 12, late: 1, absent: 2, capacity: 16, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B205", status: .upcoming, sessionType: .assessment, className: "2026《从目标到方法》讲座", time: "18:30-21:30", teacher: "郑老师", teacherPhone: "13800138008", teacherSignedIn: false, assistant: "吴助教", assistantPhone: "13900139008", assistantSignedIn: false, arrived: 0, expected: 30, late: 0, absent: 0, capacity: 32, hasScreen: false, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B206", status: .idle, sessionType: .none, className: nil, time: "晚间空档 2 小时", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 20, hasScreen: true, hasNetwork: false, availableTimes: ["08:30-09:40", "10:10-11:30", "18:00-20:00"]),
        RoomSession(floor: .third, roomName: "C301", status: .notStarted, sessionType: .activity, className: "晚上15:30小学森林探秘", time: "15:30-17:30", teacher: "许艳博", teacherPhone: "13800138009", teacherSignedIn: false, assistant: "李助教", assistantPhone: "13900139009", assistantSignedIn: false, arrived: 0, expected: 22, late: 0, absent: 0, capacity: 24, hasScreen: false, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C302", status: .idle, sessionType: .none, className: nil, time: "全天 2 个空档", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 22, hasScreen: true, hasNetwork: false, availableTimes: ["09:30-12:00", "14:00-15:30", "16:00-16:50", "19:30-21:30"]),
        RoomSession(floor: .third, roomName: "C303", status: .running, sessionType: .activity, className: "机器人搭建社团", time: "18:20-19:50", teacher: "段老师", teacherPhone: "13800138010", teacherSignedIn: true, assistant: "彭助教", assistantPhone: "13900139010", assistantSignedIn: true, arrived: 14, expected: 15, late: 0, absent: 1, capacity: 24, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C304", status: .ended, sessionType: .course, className: "图形化编程启蒙", time: "15:30-17:00", teacher: "孙老师", teacherPhone: "13800138011", teacherSignedIn: true, assistant: "何助教", assistantPhone: "13900139011", assistantSignedIn: true, arrived: 10, expected: 11, late: 0, absent: 1, capacity: 14, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C305", status: .upcoming, sessionType: .course, className: "小升初算法集训", time: "20:20-22:00", teacher: "邢老师", teacherPhone: "13800138012", teacherSignedIn: false, assistant: "高助教", assistantPhone: "13900139012", assistantSignedIn: false, arrived: 0, expected: 20, late: 0, absent: 0, capacity: 24, hasScreen: true, hasNetwork: true)
    ]

    static let alerts: [WorkspaceAlert] = [
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "白可心", detail: "课堂签到异常", timeDetail: "未到 18 分钟", phone: "186****5801", actionTitle: "联系家长", studentNumber: "STU240501", studentGrade: "一年级", studentSubject: "图形化编程", className: "图形化编程 B 班", classTeacher: "周老师", classroom: "A103", lateTime: "迟到 18 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "白芷晴", detail: "课堂签到异常", timeDetail: "未到 11 分钟", phone: "180****3001", actionTitle: "联系家长", studentNumber: "STU240502", studentGrade: "一年级", studentSubject: "Scratch", className: "Scratch 启蒙 A 班", classTeacher: "陈老师", classroom: "A102", lateTime: "迟到 11 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "柏俊豪", detail: "课堂签到异常", timeDetail: "未到 23 分钟", phone: "133****0921", actionTitle: "联系家长", studentNumber: "STU240503", studentGrade: "二年级", studentSubject: "信息学算法", className: "二年级信息学算法晚班", classTeacher: "杨老师", classroom: "A101", lateTime: "迟到 23 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "毕若溪", detail: "课堂签到异常", timeDetail: "未到 9 分钟", phone: "151****2290", actionTitle: "联系家长", studentNumber: "STU240504", studentGrade: "一年级", studentSubject: "逻辑思维", className: "一年级逻辑思维课", classTeacher: "顾老师", classroom: "A104", lateTime: "迟到 9 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "卜宇轩", detail: "课堂签到异常", timeDetail: "未到 18 分钟", phone: "186****5801", actionTitle: "联系家长", studentNumber: "STU240505", studentGrade: "一年级", studentSubject: "图形化编程", className: "图形化编程 B 班", classTeacher: "周老师", classroom: "A103", lateTime: "迟到 18 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "班一诺", detail: "课堂签到异常", timeDetail: "未到 7 分钟", phone: "177****3328", actionTitle: "联系家长", studentNumber: "STU240506", studentGrade: "小升初", studentSubject: "算法", className: "小升初算法集训", classTeacher: "邢老师", classroom: "C305", lateTime: "迟到 7 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "边梓晨", detail: "课堂签到异常", timeDetail: "未到 10 分钟", phone: "182****4136", actionTitle: "联系家长", studentNumber: "STU240507", studentGrade: "三年级", studentSubject: "机器人", className: "机器人搭建社团", classTeacher: "段老师", classroom: "C303", lateTime: "迟到 10 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "包泽宇", detail: "课堂签到异常", timeDetail: "未到 16 分钟", phone: "180****3001", actionTitle: "联系家长", studentNumber: "STU240508", studentGrade: "一年级", studentSubject: "Scratch", className: "Scratch 启蒙 A 班", classTeacher: "陈老师", classroom: "A102", lateTime: "迟到 16 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "鲍嘉禾", detail: "课堂签到异常", timeDetail: "未到 8 分钟", phone: "136****1920", actionTitle: "联系家长", studentNumber: "STU240509", studentGrade: "初一", studentSubject: "C++", className: "C++ 基础提高班", classTeacher: "周老师", classroom: "B201", lateTime: "迟到 8 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "潘昊然", detail: "课堂签到异常", timeDetail: "未到 21 分钟", phone: "138****6507", actionTitle: "联系家长", studentNumber: "STU240510", studentGrade: "一年级", studentSubject: "思维训练", className: "一年级思维训练", classTeacher: "刘老师", classroom: "B203", lateTime: "迟到 21 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "钱思远", detail: "课堂签到异常", timeDetail: "未到 13 分钟", phone: "189****7412", actionTitle: "联系家长", studentNumber: "STU240511", studentGrade: "三年级", studentSubject: "信息学算法", className: "入学诊断现场测评", classTeacher: "陈明明", classroom: "A102", lateTime: "迟到 13 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "沈语彤", detail: "课堂签到异常", timeDetail: "未到 6 分钟", phone: "135****3384", actionTitle: "联系家长", studentNumber: "STU240512", studentGrade: "一年级", studentSubject: "图形化编程", className: "图形化编程启蒙", classTeacher: "孙老师", classroom: "C304", lateTime: "迟到 6 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "王启航", detail: "课堂签到异常", timeDetail: "未到 19 分钟", phone: "139****0287", actionTitle: "联系家长", studentNumber: "STU240513", studentGrade: "二年级", studentSubject: "信息学算法", className: "二年级信息学算法晚班", classTeacher: "杨老师", classroom: "A101", lateTime: "迟到 19 分钟"),
        WorkspaceAlert(priority: .medium, category: "学生未到", contactName: "徐沐阳", detail: "课堂签到异常", timeDetail: "未到 12 分钟", phone: "181****5540", actionTitle: "联系家长", studentNumber: "STU240514", studentGrade: "高一", studentSubject: "Python", className: "Python 体验活动", classTeacher: "罗老师", classroom: "A103", lateTime: "迟到 12 分钟"),
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "张一帆", detail: "课堂签到异常", timeDetail: "未到 24 分钟", phone: "187****1669", actionTitle: "联系家长", studentNumber: "STU240515", studentGrade: "初一", studentSubject: "信息学算法", className: "算法竞赛冲刺班", classTeacher: "朱老师", classroom: "B204", lateTime: "迟到 24 分钟"),
        WorkspaceAlert(priority: .high, category: "老师缺勤", contactName: "陈老师", detail: "课堂签到异常", timeDetail: "18:30 未签到", phone: "138****8120", actionTitle: "联系老师", staffNumber: "TEA0821", className: "Scratch 启蒙 A 班", classTeacher: "陈老师", classroom: "A102", lateTime: "迟到 30 分钟"),
        WorkspaceAlert(priority: .medium, category: "助教缺勤", contactName: "林助教", detail: "课堂签到异常", timeDetail: "待确认", phone: "139****7721", actionTitle: "联系助教", staffNumber: "AST1017", className: "二年级信息学算法晚班", classTeacher: "杨老师", classroom: "A101", lateTime: "迟到 15 分钟"),
        WorkspaceAlert(priority: .medium, category: "助教缺勤", contactName: "王助教", detail: "课堂签到异常", timeDetail: "待确认", phone: "139****9048", actionTitle: "联系助教", staffNumber: "AST1103", className: "小升初算法集训", classTeacher: "邢老师", classroom: "C305", lateTime: "迟到 9 分钟")
    ]

    static let leavingRecords: [StudentLeavingRecord] = [
        StudentLeavingRecord(name: "许魏洲", state: "已离校", time: "20:34", phone: "130****0619"),
        StudentLeavingRecord(name: "李泽宇", state: "未离校", time: "等待家长", phone: "180****3001"),
        StudentLeavingRecord(name: "冯宇轩", state: "未到校", time: "未签到", phone: "186****5801")
    ]

    static let toolboxItems: [ToolboxItem] = [
        ToolboxItem(title: "调课", pendingCount: 4, symbol: "calendar.badge.clock"),
        ToolboxItem(title: "转班", pendingCount: 2, symbol: "arrow.left.arrow.right.circle"),
        ToolboxItem(title: "退款处理", pendingCount: 3, symbol: "creditcard.trianglebadge.exclamationmark"),
        ToolboxItem(title: "回访记录", pendingCount: 5, symbol: "phone.badge.checkmark")
    ]
}

struct WorkspaceSummary: Identifiable {
    let id = UUID()
    var title: String
    var value: String
    var tint: Color
    var symbol: String
}

enum WorkspaceQuickActionKind {
    case newStudent
    case enrollCourse
    case assessment
    case activityQRCode
}

struct WorkspaceQuickAction: Identifiable {
    let id = UUID()
    var kind: WorkspaceQuickActionKind
    var title: String
    var symbol: String
    var illustrationSymbol: String
}

struct WorkspaceStudentResult: Identifiable {
    let id = UUID()
    var name: String
    var grade: String
    var phone: String
    var courseState: String
    var className: String
}

struct WorkspaceClassResult: Identifiable {
    let id = UUID()
    var name: String
    var teacher: String
    var room: String
    var time: String
    var session: RoomSession
}

struct WorkspaceTeacherResult: Identifiable {
    let id = UUID()
    var name: String
    var todayClasses: String
    var checkState: String
}

enum WorkspaceTimePeriod: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "上午"
        case .afternoon: "下午"
        case .evening: "晚上"
        }
    }

    static func autoByCurrentTime(_ date: Date = Date()) -> WorkspaceTimePeriod {
        let calendar = Calendar(identifier: .gregorian)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let minutes = hour * 60 + minute

        if minutes >= 13 * 60 && minutes < 17 * 60 {
            return .afternoon
        }
        if minutes >= 17 * 60 {
            return .evening
        }
        return .morning
    }
}

enum RoomSessionStatus: String {
    case running = "上课中"
    case upcoming = "即将开始"
    case notStarted = "未开始"
    case idle = "空闲"
    case ended = "已结束"

    var tint: Color {
        switch self {
        case .running: JWColor.success
        case .upcoming: JWColor.warning
        case .idle: JWColor.textMuted
        case .ended: JWColor.success
        case .notStarted: JWColor.warning
        }
    }

    var surface: Color {
        switch self {
        case .running: JWColor.success.opacity(0.10)
        case .upcoming: JWColor.warning.opacity(0.10)
        case .idle: JWColor.surface
        case .ended: JWColor.success.opacity(0.08)
        case .notStarted: JWColor.warning.opacity(0.10)
        }
    }
}

enum RoomFloor: String, CaseIterable, Identifiable {
    case all = "全部"
    case first = "1楼"
    case second = "2楼"
    case third = "3楼"
    var id: String { rawValue }
}

enum RoomSessionType: String {
    case none = ""
    case course = "课程"
    case activity = "活动"
    case parentsMeeting = "家长会"
    case assessment = "入学诊断"

    var tint: Color {
        switch self {
        case .none: JWColor.textMuted
        case .course: JWColor.primary
        case .activity: JWColor.warning
        case .parentsMeeting: JWColor.success
        case .assessment: JWColor.accent
        }
    }
}

struct RoomSessionPeriod: Identifiable, Hashable {
    let id = UUID()
    var status: RoomSessionStatus
    var sessionType: RoomSessionType
    var className: String?
    var time: String
    var teacher: String?
    var teacherPhone: String? = nil
    var teacherSignedIn: Bool = false
    var assistant: String?
    var assistantPhone: String? = nil
    var assistantSignedIn: Bool = false
    var arrived: Int
    var expected: Int
    var late: Int
    var absent: Int

    init(
        status: RoomSessionStatus,
        sessionType: RoomSessionType,
        className: String?,
        time: String,
        teacher: String?,
        teacherPhone: String? = nil,
        teacherSignedIn: Bool = false,
        assistant: String?,
        assistantPhone: String? = nil,
        assistantSignedIn: Bool = false,
        arrived: Int,
        expected: Int,
        late: Int,
        absent: Int
    ) {
        self.status = status
        self.sessionType = sessionType
        self.className = className
        self.time = time
        self.teacher = teacher
        self.teacherPhone = teacherPhone
        self.teacherSignedIn = teacherSignedIn
        self.assistant = assistant
        self.assistantPhone = assistantPhone
        self.assistantSignedIn = assistantSignedIn
        self.arrived = arrived
        self.expected = expected
        self.late = late
        self.absent = absent
    }

    init(session: RoomSession) {
        self.init(
            status: session.status,
            sessionType: session.sessionType,
            className: session.className,
            time: session.time,
            teacher: session.teacher,
            teacherPhone: session.teacherPhone,
            teacherSignedIn: session.teacherSignedIn,
            assistant: session.assistant,
            assistantPhone: session.assistantPhone,
            assistantSignedIn: session.assistantSignedIn,
            arrived: session.arrived,
            expected: session.expected,
            late: session.late,
            absent: session.absent
        )
    }
}

struct RoomSession: Identifiable, Hashable {
    let id = UUID()
    var floor: RoomFloor
    var roomName: String
    var status: RoomSessionStatus
    var sessionType: RoomSessionType
    var className: String?
    var time: String
    var teacher: String?
    var teacherPhone: String? = nil
    var teacherSignedIn: Bool = false
    var assistant: String?
    var assistantPhone: String? = nil
    var assistantSignedIn: Bool = false
    var arrived: Int
    var expected: Int
    var late: Int
    var absent: Int
    var capacity: Int
    var hasScreen: Bool
    var hasNetwork: Bool
    var availableTimes: [String] = []
    var periods: [RoomSessionPeriod] = []

    func resolved(with period: RoomSessionPeriod) -> RoomSession {
        var copy = self
        copy.status = period.status
        copy.sessionType = period.sessionType
        copy.className = period.className
        copy.time = period.time
        copy.teacher = period.teacher
        copy.teacherPhone = period.teacherPhone
        copy.teacherSignedIn = period.teacherSignedIn
        copy.assistant = period.assistant
        copy.assistantPhone = period.assistantPhone
        copy.assistantSignedIn = period.assistantSignedIn
        copy.arrived = period.arrived
        copy.expected = period.expected
        copy.late = period.late
        copy.absent = period.absent
        return copy
    }
}

enum WorkspaceAlertPriority: String {
    case high = "高"
    case medium = "中"
    case low = "低"

    var tint: Color {
        switch self {
        case .high: JWColor.danger
        case .medium: JWColor.warning
        case .low: JWColor.primary
        }
    }
}

struct WorkspaceAlert: Identifiable {
    let id = UUID()
    var priority: WorkspaceAlertPriority
    var category: String
    var contactName: String
    var detail: String
    var timeDetail: String
    var phone: String
    var actionTitle: String
    var studentNumber: String? = nil
    var studentGrade: String? = nil
    var studentSubject: String? = nil
    var staffNumber: String? = nil
    var className: String? = nil
    var classTeacher: String? = nil
    var classroom: String? = nil
    var lateTime: String? = nil
    var contactNote: String? = nil
    var isContacted: Bool = false
    var isSignedIn: Bool = false

    var isStudentAlert: Bool {
        category.contains("学生") || category.contains("学员")
    }

    var isStaffAlert: Bool {
        category.contains("老师") || category.contains("助教")
    }
}

struct StudentLeavingRecord: Identifiable {
    let id = UUID()
    var name: String
    var state: String
    var time: String
    var phone: String
}

struct RoomReservationDraft {
    var room: String
    var dateText: String
    var period: String
    var purpose = "临时接待"
    var owner = "许艳博"
    var note = ""
}

struct ToolboxItem: Identifiable {
    let id = UUID()
    var title: String
    var pendingCount: Int
    var symbol: String
}
