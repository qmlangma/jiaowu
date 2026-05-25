import SwiftUI

struct WorkspaceView: View {
    @Environment(AppStore.self) private var store
    @State private var searchText = ""
    @State private var isSearchPagePresented = false
    @State private var recentSearches = ["张明明", "A101", "二年级信息学算法晚班", "李梓轩", "陈老师", "138****5621", "Python 体验活动"]
    @State private var selectedPeriod: WorkspaceTimePeriod = .afternoon
    @State private var selectedDate = WorkspaceMockData.today
    @State private var selectedFloor: RoomFloor = .all
    @State private var hideIdleRooms = true
    @State private var reservedRooms: Set<UUID> = []
    @State private var reservationDraft: RoomReservationDraft?
    @State private var selectedStudent: WorkspaceStudentResult?
    @State private var selectedSession: RoomSession?
    @State private var selectedRosterSession: RoomSession?
    @State private var selectedTeacherProfile: TeacherProfile?
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
                        if let selectedTeacherProfile {
                            TeacherDetailPage(teacher: selectedTeacherProfile) {
                                self.selectedTeacherProfile = nil
                            }
                        } else if isSearchPagePresented {
                            WorkspaceSearchPage(
                                query: $searchText,
                                recentSearches: $recentSearches,
                                cancel: { isSearchPagePresented = false },
                                submit: handleWorkspaceSearch
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
                                viewClass: { selectedRosterSession = $0 },
                                viewRoster: { selectedRosterSession = $0 },
                                reserveRoom: { reservationDraft = RoomReservationDraft(room: $0.roomName, dateText: selectedDate.displayText, period: selectedPeriod.title) }
                            )
                        }
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
                            contactAction: { alert in
                                let role: CallTargetRole = alert.actionTitle.contains("老师") ? .teacher : (alert.actionTitle.contains("助教") ? .assistant : .student)
                                store.openCallDrawer(role: role, name: alert.contactName, phone: alert.phone)
                            },
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

                if let selectedRosterSession {
                    ClassRosterDrawerSheet(
                        session: selectedRosterSession,
                        openTeacherDetail: { teacher in
                            self.selectedTeacherProfile = teacher
                        },
                        close: { self.selectedRosterSession = nil }
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

    private func handleWorkspaceSearch(_ keyword: String) {
        let value = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        store.toast = "搜索：\(value)"
    }
}
