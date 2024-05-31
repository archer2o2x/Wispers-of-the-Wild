extends Node

var testData = """
entry: "ollanise-110-forest"

ollanise-110-forest:
- question: "What are you doing here?"
  response: "I needed some herbs for dinner tonight, I thought I would be fine to quickly find some, but I can't find any. If you find some, please bring it over, I'll give you some in return."
  follow: "ollanise-110-herb-gathering"

- question: "What are you hiding from me?"
  response: "Nothing. I just needed some herbs, but I guess it is pretty dark now. Grab some for dinner, OK?"
  follow: "ollanise-110-herb-gathering"

- question: "What are you up to, honey?"
  condition: "ollanise"
  response: "Grabbing some herbs for dinner, sweetie. It's kinda late though, could you grab some for me?"
  follow: "ollanise-110-herb-gathering"

- question: "What are you up to?"
  destination: "What are you doing here?"

- question: "What do you want from Kasperl"
  condition: "ollanise-love > 2 & kasperl-like > 3"
  responses: 
  - response: "He told you huh. It's nothing much, I just need a bit of extra help around the shop from now on."
	condition: "ollanise-love > 5"
	follow: "ollanise-110-pregnancy"
  - response: "I just went to talk to him about getting extra help for the shop. I'm getting older you know."
	follow: "ollanise-110-goodbye"

- question: "How is jorgen doing?"
  response: "Not good. The poor thing was nearly beaten to death, he's recovering but slowly. It would help if you could make him feel more comfortable upstairs, he's gonna be there awhile."
  follow: "ollanise-110-jorgen-recovery"

- question: "How did you leave the village?"
  response: "The village door, same as you presumably. Sometimes people ask the dumbest questions."
  follow: "ollanise-110-sarcasm"

ollanise-110-herb-gathering:
- question: "Which herb did you need?"
  response: "Thistleflower, I don't need much, just a sprig or two."
  follow: "ollanise-110-herb-gathering"

- question: "I'm really sorry, I can't right now."
  responses: 
  - response: "OK, well I guess I'll have to do without. Shame, just a touch would bring it to a whole new level"
	condition: "ollanise-love > 2 / ollanise-like > 4"
  - response: "Alright, I guess I should head home then. I'll grab some tomorrow"
	condition: "ollanise-like > 0 / ollanise-love > 0"
  - response: "Thanks for nothing then. Don't count on me for free medical treatment, starting tomorrow, I'm charging your ass."
"""

var data = Dictionary()
var stack = {}

func unserialize(data: String):
	return getObject(parse(data))

func serialize(data: Object):
	pass

func lcount(string, letters=" "):
	for i in range(len(string)):
		if !letters.contains(string[i]):
			return i

func strip(string, letters=" "):
	for i in letters:
		string = string.replace(i, "")
	return string

func process_line(line):
	var indent = floor(lcount(line, " -") / 2)
	var args = line.split(":", true, 1)
	var head = args[0].lstrip(" \t-").rstrip(" ")
	var tail = args[1].lstrip(" \t").rstrip(" ")
	if tail.begins_with("\"") and tail.ends_with("\""):
		tail = tail.lstrip("\"").rstrip("\"")
	elif tail.is_valid_float():
		tail = tail.to_float()
	elif tail.to_lower() == "true" or tail.to_lower() == "false":
		tail = tail.to_lower() == "true"
	elif tail == "":
		tail = {}
	return { indent = indent, head = head, tail = tail, element = args[0].lstrip(" \t").begins_with("-") }

func parse(data: String):
	var results = []
	data = data.replace("\t", "  ")
	var lines = data.split("\n", false)
	for i in range(len(lines)):
		var line = lines[i]
		results.append(process_line(line))
	return results

func getStackRef(dict, stack):
	var ref = dict
	for item in stack:
		if not ref.has(item):
			ref[item] = {}
		ref = ref[item]
	return ref

func getObject(data: Array):
	var result = {}
	var stack = []
	for i in range(len(data)):
		var token = data[i]
		var prev = data[max(i - 1, 0)]
		if token.indent > prev.indent:
			stack.push_back(prev.head)
		if token.indent < prev.indent:
			stack.pop_back()
			if typeof(getStackRef(result, stack)) == TYPE_ARRAY:
				stack.pop_back()
		if token.element:
			if typeof(getStackRef(result, stack)) == TYPE_ARRAY:
				stack[-1] = stack[-1] + 1
			else:
				var ref = getStackRef(result, stack)
				ref = []
				stack.push_back(0)
		var ref = getStackRef(result, stack)
		ref[token.head] = token.tail
	return result

func _ready():
	#print(parse(testData))
	print(unserialize(testData))
