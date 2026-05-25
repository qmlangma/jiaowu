import SwiftUI

struct CallDrawerSheet: View {
    @Environment(AppStore.self) private var store
    @State private var recordCall = true
    @State private var callResult = "已接通"

    var context: CallDrawerContext

    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.30)
                .ignoresSafeArea()
                .onTapGesture { store.closeCallDrawer() }

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 16) {
                        profileCard
                        qrCard
                        callForm
                    }
                    .padding(18)
                }
            }
            .frame(width: 860)
            .frame(maxHeight: .infinity)
            .background(JWColor.surface)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 24))
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 24)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 34, x: -10, y: 0)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("拨打电话")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(JWColor.text)
            Spacer(minLength: 0)
            iconButton("arrow.up.left.and.arrow.down.right", title: "全屏")
            iconButton("pin", title: "钉住")
            Button {
                store.closeCallDrawer()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                    Text("关闭")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(JWColor.text)
                .frame(width: 96, height: 52)
                .background(JWColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 78)
        .overlay(alignment: .bottom) {
            Rectangle().fill(JWColor.divider).frame(height: 1)
        }
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(JWColor.appBackground)
                .frame(width: 158, height: 158)
                .overlay(
                    Image(systemName: context.role == .student ? "person.fill" : "person.crop.square")
                        .font(.system(size: 62, weight: .regular))
                        .foregroundStyle(JWColor.primary)
                )

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Text(context.name)
                        .font(.system(size: 24, weight: .bold))
                    Text(context.role.rawValue)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(JWColor.primary)
                        .padding(.horizontal, 10)
                        .frame(height: 36)
                        .background(JWColor.primaryLight)
                        .clipShape(Capsule())
                }
                HStack(spacing: 26) {
                    profileItem("手机号", context.phone)
                    if let number = context.studentNumber {
                        profileItem("学号", number)
                    }
                    if let grade = context.grade {
                        profileItem("年级", grade)
                    }
                    if let score = context.creditScore {
                        profileItem("信用分", "\(score)分")
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var qrCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                Text("请使用钉钉扫码拨打电话")
                    .font(.system(size: 20, weight: .bold))
            }
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .frame(width: 280, height: 280)
                .overlay(
                    Image(systemName: "qrcode")
                        .font(.system(size: 180, weight: .regular))
                        .foregroundStyle(.black)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )
            Text("扫码后将在钉钉中发起通话")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(JWColor.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var callForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("通话录音", systemImage: "mic")
                    .font(.system(size: 17, weight: .bold))
                Text("支持录音转文字")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
                Spacer(minLength: 0)
                Toggle("", isOn: $recordCall)
                    .labelsHidden()
                    .tint(JWColor.primary)
            }
            Divider()
            HStack(spacing: 10) {
                Text("通话结果")
                    .font(.system(size: 17, weight: .bold))
                resultPill("已接通")
                resultPill("未接通")
                resultPill("拒接")
                resultPill("空号")
                Spacer(minLength: 0)
            }
            Divider()
            Text("备注内容")
                .font(.system(size: 17, weight: .bold))
            TextEditor(text: Binding(
                get: { store.callDrawer?.note ?? context.note },
                set: { store.callDrawer?.note = $0 }
            ))
            .font(.system(size: 16, weight: .medium))
            .frame(minHeight: 126)
            .padding(10)
            .background(JWColor.appBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(JWColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 14) {
                SecondaryButton(title: "取消") { store.closeCallDrawer() }
                PrimaryButton(title: "保存记录") {
                    store.toast = "已保存\(context.name)通话记录（\(callResult)）"
                    store.closeCallDrawer()
                }
            }
            .frame(height: 56)
        }
        .padding(16)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func profileItem(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(JWColor.textMuted)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JWColor.text)
        }
    }

    private func iconButton(_ symbol: String, title: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(JWColor.text)
        .frame(width: 96, height: 52)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func resultPill(_ title: String) -> some View {
        Button {
            callResult = title
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(callResult == title ? JWColor.primary : JWColor.text)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(callResult == title ? JWColor.primaryLight : JWColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(callResult == title ? JWColor.primary : JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
