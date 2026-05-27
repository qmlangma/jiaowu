import SwiftUI

struct TeacherDetailPage: View {
    @Environment(AppStore.self) private var store
    var teacher: TeacherProfile
    var close: () -> Void
    @State private var isDrawerVisible = false
    private let drawerAnimationDuration = 0.24

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .trailing) {
                Color.black.opacity(isDrawerVisible ? 0.30 : 0)
                    .ignoresSafeArea()
                    .onTapGesture(perform: dismissDrawer)

                VStack(spacing: 0) {
                    header
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            headCard
                            featureCard
                            bioCard
                        }
                        .padding(16)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                    }
                }
                .frame(width: 860)
                .frame(maxHeight: .infinity)
                .background(JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.16), radius: 30, x: -6, y: 0)
                .padding(.trailing, 12)
                .padding(.vertical, 10)
                .offset(x: isDrawerVisible ? 0 : 420)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.easeOut(duration: drawerAnimationDuration)) {
                    isDrawerVisible = true
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("老师详情")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(JWColor.text)
            Spacer(minLength: 0)
            Button(action: dismissDrawer) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
                    .accessibilityLabel("关闭")
            }
            .foregroundStyle(JWColor.text)
            .frame(width: 48, height: 48)
            .background(JWColor.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .frame(height: 72)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(JWColor.divider)
                .frame(height: 1)
        }
    }

    private var headCard: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 0) {
                teacherAvatar
                    .frame(width: 190, height: 244)
            }
            .frame(width: 190)
            .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(normalizedTeacherName(teacher.name))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(JWColor.text)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    PrimaryButton(title: "查看课表", systemImage: "calendar") {
                        store.navigate(.schedule)
                    }
                    .frame(width: 150)
                }

                HStack(spacing: 10) {
                    teacherMetaPill(icon: "phone.fill", text: maskedPhone(teacher.phone))
                    teacherMetaPill(icon: "building.2.fill", text: "\(teacher.campus) · \(teacher.department)")
                }

                HStack(spacing: 8) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(JWColor.primary)
                        .frame(width: 24, height: 24)
                        .background(JWColor.primaryLight)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    Text("毕业院校：\(teacher.graduateSchool)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(JWColor.appBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text("个人宣言")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(JWColor.textMuted)

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(JWColor.primary.opacity(0.72))
                            .padding(.top, 1)
                        Text(teacher.motto)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(JWColor.text)
                            .lineSpacing(4)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(JWColor.primary.opacity(0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [JWColor.primaryLight.opacity(0.50), JWColor.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(JWColor.primary.opacity(0.14), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var teacherAvatar: some View {
        Image("ZhangMingmingAvatar")
            .resizable()
            .scaledToFill()
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private func teacherMetaPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(JWColor.textMuted)
        .padding(.horizontal, 10)
        .frame(height: 34)
        .background(JWColor.appBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var featureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("授课特点", systemImage: "sparkles")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JWColor.text)
            FlowTagRow(tags: teacher.tags)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [JWColor.primaryLight.opacity(0.88), JWColor.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.primary.opacity(0.18)))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var bioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("个人简介", systemImage: "person.text.rectangle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JWColor.text)
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(JWColor.success)
                    .frame(width: 4)
                Text(bioRichText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(JWColor.text)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(JWColor.appBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(JWColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var bioRichText: AttributedString {
        let markdown = """
        **教学经历**：\(teacher.bio)

        **教学关键词**：\(teacher.tags.joined(separator: "、"))

        **沟通重点**：关注课堂反馈、阶段复盘与家校协同，帮助孩子稳定进步。
        """
        return (try? AttributedString(markdown: markdown)) ?? AttributedString(teacher.bio)
    }

    private func maskedPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 11 else { return phone }
        return "\(digits.prefix(3))****\(digits.suffix(4))"
    }

    private func normalizedTeacherName(_ name: String) -> String {
        name.hasSuffix("老师") ? name : "\(name)老师"
    }

    private func dismissDrawer() {
        guard isDrawerVisible else {
            close()
            return
        }
        withAnimation(.easeIn(duration: drawerAnimationDuration)) {
            isDrawerVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + drawerAnimationDuration) {
            close()
        }
    }
}

private struct FlowTagRow: View {
    var tags: [String]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.white.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(JWColor.primary.opacity(0.22), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}
