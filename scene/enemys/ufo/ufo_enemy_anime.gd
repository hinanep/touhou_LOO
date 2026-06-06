extends AnimatedSprite2D

## 动画周期，单位为秒
@export var cycle: float
## 椭圆水平轴，单位为像素
@export var a: int
## 椭圆垂直轴，单位为像素
@export var b: int
## 最大倾角，单位为角度
@export var theta: float
## 缩放振幅
@export var amp_scale: float
## 外发光脉冲周期，单位为秒
@export var glow_cycle: float = 1.0
## 外发光 width 最小值
@export var min_width: float = 5
## 外发光 width 最大值
@export var max_width: float = 6
## 外发光 glow_alpha 最小值
@export var min_glow_alpha: float = 0.3
## 外发光 glow_alpha 最大值
@export var max_glow_alpha: float = 0.9

## 运动相位自变量
var x: float
## 运动相位每帧变化值
var deltax: float
## 最大倾角，单位为弧度
var theta_rad: float
## 缩放平均值
var avg_scale: float
## 外发光脉冲相位自变量
var glow_x: float
## 外发光脉冲相位每帧变化值
var glow_deltax: float
## 外发光 width 均值
var avg_width: float
## 外发光 width 振幅
var amp_width: float
## 外发光 glow_alpha 均值
var avg_glow_alpha: float
## 外发光 glow_alpha 振幅
var amp_glow_alpha: float
## light 相对 sprite 的局部偏移（与 tscn 一致）
const _LIGHT_LOCAL_OFFSET := Vector2(0.0, 3.3333333)

func _ready() -> void:
	x = 0.0
	deltax = TAU / cycle
	theta_rad = TAU * theta / 360.0
	avg_scale = scale.x
	glow_x = 0.0
	glow_deltax = TAU / glow_cycle
	avg_width = (max_width + min_width) / 2.0
	amp_width = (max_width - min_width) / 2.0
	avg_glow_alpha = (max_glow_alpha + min_glow_alpha) / 2.0
	amp_glow_alpha = (max_glow_alpha - min_glow_alpha) / 2.0

func _physics_process(delta: float) -> void:
	position = Vector2(a * cos(x), b * sin(x))
	rotation = -theta_rad * cos(x)
	scale = Vector2(avg_scale + amp_scale * sin(x), avg_scale + amp_scale * sin(x))
	x += deltax * delta
	if x >= TAU:
		x -= TAU
	var pulse := sin(glow_x)
	set_instance_shader_parameter("width", avg_width + amp_width * pulse)
	set_instance_shader_parameter("glow_alpha", avg_glow_alpha + amp_glow_alpha * pulse)
	glow_x += glow_deltax * delta
	if glow_x >= TAU:
		glow_x -= TAU
	_sync_light_transform()


## 重置 light 局部变换，使其与 sprite 同原点随动，仅保留编辑器配置的 Y 偏移
func _sync_light_transform() -> void:
	var light_node := get_node_or_null("light") as AnimatedSprite2D
	if light_node == null:
		return
	light_node.position = _LIGHT_LOCAL_OFFSET
	light_node.rotation = 0.0
	light_node.scale = Vector2.ONE
