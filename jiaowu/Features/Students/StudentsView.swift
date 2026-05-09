import SwiftUI

struct StudentsView: View {
    @Environment(AppStore.self) private var store
    @State private var listSearch = ""
    @State private var detailTab = "在读课程"
    @State private var showDetailPage = false
    @State private var showAddStudent = false
    @State private var showAddLevel = false
    @State private var showCredit = false

    var filteredStudents: [Student] {
        if listSearch.isEmpty { return store.students }
        return store.students.filter { $0.name.localizedStandardContains(listSearch) || $0.number.contains(listSearch) || $0.phone.contains(listSearch) }
    }

    var body: some View {
        Group {
            if showDetailPage, let student = store.selectedStudent {
                StudentDetailPage(
                    student: student,
                    tab: $detailTab,
                    back: { showDetailPage = false },
                    showCredit: { showCredit = true },
                    showAddLevel: { showAddLevel = true }
                )
            } else {
                StudentListPage(
                    search: $listSearch,
                    students: filteredStudents,
                    addStudent: { showAddStudent = true },
                    openDetail: { student in
                        store.selectedStudentID = student.id
                        showDetailPage = true
                    }
                )
            }
        }
        .overlay {
            if showAddStudent {
                AddStudentModal(close: { showAddStudent = false })
            }
            if showAddLevel, let student = store.selectedStudent {
                AddLevelModal(student: student, close: { showAddLevel = false })
            }
            if showCredit, let student = store.selectedStudent {
                CreditModal(student: student, close: { showCredit = false })
            }
        }
    }
}

private struct StudentListPage: View {
    @Binding var search: String
    var students: [Student]
    var addStudent: () -> Void
    var openDetail: (Student) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("学员列表")
                    .font(.system(size: 38, weight: .bold))
                Spacer()
                PrimaryButton(title: "增加学员", systemImage: "plus", action: addStudent)
                    .frame(width: 138)
            }

            HStack(spacing: 10) {
                SearchField(placeholder: "搜索姓名 / 电话 / 编号", text: $search)
                Menu("年级  全部") {}
                    .menuStyle(.button)
                Menu("校区  全部") {}
                    .menuStyle(.button)
                Menu("状态  全部") {}
                    .menuStyle(.button)
            }
            .font(.system(size: 14, weight: .semibold))

            VStack(spacing: 0) {
                StudentTableHeaderRow()
                ForEach(students) { student in
                    StudentTableDataRow(student: student) {
                        openDetail(student)
                    }
                }
            }
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
        }
    }
}

private struct StudentDetailPage: View {
    var student: Student
    @Binding var tab: String
    var back: () -> Void
    var showCredit: () -> Void
    var showAddLevel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: back) {
                Label("返回学员列表", systemImage: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
            }
            .buttonStyle(.plain)

            VStack(spacing: 12) {
                StudentProfileHeader(student: student, showCredit: showCredit, showAddLevel: showAddLevel)
                HStack {
                    ForEach(["在读课程", "跟课记录", "订单记录", "测试级别", "信用分明细"], id: \.self) { item in
                        FilterChip(title: item, isSelected: tab == item) { tab = item }
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                StudentDetailTab(tab: mappedTab(tab), student: student)
            }
            .padding(16)
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
        }
    }

    private func mappedTab(_ tab: String) -> String {
        switch tab {
        case "跟课记录": return "记录"
        case "订单记录": return "订单"
        case "信用分明细": return "信用分"
        default: return tab
        }
    }
}

private struct StudentTableHeaderRow: View {
    var body: some View {
        HStack {
            Text("头像").frame(width: 70, alignment: .leading)
            Text("姓名").frame(width: 90, alignment: .leading)
            Text("性别").frame(width: 60, alignment: .leading)
            Text("年级").frame(width: 80, alignment: .leading)
            Text("学校").frame(width: 170, alignment: .leading)
            Text("电话").frame(width: 150, alignment: .leading)
            Text("信用分").frame(width: 80, alignment: .leading)
            Text("状态").frame(width: 70, alignment: .leading)
            Text("操作").frame(width: 70, alignment: .leading)
            Spacer()
        }
        .font(.system(size: 13, weight: .bold))
        .foregroundStyle(JWColor.textMuted)
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(JWColor.surfaceMuted.opacity(0.68))
    }
}

