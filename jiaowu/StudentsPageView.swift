import SwiftUI

struct StudentsPageView: View {
    @Environment(AppStore.self) private var store
    @State private var tab = "档案"
    @State private var searchText = ""
    @State private var showAdd = false

    private var filteredStudents: [Student] {
        if searchText.isEmpty { return store.students }
        return store.students.filter { $0.name.localizedStandardContains(searchText) || $0.number.contains(searchText) }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AppCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("学员目录")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(JWColor.primaryLight)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    SearchField(placeholder: "搜索学员", text: $searchText)
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredStudents) { student in
                                Button {
                                    store.selectedStudentID = student.id
                                } label: {
                                    HStack {
                                        Text(student.name)
                                            .font(.system(size: 16, weight: .bold))
                                        Spacer()
                                        Text(student.grade)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(JWColor.textMuted)
                                    }
                                    .padding(12)
                                    .background(store.selectedStudentID == student.id ? JWColor.primaryLight : JWColor.surfaceMuted)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .frame(width: 320)

            AppCard {
                HStack {
                    ForEach(["档案", "在读", "测评", "信用", "轨迹"], id: \.self) { item in
                        FilterChip(title: item, isSelected: tab == item) { tab = item }
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                if let student = store.selectedStudent {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(student.name)
                            .font(.system(size: 26, weight: .bold))
                        Text("编号 \(student.number) · \(student.phone)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(JWColor.textMuted)
                        studentTabContent(student: student)
                    }
                } else {
                    EmptyStateView(title: "请选择学员", systemImage: "person.crop.circle")
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .overlay {
            if showAdd {
                AddStudentQuickModal {
                    showAdd = false
                }
            }
        }
    }

    @ViewBuilder
    private func studentTabContent(student: Student) -> some View {
        switch tab {
        case "在读":
            ForEach(store.enrollments.filter { $0.studentID == student.id }) { enrollment in
                Text("在读课程：\(store.courses.first(where: { $0.id == enrollment.courseID })?.title ?? "-")")
            }
        case "测评":
            ForEach(student.testLevels) { level in
                Text("\(level.subject) · \(level.grade) · \(level.level)")
            }
        case "信用":
            ForEach(store.creditRecords.filter { $0.studentID == student.id }) { record in
                Text("\(record.delta > 0 ? "+" : "")\(record.delta)  \(record.title)")
            }
        case "轨迹":
            ForEach(store.attendanceRecords.filter { $0.studentID == student.id }) { record in
                Text("\(record.classTitle) · \(record.status)")
            }
        default:
            Text("学校：\(student.school)")
            Text("性别：\(student.gender.rawValue)")
            Text("信用分：\(student.creditScore)")
        }
    }
}

private struct AddStudentQuickModal: View {
    @Environment(AppStore.self) private var store
    @State private var name = ""
    @State private var phone = ""
    @State private var grade = "一年级"
    @State private var gender: Gender = .male
    var close: () -> Void

    var body: some View {
        ModalShell(title: "新增学员", close: close) {
            VStack(spacing: 12) {
                TextField("姓名", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("手机号", text: $phone)
                    .textFieldStyle(.roundedBorder)
                Picker("年级", selection: $grade) {
                    ForEach(["一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初一", "初二", "初三", "高一", "高二", "高三"], id: \.self, content: Text.init)
                }
                Picker("性别", selection: $gender) {
                    ForEach(Gender.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                HStack {
                    SecondaryButton(title: "取消", action: close)
                    PrimaryButton(title: "保存") {
                        store.addStudent(name: name, phone: phone, grade: grade, gender: gender)
                        close()
                    }
                }
            }
        }
    }
}
