extends Node2D

var Exp = 0
var Score = 0
var Mul = 1
var kill_num = 0

func add_exp(value):
	print("Exp+3, good bye!")
	Exp += value

func add_score(value):
	print("Score+3, good bye!")
	Score += value * Mul
