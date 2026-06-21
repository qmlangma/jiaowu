# AI / Developer UI Design Constraints

本文档用于把当前首页实际形态与既有 UI 文档转成可执行的开发约束，适用于人类开发者、AI 编码 Agent、设计走查与 PR Review。

## 1. 规范目标

- 保持当前 iPadOS 教务工作台的原生、清晰、低装饰风格。
- 让新页面、新组件优先复用 `DesignSystem` 与既有组件，不引入临时视觉体系。
- 给 AI 开发明确边界：先判断页面模式，再选 token / 组件 / 布局，不自由发挥“新皮肤”。
- 保护首页当前体验：搜索、快捷操作、课表教室、异常提醒、弹窗/侧滑详情的层级和交互不得回退。

## 2. 约束优先级

当文档、设计稿或代码之间出现冲突时，按以下顺序决策：

1. 当前可运行首页实现：`jiaowu/Features/Workspace/**`、`jiaowu/Features/Shell/ContentView.swift`。
2. 当前 token 和基础组件：`jiaowu/Core/UI/DesignSystem.swift`。
3. 当前 UI 规范：`docs/ui/UI_GOVERNANCE.md`、`UI_FOUNDATIONS.md`、`COMPONENT_LIBRARY_SPEC.md`、`PAGE_PATTERNS_SPEC.md`。
4. `DESIGN.md` 仅作为历史设计分析或视觉灵感参考；其中黑白 editorial / 大色块营销风格不得覆盖当前 iPadOS 教务系统规范。

## 3. 当前首页设计基线

首页是 `AppShell + WorkspaceView` 组合，不是营销首页。

### 3.1 Shell 基线

- 全局底色必须使用 `JWColor.appBackground`。
- 主结构固定为 `Sidebar + MainContent`。
- 外层水平边距为 `16`，侧栏与主内容间距为 `16`。
- 右侧主内容使用单一纵向滚动容器，不额外套背景卡片，不额外增加水平压缩。
- Toast 使用顶部居中胶囊样式，背景 `JWColor.text`，高度不低于 `44`。

### 3.2 Workspace 信息结构

当前首页从上到下为：

1. `WorkspaceHeaderView`
   - 页面标题、校区切换、设备/告警开关、全局搜索、异常提醒入口。
   - 下方 5 个概览指标卡，强调值 + 标签，数字使用 `monospacedDigit()`。
2. `QuickActionGridView`
   - 3 列快捷动作卡片。
   - 允许使用轻量浅色插画背景，但不得替代主内容层级。
3. `RoomMonitorView`
   - 课表教室核心区域，包含楼层筛选、隐藏空教室、日期、时段。
   - 3 列教室卡片，信息密度和可扫描性优先。
4. 叠加层
   - `AlertPanelView`：右侧异常提醒面板。
   - `RoomReservationSheet`、`StudentQuickDetailSheet`、`ClassSessionDetailSheet`：流程弹窗或侧滑详情。

### 3.3 首页视觉层级

- 单屏最多 3 层：页面区块 / 卡片 / 行内元素。
- 卡片不使用大面积状态色。状态色只用于徽标、图标、小面积反馈。
- 首页主要容器圆角偏大，典型值为 `24-28`；行内控件圆角为 `10-18` 或胶囊。
- 阴影必须弱，主要用于浮层、提醒面板、搜索建议；普通卡片优先无阴影或极弱阴影。

## 4. Token 使用规则

所有页面样式必须从 `DesignSystem.swift` 出发。

### 4.1 颜色

必须优先使用语义 token：

- 背景：`JWColor.appBackground`、`JWColor.surface`、`JWColor.surfaceMuted`
- 品牌与强调：`JWColor.primary`、`JWColor.primaryLight`、`JWColor.accent`
- 文本：`JWColor.text`、`JWColor.textMuted`
- 结构线：`JWColor.divider`
- 状态：`JWColor.success`、`JWColor.warning`、`JWColor.danger`

禁止：

- 在页面内新增硬编码品牌色、灰阶、状态色。
- 用 `Color.red`、`Color.green` 等系统裸色表达业务状态。
- 用渐变或高饱和大色块作为普通业务模块背景。

例外：

- 当前 `QuickActionGridView` 已存在的浅色渐变插画卡片可保留；新增快捷动作时应先抽象到组件或补充 token，不继续散落硬编码色值。
- 临时调试色必须在合并前删除。

### 4.2 字体

