extends Area2D
var enemy_detect_zone
var enemy_in_zone
func _ready():
	enemy_detect_zone = $"."
func _physics_process(_delta):
	#enemy_in_zone = enemy_detect_zone.get_overlapping_bodies()
	#if !enemy_in_zone.is_empty():
		##player_var.nearest_enemy = enemy_in_zone.reduce(func(min_e,val):return val if enemy_near(val,min_e) else min_e)
#
		#player_var.nearest_enemy = get_near_kenemies(enemy_in_zone,1)[0]
		#if player_var.nearest_enemy!=null:
			#player_var.nearest_enemy_position = player_var.nearest_enemy.global_position
		#else:
			#print("nearest == null!!")
	pass

func get_near_kenemies(enemy_array,k):
	var n = enemy_array.size()
	for i in range(n):
		enemy_array.erase(null)
	n = enemy_array.size()
	if(k>=n):
		k = n
	for i in range(k):
		var flag = false;
		for j in range(n-1,i,-1):
			if(enemy_near(enemy_array[j],enemy_array[j-1])):
				var tmp = enemy_array[j-1]
				enemy_array[j-1] = enemy_array[j]
				enemy_array[j] = tmp
				flag = true
		if flag == false:
			return enemy_array.slice(0,k)
	return enemy_array.slice(0,k)


func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
