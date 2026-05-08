import SwiftUI

struct StudentsView: View {
    @Environment(AppStore.self) private var store
    @State private var search = ""
    @State private var tab = "在读课程"
    @State private var showAddStudent = false
    @State private var showAddLevel = false
    @State private var showCredit = false

    var filteredStudents: [Student] {
        if search.isEmpty { return store.students }
        return store.students.filter { $0.name.localizedStandardContains(search) || $0.number.contains(search) || $0.phone.contains(search) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 14) {
                HStack {
                    Text("学员目录")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Button {
                        showAddStudent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(JWColor.primary)
                }
                SearchField(placeholder: "搜索学员、编号、手机号", text: $search)
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(filteredStudents) { student in
                            StudentListRow(student: student, selected: store.selectedStudentID == student.id) {
                                store.selectedStudentID = student.id
                            }
                        }
                    }
                }
            }
            .padding(14)
            .background(JWColor.surface)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .frame(width: 340)

            if let student = store.selectedStudent {
                VStack(spacing: 14) {
                    VStack(spacing: 12) {
                        StudentProfileHeader(student: student, showCredit: { showCredit = true }, showAddLevel: { showAddLevel = true })
                        HStack {
                            ForEach(["在读课程", "订单", "测试级别", "信用分", "记录"], id: \.self) { item in
                                FilterChip(title: item, isSelected: tab == item) { tab = item }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        StudentDetailTab(tab: tab, student: student)
                    }
                    .padding(16)
                    .background(JWColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
                }
                .frame(maxWidth: .infinity, alignment: .top)
            } else {
                EmptyStateView()
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

