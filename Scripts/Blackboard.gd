extends Object

var data: Dictionary

func _init():
	data = Dictionary()

func setState(key, value):
	data[key] = value

func hasState(key):
	return data.find_key(key) != null

func getState(key, default):
	if hasState(key):
		return data[key]
	else:
		return default

func checkCondition(condition: String):
	var words = condition.split(" ", false)
	var stack: Array = Array()
	var next = ""
	for i in range(len(words)):
		stack.push_back(words[i])
		if words[i] == ">":
			stack.pop_back()
