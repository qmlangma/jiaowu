import SwiftUI

struct WorkspaceSearchPage: View {
    @Binding var query: String
    @Binding var recentSearches: [String]
    var studentResults: [WorkspaceStudentResult]
    var teacherResults: [WorkspaceTeacherResult]
    var classResults: [WorkspaceClassResult]
    var cancel: () -> Void
    var submit: (String) -> Void
    var openStudent: (WorkspaceStudentResult) -> Void
    var openTeacher: (WorkspaceTeacherResult) -> Void
    var openClass: (WorkspaceClassResult) -> Void
    @FocusState private var isInputFocused: Bool

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        !trimmedQuery.isEmpty
    }

    private var filteredStudents: [WorkspaceStudentResult] {
        guard isSearching else { return [] }
        return studentResults.filter { item in
            item.name.localizedCaseInsensitiveContains(trimmedQuery)
                || item.phone.localizedCaseInsensitiveContains(trimmedQuery)
                || item.className.localizedCaseInsensitiveContains(trimmedQuery)
                || item.grade.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var filteredTeachers: [WorkspaceTeacherResult] {
        guard isSearching else { return [] }
        return teacherResults.filter { item in
            item.name.localizedCaseInsensitiveContains(trimmedQuery)
                || item.todayClasses.localizedCaseInsensitiveContains(trimmedQuery)
                || item.checkState.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var filteredClasses: [WorkspaceClassResult] {
        guard isSearching else { return [] }
        return classResults.filter { item in
            item.name.localizedCaseInsensitiveContains(trimmedQuery)
                || item.teacher.localizedCaseInsensitiveContains(trimmedQuery)
                || item.room.localizedCaseInsensitiveContains(trimmedQuery)
                || item.time.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var hasSearchResult: Bool {
        !filteredStudents.isEmpty || !filteredTeachers.isEmpty || !filteredClasses.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(JWColor.primary)

                    TextField("搜索学员 / 手机号 / 班级 / 老师", text: $query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 24, weight: .semibold))
                        .focused($isInputFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            appendHistory(query)
                            submit(query)
                        }

                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(JWColor.textMuted.opacity(0.75))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
                .frame(height: 74)
                .background(JWColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(JWColor.primary, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Button("取消") {
                    cancel()
                }
                .buttonStyle(.plain)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(JWColor.text)
            }

            HStack {
                Text("最近搜索")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Spacer(minLength: 0)
                Button {
                    recentSearches.removeAll()
                } label: {
                    Label("清空历史", systemImage: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                }
                .buttonStyle(.plain)
            }

            if recentSearches.isEmpty {
                Text("暂无搜索历史")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                LeftFlowLayout(spacing: 12, rowSpacing: 12) {
                    ForEach(recentSearches, id: \.self) { item in
                        Button {
                            query = item
                            submit(item)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(JWColor.textMuted)
                                Text(item)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(JWColor.text)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 48)
                            .background(JWColor.appBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .padding(.top, 6)

            if isSearching {
                resultPanel
            } else {
                HStack {
                    Spacer(minLength: 0)
                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted.opacity(0.85))
                    Text("可搜索学员、手机号、班级或老师，快速定位你需要的信息")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Spacer(minLength: 0)
                }

                Spacer(minLength: 0)

                HStack(spacing: 20) {
                    Spacer(minLength: 0)
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 54, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                    Text("按住 说出你要搜的内容")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                    Spacer(minLength: 0)
                }
                .frame(height: 102)
                .background(JWColor.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(JWColor.primary.opacity(0.18), lineWidth: 2)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onAppear {
            requestInputFocus()
        }
    }

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("搜索结果")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Spacer(minLength: 0)
                Text("学员 \(filteredStudents.count) · 老师 \(filteredTeachers.count) · 班级 \(filteredClasses.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }

            if !hasSearchResult {
                Text("没有找到“\(trimmedQuery)”相关结果")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if !filteredStudents.isEmpty {
                            resultSection(title: "学员", symbol: "person.2.fill") {
                                ForEach(filteredStudents) { item in
                                    Button {
                                        openStudent(item)
                                    } label: {
                                        HStack(alignment: .center, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(JWColor.text)
                                                Text("\(item.grade) · \(item.phone)")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(JWColor.textMuted)
                                            }
                                            Spacer(minLength: 0)
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(item.className)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(JWColor.text)
                                                Text(item.courseState)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundStyle(JWColor.primary)
                                            }
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 66)
                                        .background(JWColor.appBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !filteredTeachers.isEmpty {
                            resultSection(title: "老师", symbol: "person.crop.square.fill") {
                                ForEach(filteredTeachers) { item in
                                    Button {
                                        openTeacher(item)
                                    } label: {
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(JWColor.text)
                                                Text(item.todayClasses)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(JWColor.textMuted)
                                            }
                                            Spacer(minLength: 0)
                                            Text(item.checkState)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(item.checkState.contains("未") || item.checkState.contains("缺") ? JWColor.danger : JWColor.success)
                                                .padding(.horizontal, 10)
                                                .frame(height: 28)
                                                .background((item.checkState.contains("未") || item.checkState.contains("缺") ? JWColor.danger : JWColor.success).opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 62)
                                        .background(JWColor.appBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !filteredClasses.isEmpty {
                            resultSection(title: "班级", symbol: "book.closed.fill") {
                                ForEach(filteredClasses) { item in
                                    Button {
                                        openClass(item)
                                    } label: {
                                        HStack(alignment: .center, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name)
                                                    .font(.system(size: 17, weight: .bold))
                                                    .foregroundStyle(JWColor.text)
                                                    .lineLimit(1)
                                                Text("\(item.teacher) · \(item.room)")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(JWColor.textMuted)
                                            }
                                            Spacer(minLength: 0)
                                            Text(item.time)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(JWColor.primary)
                                        }
                                        .padding(.horizontal, 14)
                                        .frame(height: 62)
                                        .background(JWColor.appBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 6)
                }
            }
        }
    }

    private func requestInputFocus() {
        DispatchQueue.main.async {
            isInputFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            isInputFocused = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isInputFocused = true
        }
    }

    @ViewBuilder
    private func resultSection<Content: View>(title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(JWColor.text)
            }
            content()
        }
    }

    private func appendHistory(_ text: String) {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        recentSearches.removeAll { $0 == value }
        recentSearches.insert(value, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }
}

private struct LeftFlowLayout: Layout {
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
