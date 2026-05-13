import Foundation
import SwiftUI

enum WorkspaceMockData {
    static let today = Date()

    static let summaries: [WorkspaceSummary] = [
        WorkspaceSummary(title: "今日班级", value: "18", tint: JWColor.primary, symbol: "calendar"),
        WorkspaceSummary(title: "当前上课", value: "7", tint: JWColor.success, symbol: "play.circle.fill"),
        WorkspaceSummary(title: "迟到/未到学员", value: "12", tint: JWColor.warning, symbol: "person.fill.questionmark"),
        WorkspaceSummary(title: "缺勤老师/助教", value: "3", tint: JWColor.danger, symbol: "exclamationmark.triangle.fill"),
        WorkspaceSummary(title: "待处理事项", value: "9", tint: JWColor.accent, symbol: "tray.full.fill")
    ]

    static let quickActions: [WorkspaceQuickAction] = [
        WorkspaceQuickAction(kind: .assessment, title: "预约入学测", symbol: "doc.text.magnifyingglass", illustrationSymbol: "pencil.and.ruler.fill"),
        WorkspaceQuickAction(kind: .enrollCourse, title: "新生报名", symbol: "graduationcap.fill", illustrationSymbol: "books.vertical.fill"),
        WorkspaceQuickAction(kind: .activityQRCode, title: "活动二维码", symbol: "qrcode", illustrationSymbol: "qrcode.viewfinder")
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
            WorkspaceClassResult(name: "二年级信息学算法晚班", teacher: "杨老师", room: "A101", time: "18:30-20:30", session: roomSessions[0]),
            WorkspaceClassResult(name: "Scratch 启蒙 A 班", teacher: "陈老师", room: "A102", time: "18:30-20:00", session: roomSessions[1]),
            WorkspaceClassResult(name: "C++ 基础提高班", teacher: "周老师", room: "B201", time: "19:00-21:00", session: roomSessions[3])
        ]
    }

    static let roomSessions: [RoomSession] = [
        RoomSession(floor: .first, roomName: "A101", status: .running, sessionType: .course, className: "二年级信息学算法晚班", time: "18:30-20:30", teacher: "张明明", teacherPhone: "13800138001", teacherSignedIn: true, assistant: "刘三副", assistantPhone: "13900139001", assistantSignedIn: true, arrived: 16, expected: 18, late: 1, absent: 1, capacity: 20, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A102", status: .running, sessionType: .assessment, className: "入学测现场诊断", time: "18:30-20:00", teacher: "陈老师", teacherPhone: "13800138002", teacherSignedIn: true, assistant: "王助教", assistantPhone: "13900139002", assistantSignedIn: true, arrived: 11, expected: 14, late: 2, absent: 1, capacity: 16, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A103", status: .upcoming, sessionType: .activity, className: "Python 体验活动", time: "20:10-21:00", teacher: "罗老师", teacherPhone: "13800138003", teacherSignedIn: false, assistant: "周助教", assistantPhone: "13900139003", assistantSignedIn: false, arrived: 0, expected: 8, late: 0, absent: 0, capacity: 12, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A104", status: .notStarted, sessionType: .course, className: "一年级逻辑思维课", time: "19:30-21:00", teacher: "顾老师", teacherPhone: "13800138004", teacherSignedIn: false, assistant: "徐助教", assistantPhone: "13900139004", assistantSignedIn: false, arrived: 0, expected: 12, late: 0, absent: 0, capacity: 14, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .first, roomName: "A105", status: .idle, sessionType: .none, className: nil, time: "19:00-21:00 可预约", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B201", status: .running, sessionType: .course, className: "C++ 基础提高班", time: "19:00-21:00", teacher: "周老师", teacherPhone: "13800138005", teacherSignedIn: true, assistant: "刘助教", assistantPhone: "13900139005", assistantSignedIn: true, arrived: 13, expected: 16, late: 0, absent: 3, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B202", status: .idle, sessionType: .none, className: nil, time: "18:30-21:00 可预约", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 14, hasScreen: false, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B203", status: .ended, sessionType: .course, className: "一年级思维训练", time: "14:00-16:00", teacher: "刘老师", teacherPhone: "13800138006", teacherSignedIn: true, assistant: "唐助教", assistantPhone: "13900139006", assistantSignedIn: true, arrived: 12, expected: 12, late: 0, absent: 0, capacity: 18, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B204", status: .running, sessionType: .course, className: "算法竞赛冲刺班", time: "18:40-20:40", teacher: "朱老师", teacherPhone: "13800138007", teacherSignedIn: true, assistant: "韩助教", assistantPhone: "13900139007", assistantSignedIn: false, arrived: 9, expected: 12, late: 1, absent: 2, capacity: 16, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B205", status: .upcoming, sessionType: .assessment, className: "入学测一对一", time: "20:00-20:40", teacher: "郑老师", teacherPhone: "13800138008", teacherSignedIn: false, assistant: "吴助教", assistantPhone: "13900139008", assistantSignedIn: false, arrived: 0, expected: 3, late: 0, absent: 0, capacity: 8, hasScreen: false, hasNetwork: true),
        RoomSession(floor: .second, roomName: "B206", status: .idle, sessionType: .none, className: nil, time: "晚间空档 2 小时", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 20, hasScreen: true, hasNetwork: false),
        RoomSession(floor: .third, roomName: "C301", status: .notStarted, sessionType: .parentsMeeting, className: "家长会一对一沟通", time: "19:10-19:50", teacher: "许艳博", teacherPhone: "13800138009", teacherSignedIn: false, assistant: "李助教", assistantPhone: "13900139009", assistantSignedIn: false, arrived: 0, expected: 6, late: 0, absent: 0, capacity: 10, hasScreen: false, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C302", status: .idle, sessionType: .none, className: nil, time: "全天 2 个空档", teacher: nil, assistant: nil, arrived: 0, expected: 0, late: 0, absent: 0, capacity: 22, hasScreen: true, hasNetwork: false),
        RoomSession(floor: .third, roomName: "C303", status: .running, sessionType: .activity, className: "机器人搭建社团", time: "18:20-19:50", teacher: "段老师", teacherPhone: "13800138010", teacherSignedIn: true, assistant: "彭助教", assistantPhone: "13900139010", assistantSignedIn: true, arrived: 14, expected: 15, late: 0, absent: 1, capacity: 24, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C304", status: .ended, sessionType: .course, className: "图形化编程启蒙", time: "15:30-17:00", teacher: "孙老师", teacherPhone: "13800138011", teacherSignedIn: true, assistant: "何助教", assistantPhone: "13900139011", assistantSignedIn: true, arrived: 10, expected: 11, late: 0, absent: 1, capacity: 14, hasScreen: true, hasNetwork: true),
        RoomSession(floor: .third, roomName: "C305", status: .upcoming, sessionType: .course, className: "小升初算法集训", time: "20:20-22:00", teacher: "邢老师", teacherPhone: "13800138012", teacherSignedIn: false, assistant: "高助教", assistantPhone: "13900139012", assistantSignedIn: false, arrived: 0, expected: 20, late: 0, absent: 0, capacity: 24, hasScreen: true, hasNetwork: true)
    ]

    static let alerts: [WorkspaceAlert] = [
        WorkspaceAlert(priority: .high, category: "学生未到", contactName: "冯宇轩", detail: "图形化编程 B 班 · 周老师", timeDetail: "未到 18 分钟", phone: "186****5801", actionTitle: "联系家长"),
        WorkspaceAlert(priority: .high, category: "老师缺勤", contactName: "陈老师", detail: "Scratch 启蒙 A 班", timeDetail: "18:30 未签到", phone: "138****8120", actionTitle: "联系老师"),
        WorkspaceAlert(priority: .medium, category: "学生迟到", contactName: "李泽宇", detail: "Scratch 启蒙 A 班 · 陈老师", timeDetail: "迟到 12 分钟", phone: "180****3001", actionTitle: "联系家长"),
        WorkspaceAlert(priority: .medium, category: "助教缺勤", contactName: "林助教", detail: "二年级信息学算法晚班", timeDetail: "待确认", phone: "139****7721", actionTitle: "联系助教")
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
    case assessment = "入学测"

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
