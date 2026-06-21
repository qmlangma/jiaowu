# 输出模板

当需要为项目产出 UI 设计规范时，使用以下结构。

````markdown
# UI 设计规范

## 1. 范围与事实来源

- 产品类型：
- 平台：
- 权威文件：
- 非权威或过期文件：
- 设计目标：

## 2. 设计原则

- 原则 1：
- 原则 2：
- 原则 3：
- 原则 4：

## 3. Token 架构

使用 primitive -> semantic -> component 三层 token。

### 3.1 颜色

Primitive 色阶：

- Neutral：
- Primary：
- Accent：
- Success：
- Warning：
- Danger：
- Info：
- Chart：

Semantic colors：

- Background：
- Text：
- Border：
- Action：
- Status：
- Selection / focus：

### 3.2 字体

- Font families：
- Weights：
- Display：
- Titles：
- Body：
- Caption / label：
- Numeric：

### 3.3 间距与布局

- Base grid：
- Spacing scale：
- Page spacing：
- Section spacing：
- Component spacing：

### 3.4 尺寸

- Control heights：
- Touch targets：
- Icon sizes：
- Shell dimensions：
- Modal / sheet dimensions：

### 3.5 圆角、描边、阴影

- Radius scale：
- Border rules：
- Elevation levels：

### 3.6 动效与层级

- Duration：
- Easing：
- Z-index / layer rules：

## 4. 组件契约

### 4.1 组件分层

- Tier A：
- Tier B：
- Tier C：

### 4.2 核心组件

每个组件应包含：

- 用途：
- 结构：
- 变体：
- 状态：
- Token：
- 无障碍：
- Do / Don't：

## 5. 页面模式

每个页面模式应包含：

- 结构：
- 信息层级：
- 布局规则：
- 响应式规则：
- 状态规则：
- 约束：

## 6. AI / 开发约束

- Must：
- Must not：
- Source priority：
- Reuse rules：
- Deviation rules：

## 7. PR Gate Checklist

- Token：
- Layout：
- Component：
- Interaction：
- Accessibility：
- Governance：

## 8. 未来 AI 开发 Prompt

```text
请以项目 UI 规范作为事实来源。复用既有 token 和组件。不要引入新的视觉风格、硬编码颜色、装饰性嵌套卡片或常规横向滚动。保持已定义的页面模式；新增 token 或可复用组件时，同步更新 UI 文档。
```
````
