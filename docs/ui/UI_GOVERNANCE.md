# UI Governance & Review Checklist

## 1. Governance Goal
保证后续所有页面持续遵循 iPadOS 原生化规范，避免页面风格回退和组件分叉。
补充目标：在保证可用性的前提下，优先“减装饰、强信息”，避免无意义底色块堆叠。

## 2. Mandatory Workflow
1. 需求阶段：标注页面属于哪个 Pattern（登录/表格/主从/表单等）。
2. 设计阶段：只使用规范 token 和组件清单。
3. 开发阶段：优先复用 `DesignSystem` 组件，不得新增硬编码样式。
4. 合并阶段：通过 UI checklist；不满足则不合并。

## 3. PR Gate (Must Pass)
- Token:
  - 无新硬编码颜色（除临时调试）
  - 语义色替代直接色值
  - 非状态型元素（普通 icon 按钮、次要入口）默认不使用高对比实底
- Component:
  - 主按钮仅使用 `PrimaryButton` 规范实现
  - 弹窗/抽屉仅使用 `ModalShell` / `SideSheetShell` 或兼容封装
- Interaction:
  - 点击反馈完整（loading/disabled/success/error）
  - 核心流程有明确退出路径
- Accessibility:
  - 触控面积 >= 44pt
  - 颜色对比满足 AA
  - icon-only 控件有可访问标签

## 4. UI Review Checklist
- 视觉一致性
  - [ ] 同类组件外观一致
  - [ ] 图标线重和尺寸一致
  - [ ] 页面层级清晰（标题、模块、正文）
  - [ ] 次级操作底色弱化（优先透明/浅底+细描边）
  - [ ] icon-only 按钮无非必要背景底（仅在选中/危险/强提醒时加底）
- 交互一致性
  - [ ] 主次动作区分明确
  - [ ] 状态反馈统一
  - [ ] 弹窗和表单可取消/关闭
- 信息架构
  - [ ] 页面信息分区合理
  - [ ] 表格字段对齐、可读
  - [ ] 空态/异常态可理解

## 5. Versioning Rules
- 规范文件采用语义版本：
  - Major: 模式级变更（破坏兼容）
  - Minor: 新增组件或新页面模板
  - Patch: 文案和细节优化

## 6. Change Control
- 任何新增页面/组件先更新规范再写代码。
- 若业务紧急需临时偏离规范，必须在 PR 中记录偏离原因与回收计划。

## 7. Ownership
- 规范 owner：前端/UI 负责人
- 审核 owner：当前功能负责人 + 设计评审人
- 交付 owner：对应页面开发者
