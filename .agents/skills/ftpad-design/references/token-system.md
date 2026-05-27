# Token 体系参考

当任务需要建立完整 UI token 模型时使用本参考。实际落地时应根据目标技术栈调整命名，但必须保留 primitive -> semantic -> component 三层结构。

## 1. 架构

- Primitive tokens：原始值。产品页面不得直接使用。
- Semantic tokens：按用途命名的语义别名，供页面和组件使用。
- Component tokens：组件专属 token，由 semantic tokens 派生。

示例：

```css
--primitive-blue-600: #2563eb;
--color-action-primary: var(--primitive-blue-600);
--button-primary-bg: var(--color-action-primary);
```

## 2. Primitive 颜色 Token

必须先定义完整色阶，再定义语义颜色。

- Neutral：`neutral-0, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950`
- Brand primary：`primary-50 ... primary-950`
- Brand secondary / accent：`accent-50 ... accent-950`
- Success：`success-50 ... success-950`
- Warning：`warning-50 ... warning-950`
- Danger / Error：`danger-50 ... danger-950`
- Info：`info-50 ... info-950`
- Overlay：`overlay-scrim`、`overlay-backdrop`、`overlay-hover`
- Data visualization：`chart-1 ... chart-12`

色阶规则：

- `50-100`：浅色背景、选中弱状态。
- `200-300`：弱描边、非关键填充。
- `400-600`：图标、激活控件、图表标记。
- `700-900`：按压态、浅色背景上的可访问文本。
- `950`：高对比文字或深色表面。

## 3. Semantic 颜色 Token

按职责命名，不按色相命名。

Surface：

- `color-bg-page`
- `color-bg-surface`
- `color-bg-surface-muted`
- `color-bg-surface-raised`
- `color-bg-inverse`
- `color-bg-disabled`

Text：

- `color-text-primary`
- `color-text-secondary`
- `color-text-tertiary`
- `color-text-disabled`
- `color-text-inverse`
- `color-text-link`
- `color-text-link-hover`

Border：

- `color-border-subtle`
- `color-border-default`
- `color-border-strong`
- `color-border-focus`
- `color-border-danger`

Action：

- `color-action-primary`
- `color-action-primary-hover`
- `color-action-primary-pressed`
- `color-action-primary-disabled`
- `color-action-secondary`
- `color-action-secondary-hover`
- `color-action-danger`

Status：

- `color-status-success-bg`、`color-status-success-text`、`color-status-success-border`
- `color-status-warning-bg`、`color-status-warning-text`、`color-status-warning-border`
- `color-status-danger-bg`、`color-status-danger-text`、`color-status-danger-border`
- `color-status-info-bg`、`color-status-info-text`、`color-status-info-border`

Selection / Focus：

- `color-focus-ring`
- `color-selection-bg`
- `color-selection-text`
- `color-hover-bg`
- `color-active-bg`

Data：

- `color-chart-categorical-1 ... 12`
- `color-chart-positive`
- `color-chart-negative`
- `color-chart-neutral`
- `color-chart-reference-line`

## 4. 字体 Token

字体族：

- `font-family-sans`
- `font-family-serif`：仅在内容型或 editorial 场景需要时使用
- `font-family-mono`
- `font-family-number`：用于表格数据、金额、计数器等数字场景

字重：

- `font-weight-regular`: 400
- `font-weight-medium`: 500
- `font-weight-semibold`: 600
- `font-weight-bold`: 700

字号角色：

- `font-display-lg`：落地页 hero 或极少数首屏标题
- `font-display-md`
- `font-title-lg`：页面标题
- `font-title-md`：区块标题
- `font-title-sm`：卡片标题
- `font-body-lg`
- `font-body-md`
- `font-body-sm`
- `font-caption`
- `font-label`
- `font-code`
- `font-number-lg`
- `font-number-md`

每个字体角色必须声明 font family、size、weight、line height、letter spacing，以及必要的 paragraph spacing。

规则：

- App、后台、管理系统应使用克制的标题尺寸和清晰的信息层级。
- 数据密集型产品的数字列、KPI、计数器应使用 tabular/monospaced digits。
- 不使用 viewport width 缩放字号；响应式应通过布局变化解决。

## 5. 间距 Token

默认使用 4px / 4pt 基线，除非平台有更强的原生规范。

基础间距：

- `space-0`: 0
- `space-1`: 4
- `space-2`: 8
- `space-3`: 12
- `space-4`: 16
- `space-5`: 20
- `space-6`: 24
- `space-8`: 32
- `space-10`: 40
- `space-12`: 48
- `space-16`: 64
- `space-20`: 80
- `space-24`: 96

语义间距：

- `space-page-x`
- `space-page-y`
- `space-section-gap`
- `space-card-padding`
- `space-control-gap`
- `space-list-gap`
- `space-table-cell-x`
- `space-table-cell-y`
- `space-modal-padding`
- `space-sidebar-padding`

