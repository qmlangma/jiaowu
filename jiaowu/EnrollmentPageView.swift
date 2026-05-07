import SwiftUI

struct EnrollmentPageView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedGrade = "全部"
    @State private var selectedType = "全部"
    @State private var selectedYear = "全部"
    @State private var selectedSubject = "全部"

    private var filteredCourses: [Course] {
        store.courses.filter { course in
            (selectedGrade == "全部" || course.grade == selectedGrade) &&
            (selectedType == "全部" || course.type == selectedType) &&
            (selectedYear == "全部" || course.year == selectedYear) &&
            (selectedSubject == "全部" || course.subject == selectedSubject)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            StepProgressBar(
                steps: EnrollmentStep.allCases.map(\.rawValue),
                activeStep: store.enrollmentState.step.rawValue
            )
            AppCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("流程报名")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        SecondaryButton(title: "重置流程", systemImage: "arrow.counterclockwise") {
                            store.updateEnrollmentStep(.filterCourse)
                            store.enrollmentState.qualification = .unknown
                        }
                    }
                    filterRow
                }
            }

            HStack(alignment: .top, spacing: 14) {
                AppCard {
                    SectionTitle(title: "1. 选课程", actionTitle: nil, action: nil)
                    VStack(spacing: 8) {
                        ForEach(filteredCourses) { course in
                            Button {
                                store.selectedCourseID = course.id
                                store.selectedClassID = course.classes.first?.id
                                store.updateEnrollmentStep(.chooseClass)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(course.title).font(.system(size: 16, weight: .bold))
                                        Text("\(course.type) · \(course.grade) · ¥\(course.price)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(JWColor.textMuted)
                                    }
                                    Spacer()
                                    Image(systemName: store.selectedCourseID == course.id ? "checkmark.circle.fill" : "circle")
                                }
                                .padding(12)
                                .background(JWColor.surfaceMuted)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                AppCard {
                    SectionTitle(title: "2. 选班级", actionTitle: nil, action: nil)
                    if let course = store.selectedCourse {
                        ForEach(course.classes) { klass in
                            Button {
                                store.selectedClassID = klass.id
                                store.updateEnrollmentStep(.chooseStudent)
                            } label: {
                                HStack {
                                    Text(klass.title).font(.system(size: 15, weight: .bold))
                                    Spacer()
                                    Text("\(klass.capacity - klass.enrolled) 个名额")
                                }
                                .padding(12)
                                .background(store.selectedClassID == klass.id ? JWColor.primaryLight : JWColor.surfaceMuted)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        EmptyStateView(title: "先选择课程", systemImage: "list.bullet")
                    }
                }
                AppCard {
                    SectionTitle(title: "3/4. 选学员并确认", actionTitle: nil, action: nil)
                    ForEach(store.students.prefix(6)) { student in
                        Button {
                            store.selectedStudentID = student.id
                            let result = store.evaluateQualification(studentID: student.id, course: store.selectedCourse)
                            store.updateEnrollmentStep(.confirm)
                            if result == .needDiagnostic {
                                store.sendFeedback("级别不足，建议先报名诊断测试", level: .warning)
                            }
                        } label: {
                            HStack {
                                Text(student.name)
                                Spacer()
                                if store.selectedStudentID == student.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(10)
                        }
                        .buttonStyle(.plain)
                    }
                    Divider()
                    PrimaryButton(title: "确认报名", systemImage: "checkmark.seal.fill", isEnabled: store.selectedStudentID != nil && store.selectedClassID != nil) {
                        if store.enrollmentState.qualification == .needDiagnostic {
                            store.sendFeedback("已走诊断分支并保留报名记录", level: .warning)
                        }
                        store.enrollSelectedStudent()
                    }
                }
            }
        }
    }

    private var filterRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("年级", selection: $selectedGrade) { ForEach(["全部", "一年级", "二年级", "三年级", "初一", "高三"], id: \.self, content: Text.init) }
            Picker("类型", selection: $selectedType) { ForEach(["全部", "寒假课", "春季课", "暑假课", "秋季课", "考试"], id: \.self, content: Text.init) }
            Picker("年度", selection: $selectedYear) { ForEach(["全部", "2027", "2026", "2025"], id: \.self, content: Text.init) }
            Picker("学科", selection: $selectedSubject) { ForEach(["全部", "信息学算法", "国文素养", "信息学实验P", "信息学实验C", "信息学语言传播"], id: \.self, content: Text.init) }
        }
    }
}
