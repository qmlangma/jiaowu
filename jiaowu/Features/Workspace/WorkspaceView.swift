import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""
    @State private var isSearchFocused = false
    @State private var selectedPeriod: WorkspaceTimePeriod = .afternoon
    @State private var selectedDate = WorkspaceMockData.today
    @State private var selectedFloor: RoomFloor = .all
    @State private var hideIdleRooms = true
    @State private var reservedRooms: Set<UUID> = []
    @State private var reservationDraft: RoomReservationDraft?
    @State private var selectedStudent: WorkspaceStudentResult?
    @State private var selectedSession: RoomSession?
    @State private var isAlertCollapsed = true
    @State private var alarmOn = false
    @State private var lightOn = false
    @State private var webOn = false

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
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        WorkspaceHeaderView(
                            campusName: store.currentCampus?.name ?? "请选择校区",
                            summaries: WorkspaceMockData.summaries,
                            searchText: $searchText,
                            isSearchFocused: $isSearchFocused,
                            studentResults: WorkspaceMockData.studentResults,
                            classResults: WorkspaceMockData.classResults,
                            teacherResults: WorkspaceMockData.teacherResults,
                            selectStudent: { selectedStudent = $0 },
                            selectClass: { selectedSession = $0.session },
                            selectTeacher: { store.toast = "已打开\($0.name)今日班级" },
                            openCampus: {
                                store.pendingCampusSelectionID = store.currentCampus?.id
                                store.shouldPresentCampusDialog = true
                            },
                            openAlerts: {
                                withAnimation(.easeInOut(duration: 0.22)) {
                                    isAlertCollapsed = false
                                }
                            },
                            hasUnreadAlerts: !WorkspaceMockData.alerts.isEmpty,
                            alarmOn: $alarmOn,
                            lightOn: $lightOn,
                            webOn: $webOn
                        )

                        QuickActionGridView(
                            actions: WorkspaceMockData.quickActions,
                            handleAction: handleQuickAction
                        )

                        RoomMonitorView(
                            selectedPeriod: $selectedPeriod,
                            selectedDate: $selectedDate,
                            sessions: roomSessions,
                            selectedFloor: $selectedFloor,
                            hideIdleRooms: $hideIdleRooms,
                            previousDate: { selectedDate = selectedDate.addingTimeInterval(-86_400) },
                            nextDate: { selectedDate = selectedDate.addingTimeInterval(86_400) },
                            viewClass: { selectedSession = $0 },
                            viewRoster: { selectedSession = $0 },
                            reserveRoom: { reservationDraft = RoomReservationDraft(room: $0.roomName, dateText: selectedDate.displayText, period: selectedPeriod.title) }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                if !isAlertCollapsed {
                    HStack {
                        Spacer(minLength: 0)
                        AlertPanelView(
                            alerts: WorkspaceMockData.alerts,
                            collapse: { isAlertCollapsed = true },
                            contactAction: { store.toast = "已呼叫\($0.contactName)" },
                            markAction: { store.toast = "已标记\($0.contactName)完成联系" }
                        )
                        .frame(width: 344)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.trailing, 8)
                        .padding(.vertical, 20)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(8)
                }

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
}
