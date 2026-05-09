import SwiftUI

enum JWPrimitive {
    static let blue900 = Color(red: 0.02, green: 0.12, blue: 0.41)
    static let blue800 = Color(red: 0.02, green: 0.22, blue: 0.58)
    static let blue700 = Color(red: 0.302, green: 0.561, blue: 0.969)
    static let blue600 = Color(red: 0.07, green: 0.49, blue: 0.92)
    static let blue500 = Color(red: 0.13, green: 0.61, blue: 1.00)
    static let blue100 = Color(red: 0.90, green: 0.95, blue: 1.00)
    static let blue050 = Color(red: 0.96, green: 0.98, blue: 1.00)

    static let gray950 = Color(red: 0.11, green: 0.15, blue: 0.23)
    static let gray700 = Color(red: 0.33, green: 0.40, blue: 0.53)
    static let gray400 = Color(red: 0.80, green: 0.84, blue: 0.90)
    static let gray200 = Color(red: 0.92, green: 0.95, blue: 0.98)
    static let gray100 = Color(red: 0.98, green: 0.99, blue: 1.00)
    static let gray000 = Color.white

    static let green500 = Color(red: 0.13, green: 0.63, blue: 0.41)
    static let orange500 = Color(red: 0.94, green: 0.57, blue: 0.17)
    static let red500 = Color(red: 0.84, green: 0.23, blue: 0.25)
}

enum JWSemanticColor {
    static let brandPrimary = JWPrimitive.blue700
    static let brandPrimaryPressed = JWPrimitive.blue800
    static let brandPrimaryLight = JWPrimitive.blue100

    static let backgroundPage = Color(red: 0.95, green: 0.96, blue: 0.99)
    static let backgroundSurface = JWPrimitive.gray000
    static let backgroundSurfaceMuted = JWPrimitive.blue100

    static let textPrimary = JWPrimitive.gray950
    static let textSecondary = JWPrimitive.gray700
    static let divider = JWPrimitive.gray200

    static let success = JWPrimitive.green500
    static let warning = JWPrimitive.orange500
    static let danger = JWPrimitive.red500
}

enum JWColor {
    static let appBackground = JWSemanticColor.backgroundPage
    static let surface = JWSemanticColor.backgroundSurface
    static let surfaceMuted = JWSemanticColor.backgroundSurfaceMuted
    static let primary = JWSemanticColor.brandPrimary
    static let primaryLight = JWSemanticColor.brandPrimaryLight
    static let accent = JWPrimitive.blue600
    static let text = JWSemanticColor.textPrimary
    static let textMuted = JWSemanticColor.textSecondary
    static let divider = JWSemanticColor.divider
    static let success = JWSemanticColor.success
    static let warning = JWSemanticColor.warning
    static let danger = JWSemanticColor.danger
    static let rail = JWPrimitive.blue100
}

struct AppCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(JWColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
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
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? JWColor.primary : JWColor.primary.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(minHeight: 42)
                .padding(.horizontal, 18)
                .background(tint.opacity(0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? JWColor.primary : JWColor.textMuted)
                .frame(minHeight: 36)
                .padding(.horizontal, 18)
                .background(isSelected ? JWColor.primaryLight : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(isSelected ? JWColor.primary.opacity(0.35) : JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    var title: String
    var tint: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
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
        HStack(alignment: .center) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(JWColor.text)
            Spacer(minLength: 0)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(JWColor.primary)
                    .buttonStyle(.plain)
            }
        }
        .frame(minHeight: 36, alignment: .leading)
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.12))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(JWColor.textMuted)
                    Text(value)
                        .font(.title2.weight(.bold))
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
        .frame(minHeight: 44)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
    }
}

struct ModalShell<Content: View>: View {
    var title: String
    var close: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.36)
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
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 36, x: 0, y: 18)
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
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 22))
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 22)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.14), radius: 30, x: -12, y: 0)
            .ignoresSafeArea(edges: .vertical)
        }
    }
}
