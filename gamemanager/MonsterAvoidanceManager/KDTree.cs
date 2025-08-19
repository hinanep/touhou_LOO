// KDTree.cs
using Godot;
using System.Collections.Generic;

// KD树中的节点
public class KDNode
{
	public Node2D Point { get; private set; }
	public KDNode Left { get; set; }
	public KDNode Right { get; set; }

	public KDNode(Node2D point)
	{
		Point = point;
	}
}

// KD树本身
public class KDTree
{
	private KDNode _root;
	private const int K = 2; // 我们处理的是2D空间

	// 公共接口：构建树
	public void Build(List<Node2D> points)
	{
		_root = BuildRecursive(new List<Node2D>(points), 0);
	}

	// 递归构建树的内部方法
	private KDNode BuildRecursive(List<Node2D> points, int depth)
	{
		if (points == null || points.Count == 0)
		{
			return null;
		}

		int axis = depth % K; // 决定当前以哪个轴进行分割 (0 for X, 1 for Y)

		// 根据当前轴对点进行排序，找到中位数
		points.Sort((a, b) => GetAxisValue(a, axis).CompareTo(GetAxisValue(b, axis)));
		int medianIndex = points.Count / 2;

		KDNode node = new KDNode(points[medianIndex]);

		// 递归为左右子树构建
		node.Left = BuildRecursive(points.GetRange(0, medianIndex), depth + 1);
		node.Right = BuildRecursive(points.GetRange(medianIndex + 1, points.Count - medianIndex - 1), depth + 1);

		return node;
	}

	// 公共接口：查找最近邻
	public Node2D FindClosest(Vector2 target, Node excludeNode = null)
	{
		if (_root == null)
		{
			return null;
		}

		Node2D bestNode = null;
		float bestDistSq = float.PositiveInfinity;

		// 如果要排除的节点存在，则先计算一个初始的最佳距离
		if (excludeNode != null)
		{
			// 找到一个不是排除节点的有效节点作为初始比较对象
			FindInitialBestNode(_root, target, excludeNode, ref bestNode, ref bestDistSq);

			// 如果没有找到有效的初始节点，直接返回null
			if (bestNode == null)
			{
				return null;
			}
		}

		FindClosestRecursive(_root, target, 0, ref bestNode, ref bestDistSq, excludeNode);
		return bestNode;
	}

	// 递归查找的内部方法
	private void FindClosestRecursive(KDNode node, Vector2 target, int depth, ref Node2D bestNode, ref float bestDistSq, Node excludeNode)
	{
		if (node == null || !GodotObject.IsInstanceValid(node.Point))
		{
			return;
		}

		// 如果当前节点不是被排除的节点
		if (node.Point != excludeNode)
		{
			float dSq = node.Point.GlobalPosition.DistanceSquaredTo(target);
			if (dSq < bestDistSq)
			{
				bestDistSq = dSq;
				bestNode = node.Point;
			}
		}

		int axis = depth % K;
		float axisDist = (axis == 0 ? target.X : target.Y) - GetAxisValue(node.Point, axis);

		KDNode nearNode = axisDist < 0 ? node.Left : node.Right;
		KDNode farNode = axisDist < 0 ? node.Right : node.Left;

		// 首先在更近的子空间中搜索
		FindClosestRecursive(nearNode, target, depth + 1, ref bestNode, ref bestDistSq, excludeNode);

		// 剪枝：如果目标点到分割平面的距离比当前最优距离还大，就没必要搜索另一个子空间了
		if (axisDist * axisDist < bestDistSq)
		{
			FindClosestRecursive(farNode, target, depth + 1, ref bestNode, ref bestDistSq, excludeNode);
		}
	}

	// 优化的初始节点查找方法
	private void FindInitialBestNode(KDNode node, Vector2 target, Node excludeNode, ref Node2D bestNode, ref float bestDistSq)
	{
		if (node == null) return;

		// 检查当前节点
		if (node.Point != excludeNode && GodotObject.IsInstanceValid(node.Point))
		{
			bestNode = node.Point;
			bestDistSq = node.Point.GlobalPosition.DistanceSquaredTo(target);
			return; // 找到第一个有效节点就返回
		}

		// 递归查找左右子树
		FindInitialBestNode(node.Left, target, excludeNode, ref bestNode, ref bestDistSq);
		if (bestNode == null)
		{
			FindInitialBestNode(node.Right, target, excludeNode, ref bestNode, ref bestDistSq);
		}
	}

	// 辅助方法，用于在排序时获取节点的X或Y坐标
	private float GetAxisValue(Node2D node, int axis)
	{
		return axis == 0 ? node.GlobalPosition.X : node.GlobalPosition.Y;
	}


}
