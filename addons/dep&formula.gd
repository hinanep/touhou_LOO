class_name dep_formula
var dep_table = table.Atk_Dependence
func operate_dep(depid,value):
	if not dep_table.has(depid):
		#push_warning('not found depend')

		return value
	var addi
	print(depid)
	match dep_table[depid].calculation:
		'linear':
			addi = dep_table[depid].calculation_parameter[0] * player_var.get(dep_table[depid].attribute) + dep_table[depid].calculation_parameter[1]
		'sin':
			addi = sin(player_var.get(dep_table[depid].calculation_parameter[0] * dep_table[depid].attribute))
	print(addi)
	match dep_table[depid].relationship:
		'multiply':
			return value * addi
		'add':
			return value + addi

  #"atkdep_mana_multiply": {
	#"id": "atkdep_mana_multiply",
	#"attribute": "mana",
	#"calculation": "linear",
	#"calculation_parameter": [
	  #0.0025,
	  #0
	#],
	#"relationship": "multiply"
  #}
