extends AnimatedSprite2D

## 动画周期，单位为秒
@export var cycle:float;
## 缩放振幅
@export var max_scale:float;
## 最小缩放倍数
@export var min_scale:float;
## 最大不透明度
@export var max_alpha:float;
## 最小不透明度
@export var min_alpha:float;

## 自变量
var x:float;
## 自变量每帧变化值
var deltax:float;
## 父节点
var parent_node:AnimatedSprite2D;
## 缩放均值
var avg_scale:float;
## 缩放振幅
var amp_scale:float;
## 不透明度均值
var avg_alpha:float;
## 不透明度振幅
var amp_alpha:float;

func _ready() -> void:
	## 变量初始化
	x = 0;
	deltax = 2 * PI / cycle;
	parent_node = get_parent();
	avg_scale = (max_scale + min_scale) / 2;
	amp_scale = (max_scale - min_scale) / 2;
	avg_alpha = (max_alpha + min_alpha) / 2;
	amp_alpha = (max_alpha - min_alpha) / 2;
	## 令发光图层比贴图图层靠后一点
	z_index = parent_node.z_index - 1;

func _process(delta: float) -> void:
	## 使发光图层大小周期性变化
	scale = Vector2(avg_scale + amp_scale * sin(x), avg_scale + amp_scale * sin(x));
	## 使发光图层透明度周期性变化
	self_modulate.a = avg_alpha + amp_alpha * sin(x);
	## 每帧更新自变量
	x += (deltax * delta);
	if x >= 2 * PI:
		x -= 2 * PI;
	return;
