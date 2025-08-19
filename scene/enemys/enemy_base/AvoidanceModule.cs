// AvoidanceModule.cs
// 将这个脚本附加到一个 Node 节点上，并使其成为怪物 CharacterBody2D 的子节点。
using Godot;
using System;

public partial class AvoidanceModule : Node
{
	private MonsterAvoidanceManager _avoidanceManager;
	private CharacterBody2D _monsterParent; // 对父节点（怪物本身）的引用

	public void regis()
	{
		// 1. 获取单例管理器
		_avoidanceManager = GetNode<MonsterAvoidanceManager>("/root/MonsterAvoidanceManager");

		// 2. 获取父节点，它才是真正的“怪物”
		// 我们假设这个模块的父节点是一个 CharacterBody2D
		_monsterParent = GetParent<CharacterBody2D>();
		if (_monsterParent == null)
		{
			GD.PrintErr("AvoidanceModule must be a child of a CharacterBody2D node.");
			SetProcess(false); // 禁用此节点
			return;
		}

		// 3. 从父节点（GDScript）获取参数
		// 使用 .Get() 来安全地访问 GDScript 中定义的 @export 变量
		var config = new MonsterAvoidanceConfig
		{
			Radius = _monsterParent.Get("radius").AsSingle(),
			MaxSpeed = _monsterParent.Get("max_speed").AsSingle()
			// 你可以在这里添加更多从父节点获取的参数
		};

		// 4. 使用父节点去注册避障服务
		// 注意：注册的是 _monsterParent，而不是 this (模块本身)
		_avoidanceManager.RegisterMonster(_monsterParent, config);
	}

	/// <summary>
	/// 这是提供给外部 GDScript 调用的核心接口
	/// </summary>
	/// <param name="preferredVelocity">由 GDScript 计算出的理想速度</param>
	/// <returns>经过避障计算后的安全速度</returns>
	public Vector2 CalculateSafeVelocity(Vector2 preferredVelocity)
	{
		// 安全检查
		if (_avoidanceManager == null || !IsInstanceValid(_monsterParent))
		{
			// 如果管理器或父节点无效，直接返回理想速度以避免崩溃
			return preferredVelocity;
		}

		// 在计算前，更新怪物在避障系统中的状态
		_avoidanceManager.SetMonsterPosition(_monsterParent, _monsterParent.GlobalPosition);
		_avoidanceManager.SetMonsterPreferredVelocity(_monsterParent, preferredVelocity);

		// 从管理器获取并返回最终的安全速度
		return _avoidanceManager.GetMonsterSafeVelocity(_monsterParent);
	}

	// 当节点被销毁时，确保从管理器中注销父节点
	public override void _ExitTree()
	{
		if (_avoidanceManager != null && IsInstanceValid(_monsterParent))
		{
			_avoidanceManager.RemoveMonster(_monsterParent);
		}
	}
}
