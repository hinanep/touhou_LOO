# warnings-disable
extends RefCounted

@warning_ignore("unused_variable")
var True = true
@warning_ignore("unused_variable")
var False = false
@warning_ignore("unused_variable")
var None = null


var data = \
{
1:{ "id":1,  "_int":1,  "_float ":1.0,  "_string":'恭喜你！成功配置好了Godot导表项目。',  "_bool":True,  "_array":[1, 2, 3, 4, 5],  "_array_str":['a', 'b', 'c'],  "_array_bool":[True, False],  "_dict":{'name': 'Tom', 'age': 10},  "_function":Callable(self,'_function_1'),  "_function_params":Callable(self,'_function_params_1'),  "_tr_string":'这段话需要翻译1',  "_tr_array_str":['a', 'b', 'c'],  "_tr_dict":{'name': 'Tom', 'age': 10}, },
2:{ "id":2,  "_int":0,  "_float ":0.0,  "_string":'aa',  "_bool":False,  "_array":[],  "_array_str":[],  "_array_bool":[],  "_dict":{},  "_function":Callable(self,'_function_2'),  "_function_params":Callable(self,'_function_params_2'),  "_tr_string":'这段话需要翻译1',  "_tr_array_str":[],  "_tr_dict":{}, },
3:{ "id":3,  "_int":2,  "_float ":2.0,  "_string":'',  "_bool":False,  "_array":[1, 2, 3],  "_array_str":['b', 'c'],  "_array_bool":[True],  "_dict":{'name': 'Tom', 'age': 10},  "_function":Callable(self,'_function_3'),  "_function_params":Callable(self,'_function_params_3'),  "_tr_string":'这段话需要翻译2',  "_tr_array_str":['b', 'c'],  "_tr_dict":{'name': 'Tom', 'age': 10}, },
4:{ "id":4,  "_int":3,  "_float ":3.01,  "_string":'',  "_bool":True,  "_array":[],  "_array_str":[],  "_array_bool":[],  "_dict":{},  "_function":Callable(self,'_function_4'),  "_function_params":Callable(self,'_function_params_4'),  "_tr_string":'',  "_tr_array_str":[],  "_tr_dict":{'name': 'Tom2', 'age': 10}, },
5:{ "id":5,  "_int":4,  "_float ":0.0,  "_string":'你真可悲，你什么都不是，你毫无作为，你无足轻重，你一无是处。\n我，整个城市都是我的。\n等警察抓住你们的时候......你会死的毫无意义。这里是我的地盘。\n你...你....你就是人们要躲避的东西。',  "_bool":False,  "_array":[],  "_array_str":[],  "_array_bool":[],  "_dict":{},  "_function":Callable(self,'_function_5'),  "_function_params":Callable(self,'_function_params_5'),  "_tr_string":'',  "_tr_array_str":[],  "_tr_dict":{}, },
6:{ "id":6,  "_int":0,  "_float ":0.0,  "_string":'',  "_bool":False,  "_array":[],  "_array_str":[],  "_array_bool":[],  "_dict":{},  "_function":Callable(self,'_function_6'),  "_function_params":Callable(self,'_function_params_6'),  "_tr_string":'',  "_tr_array_str":[],  "_tr_dict":{}, },

}


@warning_ignore("unused_parameter")
func _function_1(args=[]):
	print(args)

@warning_ignore("unused_parameter")
func _function_params_1(a,b=null,c=null):
	print(a)

@warning_ignore("unused_parameter")
func _function_2(args=[]):
	pass

@warning_ignore("unused_parameter")
func _function_params_2(a,b=null,c=null):
	pass

@warning_ignore("unused_parameter")
func _function_3(args=[]):
	pass

@warning_ignore("unused_parameter")
func _function_params_3(a,b=null,c=null):
	pass

@warning_ignore("unused_parameter")
func _function_4(args=[]):
	pass

@warning_ignore("unused_parameter")
func _function_params_4(a,b=null,c=null):
	pass

@warning_ignore("unused_parameter")
func _function_5(args=[]):
	pass

@warning_ignore("unused_parameter")
func _function_params_5(a,b=null,c=null):
	pass

@warning_ignore("unused_parameter")
func _function_6(args=[]):
	pass

@warning_ignore("unused_parameter")
func _function_params_6(a,b=null,c=null):
	pass