private struct StudentTableDataRow: View {
    var student: Student
    var open: () -> Void

    var body: some View {
        HStack {
            Image("DefaultAvatar")
                .resizable()
                .scaledToFill()
                .frame(width: 34, height: 34)
                .clipShape(Circle())
                .frame(width: 70, alignment: .leading)
            Text(student.name).frame(width: 90, alignment: .leading)
            Text(student.gender.rawValue).frame(width: 60, alignment: .leading)
            Text(student.grade).frame(width: 80, alignment: .leading)
            Text(student.school).frame(width: 170, alignment: .leading).lineLimit(1)
            Text(student.phone).frame(width: 150, alignment: .leading)
            Text("\(student.creditScore)").frame(width: 80, alignment: .leading)
            StatusBadge(title: "在读", tint: JWColor.success)
                .frame(width: 70, alignment: .leading)
            Button("查看", action: open)
                .font(.system(size: 14, weight: .bold))
                .frame(width: 70, alignment: .leading)
            Spacer()
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(JWColor.text)
        .padding(.horizontal, 14)
        .frame(height: 56)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
    }
}

struct StudentListRow: View {
    var student: Student
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(String(student.name.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(selected ? .white.opacity(0.18) : JWColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.name).font(.system(size: 16, weight: .bold))
                    Text("\(student.grade) · \(student.number)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selected ? .white.opacity(0.78) : JWColor.textMuted)
                }
                Spacer()
            }
            .foregroundStyle(selected ? .white : JWColor.text)
            .padding(12)
            .background(selected ? JWColor.primary : JWColor.surface)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? Color.clear : JWColor.divider))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct StudentProfileHeader: View {
    var student: Student
    var showCredit: () -> Void
    var showAddLevel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(String(student.name.prefix(1)))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(JWColor.primary)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(student.name)
                        .font(.system(size: 24, weight: .bold))
                    StatusBadge(title: student.grade, tint: JWColor.primary)
                    StatusBadge(title: student.gender.rawValue, tint: JWColor.textMuted)
                }
                HStack(spacing: 22) {
                    InfoPill(label: "NO", value: student.number)
                    InfoPill(label: "电话", value: student.phone)
                    InfoPill(label: "学校", value: student.school)
                    InfoPill(label: "信用", value: "\(student.creditScore)")
                }
            }
            Spacer()
            HStack(spacing: 10) {
                SecondaryButton(title: "信用明细", systemImage: "list.bullet.rectangle", action: showCredit)
                PrimaryButton(title: "添加成绩", systemImage: "plus", action: showAddLevel)
                    .frame(width: 130)
            }
        }
    }
}

private struct InfoPill: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(JWColor.textMuted)
            Text(value).font(.system(size: 15, weight: .bold)).foregroundStyle(JWColor.text)
        }
    }
}

private struct StudentDetailTab: View {
    @Environment(AppStore.self) private var store
    var tab: String
    var student: Student

