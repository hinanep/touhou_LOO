# 东方幸存者（thloo）领域术语

本仓库 Godot 项目的共享词汇；架构 skill 与 Issue 标题应使用下列术语。

## ConfigRegistry（配置表）

- 指 Autoload `table` 从 `settings/dist/**/*.json` 加载的**只读**设计数据（`Attack`、`Skill`、`Routine` 等）。
- 局内不得直接改写 `table.Attack[id]` 等字段。

## RunModifiers（局内修饰）

- Autoload `RunModifiers`：在 ConfigRegistry 基表之上叠加升级、羁绊 CP 等局内变更。
- 生命周期：`player_var.new_scene()` 与 `table.clear_session_state()` 时 `RunModifiers.clear()`。
- 查询有效行：`RunModifiers.resolve("Attack", id)` 或 `table.resolve_attack(id)`。

## EffectiveRow（有效配置行）

- 某表某 id 经 RunModifiers 解析后的 `Dictionary`，供 Attack、Routine、Summon 等运行时读取。

## RunSession（局内会话）

- Autoload `RunSession`：单局内的 Skill/Card/Passive/Cp/Spawn Manager、空气墙、`tmp_scene`、Boss 演出、`underrecycle_tween`。
- 生命周期：`RunSession.begin_run()`（通常经 `player_var.new_scene()`）、`RunSession.end_run()`（回主菜单时与 `table.clear_session_state()` 一并调用）。
- `player_var` 保留玩家数值、伤害/治疗公式、升级 UI；局内编排请优先使用 `RunSession`。
