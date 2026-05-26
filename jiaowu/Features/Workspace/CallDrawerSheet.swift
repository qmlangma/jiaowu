import SwiftUI
import Combine

struct CallDrawerSheet: View {
    private enum CallMethod: String {
        case qr = "扫码拨打"
        case landline = "座机拨打"
    }

    @Environment(AppStore.self) private var store

    @State private var recordCall = false
    @State private var recordingSeconds = 0
    @State private var callResult: String?
    @State private var selectedMethod: CallMethod = .qr
    @State private var landlineNumber = ""
    @State private var isFloatingCollapsed = false
    @State private var selectedContactID: UUID?
    @State private var floatingOffset: CGSize = .zero
    @State private var floatingDragStart: CGSize = .zero
    @State private var syncNoteToStudentProfile = false
    @State private var isDrawerVisible = false
    private let drawerAnimationDuration = 0.24

    private let recordingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var context: CallDrawerContext

    private var noteBinding: Binding<String> {
        Binding(
            get: { store.callDrawer?.note ?? context.note },
            set: { store.callDrawer?.note = $0 }
        )
    }

    private var trimmedLandlineNumber: String {
        landlineNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canDialWithLandline: Bool {
        !trimmedLandlineNumber.isEmpty
    }

    private var canSaveRecord: Bool {
        callResult != nil
    }

    private var shouldShowRecordingFile: Bool {
        !recordCall && recordingSeconds > 0
    }

    private var phoneContacts: [CallContactPhone] {
        if context.contactPhones.isEmpty {
            return [CallContactPhone(relation: context.role.rawValue, phone: context.phone, isPrimary: true)]
        }
        return context.contactPhones
    }

    private var activeContact: CallContactPhone {
        if let selectedContactID, let selected = phoneContacts.first(where: { $0.id == selectedContactID }) {
            return selected
        }
        if let primary = phoneContacts.first(where: \.isPrimary) {
            return primary
        }
        return phoneContacts[0]
    }

    private var isStudentRole: Bool {
        context.role == .student
    }

    private var activePhoneDisplay: String {
        if isStudentRole {
            return "\(maskedPhone(activeContact.phone))（\(activeContact.relation)）"
        }
        return maskedPhone(activeContact.phone)
    }

    private var avatarInitial: String {
        let trimmed = context.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).isEmpty ? "?" : String(trimmed.prefix(1))
    }

