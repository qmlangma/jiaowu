import SwiftUI

struct WorkspaceSearchBar: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    var studentResults: [WorkspaceStudentResult]
    var classResults: [WorkspaceClassResult]
    var teacherResults: [WorkspaceTeacherResult]
    var selectStudent: (WorkspaceStudentResult) -> Void
    var selectClass: (WorkspaceClassResult) -> Void
    var selectTeacher: (WorkspaceTeacherResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                TextField("搜索学员 / 手机号 / 班级 / 老师", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 19, weight: .semibold))
                    .onTapGesture { isFocused = true }
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.leading, 18)
            .padding(.trailing, 8)
            .frame(height: 62)
            .background(JWColor.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isFocused ? JWColor.primary.opacity(0.45) : Color.clear, lineWidth: 2)
            )

            if isFocused {
                SearchSuggestionPanel(
                    studentResults: filteredStudents,
                    classResults: filteredClasses,
                    teacherResults: filteredTeachers,
                    selectStudent: { result in
                        isFocused = false
                        selectStudent(result)
                    },
                    selectClass: { result in
                        isFocused = false
                        selectClass(result)
                    },
                    selectTeacher: { result in
                        isFocused = false
                        selectTeacher(result)
                    }
                )
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.86), value: isFocused)
    }

    private var filteredStudents: [WorkspaceStudentResult] {
        guard !text.isEmpty else { return studentResults }
        return studentResults.filter { $0.name.contains(text) || $0.phone.contains(text) || $0.className.contains(text) }
    }

    private var filteredClasses: [WorkspaceClassResult] {
        guard !text.isEmpty else { return classResults }
        return classResults.filter { $0.name.contains(text) || $0.teacher.contains(text) || $0.room.contains(text) }
    }

    private var filteredTeachers: [WorkspaceTeacherResult] {
        guard !text.isEmpty else { return teacherResults }
        return teacherResults.filter { $0.name.contains(text) || $0.checkState.contains(text) }
    }
}

private struct SearchSuggestionPanel: View {
    var studentResults: [WorkspaceStudentResult]
    var classResults: [WorkspaceClassResult]
    var teacherResults: [WorkspaceTeacherResult]
    var selectStudent: (WorkspaceStudentResult) -> Void
    var selectClass: (WorkspaceClassResult) -> Void
    var selectTeacher: (WorkspaceTeacherResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SearchSectionTitle(title: "学员")
            ForEach(studentResults.prefix(3)) { result in
                Button { selectStudent(result) } label: {
                    SearchResultRow(
                        symbol: "person.fill",
                        title: result.name,
                        subtitle: "\(result.grade) · \(result.phone)",
                        trailing: result.courseState,
                        tint: result.courseState.contains("未到") || result.courseState.contains("迟到") ? JWColor.warning : JWColor.success
                    )
                }
                .buttonStyle(.plain)
            }

            SearchSectionTitle(title: "班级")
            ForEach(classResults.prefix(2)) { result in
                Button { selectClass(result) } label: {
                    SearchResultRow(
                        symbol: "rectangle.3.group.fill",
                        title: result.name,
                        subtitle: "\(result.teacher) · \(result.room)",
                        trailing: result.time,
                        tint: JWColor.primary
                    )
                }
                .buttonStyle(.plain)
            }

            SearchSectionTitle(title: "老师")
            ForEach(teacherResults.prefix(2)) { result in
                Button { selectTeacher(result) } label: {
                    SearchResultRow(
                        symbol: "person.badge.key.fill",
                        title: result.name,
                        subtitle: result.todayClasses,
                        trailing: result.checkState,
                        tint: result.checkState.contains("未") || result.checkState.contains("缺勤") ? JWColor.danger : JWColor.success
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: 12)
    }
}

private struct SearchSectionTitle: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(JWColor.textMuted)
    }
}

private struct SearchResultRow: View {
    var symbol: String
    var title: String
    var subtitle: String
    var trailing: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer(minLength: 0)
            Text(trailing)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(tint.opacity(0.10))
                .clipShape(Capsule())
        }
        .frame(minHeight: 50)
    }
}
