import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""
    @State private var isSearchPagePresented = false
    @State private var recentSearches = ["张明明", "A101", "二年级信息学算法晚班", "李梓轩", "陈老师", "138****5621", "Python 体验活动"]
    @State private var selectedPeriod: WorkspaceTimePeriod = WorkspaceTimePeriod.autoByCurrentTime()
    @State private var selectedDate = WorkspaceMockData.today
    @State private var selectedFloor: RoomFloor = .all
    @State private var hideIdleRooms = true
    @State private var reservedRooms: Set<UUID> = []
    @State private var reservationDraft: RoomReservationDraft?
    @State private var selectedStudent: WorkspaceStudentResult?
    @State private var selectedSession: RoomSession?

    private var roomSessions: [RoomSession] {
        WorkspaceMockData.roomSessions.map { session in
            var next = session
            if reservedRooms.contains(session.id), session.status == .idle {
                next.status = .notStarted
                next.sessionType = .assessment
                next.className = "临时预约"
                next.teacher = store.currentStaff?.name ?? "教务老师"
            }
            return next
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    if isSearchPagePresented {
                        WorkspaceSearchPage(
                            query: $searchText,
                            recentSearches: $recentSearches,
                            studentResults: WorkspaceMockData.studentResults,
                            teacherResults: WorkspaceMockData.teacherResults,
                            classResults: WorkspaceMockData.classResults,
                            cancel: { isSearchPagePresented = false },
                            submit: handleWorkspaceSearch,
                            openStudent: { selectedStudent = $0 },
                            openTeacher: { store.workspaceSelectedTeacherProfile = makeTeacherProfile(from: $0) },
                            openClass: { store.workspaceSelectedRosterSession = $0.session }
                        )
                    } else {
                        WorkspaceHeaderView(
                            campusName: store.currentCampus?.name ?? "请选择校区",
                            summaries: WorkspaceMockData.summaries,
                            openCampus: {
                                store.pendingCampusSelectionID = store.currentCampus?.id
                                store.shouldPresentCampusDialog = true
                            },
                            openSearch: {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    isSearchPagePresented = true
                                }
                            },
                            openAlerts: {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    store.workspaceAlertDrawerFilter = .all
                                    store.workspaceAlertDrawerVisible = false
                                    store.workspaceAlertDrawerPresented = true
                                }
                            },
                            openSummary: handleSummaryTap,
                            requestAlarmConfirm: { store.shouldPresentAlarmConfirm = true },
                            hasUnreadAlerts: store.workspaceAlerts.contains(where: { !$0.isContacted }),
                            alarmOn: Binding(
                                get: { store.workspaceAlarmOn },
                                set: { store.workspaceAlarmOn = $0 }
                            )
                        )

                        QuickActionGridView(
                            actions: WorkspaceMockData.quickActions,
                            handleAction: handleQuickAction
                        )

                        RoomMonitorView(
                            selectedPeriod: $selectedPeriod,
                            sessions: roomSessions,
                            selectedFloor: $selectedFloor,
                            hideIdleRooms: $hideIdleRooms,
                            openScheduleTab: { store.navigate(.schedule) },
                            viewClass: { store.workspaceSelectedRosterSession = $0 },
                            viewRoster: { store.workspaceSelectedRosterSession = $0 },
                            reserveRoom: { reservationDraft = RoomReservationDraft(room: $0.roomName, dateText: selectedDate.displayText, period: selectedPeriod.title) },
                            callTeacher: { session in
                                store.openCallDrawer(
                                    role: .teacher,
                                    name: session.teacher ?? "老师",
                                    phone: session.teacherPhone ?? "--"
                                )
                            },
                            callAssistant: { session in
                                store.openCallDrawer(
                                    role: .assistant,
                                    name: session.assistant ?? "助教",
                                    phone: session.assistantPhone ?? "--"
                                )
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            if let reservationDraft {
                RoomReservationSheet(
                    draft: reservationDraft,
                    close: { self.reservationDraft = nil },
                    submit: { draft in
                        if let room = WorkspaceMockData.roomSessions.first(where: { $0.roomName == draft.room }) {
                            reservedRooms.insert(room.id)
                        }
                        self.reservationDraft = nil
                        store.toast = "\(draft.room) 已预约"
                    }
                )
            }

            if let selectedStudent {
                StudentQuickDetailSheet(
                    student: selectedStudent,
                    close: { self.selectedStudent = nil },
                    enroll: {
                        self.selectedStudent = nil
                        store.navigate(.courseSelection)
                    },
                    assessment: {
                        self.selectedStudent = nil
                        store.navigate(.assessment)
                    }
                )
            }

            if let selectedSession {
                ClassSessionDetailSheet(
                    session: selectedSession,
                    close: { self.selectedSession = nil },
                    openSchedule: {
                        self.selectedSession = nil
                        store.navigate(.schedule)
                    },
                    openAttendance: {
                        self.selectedSession = nil
                        store.navigate(.attendance)
                    }
                )
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            selectedPeriod = WorkspaceTimePeriod.autoByCurrentTime()
            if store.workspaceAlerts.isEmpty {
                store.workspaceAlerts = WorkspaceMockData.alerts
            }
        }
    }

    private func handleQuickAction(_ action: WorkspaceQuickAction) {
        switch action.kind {
        case .newStudent:
            store.navigate(.students)
        case .enrollCourse:
            store.navigate(.courseSelection)
        case .assessment:
            store.navigate(.assessment)
        case .activityQRCode:
            store.toast = "已展示活动二维码，家长可扫码查看活动详情"
        }
    }

    private func handleWorkspaceSearch(_ keyword: String) {
        let value = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        store.toast = "搜索：\(value)"
    }

    private func makeTeacherProfile(from result: WorkspaceTeacherResult) -> TeacherProfile {
        TeacherProfile(
            name: result.name,
            phone: "13800138001",
            campus: store.currentCampus?.name ?? "合肥分校",
            department: "教学部",
            onboardDate: "2021-08-16",
            yearsOfTeaching: "6年",
            graduateSchool: "华中师范大学",
            subjects: "小学数学 / 信息学思维",
            tags: ["课堂节奏稳", "互动反馈快", "善于激发思考", "分层教学"],
            motto: "让每个孩子都能找到理解知识的成就感。",
            bio: "\(result.name)当前\(result.checkState)，今日带班\(result.todayClasses)。擅长课堂组织与学习习惯培养，注重过程反馈和成长激励。"
        )
    }

    private func handleSummaryTap(_ summary: WorkspaceSummary) {
        switch summary.title {
        case "今日缺勤学员":
            store.workspaceAlertDrawerFilter = .absentStudent
        case "今日缺勤老师":
            store.workspaceAlertDrawerFilter = .absentTeacher
        case "今日缺勤助教":
            store.workspaceAlertDrawerFilter = .absentAssistant
        default:
            return
        }
        withAnimation(.easeInOut(duration: 0.22)) {
            store.workspaceAlertDrawerVisible = false
            store.workspaceAlertDrawerPresented = true
        }
    }
}
