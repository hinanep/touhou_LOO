extends Node


var waza_pool = ["reimu","sanae","alice"]
var card_pool = ["marisa"]
var waza_full = player_var.waza_full
var card_full = player_var.card_full
var name_path_pair ={
	"reimu" : "res://scene/weapons/reimu/reimu_weapon.tscn",
	"sanae": "res://scene/weapons/sanae/sanae_weapon.tscn",
	"alice": "res://scene/weapons/alice_weapon/alice_weapon.tscn",
	"marisa": "res://scene/cards/masterapark/masterspark.tscn"
}
func _ready():
	pass

func random_nselect_from_allpool(n:int):
	var cards = []
	var wazas = []
	if waza_full:
		if card_full:
			return null
		else:
			#card
			for i in n:
				cards.append(random_select_from_card())

	else:
		if card_full:
			#waza
			for i in n:
				wazas.append(random_select_from_waza())

		else:
			for i in n:			
				if(randi()%2 == 0):
					#waza
					var rdwaza = random_select_from_waza()
					if rdwaza == null:
						cards.append(random_select_from_card())
					else:
						#print(rdwaza)
						wazas.append(rdwaza)

				else:
					#card
					var rdcard = random_select_from_card()
					if rdcard == null:
						
						wazas.append(random_select_from_waza())
					else:
						#print(rdcard)
						cards.append(rdcard)

	for c in cards:
		card_pool.append(c)

	for w in wazas:
		waza_pool.append(w)
		
	return{"cards":cards,"wazas":wazas}
	
func random_select_from_waza():
	if waza_pool.is_empty():
		return null
	var num = randi_range(0,waza_pool.size()-1)
	return waza_pool.pop_at(num)

func random_select_from_card():
	if card_pool.is_empty():
		return null
	var num = randi_range(0,card_pool.size()-1)
	
	var cardname = card_pool.pop_at(num)
	print("rr")
	print(cardname)
	print("rr")
	return cardname
