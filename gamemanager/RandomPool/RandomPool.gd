extends Node
var rnd
func _ready():
	rnd = RandomNumberGenerator.new()
	#rnd.seed = hash("Hello world")


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

	if !player_var.PassiveManager.passive_num_full:
		for passivename in player_var.PassiveManager.passive_pool['unlocked']:
			passives.append([passivename,player_var.PassiveManager.passive_pool['unlocked'][passivename]["weight"]])
	for passivename in player_var.PassiveManager.passive_pool["choosed"]:
		passives.append([passivename,player_var.PassiveManager.passive_pool["choosed"][passivename]["weight"]])

	var pool = []
	pool.append_array(cards)
	pool.append_array(skills)
	pool.append_array(passives)

	var nselect = selectm_from_samples(pool,n)

	var skills_ans = []
	var cards_ans = []
	var passives_ans = []
	var ans = {}
	for x in nselect:
		if x in skills:
			skills_ans.append(x[0])
			ans[x[0]]='skill'
		elif x in cards:
			cards_ans.append(x[0])
			ans[x[0]]='card'
		elif x in passives:
			passives_ans.append(x[0])
			ans[x[0]]='passive'

	return ans



func selectm_from_samples(samples, m):

	var heap = [] # [(new_weight, item), ...]
	var wi
	var ui
	var ki
	for sample in samples:
		if sample[1]==0:
			continue

		wi = sample[1]
		ui = rnd.randf_range(0,1)
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
