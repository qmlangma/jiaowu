---
name: ftpad-design
description: 创建、审计或演进可复用的 UI 设计规范与设计系统。适用于 Codex 需要从现有产品中提炼 UI 规则、生成完整设计 token、定义组件契约、沉淀页面模式、编写 AI/开发约束、检查 UI 一致性，或产出可跨项目复用的设计治理文档与设计到代码交付说明。
---

# FtPad-design

## 概览

使用本 skill 将一个产品当前的 UI 形态转化为可复用、可执行、可审查的设计规范。输出结果应同时服务人类开发者和 AI 开发 Agent，让不同项目在开发 UI 时能保持一致，而不是每次都重新发明一套视觉系统。

## 工作流程

1. 先检查产品，再编写规则。
   - 读取已有 UI 文档、设计 token、组件文件、代表性页面和可用截图。
   - 识别真正的事实来源，并指出过期或互相冲突的文档。
2. 对产品界面分类。
   - 判断平台：Web、iOS/iPadOS、Android、桌面端、跨平台，或纯设计系统。
   - 判断产品类型：Dashboard、SaaS、后台管理、电商、内容站、作品集、移动工具、游戏或营销页。
   - 判断页面模式：壳层、工作台、主从详情、数据表格、表单/弹窗、编辑器/画布、详情页、认证、引导、设置。
3. 建立完整 token 模型。
   - 读取 `references/token-system.md`。
   - 定义 primitive、semantic、component 三层 token，覆盖颜色、字体、间距、尺寸、圆角、描边、阴影、透明度、层级、动效、断点、图标和密度。
4. 定义组件契约。
   - 读取 `references/component-contracts.md`。
   - 明确组件分层、状态、变体、结构、交互、无障碍和新增准入规则。
5. 定义页面模式。
   - 读取 `references/page-patterns.md`。
   - 映射信息层级、布局、响应式规则、滚动方式、空态/错误/加载/成功状态和导航模式。
6. 定义治理规则。
   - 读取 `references/governance.md`。
   - 产出评审门禁、AI 约束、变更控制和禁止模式。
7. 以项目可采用的格式交付。
   - 若产出可复用规范，使用 `references/output-template.md`。
   - 若修改代码仓库，在仓库内创建或更新文档，并从本地文档索引链接过去。
   - 将项目专属示例与通用规则清晰分离。

## 事实来源规则

- 当前可运行的 UI 实现优先于过期设计笔记。
- 项目设计 token 优先于页面局部常量。
- 既有可复用组件优先于新的视觉模式。
- 历史灵感文件、Figma 分析、截图、营销参考默认视为次级材料，除非用户明确指定其为权威来源。
- 当多个来源冲突时，记录冲突，并选择最符合当前用户实际体验的来源。

## 输出要求

生成简洁但可执行的文档。高质量输出应包含：

- 与产品类型绑定的清晰设计原则。
- 完整 token 体系，而不只是颜色。
- 带状态和约束的组件契约。
- 解释布局和交互的页面模式规则。
- 面向 AI/开发者的明确 do/don't 约束。
- 可用于阻止不一致改动的 PR 或评审 checklist。
- 一段可复制到未来 AI 开发请求中的短 prompt。

## 项目适配

将本 skill 应用于具体项目时：

- 保留项目已有框架和组件命名方式。
- 将 token 名称转换为项目使用的形态：CSS 变量、Tailwind theme、SwiftUI enum、Android resource、Flutter ThemeData 或 design-token JSON。
- 避免套用通用审美。产品领域本身决定信息密度、对比度、动效和装饰克制程度。
- 除非任务明确要求重设计，否则不要在既有设计系统旁边另起一套新系统。

## 参考资源

- `references/token-system.md`：完整设计 token 架构与命名。
- `references/component-contracts.md`：可复用组件分层、状态和准入规则。
- `references/page-patterns.md`：跨项目页面布局和交互模式。
- `references/governance.md`：评审门禁、AI 约束和变更控制。
- `references/output-template.md`：推荐的最终文档结构。
