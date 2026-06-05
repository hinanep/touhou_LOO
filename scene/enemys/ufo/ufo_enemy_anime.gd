extends AnimatedSprite2D	

## 动画周期，单位为秒
@export var cycle:float;
## 椭圆水平轴，单位为像素
@export var a:int;
## 椭圆垂直轴，单位为像素
@export var b:int;
## 最大倾角，单位为角度
@export var theta:float;
## 缩放振幅
@export var amp_scale:float;

## 自变量
var x:float;
## 自变量变化量
var deltax:float;
## 最大倾角，单位为弧度
var theta_rad:float;
## 缩放平均值
var avg_scale:float;

func _ready() -> void:
	## 变量初始化
	x = 0;
	deltax = 2 * PI / cycle;
	theta_rad = (2 * PI) * theta / 360;
	avg_scale = scale.x;

func _process(delta: float) -> void:
	## 令贴图沿椭圆轨道周期性运动
	position = Vector2(a * cos(x), b * sin(x));
	## 令贴图周期性左右摆动
	rotation = (-1 * theta_rad * cos(x));
	## 令贴图大小周期性变化
	scale = Vector2(avg_scale + amp_scale * sin(x), avg_scale + amp_scale * sin(x));
	## 每帧更新自变量
	x += (deltax * delta);
	if x >= 2 * PI:
		x -= 2 * PI;
	return;
