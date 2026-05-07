import SwiftUI

struct OrdersPageView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedStatus: OrderStatus = .paid
    @State private var showRefund = false
    @State private var selectedOrder: Order?

    private var rows: [Order] {
        store.orders.filter { $0.status == selectedStatus }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppCard {
                HStack {
                    Text("订单处理中心")
                        .font(.system(size: 22, weight: .bold))
                    Spacer()
                    Picker("", selection: $selectedStatus) {
                        ForEach(OrderStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 420)
                }
                .padding(.bottom, 6)

                ForEach(rows) { row in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.courseTitle)
                                .font(.system(size: 16, weight: .bold))
                            Text("\(store.studentName(row.studentID)) · ¥\(row.amount)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(JWColor.textMuted)
                        }
                        Spacer()
                        if row.status == .paid {
                            SecondaryButton(title: "发起退款", systemImage: "arrow.uturn.backward", tint: JWColor.danger) {
                                selectedOrder = row
                                store.beginRefundFlow()
                                showRefund = true
                            }
                        }
                    }
                    Divider()
                }
            }

            AppCard {
                Text("退款状态")
                    .font(.system(size: 18, weight: .bold))
                ForEach(RefundFlowState.allCases) { state in
                    StatusBadge(title: state.rawValue, tint: store.orderState.refundState == state ? JWColor.primary : JWColor.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: 260)
        }
        .overlay {
            if showRefund, let order = selectedOrder {
                RefundFlowModal(order: order) {
                    showRefund = false
                }
            }
        }
    }
}

private struct RefundFlowModal: View {
    @Environment(AppStore.self) private var store
    var order: Order
    var close: () -> Void
    @State private var reason = "课程退款"
    @State private var amount = "0"

    var body: some View {
        ModalShell(title: "退款流程", close: close) {
            VStack(alignment: .leading, spacing: 12) {
                Text("订单：\(order.courseTitle)")
                    .font(.system(size: 16, weight: .bold))
                Picker("原因", selection: $reason) {
                    ForEach(["课程退款", "线上课返利", "其他"], id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)
                TextField("金额", text: $amount)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    SecondaryButton(title: "校验", systemImage: "checkmark.shield") {
                        store.validateRefundFlow()
                    }
                    SecondaryButton(title: "审核确认", systemImage: "person.badge.shield.checkmark") {
                        store.confirmRefundFlow()
                    }
                    PrimaryButton(title: "提交退款", systemImage: "paperplane.fill") {
                        store.refund(orderID: order.id, reason: reason, type: "仅退款", amount: Int(amount) ?? 0, note: "")
                        store.submitRefundFlow()
                        close()
                    }
                }
            }
        }
    }
}
