# 东方幸存者（touhouSurvivors）

Godot **4.6** 类幸存者项目：主逻辑 **GDScript**，怪物避让等少量 **C#**（.NET 8）。

介绍视频：<https://www.bilibili.com/video/BV1kYZxYbE4b>

## 快速开始

1. 安装 [Godot 4.6](https://godotengine.org/)（须带 **.NET** 支持）与 [.NET 8 SDK](https://dotnet.microsoft.com/download)。
2. 用 Godot 打开本仓库根目录（含 `project.godot`）。
3. 若提示 C#：在编辑器中 **构建** 解决方案。
4. **F5** 运行（主场景 `ui/game.tscn`）。

详细步骤与常见问题见 [docs/环境搭建.md](docs/环境搭建.md)。

## 文档

| 文档 | 说明 |
|------|------|
| [docs/新人入职.md](docs/新人入职.md) | **新同学入口**：阅读顺序与一周自检 |
| [docs/游戏流程.md](docs/游戏流程.md) | 菜单 → 局内 → 回菜单 |
| [docs/架构全景.md](docs/架构全景.md) | 模块与 Autoload 关系 |
| [docs/领域索引.md](docs/领域索引.md) | 按功能找文件 |
| [docs/练手任务.md](docs/练手任务.md) | 低风险练手 |
| [CONTEXT.md](CONTEXT.md) | 领域术语表 |
| [docs/adr/](docs/adr/) | 架构决策记录（ADR） |

Agent / Issue 工作流见 [AGENTS.md](AGENTS.md) 与 [docs/agents/](docs/agents/)。
