import SwiftUI

struct AlertPanelView: View {
    var title: String = "异常提醒"
    var alerts: [WorkspaceAlert]
    var showSurnameIndex = false
    var collapse: () -> Void
    var contactAction: (WorkspaceAlert) -> Void
    var markAction: (WorkspaceAlert) -> Void
    var quickSignAction: (WorkspaceAlert) -> Void

    private var groupedAlerts: [AlertGroup] {
        guard showSurnameIndex else {
            return [AlertGroup(initial: nil, alerts: alerts)]
        }

        let sortedAlerts = alerts.sorted { lhs, rhs in
            let lhsInitial = lhs.contactName.surnameInitial
            let rhsInitial = rhs.contactName.surnameInitial
            if lhsInitial == rhsInitial {
                return lhs.contactName < rhs.contactName
            }
            if lhsInitial == "#" { return false }
            if rhsInitial == "#" { return true }
            return lhsInitial < rhsInitial
        }

        let bucket = Dictionary(grouping: sortedAlerts) { $0.contactName.surnameInitial }
        let sortedInitials = bucket.keys.sorted { lhs, rhs in
            if lhs == "#" { return false }
            if rhs == "#" { return true }
            return lhs < rhs
        }

        return sortedInitials.compactMap { initial in
            guard let sectionAlerts = bucket[initial], !sectionAlerts.isEmpty else { return nil }
            return AlertGroup(initial: initial, alerts: sectionAlerts)
        }
    }

    private var indexLetters: [String] {
        groupedAlerts.compactMap(\.initial)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(JWColor.warning)
                        .clipShape(Circle())
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(JWColor.text)
                }
                Spacer()
                Button(action: collapse) {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(JWColor.textMuted)
                        .frame(width: 34, height: 34)
                        .background(JWColor.appBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(JWColor.divider)
                    .frame(height: 1)
            }

            ScrollViewReader { proxy in
                HStack(alignment: .top, spacing: 8) {
                    ScrollView(showsIndicators: false) {
                        if alerts.isEmpty {
                            Text("暂无相关提醒")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(JWColor.textMuted)
                                .frame(maxWidth: .infinity, minHeight: 220, alignment: .center)
                        } else {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                ForEach(groupedAlerts) { group in
                                    if let initial = group.initial {
                                        Text(initial)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(JWColor.textMuted)
                                            .padding(.leading, 6)
                                            .id(group.anchorID)
                                    }

                                    VStack(spacing: AppSpacing.small) {
                                        ForEach(group.alerts) { alert in
                                            AlertCardView(
                                                alert: alert,
                                                contactAction: { contactAction(alert) },
                                                markAction: { markAction(alert) },
                                                quickSignAction: { quickSignAction(alert) }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if showSurnameIndex && !indexLetters.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(indexLetters, id: \.self) { letter in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.18)) {
                                        proxy.scrollTo("alert-index-\(letter)", anchor: .top)
                                    }
                                } label: {
                                    Text(letter)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(JWColor.textMuted)
                                        .frame(width: 22, height: 18)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(JWColor.appBackground)
                        .clipShape(Capsule())
                        .padding(.trailing, 2)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(JWColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.045), radius: 20, x: 0, y: 10)
    }
}

private struct AlertGroup: Identifiable {
    var initial: String?
    var alerts: [WorkspaceAlert]

    var id: String {
        initial.map { "section-\($0)" } ?? "section-default"
    }

    var anchorID: String {
        "alert-index-\(initial ?? "default")"
    }
}

private extension String {
    var surnameInitial: String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return "#" }

        let source = String(first)
        let latin = source.applyingTransform(.toLatin, reverse: false) ?? source
        let normalized = latin
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "zh_Hans_CN"))
            .replacingOccurrences(of: " ", with: "")
            .uppercased()

        guard let head = normalized.first, head.isASCII, head.isLetter else { return "#" }
        return String(head)
    }
}
