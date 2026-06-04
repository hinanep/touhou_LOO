extends AnimatedSprite2D	

## 动画周期，单位为秒
@export var cycle:float;
## 椭圆水平轴，单位为像素
@export var a:int;
## 椭圆垂直轴，单位为像素
@export var b:int;
## 最大倾角，单位为角度
@export var theta:float;

var x:float = 0;
var deltax:float;
var theta_rad:float;

func _ready() -> void:
	deltax = 2 * PI / cycle;
	theta_rad = (2 * PI) * theta / 360;

func _process(delta: float) -> void:
	position = Vector2(a * cos(x), b * sin(x));
	rotation = (-1 * theta_rad * cos(x));
	print("cycle=")
	print(cycle)
	print("2 * PI / cycle=")
	print(2 * PI / cycle)
	x += (deltax * delta);
	if x >= 2 * PI:
		x -= 2 * PI;
	return;
