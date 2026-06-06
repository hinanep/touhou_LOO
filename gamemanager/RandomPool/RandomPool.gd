extends Node
var rnd: RandomNumberGenerator
func _ready() -> void:
	rnd = RandomNumberGenerator.new()
	#rnd.seed = hash("Hello world")


func random_nselect_from_allpool(n: int) -> Dictionary[String, String]:
	var cards: Array = []
	var skills: Array = []
	var passives: Array = []
	if !RunSession.SkillManager.skill_num_full:
		for skillname in RunSession.SkillManager.skill_pool["unlocked"]:
			skills.append([skillname,RunSession.SkillManager.skill_pool["unlocked"][skillname]["weight"]])
	for skillname in RunSession.SkillManager.skill_pool["choosed"]:
		skills.append([skillname,RunSession.SkillManager.skill_pool["choosed"][skillname]["weight"]])

	if !player_var.card_num_full:
		for cardname in RunSession.CardManager.card_pool["unlocked"]:
			cards.append([cardname,RunSession.CardManager.card_pool["unlocked"][cardname]["weight"]])
	for cardname in RunSession.CardManager.card_pool["choosed"]:
		cards.append([cardname,RunSession.CardManager.card_pool["choosed"][cardname]["weight"]])

	if !RunSession.PassiveManager.passive_num_full:
		for passivename in RunSession.PassiveManager.passive_pool['unlocked']:
			passives.append([passivename,RunSession.PassiveManager.passive_pool['unlocked'][passivename]["weight"]])
	for passivename in RunSession.PassiveManager.passive_pool["choosed"]:
		passives.append([passivename,RunSession.PassiveManager.passive_pool["choosed"][passivename]["weight"]])

	var pool: Array = []
	pool.append_array(cards)
	pool.append_array(skills)
	pool.append_array(passives)

	var nselect: Array = selectm_from_samples(pool,n)

	var skills_ans: Array = []
	var cards_ans: Array = []
	var passives_ans: Array = []
	var ans: Dictionary[String, String] = {}
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

func random_nselect_from_have(n: int) -> Dictionary[String, String]:
	var cards: Array = []
	var skills: Array = []
	var passives: Array = []

	for skillname in RunSession.SkillManager.skill_pool["choosed"]:
		skills.append([skillname,RunSession.SkillManager.skill_pool["choosed"][skillname]["weight"]])


	for cardname in RunSession.CardManager.card_pool["choosed"]:
		cards.append([cardname,RunSession.CardManager.card_pool["choosed"][cardname]["weight"]])

	for passivename in RunSession.PassiveManager.passive_pool["choosed"]:
		passives.append([passivename,RunSession.PassiveManager.passive_pool["choosed"][passivename]["weight"]])

	var pool: Array = []
	pool.append_array(cards)
	pool.append_array(skills)
	pool.append_array(passives)

	var nselect: Array = selectm_from_samples(pool,n)

	var skills_ans: Array = []
	var cards_ans: Array = []
	var passives_ans: Array = []
	var ans: Dictionary[String, String] = {}
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


func selectm_from_samples(samples: Array, m: int) -> Array:

	var heap: Array = [] # [(new_weight, item), ...]
	var wi: float
	var ui: float
	var ki: float
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
	var ans: Array = []
	for h in heap:
		ans.append(h[0])
	return ans


func sort_ascending(a: Array, b: Array) -> bool:
	if a[1] > b[1]:
		return true
	return false
