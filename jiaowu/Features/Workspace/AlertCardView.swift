import SwiftUI

struct AlertCardView: View {
    var alert: WorkspaceAlert
    var openStudentDetailAction: () -> Void
    var contactAction: () -> Void
    var markAction: () -> Void
    var quickSignAction: () -> Void
    var rescheduleAction: () -> Void
    var transferAction: () -> Void
    private let actionButtonWidth: CGFloat = 96
    
    private var stateTint: Color {
        alert.isContacted ? JWColor.primary : alert.priority.tint
    }

    private var alertTimeText: String {
        alert.lateTime ?? alert.timeDetail
    }

    private var classSummary: String {
        let className = alert.className ?? "--"
        let classroom = (alert.classroom ?? "--") + "教室"
        let rawTeacher = alert.classTeacher ?? "--"
        let teacher = rawTeacher.hasSuffix("老师") ? rawTeacher : "\(rawTeacher)老师"
        return "\(className)·\(classroom)·\(teacher)"
    }

    private var studentTags: [StudentTag] {
        let grade = inferredGrade(from: alert.className) ?? alert.studentGrade ?? "年级未录入"
        let course = inferredSubject(from: alert.className) ?? alert.studentSubject ?? "学科未录入"

        return [
            StudentTag(title: grade, tint: JWColor.primary),
            StudentTag(title: course, tint: Color(red: 0.55, green: 0.39, blue: 0.95))
        ]
    }

