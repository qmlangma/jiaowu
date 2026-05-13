import SwiftUI

struct StudentQuickDetailSheet: View {
    var student: WorkspaceStudentResult
    var close: () -> Void
    var enroll: () -> Void
    var assessment: () -> Void

    var body: some View {
        SideSheetShell(title: student.name, subtitle: "\(student.grade) · \(student.phone)", close: close) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                detailCard(title: "今日课程状态", value: student.courseState, symbol: "checkmark.seal.fill", tint: stateTint)
                detailCard(title: "所属班级", value: student.className, symbol: "rectangle.3.group.fill", tint: JWColor.primary)
                detailCard(title: "家长手机号", value: student.phone, symbol: "phone.fill", tint: JWColor.success)

                HStack(spacing: 12) {
                    PrimaryButton(title: "报名课程", systemImage: "graduationcap.fill", action: enroll)
                    SecondaryButton(title: "入学测报名", systemImage: "doc.text.magnifyingglass", action: assessment)
                }
                .frame(height: 52)
            }
        }
    }

    private var stateTint: Color {
        student.courseState.contains("未到") || student.courseState.contains("迟到") ? JWColor.warning : JWColor.success
    }

    private func detailCard(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.textMuted)
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(JWColor.text)
            }
            Spacer()
        }
        .padding(16)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
