extends Node



var waza_full = player_var.waza_full
var card_full = player_var.card_full

func _ready():

	pass

func random_nselect_from_allpool(n:int):
	var cards = []
	var wazas = []
	var buffs = []
	if !player_var.waza_num_full:
		for wazaname in WazaManager.waza_pool["unchoosed"]:
			wazas.append([wazaname,WazaManager.waza_pool["unchoosed"][wazaname]["weight"]])
	for wazaname in WazaManager.waza_pool["choosed"]:
		wazas.append([wazaname,WazaManager.waza_pool["choosed"][wazaname]["weight"]])
		
	if !player_var.card_num_full:
		for cardname in CardManager.card_pool["unchoosed"]:
			cards.append([cardname,CardManager.card_pool["unchoosed"][cardname]["weight"]])
	for cardname in CardManager.card_pool["choosed"]:
		cards.append([cardname,CardManager.card_pool["choosed"][cardname]["weight"]])
		
	if !player_var.passive_num_full:
		for buffname in BuffManager.buff_pool["unchoosed"]:
			buffs.append([buffname,BuffManager.buff_pool["unchoosed"][buffname]["weight"]])
	for buffname in BuffManager.buff_pool["choosed"]:
		buffs.append([buffname,BuffManager.buff_pool["choosed"][buffname]["weight"]])	
		
	var pool = []
	pool.append_array(cards)
	pool.append_array(wazas)
	pool.append_array(buffs)
	var nselect = selectm_from_samples(pool,n)
	var wazas_ans = []
	var cards_ans = []
	var buffs_ans = []
	for x in nselect:
		if x in wazas:
			wazas_ans.append(x[0])
		if x in cards:
			cards_ans.append(x[0])
		if x in buffs:
			buffs_ans.append(x[0])
	return{"cards":cards_ans,"wazas":wazas_ans,"buffs":buffs_ans}


func random_select_from_waza():
	var pool = [
		#name:weight
	]
	
	for wazaname in WazaManager.waza_pool["unchoosed"]:
		pool.append([wazaname,WazaManager.waza_pool["unchoosed"][wazaname]["weight"]])
	for wazaname in WazaManager.waza_pool["choosed"]:
		pool.append([wazaname,WazaManager.waza_pool["choosed"][wazaname]["weight"]])
	#a_expj(pool,1)
	if pool.is_empty():
		return null

	return selectm_from_samples(pool,1)[0][0]

func random_select_from_card():
	pass


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