- 基础字体使用系统字体 SF Pro。
- 页面大标题：`34 / bold` 或既有页面标题标准。
- 区块标题：`24-26 / bold`。
- 卡片主标题：`17-22 / bold`。
- 正文：`15-17 / regular|semibold`。
- Meta / 标签：`12-14 / semibold|bold`。
- 数据和 KPI 数字必须使用 `monospacedDigit()`。
- 不引入自定义字体，不使用营销式超大 display 字号。

### 4.3 间距

- 使用 4pt 基线，优先值：`8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32`。
- 跨组件布局优先使用 `AppSpacing.small / medium / large / xlarge`。
- 触控目标不低于 `44x44 pt`。
- 网格间距与容器内边距要成体系：首页主网格常用 `16`，大容器内边距常用 `20-22`。

### 4.4 圆角与描边

- 页面级大容器：`24-28`。
- 卡片：`16-24`。
- 输入框、筛选器、行内容器：`10-20`。
- 胶囊按钮和徽标使用 `Capsule()`。
- 描边只用于输入框、筛选器、弱按钮、可选项、教室卡片边界。
- 描边颜色使用 `JWColor.divider`，可按层级降低 opacity。

## 5. 组件复用约束

### 5.1 组件优先级

新增 UI 时按以下顺序选择：

1. 复用 `DesignSystem.swift` 中已有基础组件。
2. 复用 `Features/Workspace` 中已形成的业务组件样式。
3. 在现有组件基础上扩展参数。
4. 新建组件，并同步补充本规范或组件库规范。

不得直接复制局部样式常量到新页面。

### 5.2 基础组件边界

- `PrimaryButton`
  - 用于主流程动作。
  - 每个流程区域最多一个强主按钮。
  - 高度不低于 `44`，可铺满容器宽度。
- `SecondaryButton`
  - 用于工具动作、次级动作。
  - 必须与主按钮形成明显层级差。
- `AppCard`
  - 用于承载业务内容模块。
  - 不在页面内重复定义同类卡片背景、圆角、阴影。
- `SearchField` / `WorkspaceSearchBar`
  - 搜索入口必须带放大镜图标。
  - 聚焦态必须有明确反馈。
  - 搜索建议面板应贴近输入框，不跳转到远处。
- `StatusBadge`
  - 只表达状态，不承载主要操作。
  - 状态颜色必须配合文案，不单靠颜色传达。
- `ModalShell` / `SideSheetShell`
  - 必须有标题、关闭入口、遮罩、安全退出路径。
  - 适合详情、预约、选择、确认流程，不做普通页面容器。

## 6. 首页特定约束

### 6.1 顶部工作台区

- `工作台` 标题保持首页第一视觉锚点。
- 校区切换使用浅蓝胶囊，不改为普通文本链接。
- 顶部图标按钮必须是 SF Symbols，尺寸稳定，不随文案撑开。
- 异常提醒入口允许使用更高强调，但红点只表示未读/待处理。
- 搜索框宽度在横屏首页保持稳定，不挤压标题与校区选择。

### 6.2 快捷动作区

- 保持 3 列网格。
- 卡片内部为“标题 + 副标题 + 右侧轻插画”结构。
- 副标题必须短，单行截断。
- 浅色背景用于动作分类，不表达紧急状态。
- 若新增第 4 个以上动作，优先换行，不压缩单卡最小高度。

### 6.3 课表教室区

- 这是首页核心工作区域，视觉权重不得低于快捷动作区。
- 标题为 `课表教室`，左侧筛选，右侧日期和时段。
- 楼层默认包含 `全部`，筛选容器使用灰色弱背景。
- 日期控件、楼层控件、时段控件必须属于同一“灰色容器体系”。
- 页面允许纵向滚动，但不得让局部横向手势干扰筛选。
- 教室卡片保持 3 列；竖屏或窄屏适配时可降为 2 列或 1 列，但不得出现常态横向滚动。

### 6.4 教室卡片

- 卡片底色统一 `JWColor.surface`。
- 空教室不显示右上状态徽标，避免无意义强调。
- 非空教室右上显示状态徽标，例如进行中、未开始。
- 课程名最多 2 行。
- 到课信息使用弱按钮样式，点击后进入学员名单/详情。
- 老师与助教信息贴底，和空教室 CTA 的底部节奏一致。
- 空教室 CTA 文案为 `预约教室`，按钮铺满卡片内容宽度，文案居中，不加右箭头。

### 6.5 异常提醒面板

- 从右侧进入，宽度保持稳定。
- 面板背景使用 `JWColor.surface`，圆角与首页大容器一致。
- 列表内部可滚动，但不得与主页面滚动产生明显竞争。
- 每条提醒必须提供联系、标记或关闭等明确处理路径。

## 7. 交互与状态

