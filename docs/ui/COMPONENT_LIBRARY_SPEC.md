# Component Library Spec

## 1. Scope
本组件库规范覆盖：
- 基础组件（Button/Card/Badge/Chip/Field）
- 容器组件（Modal/SideSheet/Section/Header）
- 数据展示组件（TableHeader/TableRow/MetricCard/EmptyState）

实现基线文件：`jiaowu/DesignSystem.swift`

## 2. Component Tiers
- Tier A (Core): `PrimaryButton`, `SecondaryButton`, `AppCard`, `SearchField`
- Tier B (Workflow): `ModalShell`, `SideSheetShell`, `FilterChip`, `StatusBadge`
- Tier C (Page-specific): `TaskRow`, `OrderRow`, `ScheduleTable` 等业务组件

规则：Tier C 不得绕开 Tier A/B 直接写硬编码样式。

## 3. Core Components Contract

### 3.1 PrimaryButton
- 用途：页面主动作（每屏最多 1 个主按钮）。
- States：`enabled`, `disabled`, `pressed`.
- Constraints：
  - 高度 >= 44
  - 文本 + icon（可选）
  - `disabled` 必须降对比且不可点击

### 3.2 SecondaryButton
- 用途：次级动作、工具动作。
- 与主按钮视觉层级明确区分（填充强度更低）。

### 3.3 AppCard
- 用途：承载内容模块。
- 包含：背景、描边、圆角、弱阴影。
- 禁止在页面直接重复定义卡片阴影和边框。

### 3.4 SearchField
- 用途：统一搜索输入。
- 包含 leading icon + plain text field + 统一高度。

### 3.5 ModalShell / SideSheetShell
- 用途：流程弹窗、侧边抽屉。
- 必须包含：
  - 可见标题
  - 明确关闭入口
  - 背景遮罩
  - 安全可退出路径

## 4. Data Components Contract
- 表格 header 使用同一字体和对齐逻辑。
- 行组件必须支持：
  - 正常/选中/禁用态
  - 操作按钮的最小点击尺寸
  - 长文本截断策略（必要时显示完整信息入口）

## 5. State Rules
- Loading: 禁止“点击后无反馈”，按钮进入 disabled/loading。
- Empty: 必须用 `EmptyStateView` 或等价规范组件。
- Error: 错误提示需近场出现（字段附近或当前模块内）。
- Success: 统一 toast 或状态徽标。

## 6. Do / Don't
- Do:
  - 复用规范组件和 token。
  - 使用语义颜色而非页面硬编码。
  - 保持图标/文字节奏一致。
- Don't:
  - 新建页面时复制粘贴局部样式常量。
  - 同屏出现多种主按钮风格。
  - 用颜色单独表达状态（需文本/图标辅助）。

## 7. New Component Admission
新增组件必须满足：
1. 已验证无法用现有组件组合。
2. 给出 API 边界（属性、状态、交互）。
3. 提供最少一个页面落地示例。
4. 加入本规范并通过 UI review 才能复用。

