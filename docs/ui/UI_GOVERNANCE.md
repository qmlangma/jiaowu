# UI Governance & Constraints (Current Baseline)

## 1. Goal & Scope
本规范用于约束当前项目（v1.5.1 起）UI 演进，保证：
- 首页（工作台）视觉一致、交互稳定、不回退；
- 新页面沿用同一套 token、间距、容器层级；
- 避免“临时样式”进入主干。

适用范围：`jiaowu/Features/**` 全部页面，优先覆盖 `AppShell + Workspace`。

## 2. Mandatory Workflow (Must Follow)
1. 需求阶段：先映射页面 Pattern（Dashboard / Table / Form / Master-Detail）。
2. 设计阶段：只允许使用 `DesignSystem.swift` 中的语义 token。
3. 开发阶段：先复用现有组件（`PrimaryButton`, `SecondaryButton`, `StatusBadge` 等），再考虑扩展。
4. 合并阶段：通过本文档 Checklist，不满足不得合并。

## 3. Shell-Level Hard Constraints
以 `jiaowu/Features/Shell/ContentView.swift` 当前实现为基线：
- 全局底色：`JWColor.appBackground`。
- 主结构：`Sidebar + MainContent`。
- 外层左右边距：`16`。
- 侧栏与主区间距：`16`（必须与外层左右边距一致）。
- 右侧主区：
  - 使用单一纵向滚动容器；
  - 不叠加额外“包裹容器背景”；
  - 不再对 `routeView` 增加额外水平内边距（避免主区被压窄）。

## 4. Workspace (首页) Hard Constraints
基于当前 `WorkspaceView + RoomMonitorView + RoomCardView`：

### 4.1 信息层级
- 单屏最多 3 层视觉层级（页面区块 / 卡片 / 行内元素）。
- 非状态型元素禁止使用高对比大色块背景。

### 4.2 课表教室区
- 楼层默认选中：`全部`。
- 页面允许纵向滚动；不得因局部手势导致滚动误触发筛选切换。
- 日期筛选（如 `05月13日`）容器样式需与其它筛选控件一致（灰色容器体系）。

### 4.3 教室卡片
- 卡片底色统一中性 `JWColor.surface`，不按状态铺大面积背景色。
- 状态颜色仅用于右上角状态标签（空教室可不显示标签）。
- 空教室 CTA：
  - `预约教室` 为大按钮；
  - 宽度铺满卡片内容区；
  - 位于卡片底部并保持与卡片内边距对齐；
  - 文案居中，不使用右箭头。
- 上课教室底部老师/助教信息区同样贴底，与空教室 CTA 底部节奏一致。

## 5. Interaction Constraints
- 避免双层纵向滚动竞争；页面主滚动优先。
- 可点击元素最小触控面积 `>= 44pt`。
- 次要可点击信息（如“已到学员”）可弱化视觉，但需保留明确点击反馈。
- 状态变化需即时反馈（toast 或状态文案变化）。

## 6. Token & Styling Constraints
- 禁止新增硬编码色值（调试代码除外，合并前必须移除）。
- 统一使用：`JWColor.primary/text/textMuted/surface/appBackground/divider/success/warning/danger`。
- 圆角、阴影、描边遵循“弱装饰”原则：
  - 卡片：弱阴影或无阴影；
  - 描边仅用于输入/弱按钮/可选项容器等交互对象。

## 7. PR Gate Checklist
- Token
  - [ ] 无新增硬编码颜色
  - [ ] 语义 token 使用正确
- Layout
  - [ ] 侧栏-主区间距与外层边距一致
  - [ ] 右侧主区无多余包裹背景/水平压窄
  - [ ] 不引入横向常态滚动
- Component
  - [ ] 主次按钮符合既定样式层级
  - [ ] 状态颜色仅用于状态表达，不用于大面积装饰
- Interaction
  - [ ] 页面纵向滚动顺畅，无误触发筛选
  - [ ] 可点击元素触控面积达标

## 8. Change Control
- 新增/修改页面若触及上述硬约束，必须先更新本文档再改代码。
- 临时偏离规范必须在 PR 中写明：偏离原因、影响范围、回收时间。

## 9. Ownership
- 规范 Owner：前端/UI 负责人
- 审核 Owner：功能负责人 + 设计评审人
- 交付 Owner：对应页面开发者
