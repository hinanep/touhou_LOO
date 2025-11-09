// MonsterAvoidanceManager.cs
// 将此脚本设置为 AutoLoad 单例，方便全局访问
using Godot;
using System.Collections.Generic;




public partial class MonsterAvoidanceManager : Node
{
	public float NeighborDistance { get; set; } = 150.0f;
	public int MaxNeighbors { get; set; } = 10;
	public float TimeHorizon { get; set; } = 1.5f;
	public float TimeHorizonObstacles { get; set; } = 2.0f;


	private Rid _navMap;
	// 使用字典来存储 Node 和其对应的 Rid，比数组更高效、更安全
	private Dictionary<Node2D, Rid> _registeredMonsters = new Dictionary<Node2D, Rid>();

	 // --- KD树相关的新增部分 ---
	private KDTree _monsterKdTree = new KDTree();
	// 创建一个列表缓存，避免每帧都 new 一个新列表，减少GC压力
	private List<Node2D> _monsterListCache = new List<Node2D>();

	public override void _Ready()
	{
		_navMap = NavigationServer2D.MapCreate();
		NavigationServer2D.MapSetActive(_navMap, true);
	}
		// 我们需要在物理帧处理中重建树
	public override void _PhysicsProcess(double delta)
	{
		// 2. 如果有怪物存在，则重建KD树
		if (_monsterListCache.Count > 0)
		{
			_monsterKdTree.Build(_monsterListCache);

		}
	}


	/// <summary>
	/// 接口1: 注册一个怪物到避障系统
	/// </summary>
	/// <param name="monsterNode">怪物的节点实例</param>
	/// <param name="config">怪物的避障参数</param>
	/// <returns>成功返回 true, 如果已注册则返回 false</returns>
	public bool RegisterMonster(Node2D monsterNode, int Radius,int MaxSpeed)
	{
		if (_registeredMonsters.ContainsKey(monsterNode))
		{
			GD.PrintErr($"Monster {monsterNode.Name} is already registered.");
			return false;
		}

		Rid agentRid = NavigationServer2D.AgentCreate();
		NavigationServer2D.AgentSetMap(agentRid, _navMap);
		NavigationServer2D.AgentSetAvoidanceEnabled(agentRid, true);

		// 应用配置参数
		NavigationServer2D.AgentSetNeighborDistance(agentRid, NeighborDistance);
		NavigationServer2D.AgentSetMaxNeighbors(agentRid, MaxNeighbors);
		NavigationServer2D.AgentSetTimeHorizonAgents(agentRid, TimeHorizon);
		NavigationServer2D.AgentSetTimeHorizonObstacles(agentRid, TimeHorizonObstacles);
		NavigationServer2D.AgentSetRadius(agentRid, Radius);
		NavigationServer2D.AgentSetMaxSpeed(agentRid, MaxSpeed);

		_registeredMonsters.Add(monsterNode, agentRid);
		_monsterListCache.Add(monsterNode);
		return true;
	}

	/// <summary>
	/// 接口2: 从避障系统中移除一个怪物
	/// </summary>
	/// <param name="monsterNode">怪物的节点实例</param>
	public void RemoveMonster(Node2D monsterNode)
	{
		if (_registeredMonsters.TryGetValue(monsterNode, out Rid agentRid))
		{
			// 在 Godot 4.x 中，RID 会自动管理，我们只需要从字典中移除
			NavigationServer2D.FreeRid(agentRid);
			_registeredMonsters.Remove(monsterNode);
			_monsterListCache.Remove(monsterNode);
		}
	}

	/// <summary>
	/// 接口3: 设置怪物当前的位置
	/// </summary>
	/// <param name="monsterNode">怪物的节点实例</param>
	/// <param name="position">怪物的全局位置</param>
	public void SetMonsterPosition(Node2D monsterNode, Vector2 position)
	{
		if (_registeredMonsters.TryGetValue(monsterNode, out Rid agentRid))
		{
			NavigationServer2D.AgentSetPosition(agentRid, position);
		}
	}

	/// <summary>
	/// 接口4: 设置怪物的理想速度（期望速度）
	/// </summary>
	/// <param name="monsterNode">怪物的节点实例</param>
	/// <param name="preferredVelocity">怪物想移动的速度向量</param>
	public void SetMonsterPreferredVelocity(Node2D monsterNode, Vector2 preferredVelocity)
	{
		if (_registeredMonsters.TryGetValue(monsterNode, out Rid agentRid))
		{
			// 使用 AgentSetVelocity 是更符合 Godot 4.x 设计意图的做法
			NavigationServer2D.AgentSetVelocity(agentRid, preferredVelocity);
		}
	}

	/// <summary>
	/// 接口5: 获取经过避障计算后的安全速度
	/// </summary>
	/// <param name="monsterNode">怪物的节点实例</param>
	/// <returns>计算出的安全速度向量</returns>
	public Vector2 GetMonsterSafeVelocity(Node2D monsterNode)
	{
		if (_registeredMonsters.TryGetValue(monsterNode, out Rid agentRid))
		{
			return NavigationServer2D.AgentGetVelocity(agentRid);
		}
		return Vector2.Zero;
	}
	/// <summary>
	/// 接口6: 使用KD树查询距离某个点最近的已注册敌人
	/// </summary>
	public Node2D FindClosestEnemy(Vector2 position, Node2D excludeNode = null)
	{
		// 直接调用KD树的查询接口，不再需要手动遍历
		Node2D ans = _monsterKdTree.FindClosest(position, excludeNode);
		//ans.Call("highlight");
		return ans;
	}
   // --- 新增的初始化/重置接口 ---
	/// <summary>
	/// 重置管理器状态，清理所有旧场景的数据。
	/// 应该在每个新关卡或场景加载开始时调用。
	/// </summary>
	public void Reset()
	{
		GD.Print("MonsterAvoidanceManager is resetting...");

		// 1. 遍历并释放所有已注册代理在 NavigationServer 上的资源
		foreach (var agentRid in _registeredMonsters.Values)
		{
			if (agentRid.IsValid)
			{
				NavigationServer2D.FreeRid(agentRid);
			}
		}

		// 2. 清空 C# 端的怪物注册字典
		_registeredMonsters.Clear();

		// 3. 重置 KD 树 (最简单的方式是创建一个新实例)
		_monsterKdTree = new KDTree();
		_monsterListCache.Clear();

		// 4. 重置导航地图，确保一个干净的环境
		if (_navMap.IsValid)
		{
			NavigationServer2D.FreeRid(_navMap);
		}
		_navMap = NavigationServer2D.MapCreate();
		NavigationServer2D.MapSetActive(_navMap, true);

		GD.Print("MonsterAvoidanceManager has been reset.");
	}
	public Rid CreateObstacle(Vector2[] vertices)
	{
		Rid obstacleRid = NavigationServer2D.ObstacleCreate();
		NavigationServer2D.ObstacleSetMap(obstacleRid, _navMap);
		NavigationServer2D.ObstacleSetVertices(obstacleRid, vertices);
		NavigationServer2D.ObstacleSetAvoidanceEnabled(obstacleRid, true);
		return obstacleRid;
	}
}
