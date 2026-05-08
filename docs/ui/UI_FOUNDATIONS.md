# iPadOS UI Foundations

## 1. Design Principles
- iPadOS native first: 优先使用系统语义和系统组件行为，不做“网页式”视觉拼贴。
- Light brand expression: 通过深蓝主题色和少量品牌视觉元素建立识别，不破坏原生感。
- Content clarity: 信息密度高的教务场景中，优先保证可读性与可扫描性。
- Single source of truth: 所有页面颜色、尺寸、圆角、阴影必须来自 `DesignSystem` token。

## 2. Token Architecture
- `Primitive`: 纯色值/基础尺寸（不可直接在页面中使用）。
- `Semantic`: 语义层（`brandPrimary`、`textPrimary`、`backgroundSurface` 等）。
- `Component`: 组件层（按钮、卡片、表格行的固定尺寸、圆角、内边距）。

## 3. Color Tokens (Deep Blue Theme)
- Brand:
  - `brandPrimary`: 深蓝主色（默认强调）
  - `brandPrimaryPressed`: 深一阶按压态
  - `brandPrimaryLight`: 浅蓝容器背景
- Surface:
  - `backgroundPage`: 页面底色
  - `backgroundSurface`: 卡片/面板底色
  - `backgroundSurfaceMuted`: 次级容器底色
- Text:
  - `textPrimary`: 主文本
  - `textSecondary`: 次文本
- Feedback:
  - `success`, `warning`, `danger`

## 4. Typography
- 基础字体：系统字体（SF Pro）。
- 层级：
  - Page title: 28/700
  - Section title: 20/700
  - Body primary: 16/400-500
  - Secondary/body meta: 14/400-500
  - Caption/badge: 12-13/600
- 数据列数字优先使用 `monospacedDigit()`。

## 5. Spacing & Layout
- 采用 4pt 基线，主要节奏：`4, 8, 12, 16, 20, 24, 32`。
- 组件最小点击尺寸：`44x44 pt`。
- iPad 主内容建议最大宽度通过容器约束，不做超宽拉伸。
- 避免双层滚动；主滚动区中仅允许必要局部滚动（如长表格）。

## 6. Radius, Border, Elevation
- Radius：
  - Small: 8-10
  - Medium: 12-14
  - Large sheet/card: 16-24
- Border: 默认 `1px` 使用 `divider` 语义色。
- Shadow:
  - 卡片：弱阴影（y=2~4）
  - 弹窗/抽屉：中等阴影（y=8~18）

## 7. Icon Rules (SF Symbols)
- 统一 SF Symbols，不混用第三方 icon 字体。
- 同一层级统一线重（regular/semibold）。
- 导航图标建议 18-20，列表功能图标 14-16，强调图标 24+。
- 图标与文字必须成对出现（功能按钮除非有明确可访问标签）。

## 8. Motion & Feedback
- 微动效 150-250ms，ease-out。
- 状态切换优先 opacity/transform，避免布局抖动。
- 提交类动作必须有即时反馈（loading/disabled/success toast）。

## 9. Accessibility Baseline
- 对比度达到 WCAG AA（普通文本 4.5:1）。
- 所有可点击元素 >= 44pt。
- 支持 Dynamic Type 不破版。
- 关键 icon-only 按钮需提供可访问标签。

