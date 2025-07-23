extends CanvasLayer

# 预加载破碎遮罩图

# 爆炸力度
@export var explosion_force: float = 2000.0


@onready var fragment_container = $FragmentContainer

var fragments = []
var polys = []
var center = []
var diretion = []
var viewport_size = Vector2(1920,1080)
func _ready():
	print("ShatterEffect 初始化完成")

	SignalBus.shutter.connect(start_shatter_effect)
	fragments = []
	for fra in fragment_container.get_children():
		fragments.push_back(fra)
		var poly2D:Polygon2D = fra.get_child(0)
		polys.push_back(poly2D)

		viewport_size = get_viewport().get_visible_rect().size
		var centerp = Vector2.ZERO
		for point in poly2D.polygon:
			centerp += point
		centerp /= poly2D.polygon.size()
		center.push_back(centerp)

		var screen_center = viewport_size/2
		var diretionp = (centerp - screen_center).normalized()


		diretion.push_back(diretionp* explosion_force)

		viewport_size = get_viewport().get_visible_rect().size
		#get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	viewport_size = get_viewport().get_visible_rect().size
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

	print("屏幕尺寸: ", viewport_size)

	for i in fragments.size():
		polys[i].set_texture(screen_texture)

	fragment_container.visible = true

	$Maskalp.material.set_shader_parameter('begin',true)
	var tween = create_tween()
	#tween.tween_interval(2.0)
	tween.set_parallel(true)

	tween.tween_callback(tween_all_fragment)
	tween.tween_method(set_shader_phase,4.15,-1.0,0.5)
	await tween.finished
	$Maskalp.material.set_shader_parameter('begin',false)
	set_shader_phase(0.0)








func set_shader_phase(p):

	$Maskalp.material.set_shader_parameter('phase',p)
# 安全获取屏幕纹理的方法
func get_screen_texture_safe() -> Texture2D:

	# 获取主视口
	var main_viewport = get_viewport()
	print("主视口路径: ", main_viewport.get_path())

	#await RenderingServer.frame_post_draw
	var imagetmp:Image = main_viewport.get_texture().get_image()
	imagetmp.resize(viewport_size.x,viewport_size.y)
	var tex = ImageTexture.create_from_image(imagetmp)

	return tex



# 清理所有碎片
func clear_fragments():
	if fragment_container:
		for child in fragment_container.get_children():
			child.position = Vector2.ZERO
		print("已清理之前的碎片")

func tween_all_fragment():
	for i in fragments.size():
		tween_fragment(i)
# 创建单个碎片
func tween_fragment(index:int):

	fragments[index].rotation = 0
	fragments[index].modulate.a = 1.0
	await get_tree().create_timer(0.8).timeout
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