## 6. 尺寸 Token

控件：

- `size-control-xs`: 28-32
- `size-control-sm`: 36
- `size-control-md`: 40-44
- `size-control-lg`: 48
- `size-control-xl`: 56-64
- `size-touch-target-min`: 44

图标：

- `size-icon-xs`: 12
- `size-icon-sm`: 16
- `size-icon-md`: 20
- `size-icon-lg`: 24
- `size-icon-xl`: 32

布局：

- `size-sidebar-expanded`
- `size-sidebar-collapsed`
- `size-topbar-height`
- `size-sheet-width-sm`
- `size-sheet-width-md`
- `size-modal-width-sm`
- `size-modal-width-md`
- `size-content-max-width`

## 7. 圆角 Token

- `radius-none`: 0
- `radius-xs`: 2-4
- `radius-sm`: 6-8
- `radius-md`: 10-12
- `radius-lg`: 14-16
- `radius-xl`: 20-24
- `radius-2xl`: 28-32
- `radius-pill`: 999
- `radius-circle`: 50%

规则：

- 密集型企业工具优先使用较小圆角。
- Sheet、Modal、触屏卡片和移动端表面可使用较大圆角。
- 不为了装饰把圆角卡片嵌套在圆角卡片里，除非内部是重复项或输入类控件。

## 8. 描边 Token

- `border-width-none`
- `border-width-hairline`
- `border-width-default`
- `border-width-focus`
- `border-style-solid`
- `border-style-dashed`

描边适用于输入框、弱按钮、可选容器、表格分隔线、焦点态，以及背景层级不足时的卡片边界。

## 9. 阴影与层级 Token

- `shadow-none`
- `shadow-xs`：极弱表面分离
- `shadow-sm`：浅色 UI 中的卡片或小浮层
- `shadow-md`：下拉、搜索建议
- `shadow-lg`：Modal、Sheet、Drawer
- `shadow-xl`：少数阻塞型覆盖层

规则：

- 企业/后台产品优先弱阴影或无阴影。
- 浮层需要 shadow 与 z-index 同时定义。
- 除非产品风格明确要求，否则避免装饰性发光阴影。

## 10. 透明度 Token

- `opacity-disabled`: 0.35-0.50
- `opacity-muted`: 0.60-0.72
- `opacity-hover-overlay`: 0.04-0.08
- `opacity-pressed-overlay`: 0.08-0.14
- `opacity-selected-bg`: 0.08-0.16
- `opacity-scrim`: 0.22-0.48

## 11. Z-Index Token

- `z-base`: 0
- `z-sticky`: 100
- `z-dropdown`: 300
- `z-popover`: 500
- `z-toast`: 700
- `z-modal`: 900
- `z-debug`: 9999

## 12. 动效 Token

时长：

- `motion-duration-instant`: 0-75ms
- `motion-duration-fast`: 100-150ms
- `motion-duration-normal`: 180-250ms
- `motion-duration-slow`: 300-400ms

缓动：

- `motion-ease-standard`
- `motion-ease-out`
- `motion-ease-in`
- `motion-spring-soft`

规则：

- 大多数转场优先使用 opacity 和 transform。
- 数据密集型 App 避免制造布局跳动的动效。
- 尊重 reduced motion 设置。

## 13. 断点与密度 Token

断点：

- `breakpoint-xs`
- `breakpoint-sm`
- `breakpoint-md`
- `breakpoint-lg`
- `breakpoint-xl`
- `breakpoint-2xl`

密度：

- `density-compact`
- `density-comfortable`
- `density-spacious`

原生 App 应将断点映射到 size class、设备类型或窗口尺寸，而不是照搬 CSS 宽度。

## 14. 组件级 Token 示例

Button：

- `button-height-sm/md/lg`
- `button-padding-x-sm/md/lg`
- `button-radius`
- `button-primary-bg/text/border`
- `button-primary-hover-bg`
- `button-primary-pressed-bg`
- `button-disabled-bg/text`

Card：

- `card-bg`
- `card-radius`
- `card-padding`
- `card-border`
- `card-shadow`

Field：

- `field-height`
- `field-bg`
- `field-border`
- `field-focus-border`
- `field-placeholder-text`
- `field-radius`

Badge：

- `badge-height`
- `badge-padding-x`
- `badge-radius`
- `badge-success-bg/text`
- `badge-warning-bg/text`
- `badge-danger-bg/text`

Table：

- `table-header-bg`
- `table-header-text`
- `table-row-height`
- `table-row-hover-bg`
- `table-row-selected-bg`
- `table-cell-padding-x/y`
- `table-divider`

## 15. Token 输出格式

- Web：CSS custom properties。
- Tailwind：theme extension。
- 跨平台：JSON design tokens。
- SwiftUI：enum 或 static properties。
- Android：XML resources。
- Flutter：ThemeData extension。

如果用户要求实现指导，不要只把 token 写在说明文字里，必须给出可落地的结构。
