extends AnimatedSprite2D

## 旋转角速度，单位为角度/s
@export var angular_velocity: int

## 旋转角速度，单位为弧度/s
var angular_velocity_rad: float

func _ready() -> void:

	## 初始化变量
	angular_velocity_rad = angular_velocity * (2 * PI) / 360
	return
	
func _physics_process(delta: float) -> void:
	## 控制旋转
	rotation += delta * angular_velocity_rad
	return