    private var normalizedAvatarURL: URL? {
        guard let avatarURL = context.avatarURL?.trimmingCharacters(in: .whitespacesAndNewlines), !avatarURL.isEmpty else {
            return nil
        }
        return URL(string: avatarURL)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                if isFloatingCollapsed {
                    floatingBubble
                        .position(
                            x: geo.size.width - 74 + floatingOffset.width,
                            y: geo.size.height - 74 + floatingOffset.height
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let proposed = CGSize(
                                        width: floatingDragStart.width + value.translation.width,
                                        height: floatingDragStart.height + value.translation.height
                                    )
                                    floatingOffset = clampedFloatingOffset(proposed, in: geo.size)
                                }
                                .onEnded { _ in
                                    floatingDragStart = floatingOffset
                                }
                        )
                        .onTapGesture {
                            isFloatingCollapsed = false
                            floatingOffset = .zero
                            floatingDragStart = .zero
                        }
                } else {
                    Color.black.opacity(isDrawerVisible ? 0.30 : 0)
                        .ignoresSafeArea()
                        .onTapGesture { dismissDrawer() }

                    VStack(spacing: 0) {
                        header
                        content
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onReceive(recordingTimer) { _ in
            guard recordCall else { return }
            recordingSeconds += 1
        }
        .onAppear {
            syncSelectedContactIfNeeded()
            withAnimation(.easeOut(duration: drawerAnimationDuration)) {
                isDrawerVisible = true
            }
        }
        .onChange(of: context.id) { _, _ in
            syncSelectedContactIfNeeded(forceReset: true)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("拨打电话")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(JWColor.text)
            Spacer(minLength: 0)
            headerIconButton("arrow.down.right.and.arrow.up.left", label: "浮窗") {
                isFloatingCollapsed = true
                floatingOffset = .zero
                floatingDragStart = .zero
            }
            headerIconButton("xmark", label: "关闭") {
                dismissDrawer()
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 72)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(JWColor.divider)
                .frame(height: 1)
        }
    }

    private var content: some View {
        VStack(spacing: 12) {
            profileCard
            dialMethodCard
            callResultCard
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            avatarView

            Text(context.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(JWColor.text)
                .lineLimit(1)

            Text(context.role.rawValue)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(JWColor.primary)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(JWColor.primaryLight)
                .clipShape(Capsule())

            if isStudentRole {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(phoneContacts) { contact in
                            contactPhoneButton(contact)
                        }
                    }
                }
                .frame(maxWidth: 420)
            } else {
                Text(activePhoneDisplay)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 72)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var avatarView: some View {
        Group {
            if let avatarURL = normalizedAvatarURL {
                AsyncImage(url: avatarURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        initialAvatarView
                    }
                }
            } else {
                initialAvatarView
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var initialAvatarView: some View {
        ZStack {
            Circle().fill(JWColor.primary.opacity(0.18))
            Text(avatarInitial)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(JWColor.primary)
        }
    }

    private var dialMethodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                methodTab(title: CallMethod.qr.rawValue, method: .qr)
                methodTab(title: CallMethod.landline.rawValue, method: .landline)
            }

            Group {
                if selectedMethod == .qr {
                    qrDialContent
                } else {
                    landlineDialContent
                }
            }
        }
        .padding(14)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var qrDialContent: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .frame(width: 160, height: 160)
                .overlay(
                    Image(systemName: "qrcode")
                        .font(.system(size: 94, weight: .regular))
                        .foregroundStyle(.black)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )

            Text("请使用伴学田小程序扫码拨打")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(JWColor.text)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var landlineDialContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("1、请输入座机号")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.text)
                TextField("例如：0551-88886666", text: $landlineNumber)
                    .font(.system(size: 15, weight: .semibold))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .frame(height: 42)
                    .background(JWColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(JWColor.divider, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("2、拨打电话")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(JWColor.text)

                Button {
                    store.toast = "正在通过座机 \(trimmedLandlineNumber) 拨打 \(context.name) \(activePhoneDisplay)"
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                        Text("拨打电话")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(canDialWithLandline ? Color.white : JWColor.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(canDialWithLandline ? JWColor.primary : JWColor.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canDialWithLandline)
            }
        }
    }

    private var callResultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("通话结果")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Spacer(minLength: 0)
                if recordCall {
                    Label("已录制 \(recordingSeconds) s", systemImage: "waveform")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JWColor.success)
                    Button("停止录音") {
                        recordCall = false
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.danger)
                    .buttonStyle(.plain)
                } else {
                    Button {
                        recordingSeconds = 0
                        recordCall = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "mic.fill")
                            Text("开启录音")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(JWColor.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 8) {
                resultPill("已接通")
                resultPill("未接通")
                resultPill("拒接")
                resultPill("空号")
            }

            Text("通话备注")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(JWColor.text)
            if shouldShowRecordingFile {
                recordingFilePlaceholder
            }
            TextEditor(text: noteBinding)
                .font(.system(size: 14, weight: .medium))
                .frame(height: 74)
                .padding(8)
                .background(JWColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button {
                syncNoteToStudentProfile.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: syncNoteToStudentProfile ? "checkmark.square.fill" : "square")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(syncNoteToStudentProfile ? JWColor.primary : JWColor.textMuted)
                    Text("同步保存至学员详情备注内，方便其他老师查看")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(JWColor.textMuted)
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                PrimaryButton(title: "保存通话记录", isEnabled: canSaveRecord) {
                    guard let callResult else { return }
                    if syncNoteToStudentProfile {
                        store.toast = "已保存\(context.name)通话记录（\(callResult)），并同步至学员详情备注"
                    } else {
                        store.toast = "已保存\(context.name)通话记录（\(callResult)）"
                    }
                    dismissDrawer()
                }
            }
            .frame(height: 44)
        }
        .padding(14)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var recordingFilePlaceholder: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform.badge.mic")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JWColor.primary)
                .frame(width: 30, height: 30)
                .background(JWColor.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("通话录音20260501.mp3")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.text)
                Text("占位文件 · MP3")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(JWColor.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(JWColor.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(JWColor.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var floatingBubble: some View {
        ZStack {
            Circle()
                .fill(JWColor.surface)
            Circle()
                .stroke(JWColor.divider, lineWidth: 1)
            VStack(spacing: 4) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(JWColor.primary)
                Text("通话")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(JWColor.text)
                if recordCall {
                    Text("\(recordingSeconds)s")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(JWColor.success)
                }
            }
        }
        .frame(width: 96, height: 96)
        .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 6)
    }

    private func clampedFloatingOffset(_ proposed: CGSize, in size: CGSize) -> CGSize {
        let radius: CGFloat = 48
        let baseX = size.width - 74
        let baseY = size.height - 74
        let minX = radius
        let maxX = size.width - radius
        let minY = radius
        let maxY = size.height - radius

        let clampedX = min(max(baseX + proposed.width, minX), maxX)
        let clampedY = min(max(baseY + proposed.height, minY), maxY)
        return CGSize(width: clampedX - baseX, height: clampedY - baseY)
    }

    private func headerIconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 18, height: 18)
                .contentShape(Rectangle())
                .accessibilityLabel(label)
        }
        .foregroundStyle(JWColor.text)
        .frame(width: 44, height: 44)
        .background(JWColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .buttonStyle(.plain)
    }