    var body: some View {
        VStack(spacing: 12) {
            switch tab {
            case "在读课程":
                let rows = store.enrollments.filter { $0.studentID == student.id }
                if rows.isEmpty { EmptyStateView(title: "暂无在读课程") } else {
                    ForEach(rows) { enrollment in
                        RecordRow(title: store.courses.first { $0.id == enrollment.courseID }?.title ?? "课程", detail: "状态：\(enrollment.status) · 报名日期：\(enrollment.createdAt)", trailing: "修改  转班  退课")
                    }
                }
            case "订单":
                ForEach(store.orders.filter { $0.studentID == student.id }) { order in
                    RecordRow(title: order.courseTitle, detail: "\(order.classTitle) · \(order.paidAt)", trailing: order.status.rawValue)
                }
            case "测试级别":
                if student.testLevels.isEmpty { EmptyStateView(title: "暂无测试级别") } else {
                    ForEach(student.testLevels) { level in
                        RecordRow(title: "\(level.grade) · \(level.subject)", detail: "分数 \(level.score) · 级别 \(level.level)", trailing: level.source)
                    }
                }
            case "信用分":
                ForEach(store.creditRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: "\(record.delta > 0 ? "+" : "")\(record.delta)  \(record.title)", detail: record.dateText, trailing: record.canUndo ? "撤销" : "")
                }
            default:
                ForEach(store.attendanceRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: record.classTitle, detail: "\(record.time) · \(record.status)", trailing: record.hasVisit ? "已回访" : "添加回访")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(minHeight: 440, alignment: .top)
    }
}

private struct RecordRow: View {
    var title: String
    var detail: String
    var trailing: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(detail).font(.system(size: 14, weight: .medium)).foregroundStyle(JWColor.textMuted)
            }
            Spacer()
            if !trailing.isEmpty {
                Text(trailing)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.primary)
            }
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) { Rectangle().fill(JWColor.divider).frame(height: 1) }
    }
}

private struct AddStudentModal: View {
    @Environment(AppStore.self) private var store
    @State private var name = ""
    @State private var phone = ""
    @State private var grade = "一年级"
    @State private var gender: Gender = .male
    var close: () -> Void

    var body: some View {
        ModalShell(title: "新增学员", close: close) {
            VStack(spacing: 14) {
                TextField("姓名", text: $name).textFieldStyle(.roundedBorder)
                TextField("电话", text: $phone).textFieldStyle(.roundedBorder)
                Picker("年级", selection: $grade) {
                    ForEach(["一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "初二", "初三", "高一", "高二", "高三"], id: \.self, content: Text.init)
                }
                Picker("性别", selection: $gender) {
                    ForEach(Gender.allCases) { Text($0.rawValue).tag($0) }
                }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "保存学员") {
                        store.addStudent(name: name, phone: phone, grade: grade, gender: gender)
                        close()
                    }
                }
            }
        }
    }
}

private struct AddLevelModal: View {
    @Environment(AppStore.self) private var store
    var student: Student
    var close: () -> Void
    @State private var grade = "二年级"
    @State private var subject = "信息学算法"
    @State private var score = 80
    @State private var level = "A"

    var body: some View {
        ModalShell(title: "新增学员级别", close: close) {
            VStack(spacing: 14) {
                Picker("年级", selection: $grade) { ForEach(["一年级", "二年级", "三年级", "四年级", "五年级", "六年级"], id: \.self, content: Text.init) }
                Picker("学科", selection: $subject) { ForEach(["信息学算法", "信息学实验P", "信息学实验C", "信息学语言传播"], id: \.self, content: Text.init) }
                Stepper("分数：\(score)", value: $score, in: 0...100)
                Picker("级别", selection: $level) { ForEach(["A", "B", "C", "无"], id: \.self, content: Text.init) }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "保存") {
                        store.addLevel(to: student.id, grade: grade, subject: subject, score: score, level: level)
                        close()
                    }
                }
            }
        }
    }
}

private struct CreditModal: View {
    @Environment(AppStore.self) private var store
    var student: Student
    var close: () -> Void

    var body: some View {
        ModalShell(title: "信用分明细", close: close) {
            VStack(alignment: .leading, spacing: 12) {
                StatusBadge(title: "当前信用分 \(student.creditScore) 分", tint: JWColor.success)
                ForEach(store.creditRecords.filter { $0.studentID == student.id }) { record in
                    RecordRow(title: "\(record.delta > 0 ? "+" : "")\(record.delta)", detail: "\(record.dateText)  \(record.title)", trailing: record.canUndo ? "撤销" : "")
                }
            }
        }
    }
}

