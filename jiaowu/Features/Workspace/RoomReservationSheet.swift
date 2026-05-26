import SwiftUI

struct RoomReservationSheet: View {
    @State var draft: RoomReservationDraft
    var close: () -> Void
    var submit: (RoomReservationDraft) -> Void

    private let purposes = ["临时接待", "入学测", "家长沟通", "内部会议", "其他"]

    var body: some View {
        SideSheetShell(title: "预约教室", subtitle: "\(draft.room) · \(draft.dateText) · \(draft.period)", close: close) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                formField(title: "教室", value: draft.room, symbol: "door.left.hand.open")
                formField(title: "日期", value: draft.dateText, symbol: "calendar")
                formField(title: "时段", value: draft.period, symbol: "clock")

                VStack(alignment: .leading, spacing: 10) {
                    Text("用途")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(JWColor.text)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(purposes, id: \.self) { purpose in
                            Button {
                                draft.purpose = purpose
                            } label: {
                                Text(purpose)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(draft.purpose == purpose ? .white : JWColor.text)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .background(draft.purpose == purpose ? JWColor.primary : JWColor.appBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                labeledTextField(title: "预约人", text: $draft.owner)
                labeledTextField(title: "备注", text: $draft.note)

                PrimaryButton(title: "提交预约", systemImage: "checkmark.circle.fill") {
                    submit(draft)
                }
                .frame(height: 52)
            }
        }
    }

    private func formField(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(JWColor.primary)
                .frame(width: 42, height: 42)
                .background(JWColor.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(JWColor.textMuted)
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(JWColor.text)
            }
            Spacer()
        }
        .padding(14)
        .background(JWColor.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func labeledTextField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(JWColor.text)
            TextField(title, text: text)
                .textFieldStyle(.plain)
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(JWColor.appBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
