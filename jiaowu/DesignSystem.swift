import SwiftUI

enum JWColor {
    static let appBackground = Color(red: 0.95, green: 0.97, blue: 0.995)
    static let surface = Color.white
    static let surfaceMuted = Color(red: 0.92, green: 0.95, blue: 0.99)
    static let primary = Color(red: 0.19, green: 0.42, blue: 0.94)
    static let primaryLight = Color(red: 0.88, green: 0.93, blue: 1.0)
    static let accent = Color(red: 0.97, green: 0.56, blue: 0.23)
    static let text = Color(red: 0.11, green: 0.15, blue: 0.27)
    static let textMuted = Color(red: 0.44, green: 0.50, blue: 0.62)
    static let divider = Color(red: 0.83, green: 0.87, blue: 0.95)
    static let success = Color(red: 0.12, green: 0.60, blue: 0.39)
    static let warning = Color(red: 0.92, green: 0.55, blue: 0.16)
    static let danger = Color(red: 0.85, green: 0.24, blue: 0.25)
    static let rail = Color(red: 0.89, green: 0.93, blue: 0.99)
}

struct AppCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 6)
    }
}

struct PrimaryButton: View {
    var title: String
    var systemImage: String? = nil
    var isEnabled = true
    var role: ButtonRole?
    var action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 50)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? JWColor.primary : Color(red: 0.73, green: 0.84, blue: 0.91))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct SecondaryButton: View {
    var title: String
    var systemImage: String? = nil
    var tint: Color = JWColor.primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(minHeight: 50)
                .padding(.horizontal, 18)
                .background(tint.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct FilterChip: View {
    var title: String
    var isSelected = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? JWColor.primary : JWColor.textMuted)
                .frame(minHeight: 42)
                .padding(.horizontal, 18)
                .background(isSelected ? JWColor.primaryLight : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? JWColor.primary.opacity(0.35) : JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    var title: String
    var tint: Color

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .frame(minHeight: 28)
            .background(tint.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SectionTitle: View {
    var title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(JWColor.text)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(JWColor.primary)
                    .buttonStyle(.plain)
            }
        }
    }
}

struct EmptyStateView: View {
    var title: String = "当前暂无数据"
    var systemImage: String = "tray"

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(JWColor.primary.opacity(0.35))
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(JWColor.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var tint: Color = JWColor.primary
    var systemImage: String

    var body: some View {
        AppCard {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Text(value)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(JWColor.text)
                }
                Spacer()
            }
        }
    }
}

struct SearchField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(JWColor.textMuted)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ModalShell<Content: View>: View {
    var title: String
    var close: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.38)
                .ignoresSafeArea()
                .onTapGesture(perform: close)
            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(JWColor.textMuted)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                content
            }
            .padding(24)
            .frame(maxWidth: 620)
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.10), radius: 30, x: 0, y: 18)
            .padding(24)
        }
    }
}

struct SideSheetShell<Content: View>: View {
    var title: String
    var subtitle: String?
    var close: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture(perform: close)
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(JWColor.text)
                        if let subtitle {
                            Text(subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(JWColor.textMuted)
                        }
                    }
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(JWColor.textMuted)
                            .frame(width: 44, height: 44)
                            .background(JWColor.surfaceMuted)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(22)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(JWColor.divider).frame(height: 1)
                }

                ScrollView {
                    content
                        .padding(22)
                }
            }
            .frame(width: 520)
            .frame(maxHeight: .infinity)
            .background(JWColor.surface)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 18))
            .shadow(color: Color.black.opacity(0.16), radius: 28, x: -12, y: 0)
            .ignoresSafeArea(edges: .vertical)
        }
    }
}
