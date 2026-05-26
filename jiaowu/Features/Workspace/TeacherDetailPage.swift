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
                            importantInfoCard
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
        VStack(spacing: 0) {
            Color.clear.frame(height: 20)

            HStack(alignment: .top, spacing: 16) {
                teacherAvatar
                    .frame(width: 212, height: 212)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 2)

                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top, spacing: 12) {
                        Text(normalizedTeacherName(teacher.name))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(JWColor.text)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                    HStack(spacing: 10) {
                        PrimaryButton(title: "查看课表", systemImage: "calendar") {
                            store.navigate(.schedule)
                        }
                        .frame(width: 150)

                        SecondaryButton(title: "拨打电话", systemImage: "phone.fill") {
                            store.openCallDrawer(role: .teacher, name: teacher.name, phone: teacher.phone)
                        }
                        .frame(width: 150)
                    }
                    }

                    HStack(spacing: 16) {
                        Label(maskedPhone(teacher.phone), systemImage: "phone.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                        Label("\(teacher.campus)/\(teacher.department)", systemImage: "building.2.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                            .lineLimit(1)
                    }

                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(JWColor.primary.opacity(0.7))
                            .padding(.top, 1)
                        Text(teacher.motto)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(JWColor.text)
                            .lineSpacing(4)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(JWColor.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(JWColor.divider, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            Color.clear.frame(height: 24)
        }
        .padding(.horizontal, 4)
    }

    private var teacherAvatar: some View {
        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=720&q=80")) { phase in
            switch phase {
            case let .success(image):
                image.resizable().scaledToFill()
            default:
                Image("DefaultAvatar")
                    .resizable()
                    .scaledToFill()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var importantInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                infoMetricCard(
                    title: "毕业院校",
                    value: teacher.graduateSchool,
                    symbol: "graduationcap.fill",
                    gradient: [Color(red: 0.99, green: 0.97, blue: 0.94), Color(red: 1.00, green: 0.93, blue: 0.88)],
                    accent: Color(red: 0.96, green: 0.55, blue: 0.20)
                )
                infoMetricCard(
                    title: "主授方向",
                    value: teacher.subjects,
                    symbol: "books.vertical.fill",
                    gradient: [Color(red: 0.95, green: 0.98, blue: 1.00), Color(red: 0.90, green: 0.95, blue: 1.00)],
                    accent: Color(red: 0.22, green: 0.50, blue: 0.95)
                )
            }
        }
        .padding(14)
        .background(JWColor.surface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(JWColor.divider))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.bottom, 6)
    }

    private func infoMetricCard(
        title: String,
        value: String,
        symbol: String,
        gradient: [Color],
        accent: Color
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 64, height: 64)
                .offset(x: 22, y: -18)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(accent.opacity(0.10))
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(20))
                .offset(x: -10, y: 10)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: symbol)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.textMuted)
                }

                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(JWColor.text)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.opacity(0.16), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
