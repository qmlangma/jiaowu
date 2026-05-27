import SwiftUI

struct AlertCardView: View {
    var alert: WorkspaceAlert
    var contactAction: () -> Void
    var markAction: () -> Void
    var quickSignAction: () -> Void
    
    private var stateTint: Color {
        alert.isContacted ? JWColor.primary : alert.priority.tint
    }

    private var studentLateTime: String {
        alert.lateTime ?? alert.timeDetail
    }

    var body: some View {
        if alert.isStudentAlert {
            studentCard
        } else if alert.isStaffAlert {
            staffCard
        } else {
            defaultCard
        }
    }

    private var studentCard: some View {
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
                        Text("学号 \(alert.studentNumber ?? "--")")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                    }
                }
                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 6) {
                    PriorityIndicator(priority: alert.priority, isContacted: alert.isContacted)
                    Text(studentLateTime)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(stateTint)
                        .multilineTextAlignment(.trailing)
                }
            }

            classInfoRow

            HStack(spacing: 8) {
                WorkspaceTinyButton(title: "拨打电话", symbol: "phone.fill", tint: stateTint, action: contactAction)
                if alert.isContacted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("已签到")
                            .lineLimit(1)
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.success)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 40)
                    .background(JWColor.success.opacity(0.14))
                    .clipShape(Capsule())
                } else {
                    WorkspaceTinyButton(title: "签到", symbol: "checkmark.seal.fill", tint: JWColor.success, action: quickSignAction)
                }
            }
        }
        .padding(14)
        .background(stateTint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                    Text(studentLateTime)
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

    private var classInfoRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(JWColor.primary)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.className ?? "--")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.text)
                Text("老师：\(alert.classTeacher ?? "--") · 教室：\(alert.classroom ?? "--")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
