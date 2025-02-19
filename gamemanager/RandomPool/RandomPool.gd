extends Node

func _ready():
	seed("Hello world".hash())
	#print(random_nselect_from_allpool(3))
	#print(random_nselect_from_allpool(3))
#
	#print(random_nselect_from_allpool(3))
	pass

func random_nselect_from_allpool(n:int):
	var cards = []
	var skills = []
	var passives = []
	if !player_var.SkillManager.skill_num_full:
		for skillname in player_var.SkillManager.skill_pool["unlocked"]:
			skills.append([skillname,player_var.SkillManager.skill_pool["unlocked"][skillname]["weight"]])
	for skillname in player_var.SkillManager.skill_pool["choosed"]:
		skills.append([skillname,player_var.SkillManager.skill_pool["choosed"][skillname]["weight"]])

	if !player_var.card_num_full:
		for cardname in player_var.CardManager.card_pool["unlocked"]:
			cards.append([cardname,player_var.CardManager.card_pool["unlocked"][cardname]["weight"]])
	for cardname in player_var.CardManager.card_pool["choosed"]:
		cards.append([cardname,player_var.CardManager.card_pool["choosed"][cardname]["weight"]])

	if !player_var.passive_num_full:
		for passivename in PassiveManager.buff_pool["unchoosed"]:
			passives.append([passivename,PassiveManager.buff_pool["unchoosed"][passivename]["weight"]])
	for passivename in PassiveManager.buff_pool["choosed"]:
		passives.append([passivename,PassiveManager.buff_pool["choosed"][passivename]["weight"]])

	var pool = []
	pool.append_array(cards)
	pool.append_array(skills)
	pool.append_array(passives)

	var nselect = selectm_from_samples(pool,n)
	var skills_ans = []
	var cards_ans = []
	var passives_ans = []
	for x in nselect:
		if x in skills:
			skills_ans.append(x[0])
		elif x in cards:
			cards_ans.append(x[0])
		elif x in passives:
			passives_ans.append(x[0])
	return{"cards":cards_ans,"skills":skills_ans,"passives":passives_ans}

#
#func random_select_from_skill():
	#var pool = [
		##name:weight
	#]
#
	#for skillname in player_var.SkillManager.skill_pool["unchoosed"]:
		#pool.append([skillname,player_var.SkillManager.skill_pool["unchoosed"][skillname]["weight"]])
	#for skillname in player_var.SkillManager.skill_pool["choosed"]:
		#pool.append([skillname,player_var.SkillManager.skill_pool["choosed"][skillname]["weight"]])
	##a_expj(pool,1)
	#if pool.is_empty():
		#return null
#
	#return selectm_from_samples(pool,1)[0][0]
#
#func random_select_from_card():
	#pass


func selectm_from_samples(samples, m):
	#
	#:samples: [(item, weight), ...]
	#:k: number of selected items
	#:returns: [(item, weight), ...]
	#

	var heap = [] # [(new_weight, item), ...]
	var wi
	var ui
	var ki
	for sample in samples:
		if sample[1]==0:
			continue

		wi = sample[1]
		ui = randf_range(0,1)
		ki = ui ** (1.0/wi)

		if len(heap) < m:

			heap.append([sample,ki])
			continue
		heap.sort_custom(sort_ascending)

		if ki>heap[m-1][1]:

			heap.pop_back()
			heap.append([sample,ki])
	var ans = []
	for h in heap:
		ans.append(h[0])
	return ans


func sort_ascending(a, b):
	if a[1] > b[1]:
		return true
	return false
