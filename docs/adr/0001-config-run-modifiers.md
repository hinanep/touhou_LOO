# ADR-0001: 配置表与局内状态分离

## 状态

已接受

## 背景

`table` Autoload 同时承担只读 JSON 配置与局内升级/羁绊对 `Attack`、`Skill` 等字段的原地修改；回主菜单依赖 `o*` 备份与 `return_to_start()` 深拷贝还原，易漏表且难以单测。

## 决策

1. `table` 仅加载并暴露**只读**基表（`get_base_row` / `get_base_table`）。
2. 局内数值变更写入 `RunModifiers`（`_row_overrides` 与 `_cp_patches`），经 `resolve(table, id)` 查询有效行。
3. 会话结束调用 `table.clear_session_state()`（内部 `RunModifiers.clear()`），不再维护 `o*` 镜像。
4. 禁止业务代码直接赋值 `table.Attack[id].*`、`table.Skill[id].*` 等；升级逻辑在 `upgrade.gd` 中调用 `RunModifiers.set_row_fields`。

## 后果

- 正面：局内状态集中、回菜单无需 duplicate 七张表；Attack/Skill 有效值可预测。
- 负面：迁移期须经 `resolve_*` 读取会被修饰的行；已存在的 `skill_pool` 副本需在 `renew_state` 时从 resolve 刷新（如 `skill.gd` CD）。
