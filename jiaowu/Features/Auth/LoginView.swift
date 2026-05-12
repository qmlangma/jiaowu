import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

private enum JWQRCode {
    static func image(from string: String, dimension: CGFloat) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let outputImage = filter.outputImage else { return nil }
        let scale = dimension / outputImage.extent.width
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

private struct JWQRCodeView: View {
    var payload: String
    var dimension: CGFloat = 280

    var body: some View {
        Group {
            if let ui = JWQRCode.image(from: payload, dimension: dimension) {
                Image(uiImage: ui)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dimension, height: dimension)
            }
        }
    }
}

struct LoginView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private func onDingTalkScanSucceeded() {
        store.completeLoginAfterScan()
    }

    var body: some View {
        ZStack {
            LoginBackdrop()
            if horizontalSizeClass == .regular {
                HStack(spacing: 0) {
                    LoginBrandPanel()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    LoginActionPanel(onScanSucceeded: onDingTalkScanSucceeded)
                        .frame(width: 450)
                }
                .padding(.horizontal, 42)
                .padding(.vertical, 26)
            } else {
                VStack(spacing: 10) {
                    LoginBrandPanel()
                        .frame(maxHeight: 280)
                    LoginActionPanel(onScanSucceeded: onDingTalkScanSucceeded)
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
        }
        .ignoresSafeArea()
    }
}

private struct LoginBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.17, blue: 0.52),
                    Color(red: 0.08, green: 0.31, blue: 0.70),
                    JWColor.primary,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 520, height: 520)
                .rotationEffect(.degrees(22))
                .offset(x: -220, y: -260)
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 420, height: 420)
                .rotationEffect(.degrees(-18))
                .offset(x: 260, y: 220)
        }
    }
}

private struct LoginBrandPanel: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 560, height: 560)
                .offset(x: -210, y: 100)

            VStack(alignment: .leading, spacing: 14) {
                Image("LoginLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.42), lineWidth: 1)
                    )
                Text("时光胶囊-原型")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)
                Text("课表、学员、测评、订单一体化管理")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.72))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 42)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LoginActionPanel: View {
    var onScanSucceeded: () -> Void
    private let qrPayload = "https://login.dingtalk.com/oauth2/challenge?state=jiaowu-placeholder"

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 34) {
                VStack(spacing: 6) {
                    Text("钉钉扫码登录")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    Text("请使用钉钉扫描二维码登录")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(JWColor.primary.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                        .frame(width: 312, height: 312)
                    JWQRCodeView(payload: qrPayload, dimension: 274)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(JWColor.divider))
                        .onTapGesture { onScanSucceeded() }

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, JWColor.primary.opacity(0.58), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 320, height: 4)
                        .blur(radius: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted.opacity(0.7))
                Text("登录即表示同意")
                    .foregroundStyle(JWColor.textMuted.opacity(0.75))
                Text("《用户协议》")
                    .foregroundStyle(JWColor.primary.opacity(0.85))
                Text("和")
                    .foregroundStyle(JWColor.textMuted.opacity(0.75))
                Text("《隐私政策》")
                    .foregroundStyle(JWColor.primary.opacity(0.85))
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.72), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: 12)
    }
}
