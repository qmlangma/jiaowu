# 组件契约参考

当需要定义可复用 UI 组件，或检查组件一致性时使用本参考。

## 1. 组件分层

Tier A：基础组件

- Button
- IconButton
- TextField / SearchField
- Select / Picker
- Checkbox / Radio / Switch
- Badge / Tag / Chip
- Card
- Divider
- Tooltip
- Toast
- EmptyState
- LoadingIndicator

Tier B：流程组件

- Modal / Dialog
- Drawer / SideSheet
- Popover
- Tabs
- SegmentedControl
- FilterBar
- Pagination
- Stepper
- DatePicker
- CommandMenu
- UploadArea

Tier C：数据与业务组件

- DataTable
- TableHeader
- TableRow
- MetricCard
- ActivityRow
- NotificationItem
- Timeline
- Calendar / Schedule
- DetailPanel
- FormSection
- 业务专属 Card / Row

规则：Tier C 必须使用 Tier A/B 的 token 和基础能力，不得引入另一套视觉语言。

## 2. 组件规格必须包含的字段

每个可复用组件规格应包含：

- 用途
- 结构
- 变体
- 状态
- 尺寸
- token 映射
- 交互行为
- 无障碍要求
- 内容规则
- Do / Don't
- 使用示例

## 3. 通用状态

按组件需要支持以下状态：

- default
- hover
- focused
- active / pressed
- selected
- disabled
- loading
- error
- success
- empty
- skeleton

状态规则：

- Disabled 控件必须视觉弱化且不可交互。
- Loading 操作必须避免重复提交。
- Error 状态必须出现在失败字段或模块附近。
- Success 状态必须说明发生了什么。
- 不允许只靠颜色表达状态，必须配合文字、图标或形状。

## 4. Button 契约

用途：

- Primary button：每个流程区域的主动作。
- Secondary button：辅助动作。
- Tertiary / ghost button：低强调工具动作。
- Destructive button：不可逆或高风险动作。

约束：

- 最小触控目标：44px/pt。
- 文案不得溢出；仅在移动端全宽按钮中允许必要换行。
- 图标可选，但必须辅助表达动作含义。
- 同一个视觉组内不得出现多个 primary button。

必需 token：

- height
- padding x/y
- radius
- typography
- background/text/border by variant and state
- focus ring
- disabled opacity

## 5. Card 契约

用途：

- 组织相关内容或重复项。
- 不把 card 当作整页区块的装饰性外壳。

约束：

- 每张卡片只承担一个清晰职责。
- 避免 card inside card。
- 业务内容优先使用中性 surface。
- 除非卡片本身就是状态对象，否则状态色只用于小标记、徽标或局部强调。

必需 token：

- background
- radius
- padding
- border
- shadow
- title/body spacing

## 6. Field 与 Search 契约

约束：

- 必须有可见 label 或 accessible label。
- Placeholder 不能替代 label。
- 搜索框必须带搜索图标。
- Focus 状态必须清晰可见。
- 错误文案必须靠近字段。
- 清除按钮必须有 accessible label。

## 7. Badge、Tag、Chip 契约

- Badge：表达状态。
- Tag：表达元信息。
- Chip：表达可选筛选项或紧凑选项。

约束：

- 状态 Badge 必须同时具备文字和颜色。
- 可选 Chip 必须有选中和未选中状态。
- Chip 不得替代主按钮。
- 文案保持短。

## 8. Table 与 List 契约

约束：

- Header 与 Row 对齐逻辑必须一致。
- 数字列保持统一对齐，并使用 tabular digits。
- 行内操作放在右侧或明确操作区。
- 长文本必须截断，并提供查看完整内容的入口。
- 选中行状态必须明显。
- 表格密度应匹配产品类型。

## 9. Modal、Dialog、SideSheet 契约

约束：

- 必须有可见标题。
- 必须有明确关闭或取消路径。
- Overlay 必须使用 scrim 或空间层级进行区分。
- 主动作放在可预测的 footer 或固定操作区域。
- 破坏性动作必须使用清晰文案，必要时二次确认。

## 10. Navigation 与 Shell 契约

约束：

- 一级导航必须稳定。
- 当前路由状态必须可见。
- 全局搜索、账户、工作区控制不应在不同页面随意移动。
- 避免 shell 与 route content 形成嵌套滚动竞争。

## 11. 新组件准入

只有满足以下条件，才具备申请创建新的可复用组件的资格：

1. 现有组件无法表达该交互。
2. 该组件会在多个位置出现，或能隔离有意义的复杂度。
3. 已记录 API、变体、状态和 token 映射。
4. 至少有一个生产使用场景或真实示例。
5. UI 治理 checklist 已同步更新。

否则应优先局部组合现有组件。