- 所有点击区域不低于 `44pt`；小图标也必须扩大可点范围。
- Loading 禁止无反馈，按钮需要 disabled/loading 或近场状态变化。
- Empty 必须使用 `EmptyStateView` 或同等级样式。
- Error 必须近场出现，不能只用 Toast 代替字段错误。
- Success 可以用 Toast 或状态徽标，但文案要明确发生了什么。
- 筛选、日期、时段切换应即时更新，不额外二次确认。
- 校区切换：选择其他校区后立即切换并关闭弹窗。
- 动效控制在 `150-250ms`，优先 opacity / transform，不制造布局抖动。

## 8. 可访问性与内容规则

- 普通文本对比度达到 WCAG AA。
- 图标按钮必须有明确语义；必要时增加 accessibility label。
- 不用颜色单独表达状态，必须有文字或图标辅助。
- 长文本必须 `lineLimit` 或提供详情入口，不能撑破卡片。
- iPad 横屏优先；竖屏允许降列、压缩侧栏、分段展示。
- 不允许把横向滚动作为常态阅读方式。

## 9. AI 开发执行流程

AI 修改或新增页面时必须按此流程执行：

1. 判断页面模式
   - 首页/工作台：Dashboard / Workspace。
   - 学员/订单：Master-Detail。
   - 课表/考勤/测评：Data Table。
   - 预约/选择/确认：Form / Modal / SideSheet。
2. 查找可复用组件
   - 先读 `DesignSystem.swift`。
   - 再读相近业务组件，例如 `RoomCardView`、`WorkspaceSearchBar`。
3. 选择 token
   - 颜色只用 `JWColor`。
   - 间距优先用 `AppSpacing` 或当前页面已有节奏。
4. 实现布局
   - 保持单一主滚动。
   - 保持 4pt 基线。
   - 保证触控面积。
5. 自查
   - 无新增硬编码色值。
   - 无重复卡片样式。
   - 无横向常态滚动。
   - 状态、空态、错误、成功有反馈。
   - 首页核心结构没有被重排成营销页。

## 10. AI Prompt 约束模板

当把需求交给 AI 开发时，可附加以下约束：

```text
请遵守本项目 UI 约束：
1. 以 jiaowu/Core/UI/DesignSystem.swift 为唯一 token 来源，颜色必须使用 JWColor。
2. 首页/工作台保持 AppShell + WorkspaceView 的 iPadOS 原生工作台风格，不做营销页、玻璃拟态、大面积渐变或新视觉皮肤。
3. 先复用 PrimaryButton、SecondaryButton、AppCard、SearchField、StatusBadge、ModalShell、SideSheetShell 等基础组件。
4. 页面保持单一主滚动，触控目标不低于 44pt，不引入常态横向滚动。
5. 状态色只用于徽标、图标、小面积反馈，不用于卡片大面积背景。
6. 新增组件需说明 API、状态、交互，并同步更新 UI 文档。
7. 修改完成后检查 docs/ui/AI_DEVELOPMENT_DESIGN_CONSTRAINTS.md 的 PR Gate。
```

## 11. PR Gate Checklist

提交前必须确认：

- [ ] 页面模式已匹配 `PAGE_PATTERNS_SPEC.md`。
- [ ] 无新增页面级硬编码颜色。
- [ ] 新增颜色、圆角、阴影已抽象到 token 或组件。
- [ ] 复用了现有基础组件，或说明了新增组件原因。
- [ ] 主滚动结构清晰，无双层滚动竞争。
- [ ] 可点击区域不低于 `44pt`。
- [ ] 状态色有文字/图标辅助。
- [ ] 空态、错误、成功、加载状态有明确反馈。
- [ ] 首页 `WorkspaceHeaderView -> QuickActionGridView -> RoomMonitorView` 顺序未被破坏。
- [ ] `RoomCardView` 的状态表达、底部 CTA / 老师助教信息节奏未回退。
- [ ] 竖屏或窄宽度下不出现常态横向滚动。
- [ ] 若偏离本规范，PR 中写明原因、影响范围、回收时间。

## 12. 禁止清单

- 禁止把当前产品改成营销落地页风格。
- 禁止引入新的主色、渐变品牌色或第三方图标系统。
- 禁止在每个页面复制一套卡片、按钮、徽标样式。
- 禁止状态色铺满整张业务卡片。
- 禁止用纯图标按钮表达关键业务动作且无语义说明。
- 禁止通过缩小字号解决信息过多问题；应调整信息层级或提供详情入口。
- 禁止为了视觉装饰增加双层卡片、嵌套卡片或多余容器背景。
