# Page Patterns Spec

## 1. Global Shell Pattern
- 结构：`Sidebar + TopBar + MainContent`
- 侧栏负责一级导航，顶部栏负责全局搜索和上下文信息。
- 主内容区使用卡片化分组，避免大面积无结构留白。

## 2. Login Pattern
- 双栏布局：
  - 左：品牌主视觉（低频信息）
  - 右：扫码登录主任务（高优先）
- 登录成功流程：
  1. 进入首页
  2. 立即弹窗选择工作校区（默认不选中）
  3. 用户确认后进入可操作态

## 3. Dashboard / Workspace Pattern
- 顶部：核心 KPI 3-4 张指标卡
- 中部：今日场次 + 处理队列两栏布局
- 规则：信息优先级从左到右、从上到下递减

## 4. Master-Detail Pattern (Students / Orders)
- 左侧列表（可筛选）
- 右侧详情（tab 或分组）
- 行选择状态必须明显，支持快速切换不闪烁

## 5. Data Table Pattern (Schedule / Attendance / Assessment)
- 表头固定语义：字段名 + 对齐一致
- 行内操作放在右侧，数量控制在 2-4 个
- 多行信息（如多科目）保持纵向对齐，避免错位

## 6. Form & Modal Pattern
- 表单项分组展示（每组有标题）
- 错误文案紧贴字段
- 底部固定主按钮，次按钮靠左或弱化

## 7. Page-by-Page Constraints
- 工作台：不超过 3 层视觉层级
- 学员：列表与详情信息架构一致
- 选课：筛选区、课程卡、班级选择区分层明确
- 课表：行内状态与操作并列时保持等高与对齐
- 考勤/测评/订单：统一数据表风格，不另起“新皮肤”

## 8. Responsive & iPad Orientation
- 优先适配 iPad 横屏。
- 竖屏时：
  - 侧栏可压缩
  - 主内容可切单列分段
- 不允许横向滚动作为常态交互。

## 9. Pattern Mapping to Current Files
- 壳层与导航：`jiaowu/ContentView.swift` (`AppShell`, `SidebarView`, `TopBarView`)
- 基础组件：`jiaowu/DesignSystem.swift`
- 页面域：`WorkspaceView`, `StudentsView`, `CourseSelectionView`, `ScheduleView`, `AttendanceView`, `AssessmentView`, `OrdersView`