    private func methodTab(title: String, method: CallMethod) -> some View {
        Button {
            selectedMethod = method
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(selectedMethod == method ? Color.white : JWColor.textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(selectedMethod == method ? JWColor.primary : JWColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func resultPill(_ title: String) -> some View {
        Button {
            callResult = title
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(callResult == title ? JWColor.primary : JWColor.text)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(callResult == title ? JWColor.primaryLight : JWColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(callResult == title ? JWColor.primary : JWColor.divider, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func contactPhoneButton(_ contact: CallContactPhone) -> some View {
        let isSelected = activeContact.id == contact.id
        return Button {
            selectedContactID = contact.id
        } label: {
            HStack(spacing: 6) {
                Text("\(maskedPhone(contact.phone))（\(contact.relation)）")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isSelected ? JWColor.primary : JWColor.textMuted)
                if contact.isPrimary {
                    Text("第一联系人")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isSelected ? JWColor.primary : JWColor.textMuted)
                        .padding(.horizontal, 6)
                        .frame(height: 20)
                        .background(isSelected ? JWColor.primaryLight : JWColor.surfaceMuted)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(isSelected ? JWColor.primaryLight : JWColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? JWColor.primary : JWColor.divider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func syncSelectedContactIfNeeded(forceReset: Bool = false) {
        if forceReset {
            selectedContactID = nil
        }
        if let selectedContactID, phoneContacts.contains(where: { $0.id == selectedContactID }) {
            return
        }
        selectedContactID = phoneContacts.first(where: \.isPrimary)?.id ?? phoneContacts.first?.id
    }

    private func maskedPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 11 else { return phone }
        let prefix = digits.prefix(3)
        let suffix = digits.suffix(4)
        return "\(prefix)****\(suffix)"
    }

    private func dismissDrawer() {
        guard isDrawerVisible else {
            store.closeCallDrawer()
            return
        }
        withAnimation(.easeIn(duration: drawerAnimationDuration)) {
            isDrawerVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + drawerAnimationDuration) {
            store.closeCallDrawer()
        }
    }
}
