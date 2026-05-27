import SwiftUI

struct ToolboxSheet: View {
    var items: [ToolboxItem]
    var close: () -> Void
    var select: (ToolboxItem) -> Void

    var body: some View {
        SideSheetShell(title: "工具箱", subtitle: "订单、退款、调课、转班等售后能力", close: close) {
            VStack(spacing: AppSpacing.small) {
                ForEach(items) { item in
                    Button { select(item) } label: {
                        HStack(spacing: 14) {
                            Image(systemName: item.symbol)
                                .font(.system(size: 21, weight: .semibold))
                                .foregroundStyle(JWColor.primary)
                                .frame(width: 50, height: 50)
                                .background(JWColor.primary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            VStack(alignment: .leading, spacing: 5) {
                                Text(item.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(JWColor.text)
                                Text("\(item.pendingCount) 个待处理")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(JWColor.textMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(JWColor.textMuted)
                        }
                        .padding(16)
                        .background(JWColor.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