    private func inferredGrade(from className: String?) -> String? {
        guard let className else { return nil }
        return ["幼中班", "幼大班", "一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "小升初", "初一", "初二", "初三", "高一", "高二", "高三"].first { className.contains($0) }
    }

    private func inferredSubject(from className: String?) -> String? {
        guard let className else { return nil }
        if className.contains("信息学算法") { return "信息学算法" }
        if className.contains("信息学实验P") || className.contains("实验P") { return "信息学实验P" }
        if className.contains("信息学实验C") || className.contains("实验C") { return "信息学实验C" }
        if className.contains("国文素养") { return "国文素养" }
        if className.contains("信息学语言传播") || className.contains("语言传播") { return "信息学语言传播" }
        if className.contains("图形化编程") { return "图形化编程" }
        if className.contains("Scratch") { return "Scratch" }
        if className.contains("机器人") { return "机器人" }
        if className.contains("Python") { return "Python" }
        if className.contains("C++") { return "C++" }
        if className.contains("逻辑思维") { return "逻辑思维" }
        if className.contains("思维") { return "思维训练" }
        if className.contains("算法") { return "算法" }
        return nil
    }

    private var signButtonTitle: String {
        alert.isSignedIn ? "已签到" : "签到"
    }

    private var signButtonSymbol: String {
        alert.isSignedIn ? "checkmark.circle.fill" : "checkmark.seal.fill"
    }

    private var isTeacherAlert: Bool {
        alert.category.contains("老师")
    }

    private var isAssistantAlert: Bool {
        alert.category.contains("助教")
    }

    private var staffContactButtonTitle: String {
        isAssistantAlert ? "联系助教" : "联系老师"
    }

    var body: some View {
        if alert.isStudentAlert {
            studentCard
        } else if isTeacherAlert || isAssistantAlert {
            absentStaffCard
        } else if alert.isStaffAlert {
            staffCard
        } else {
            defaultCard
        }
    }

    private var studentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: openStudentDetailAction) {
                            HStack(alignment: .center, spacing: 8) {
                                Text(alert.contactName)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(JWColor.text)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(JWColor.textMuted)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 0)

                    if !studentTags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(studentTags) { tag in
                                StudentTagView(tag: tag)
                            }
                        }
                    }
                }

                Text(alert.className ?? "--")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                    .lineLimit(1)

                HStack(alignment: .bottom, spacing: 16) {
                    if let contactNote = alert.contactNote, !contactNote.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(JWColor.primary)
                                .padding(.top, 2)
                            Text(contactNote)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(JWColor.text)
                                .lineLimit(2)
                        }
                        .padding(10)
                        .frame(maxWidth: 420, alignment: .leading)
                        .background(JWColor.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: 16) {
                        StudentActionButton(title: "联系家长", symbol: "phone.fill", tint: JWColor.primary, action: contactAction)
                            .frame(width: actionButtonWidth)
                        StudentActionButton(title: signButtonTitle, symbol: signButtonSymbol, tint: JWColor.success, action: quickSignAction)
                            .frame(width: actionButtonWidth)
                        StudentActionButton(title: "调课", symbol: "calendar.badge.clock", tint: JWColor.primary, action: rescheduleAction)
                            .frame(width: actionButtonWidth)
                        StudentActionButton(title: "转班", symbol: "arrow.left.arrow.right.circle.fill", tint: JWColor.warning, action: transferAction)
                            .frame(width: actionButtonWidth)
                    }
                }
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var absentStaffCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                avatarView

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(alert.contactName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(JWColor.text)

                        Text(alertTimeText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(JWColor.warning)
                    }

                    Text(alert.phone)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                }

                Spacer(minLength: 0)

                WorkspaceTinyButton(title: staffContactButtonTitle, symbol: "phone.fill", tint: JWColor.primary, action: contactAction)
            }

            classInfoRow
        }
        .padding(14)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var staffCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                avatarView

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(alert.contactName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(JWColor.text)
                        Text(alert.category)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(stateTint)
                            .padding(.horizontal, 8)
                            .frame(height: 20)
                            .background(stateTint.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(alert.detail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)

                    HStack(spacing: 10) {
                        Text(alert.phone)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(JWColor.primary)
                        Text("工号 \(alert.staffNumber ?? "--")")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                    }
                }
                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 6) {
                    PriorityIndicator(priority: alert.priority, isContacted: alert.isContacted)
                    Text(alertTimeText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(stateTint)
                        .multilineTextAlignment(.trailing)
                }
            }

            classInfoRow

            HStack(spacing: 8) {
                WorkspaceTinyButton(title: "拨打电话", symbol: "phone.fill", tint: stateTint, action: contactAction)
            }
        }
        .padding(14)
        .background(stateTint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var defaultCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                PriorityIndicator(priority: alert.priority, isContacted: alert.isContacted)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(alert.category)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(stateTint)
                        Text(alert.timeDetail)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(JWColor.textMuted)
                        if alert.isContacted {
                            Text("已联系")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(JWColor.primary)
                                .padding(.horizontal, 8)
                                .frame(height: 22)
                                .background(JWColor.primaryLight)
                                .clipShape(Capsule())
                        }
                    }
                    Text(alert.contactName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Text(alert.detail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Text(alert.phone)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.primary)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                WorkspaceTinyButton(title: alert.actionTitle, symbol: "phone.fill", tint: stateTint, action: contactAction)
                if alert.isContacted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("已联系")
                            .lineLimit(1)
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 40)
                    .background(JWColor.primaryLight)
                    .clipShape(Capsule())
                } else {
                    WorkspaceTinyButton(title: "标记已联系", symbol: "checkmark.circle.fill", tint: JWColor.success, action: markAction)
                }
            }
        }
        .padding(14)
        .background(stateTint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [JWColor.primary.opacity(0.22), JWColor.primary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(String(alert.contactName.prefix(1)))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(JWColor.primary)
        }
        .frame(width: 48, height: 48)
    }

    private var studentAvatarView: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [JWColor.primary.opacity(0.78), JWColor.primary.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(String(alert.contactName.prefix(1)))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
    }

    private var classInfoRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(classSummary)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(JWColor.text)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
    }
}

private struct StudentTag: Identifiable {
    var title: String
    var tint: Color

    var id: String { title }
}

private struct StudentTagView: View {
    var tag: StudentTag

    var body: some View {
        Text(tag.title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tag.tint)
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(tag.tint.opacity(0.1))
            .clipShape(Capsule())
    }
}

private struct StudentActionButton: View {
    var title: String
    var symbol: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(1)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(tint.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct PriorityIndicator: View {
    var priority: WorkspaceAlertPriority
    var isContacted: Bool

    var body: some View {
        VStack(spacing: 4) {
            if isContacted {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(priority.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 32, height: 32)
        .background(isContacted ? JWColor.primary : priority.tint)
        .clipShape(Circle())
    }
}
