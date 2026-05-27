import SwiftUI

struct RoomMonitorView: View {
    @Binding var selectedPeriod: WorkspaceTimePeriod
    var sessions: [RoomSession]
    @Binding var selectedFloor: RoomFloor
    @Binding var onlyIdleRooms: Bool
    var openScheduleTab: () -> Void
    var viewClass: (RoomSession) -> Void
    var viewRoster: (RoomSession) -> Void
    var reserveRoom: (RoomSession) -> Void
    var callTeacher: (RoomSession) -> Void
    var callAssistant: (RoomSession) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.medium), count: 3)
    private let allSubject = "全部科目"
    private let allGrade = "全部年级"
    private let subjectFilterOptions = ["全部科目", "信息学算法", "信息学语言传播", "信息学实验P", "信息学实验C"]
    private let gradeFilterSections: [(title: String, options: [String])] = [
        ("幼儿园", ["幼中班", "幼大班"]),
        ("小学", ["一年级", "二年级", "三年级", "四年级", "五年级", "六年级"]),
        ("初中", ["初一", "初二", "初三"]),
        ("高中", ["高一", "高二", "高三"])
    ]

    @State private var selectedSubjectFilter = "全部科目"
    @State private var selectedGradeFilter = "全部年级"
    @State private var draftSubjectFilter = "全部科目"
    @State private var draftGradeFilter = "全部年级"
    @State private var isCourseFilterDrawerPresented = false
    @State private var hasCapturedInitialFilters = false
    @State private var initialPeriod: WorkspaceTimePeriod = .morning
    @State private var initialFloor: RoomFloor = .all
    @State private var initialOnlyIdleRooms = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack(alignment: .center, spacing: 18) {
                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日课程")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(JWColor.text)

                            Button(action: openScheduleTab) {
                                HStack(spacing: 6) {
                                    Text("查看完整课表")
                                        .font(.system(size: 15, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(JWColor.textMuted)
                            }
                            .buttonStyle(.plain)
                        }
                        periodPicker
                    }
                    Spacer(minLength: 0)
                    HStack(alignment: .center, spacing: AppSpacing.medium) {
                        floorPicker
                        hideIdleToggle
                        courseFilterTrigger
                    }
                }

                if filteredSessions.isEmpty && hasActiveFilters {
                    emptyCoursePlaceholder
                        .padding(.top, 10)
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                        ForEach(filteredSessions) { session in
                            RoomCardView(
                                session: session,
                                viewClass: { viewClass(session) },
                                viewRoster: { viewRoster(session) },
                                reserveRoom: { reserveRoom(session) },
                                callTeacher: { callTeacher(session) },
                                callAssistant: { callAssistant(session) }
                            )
                        }
                    }
                }
            }
            .padding(20)
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .animation(.easeInOut(duration: 0.22), value: isCourseFilterDrawerPresented)
        .onAppear {
            guard !hasCapturedInitialFilters else { return }
            hasCapturedInitialFilters = true
            initialPeriod = selectedPeriod
            initialFloor = selectedFloor
            initialOnlyIdleRooms = onlyIdleRooms
        }
        .fullScreenCover(isPresented: $isCourseFilterDrawerPresented) {
            ZStack {
                Color.black.opacity(0.24)
                    .ignoresSafeArea()
                    .onTapGesture { isCourseFilterDrawerPresented = false }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    courseFilterDrawer
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .background(Color.clear)
            .presentationBackground(.clear)
        }
    }

    private var periodPicker: some View {
        HStack(spacing: 12) {
            ForEach(WorkspaceTimePeriod.allCases) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.title)
                        .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(selectedPeriod == period ? .white : JWColor.textMuted)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(selectedPeriod == period ? JWColor.primary : JWColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var floorPicker: some View {
        HStack(spacing: 8) {
            ForEach(RoomFloor.allCases) { floor in
                Button {
                    selectedFloor = floor
                } label: {
                    Text(floor.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(selectedFloor == floor ? .white : JWColor.textMuted)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(selectedFloor == floor ? JWColor.primary : JWColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var hideIdleToggle: some View {
        HStack(spacing: 8) {
            Text("仅看空教室")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Toggle("", isOn: $onlyIdleRooms)
                .labelsHidden()
                .tint(JWColor.primary)
        }
        .padding(.horizontal, 10)
        .frame(height: 42)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var courseFilterSummary: String {
        if selectedSubjectFilter == allSubject && selectedGradeFilter == allGrade {
            return "科目/年级筛选"
        }
        if selectedGradeFilter == allGrade {
            return selectedSubjectFilter
        }
        if selectedSubjectFilter == allSubject {
            return selectedGradeFilter
        }
        return "\(selectedSubjectFilter) / \(selectedGradeFilter)"
    }

    private var courseFilterTrigger: some View {
        Button {
            draftSubjectFilter = selectedSubjectFilter
            draftGradeFilter = selectedGradeFilter
            normalizeDraftGradeSelection()
            isCourseFilterDrawerPresented = true
        } label: {
            HStack(spacing: 6) {
                Text(courseFilterSummary)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(JWColor.text)
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(JWColor.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var courseFilterDrawer: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(JWColor.divider)
                .frame(width: 48, height: 6)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("科目年级筛选")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(JWColor.text)
                }
                Spacer(minLength: 0)
                Button {
                    isCourseFilterDrawerPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(JWColor.textMuted)
                        .frame(width: 40, height: 40)
                        .background(JWColor.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .overlay(alignment: .bottom) {
                Rectangle().fill(JWColor.divider).frame(height: 1)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sectionTitle("科目")
                    optionGrid(options: subjectFilterOptions, selection: $draftSubjectFilter)
                    sectionTitle("年级")
                    optionGrid(options: [allGrade], selection: $draftGradeFilter, isOptionEnabled: isGradeOptionEnabled)
                    ForEach(Array(gradeFilterSections.enumerated()), id: \.offset) { _, section in
                        gradeSection(title: section.title, options: section.options)
                    }
                }
                .padding(18)
                .onChange(of: draftSubjectFilter) { _, _ in
                    normalizeDraftGradeSelection()
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.62)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(JWColor.divider)
                    .frame(height: 1)
                HStack(spacing: 12) {
                    SecondaryButton(title: "重置") {
                        draftSubjectFilter = allSubject
                        draftGradeFilter = allGrade
                    }
                    PrimaryButton(title: "确认") {
                        selectedSubjectFilter = draftSubjectFilter
                        selectedGradeFilter = draftGradeFilter
                        isCourseFilterDrawerPresented = false
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(JWColor.surface)
            }
        }
        .frame(maxWidth: .infinity)
        .background(JWColor.surface)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22))
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 24, x: 0, y: -8)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(JWColor.text)
    }

    private func gradeSection(title: String, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            optionGrid(options: options, selection: $draftGradeFilter, isOptionEnabled: isGradeOptionEnabled)
        }
    }

    private var emptyCoursePlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(JWColor.textMuted.opacity(0.65))
                .frame(width: 74, height: 74)
                .background(JWColor.appBackground)
                .clipShape(Circle())

            Text("当前筛选条件下无任何课程")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)

            Button(action: resetFiltersToInitialState) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("重置筛选")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(JWColor.primary)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(JWColor.primaryLight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, minHeight: 210)
        .padding(.vertical, 14)
        .background(JWColor.appBackground.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func optionGrid(
        options: [String],
        selection: Binding<String>,
        isOptionEnabled: @escaping (String) -> Bool = { _ in true }
    ) -> some View {
        let optionColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
        return LazyVGrid(columns: optionColumns, alignment: .leading, spacing: 10) {
            ForEach(options, id: \.self) { option in
                let enabled = isOptionEnabled(option)
                let selected = selection.wrappedValue == option
                Button {
                    selection.wrappedValue = option
                } label: {
                    Text(option)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(chipForegroundColor(selected: selected, enabled: enabled))
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(chipBackgroundColor(selected: selected, enabled: enabled))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!enabled)
            }
        }
    }

    private func subjectTag(for session: RoomSession) -> String? {
        guard let className = session.className else { return nil }
        if className.contains("算法") { return "信息学算法" }
        if className.contains("语言传播") { return "信息学语言传播" }
        if className.contains("实验P") || className.localizedCaseInsensitiveContains("Python") { return "信息学实验P" }
        if className.contains("实验C") || className.localizedCaseInsensitiveContains("C++") { return "信息学实验C" }
        return nil
    }

    private func gradeTag(for session: RoomSession) -> String? {
        guard let className = session.className else { return nil }
        let grades = allGradeFilterOptions
        return grades.first { className.contains($0) }
    }

    private var allGradeFilterOptions: [String] {
        gradeFilterSections.flatMap { $0.options }
    }

    private var availableDraftGradeOptions: Set<String> {
        Set(
            sessions.compactMap { session in
                guard let grade = gradeTag(for: session) else { return nil }
                if draftSubjectFilter == allSubject { return grade }
                return subjectTag(for: session) == draftSubjectFilter ? grade : nil
            }
        )
    }

    private func isGradeOptionEnabled(_ option: String) -> Bool {
        option == allGrade || availableDraftGradeOptions.contains(option)
    }

    private func normalizeDraftGradeSelection() {
        guard draftGradeFilter != allGrade else { return }
        if !availableDraftGradeOptions.contains(draftGradeFilter) {
            draftGradeFilter = allGrade
        }
    }

    private func chipForegroundColor(selected: Bool, enabled: Bool) -> Color {
        if selected && enabled { return .white }
        if enabled { return JWColor.text }
        return JWColor.textMuted.opacity(0.58)
    }

    private func chipBackgroundColor(selected: Bool, enabled: Bool) -> Color {
        if selected && enabled { return JWColor.primary }
        if enabled { return JWColor.appBackground }
        return JWColor.appBackground.opacity(0.58)
    }

    private var filteredSessions: [RoomSession] {
        sessions.filter { session in
            let matchesFloor = selectedFloor == .all || session.floor == selectedFloor
            let matchesIdle = onlyIdleRooms ? session.status == .idle : session.status != .idle
            let matchesSubject = selectedSubjectFilter == allSubject || subjectTag(for: session) == selectedSubjectFilter
            let matchesGrade = selectedGradeFilter == allGrade || gradeTag(for: session) == selectedGradeFilter
            return matchesFloor && matchesIdle && matchesSubject && matchesGrade
        }
    }

    private var hasActiveFilters: Bool {
        selectedFloor != initialFloor ||
        onlyIdleRooms != initialOnlyIdleRooms ||
        selectedSubjectFilter != allSubject ||
        selectedGradeFilter != allGrade ||
        selectedPeriod != initialPeriod
    }

    private func resetFiltersToInitialState() {
        selectedPeriod = initialPeriod
        selectedFloor = initialFloor
        onlyIdleRooms = initialOnlyIdleRooms
        selectedSubjectFilter = allSubject
        selectedGradeFilter = allGrade
        draftSubjectFilter = allSubject
        draftGradeFilter = allGrade
    }
}

extension Date {
    var displayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: self)
    }
}
