import SwiftUI

struct TeacherDetailPage: View {
    @Environment(AppStore.self) private var store
    var teacher: TeacherProfile
    var close: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("老师详情")
                        .font(.system(size: 44, weight: .bold))
                    Spacer(minLength: 0)
                    SecondaryButton(title: "钉住页面", systemImage: "pin") {}
                        .frame(width: 180)
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundStyle(JWColor.text)
                            .frame(width: 80, height: 52)
                            .background(JWColor.surface)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }

                headCard
                sectionCard("授课特点", icon: "person.2") {
                    FlowTagRow(tags: teacher.tags)
                }
                sectionCard("教学宣言", icon: "quote.opening") {
                    Text(teacher.motto)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(JWColor.text)
                        .padding(.horizontal, 18)
                        .frame(height: 84)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(JWColor.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                sectionCard("个人简介", icon: "person.text.rectangle") {
                    Text(teacher.bio)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(JWColor.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
        }
        .background(JWColor.appBackground)
    }

    private var headCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 160))
                    .foregroundStyle(JWColor.primary)
                    .frame(width: 260, height: 260)
                    .background(JWColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 14) {
                    Text("\(teacher.name)老师")
                        .font(.system(size: 46, weight: .bold))
                    HStack(spacing: 14) {
                        Label(teacher.phone, systemImage: "phone")
                        Divider().frame(height: 24)
                        Label("\(teacher.campus) / \(teacher.subjects) / \(teacher.department)", systemImage: "building.2")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)

                    HStack(spacing: 12) {
                        SecondaryButton(title: "查看课表", systemImage: "calendar") {
                            store.navigate(.schedule)
                        }
                        .frame(width: 200)
                        PrimaryButton(title: "拨打电话", systemImage: "phone.fill") {
                            store.openCallDrawer(role: .teacher, name: teacher.name, phone: teacher.phone)
                        }
                        .frame(width: 200)
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                metric("入职日期", teacher.onboardDate, "calendar")
                metric("教龄", teacher.yearsOfTeaching, "clock")
                metric("毕业院校", teacher.graduateSchool, "graduationcap")
                metric("授课学科", teacher.subjects, "laptopcomputer")
            }
            .frame(height: 140)
            .background(JWColor.surface)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(JWColor.divider))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(16)
        .background(JWColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func metric(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(JWColor.text)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            Rectangle().fill(JWColor.divider).frame(width: 1, height: 80)
        }
    }

    private func sectionCard<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(JWColor.text)
            content()
        }
        .padding(16)
        .background(JWColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct FlowTagRow: View {
    var tags: [String]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(JWColor.primaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer(minLength: 0)
        }
    }
}
