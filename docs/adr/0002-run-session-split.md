# ADR-0002: RunSession 与 player_var 分离

## 状态

已接受

## 背景

`player_var` Autoload 同时持有玩家属性、记忆结晶 Manager 生命周期、场景引用（`tmp_scene`、`worldenvir`）、Boss 入场与空气墙、环境光与局内 Tween 列表，interface 过大，局内编排与数值公式耦合。

## 决策

1. 新增 Autoload `RunSession`，承载单局运行时状态与编排：`begin_run` / `end_run`、各 Manager、`SpawnManager`、空气墙、Boss 演出、`screen_black`、`require_env_glowing`、`underrecycle_tween`。
2. `player_var` 保留玩家属性、`ini()`、伤害/治疗/升级公式、镜头震动；`new_scene()` 委托 `RunSession.begin_run()`。
3. 为减少迁移面，`player_var` 对 `SkillManager`、`SpawnManager`、`air_wall_*` 等提供只读/读写转发至 `RunSession`；新代码应直接使用 `RunSession`。
4. `GUIViewManager.clear_to_start()` 在 `table.clear_session_state()` 之后调用 `RunSession.end_run()`。

## 后果

- 正面：Boss/刷怪/场景绑定集中在 RunSession；与 ADR-0001 的 `RunModifiers.clear()` 同在 `begin_run` 触发。
- 负面：`player_var.SkillManager` 等转发为过渡手段，长期应改为显式 `RunSession` 引用。
