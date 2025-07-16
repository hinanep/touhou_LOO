extends CanvasLayer

# 预加载破碎遮罩图

# 爆炸力度
@export var explosion_force: float = 2000.0


@onready var fragment_container = $FragmentContainer

var fragments = []
var polys = []
var center = []
var diretion = []
func _ready():
	print("ShatterEffect 初始化完成")

	# 为了演示，我们在这里创建一个按钮来触发效果
	var button = Button.new()
	button.text = "Shatter!"
	button.position = Vector2(50, 50)
	add_child(button)
	button.pressed.connect(start_shatter_effect)

	fragments = []
	for fra in fragment_container.get_children():
		fragments.push_back(fra)
		var poly2D:Polygon2D = fra.get_child(0)
		polys.push_back(poly2D)

		var centerp = Vector2.ZERO
		for point in poly2D.polygon:
			centerp += point
		centerp /= poly2D.polygon.size()
		center.push_back(centerp)

		var screen_center = Vector2(960,540)
		var diretionp = (centerp - screen_center).normalized()

		# 如果碎片在屏幕中心，给一个随机方向
		#if directionp.length() < 1.0:
			#directionp = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		diretion.push_back(diretionp* explosion_force)

# 主要的碎裂效果函数
func start_shatter_effect():
	print("=== 开始碎裂效果 ===")
	clear_fragments()

	# 1. 获取屏幕纹理并创建副本
	var screen_texture :Texture2D= get_screen_texture_safe()

	if screen_texture:
		print("成功获取屏幕纹理，尺寸: ", screen_texture.get_width(), "x", screen_texture.get_height())
	else:
		print("错误: 无法获取屏幕纹理!")
		return
	var screen_size = get_viewport().get_visible_rect().size
	print("屏幕尺寸: ", screen_size)
	$Maskalp.material.set_shader_parameter('begin',true)
	var tween = create_tween()

	tween.tween_method(set_shader_phase,3.15,-1.0,0.6)
	tween.tween_interval(0.1)
	await tween.finished
	$Maskalp.material.set_shader_parameter('begin',false)
	set_shader_phase(0.0)
	for i in fragments.size():
		polys[i].set_texture(screen_texture)
		tween_fragment(i)
	fragment_container.visible = true
func set_shader_phase(p):
	print('set to' + str(p))
	$Maskalp.material.set_shader_parameter('phase',p)
# 安全获取屏幕纹理的方法
func get_screen_texture_safe() -> Texture2D:

	# 获取主视口
	var main_viewport = get_viewport()
	print("主视口路径: ", main_viewport.get_path())

	#await RenderingServer.frame_post_draw
	var imagetmp = main_viewport.get_texture().get_image()

	var tex = ImageTexture.create_from_image(imagetmp)

	return tex



# 清理所有碎片
func clear_fragments():
	if fragment_container:
		for child in fragment_container.get_children():
			child.position = Vector2.ZERO
		print("已清理之前的碎片")

# 创建单个碎片
func tween_fragment(index:int):

	fragments[index].rotation = 0
	fragments[index].modulate.a = 1.0
	# 创建动画来模拟爆炸效果
	var tween = create_tween()
	tween.set_parallel(true)

	# 移动动画
	#var target_pos =  direction
	tween.tween_property(fragments[index], "position", diretion[index], 2.0)

	# 旋转动画
	var rotation_amount = randf_range(-PI/4, PI/4)
	tween.tween_property(fragments[index], "rotation", rotation_amount, 2.0)

	# 透明度动画
	tween.tween_property(fragments[index], "modulate:a", 0.0, 2.0)

	# 动画完成后清理碎片
	tween.tween_callback(func():
		fragment_container.visible = false).set_delay(2.0)
