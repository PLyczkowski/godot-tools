tool
extends Node

### Settings

const debug_mode = true
const debug_verbose = false
const print_line_width = 76

### Internal

var _dictionary
const _uppercase_letters = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
const discarded_properties = ["_import_path", "pause_mode", "editor/display_folded", "script", "Node", "Pause", "Script Variables"]
const _positive_infinity = 3.402823e+38

#Printing

func print_objects(objects):
	for object in objects:
		print_object(object)

func print_object(object):
	for property in object.get_property_list():
		print(" ", property.name, ": ", object.get(property.name))

func print_node_info(node, on = 1):
	if on > 0 or debug_verbose == true:
		print("Node " + str(node) + " info:")
		print("Name: " + node.get_type())
		print("Type: " + node.get_type())
		if node.get_script() != null:
			print("Node has a script:")
			var script = node.get_script()
			print("Name: " + script.get_name())
			print("Path: " + script.get_path())
		print("Node children amount: " + str(node.get_child_count()))
		# if node.get_child_count() > 0: print("Children:")
		# for child in node.get_children():
		# 	print("Name: " + node.get_type())
		# 	print("Type: " + node.get_type())

func print_var(variable, on = 1):

	if on > 0 or debug_verbose == true:
		_print_var(variable, "  ")

func _print_varX(variable):

	if typeof(variable) == TYPE_ARRAY:
		print_array(variable)

	elif typeof(variable) == TYPE_DICTIONARY:
		print_dict(variable)

	else:
		print(variable)

func _print_var(variable, indent = ''):

	if typeof(variable) == TYPE_DICTIONARY:
		var keys = variable.keys()
		keys.sort()
		for key in keys:
			var value = variable[key]
			if typeof(value) == TYPE_DICTIONARY:
				print(indent,str(key),':')
				_print_var(variable[key], indent+'    ')
			else:
				print(indent,key,': ',value)
	else:
		if typeof(variable) == TYPE_ARRAY:
			print_array(variable)
		else:
			print(variable)

func print_array(array, on = 1): #deprecated, 1 means always on, 0 means off by default

	if on > 0 or debug_verbose == true:

		if on==1 or on==0:
			#text = str(text).left(75) #< This is to truncate text
			for i in range(array.size()):
				print(str(array[i]))

		elif on==2:
			print("----------------- "+str(array))

		print_line()

func print_dict(dict, on = 1): #deprecated

	if on > 0 or debug_verbose == true:

		if dict != null and typeof(dict) == TYPE_DICTIONARY:

			for key in dict:
				if typeof(dict[key]) in [TYPE_ARRAY, TYPE_DICTIONARY]:
					print_title(str(key))
					_print_var(dict[key])

				else:
					print(str(key) + ": " +str(dict[key]))

func print_dict_sorted_by_values(dict):

	var sorted_keys = sort_keys_by_values(dict)

	for key in sorted_keys:

		print(str(key) +":"+ str(dict[key]))

func print_warning(warning, on = 1):

	if OS.is_debug_build() and on == 1:
		print_message( str("!!! "+warning) )

func print_error(error):

	print("!!! "+error)

	if OS.is_stdout_verbose():
		var main_loop = get_scene()
		main_loop.quit()

func print_message(text, on = 1): #1 means always on, 0 means off by default
	if OS.is_debug_build() and on > 0 or debug_verbose == true:
		if on==1 or on==0:
			#text = str(text).left(75) #< This is to truncate text
			text = str("  "+text)
			print(str(text))

		elif on==2:
			print("----------------- "+str(text))

func print_line():

	var line = ""

	for i in range(0, print_line_width):
		
		line = line + "-"

	print(line)

func print_title(title):

	title = str(" "+title+" ")

	var line = ""

	for i in range(0, (print_line_width - title.length())/2 ):
		
		line = line + "-"

	line = line + title

	for i in range(0, (print_line_width - title.length())/2 ):
		
		line = line + "-"

	print("")
	print(line)
	print("")

func print_subtitle(subtitle):

	var line = "---- " + subtitle + " ----"
	var empty_space_for_prepending = ""
	
	for i in range(0, floor( (print_line_width - line.length() )/2 ) ):
		empty_space_for_prepending = empty_space_for_prepending + " "

	line = empty_space_for_prepending + line
	print(line)

#Arrays

func shuffle_array(array):

	var shuffled_array = []

	var indexList = range(array.size())

	for i in range(array.size()):

		var x = randi()%indexList.size()

		shuffled_array.append(array[x])

		indexList.remove(x)

		array.remove(x)

	return shuffled_array

func copy_array(array): #TODO TEST

	var new_array = [] + array

	return new_array

func shared_in_arrays(array1, array2):

	var shared = []

	for item in array1:

		if array2.has(item):

			shared.append(item)

	return shared

func not_shared_in_arrays(array1, array2):

	var longer_array
	var shorter_array

	if array1.size() > array2.size():

		longer_array = array1
		shorter_array = array2

	elif array1.size() < array2.size():

		longer_array = array2
		shorter_array = array1

	elif array1.size() == array2.size():

		breakpoint

	var not_shared = []

	for item in longer_array:

		if shorter_array.has(item) == false:

			not_shared.append(item)

	return not_shared

func array_insert(array1, array2, position): #inserts array1 into position in array2

	var array2_front = array_before(array2, position)

	var array2_back = array_after(array2, position)

	var array = []

	array_append(array, array2_front)
	array_append(array, array1)
	array_append(array, array2_back)

	return array

func array_before(array, position):

	var output_array = []

	for i in range(0, position):

		output_array.append(array[i])

	return output_array

func array_after(array, position):

	var output_array = []

	for i in range(position, array.size()):

		output_array.append(array[i])

	return output_array

func array_append(array1, array2): #appends array2 after array1

	for item in array2:

		array1.append(item)

func merge_arrays(array1, array2):

	array_append(array1, array2)

#Dict

func sort_keys_by_values(dict): #returns an array of dictionary's keys sorted by dictionary's values (ints), increasing

	_dictionary = dict

	var keys = dict.keys()

	keys.sort_custom(self,"_sort_keys_by_values")

	return keys

func _sort_keys_by_values(a, b):

	if _dictionary[a] < _dictionary[b]:

		return true

	else:

		return false

func find_closest_in_dict(dict, value): # dictionary must have floats as keys

	var diff = _positive_infinity

	var x

	for key in dict.keys():

		if diff > abs(value-key):

			diff = abs(value-key)

			x = key

	return x

func merge_dict(dict1, dict2): #the second overwrites the first

	for key in dict2.keys():

		dict1[key] = dict2[key]

	return dict1

func copy_dict(dict):

	var new_dict = {}

	for key in dict.keys():

		new_dict[key] = dict[key]

	return new_dict

func pick_exponential_dictionary(dictionary): #TEMP

	var integer = exponential_int(0, dictionary.size()-1)

	var key = dictionary.keys()[integer]

	return key

#Strings

func replace_by_index(original_string, insert_string, start_index, end_index):

	var outer_left = original_string.left(start_index)
	var outer_right = original_string.right(end_index)

	var new_string = outer_left + insert_string + outer_right

	return new_string

func increment_string_number(string):# String 9 > String 10

	var digits = ["0","1","2","3","4","5","6","7","8","9"]

	if string[string.length()-1] in digits:
		
		var index = string.length()-1
		while string[ index -1 ] in digits:
			index -= 1
			
		var number = int(string.right(index)) +1
		return string.left(index) + str(number)
		
	else:
		
		return string + " 1"

func capitalize_first(string):

	var first_letter = string.left(1)
	var rest = string.right(1)

	first_letter = first_letter.to_upper()

	return str(first_letter + rest)

func get_word(string, word_number):

	var words_array = string.split(" ")

	if words_array.size()-1 >= word_number && words_array[word_number].length() > 0:

		return words_array[word_number]

	else:

		return null#0 is first

func shorten(string, number): #shorten by the specified number of letters

	return string.left( string.length() - number ) 

func trim(string, number): #shorten by the specified number of letters

	shorten(string, number)

func get_words(string): #returns array

	string = string.strip_edges()

	var array = string.split(" ", false)

	var final_array = []
	for item in array:

		if item.find(",") != -1:
			var array2 = item.split(",", false)
			for item2 in array2:
				final_array.append(item2)
		
		else:
			final_array.append(item)

	return final_array

func get_word_count(string): #returns int

	var words = get_words(string)

	return words.size()

func right_of_substring(string, substring): #starts from the right

	var loc = string.rfind(substring)
	loc += substring.length() +1
	return string.right(loc)

func get_bracket_content(text, bracket_left, bracket_right): #returns string

	var content = text.right(text.find(bracket_left) +1)
	content = content.left(content.find(bracket_right))

	return content

#Random

func choose_random(array, amount = 1):

	return pick_random(array, amount)

func pick_random_key(dict, amount = 1): #returns item if amount = 1, array if amount > 1

	var array = dict.keys()

	var picked

	if amount == 1:

		var random = randi() % array.size()

		picked = array[random]

	else:

		picked = []

		if amount > array.size():

			amount = array.size()

		for i in range(0, amount):

			var random = randi() % array.size()

			picked.append(array[random])

			array.remove(random)

	return picked

func pick_exponential(list): #list is array or dict

	if typeof(list) == TYPE_ARRAY:

		var integer = exponential_int(0, list.size()-1)

		return list[integer]

	elif typeof(list) == TYPE_DICTIONARY:

		var integer = exponential_int(0, list.size()-1)

		return list[ list.keys()[integer] ]

func choose_exponential(array):

	return pick_exponential(array)

func pick_random(array, amount = 1): #returns item if amount = 1, array if amount > 1

	if array.size() > 0:
		var picked = []
		if amount > array.size():
			amount = array.size()

		for i in range(0, amount):
			var random = randi() % array.size()
			picked.append(array[random])
			array.remove(random)
		
		if picked.size() == 1:
			return picked[0]

		else:
			return picked

func pick_weighted_random(inc_dict_with_weights): #weight as values in float
		
	var dict_with_weights = copy_dict(inc_dict_with_weights)

	var total_weight = 0.0
	for weight in dict_with_weights.values():
		total_weight += weight

	var random = rand_range(0.0, total_weight)

	var keys_sorted_by_weights = sort_keys_by_values(dict_with_weights)

	var dict_with_tresholds = {}
	var sum_of_previous = 0.0
	for key in keys_sorted_by_weights:

		var weight = dict_with_weights[key]

		var treshold = weight + sum_of_previous
		sum_of_previous += weight
		dict_with_tresholds[key] = treshold

	keys_sorted_by_weights.invert()
	var current_treshold = total_weight
	for key in keys_sorted_by_weights:

		current_treshold -= dict_with_weights[key]
		if random > current_treshold:
			return key

func pick_using_rarity(dict_array): #takes array of dicts with rarity key, returns single dict

	var dict_with_weights = {}

	for dict in dict_array:
		if dict.rarity == "common":
			dict_with_weights[dict] = 1.0

		elif dict.rarity == "uncommon":
			dict_with_weights[dict] = 0.25

		elif dict.rarity == "rare":
			dict_with_weights[dict] = 0.08

		elif dict.rarity == "epic":
			dict_with_weights[dict] = 0.02

	return pick_weighted_random(dict_with_weights)
		
func random_range_int(start, end):

	return round( rand_range(start, end) )

func exponential_int(base, ran): #ran is range

	var mean = ran/4

	var random_int = floor(-mean * log(1-rand_range(0, 1)))

	if random_int > base + ran:

		random_int = base + ran

	return base + random_int

func random(base, ran): #ran is range

	var float_from = base - ran

	var float_to = base + ran

	var output = rand_range(float_from, float_to)

	return output
func roll_chance(percent): #makes random roll, returns true or false

	var random_int = random_int(50, 50)

	if random_int <= percent:

		return true

	else:

		return false

func random_int(base, ran): #ran is range. 0-100 is base 50 ran 50

	var output = round( random(base, ran) )

	return output

func gaussian(base, ran): #ran is range

	var mean = base *10 #added this because it wasn't working with mean and deviation set to 1
	var deviation = ran *10

	deviation = deviation /4

	var x1 = null
	var x2 = null
	var w = null

	while true:

		x1 = rand_range(0, 2) - 1
		x2 = rand_range(0, 2) - 1
		w = x1*x1 + x2*x2

		if 0 < w && w < 1:
			break

	w = sqrt(-2 * log(w)/w)

	var output = mean + deviation * x1 * w

	output = output/10

	if output > base + ran:
		output = base + ran
	elif output < base - ran:
		output = base - ran

	return output

func gaussian_int(mean, deviation):

	var output = floor(gaussian(mean, deviation))

	return int(output)

#Files

func node_filename(node): #returns filename
	return node.get_filename().right( node.get_filename().find_last("/") + 1)
	
func get_file_dirs(path): #returns dirs

	var files = []

	var dir = Directory.new()

	if dir.open(path) == OK:

		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":

			if file_name.begins_with(".") != true:

				if dir.current_is_dir():

					pass

				else:

					#print("Found file: " + file_name)

					files.append( str(path +"/"+ file_name) )

			file_name = dir.get_next()

	else:

		print("An error occurred when trying to access the path.")

	return files

func get_dirs(path): #returns dirs

	var dirs = []

	var dir = Directory.new()

	if dir.open(path) == OK:

		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":

			if file_name.begins_with(".") != true:

				if dir.current_is_dir():

					#print("Found directory: " + file_name)

					dirs.append( str(path + "/" +file_name) )

			file_name = dir.get_next()

	else:

		print("An error occurred when trying to access the path.")

	return dirs

func get_subdirs(initial_dir): #returns dirs, recursive

	var dirs = []

	for dir in get_dirs(initial_dir):

		dirs.append(dir)

		if get_dirs(dir).size() > 0:

			for i in range(0, get_subdirs(dir).size() ):

				dirs.append( get_subdirs(dir)[i] )

	return dirs

func get_file_dirs_from_subdirs(path): #returns paths

	var files = []

	var all_dirs = get_subdirs(path)
	all_dirs.append(path)

	for i in range(0, all_dirs.size()):

		for n in range(0, get_file_dirs(all_dirs[i]).size() ):

			files.append( get_file_dirs(all_dirs[i])[n] )

	return files

#Nodes

func analyze_node(node):
	print("Anylizing: ",node)
	# print("  ", "get_child_count(): ",node.get_child_count())
	print("  ", "get_children(): ",node.get_children())
	# print("  ", "get_filename(): ",node.get_filename())
	# print("  ", "get_groups(): ",node.get_groups())
	# print("  ", "get_index(): ",node.get_index())
	# print("  ", "get_name(): ",node.get_name())
	# print("  ", "get_owner(): ",node.get_owner())
	# print("  ", "get_parent(): ",node.get_parent())
	# print("  ", "get_path(): ",node.get_path())
	# print("  ", "get_position_in_parent(): ",node.get_position_in_parent())
	# print("  ", "get_scene_instance_load_placeholder(): ",node.get_scene_instance_load_placeholder())
	# print("  ", "get_tree(): ",node.get_tree())

	var property_names = get_property_names(node)
	print("  ", "Properties:")
	for property_name in property_names:
		if not property_name in discarded_properties:
			print("  ", "  ", property_name, ": ", node.get(property_name))

func get_property_names(node):
	var properties = node.get_property_list()
	var property_names = []
	for property in properties:
		property_names.append(property.name)
	return property_names

func get_filename(node): # has to have path
	var path = node.get_script().get_path()
	return path.right(path.find_last("/") + 1)
func generate_id(): #returns int

	#GUID
	#var id = str(OS.get_unix_time()) + str(randi())

	#RAND64
	# var id = (randi() << 32) | randi()

	#RAND32
	# var id = randi()

	# var id = _uppercase_letters[randi() % 26] + _uppercase_letters[randi() % 26] + _uppercase_letters[randi() % 26] + str(OS.get_unix_time()).right(6)
	var id = _uppercase_letters[randi() % 26] + _uppercase_letters[randi() % 26] + _uppercase_letters[randi() % 26] + str(randi() % 9999)

	return id

func get_all_children(node): #returns array

	var children = []
	for N in node.get_children():
		children.append(N)

		if N.get_child_count() > 0:
			var subchildren = get_all_children(N)
			
			for subchild in subchildren:
				children.append(subchild)

	return children
	
func get_root(node): #WIP

	return node.get_tree().get_root().get_child(0)

func invert_children_order(node):

	var children_inverted = node.get_children()
	children_inverted.invert()

	for child in children_inverted:

		node.move_child(child, 0)

	# for child in node.get_children():

	# 	node.remove_child(child)

	# for child in children_inverted:

	# 	node.add_child(child)

func transfer_all_children(from_node, to_node):

	var children = from_node.get_children()

	for i in range(children.size()):

		var child = children[i]
		from_node.remove_child(child)
		to_node.add_child(child)
		from_node.set_owner(to_node)

func reparent(from_node, to_node):

	transfer_all_children(from_node, to_node)

func add_children_below_node(children, node):

	var index = node.get_index()

	var parent = node.get_parent()

	for i in range(children.size()):

		var child = children[i]

		parent.add_child(child)

		parent.move_child(child, index + i +1)

func get_name_path_to_node(bottom_node, top_node):

	var path = ""

	path = bottom_node.get_name() + path

	if bottom_node.get_parent() != null and bottom_node.get_parent() != top_node:

		path =   get_name_path_to_node( bottom_node.get_parent(), top_node ) + "/" + path

	else:

		#path = top_node.get_name() + "/" + path
		pass

	return path


#Other

func functions_from_script(script): #returns array of strings

	var functions = []
	var index = script.find("func ") + 5

	while index != -1:

		var initial_index = index

		var left = index
		index = script.find("(", index)
		var right = index

		var function = script.substr(left, right - left)

		index = script.find("func ", index) + 5

		if index > initial_index:
			functions.append(function)
		else:
			break

	return functions

func test_access():

	print("Test succesful")

func initialize_all_children(node): #in endless engine #TODO remove

	var children = node.get_children()

	for child in children:

		child.initialize()

		if child.get_child_count() > 0:

			initialize_all_children(child)

func match_type(var1, var2): #will try to cast var1 type to var2's type, and return var1

	if typeof(var1) != typeof(var2):

		if typeof(var2) == TYPE_INT:

			_match_type_report(var1, var2)

			var1 = int(var1)

		elif typeof(var2) == TYPE_REAL:

			_match_type_report(var1, var2)

			var1 = float(var1)

	return var1

func _match_type_report(var1, var2):

	#print_message("Converting " + typeof_string(var1) + " to " + typeof_string(var2))
	print_message("Converting " + str( typeof(var1) ) + " to " + str( typeof(var2) ))



func remove_and_delete_all_children(node):

	var children = node.get_children()

	for i in range(children.size()):

		children[i].get_parent().remove_child(children[i])
		if children[i].is_inside_tree():
			children[i].queue_free()
		else:
			children[i].free()

func remove_node(node):

	var parent = node.get_parent()

	if parent != null:

		parent.remove_child(node)
		if node.is_inside_tree():
			node.queue_free()
		else:
			node.free()

func remove_and_delete_node_and_all_children(node):

	remove_and_delete_all_children(node)

	remove_node(node)

func remove_all_children(node):

	var children = node.get_children()

	for i in range(children.size()):

		node.remove_child(children[i])

func add_children(node, children):

	for i in range(children.size()):

		node.add_child(children[i])





func rgb(r, g, b):

	var r_converted = r/256.0
	var g_converted = g/256.0
	var b_converted = b/256.0

	return Color(r_converted, g_converted, b_converted)

func get_absolute_path(node, node_name):

	var path_to_target_node = str(node.get_path())+"/"+node_name

	print(path_to_target_node)

	return path_to_target_node

func check_arguments(inc_args, possible_args, mandatory_args = [], inc_default_args = {}):

	var args = copy_dict(inc_args)
	var default_args = copy_dict(inc_default_args)

	print_message("Checking args: "+str(args), 0)
	print_message("Possible_args: "+str(possible_args), 0)
	print_message("Mandatory_args: "+str(mandatory_args), 0)
	print_message("Default_args: "+str(default_args), 0)

	if typeof(args) != TYPE_DICTIONARY:

		print_warning("Arguments have to be in a dictionary > example({here})")
		breakpoint

	if typeof(possible_args) != TYPE_DICTIONARY:

		breakpoint

	if typeof(default_args) != TYPE_DICTIONARY:

		breakpoint

	if typeof(mandatory_args) != TYPE_ARRAY:

		breakpoint

	args = set_default_arguments(args, default_args)

	for key in args.keys():

		if possible_args.keys().has(key) != true:

			print_warning("Unknown argument: "+str(key))
			breakpoint

	for arg in mandatory_args:

		if args.has(arg) != true:

			print_warning("Missing mandatory argument: "+str(arg))
			breakpoint

	for arg in mandatory_args:

		if possible_args.keys().has(arg) != true:

			print_warning("An arg in mandatory args is not in possible args: "+str(arg))
			breakpoint

	for arg in default_args:

		if possible_args.has(arg) != true:

			print_warning("An arg in default args is not in possible args: "+str(arg))
			breakpoint

	for arg in args.keys():

		var value = args[arg]

		_fix_arg(arg, value, args, possible_args)

	for arg in args.keys():

		var value = args[arg]

		_check_arg(arg, value, args, possible_args)

	for arg in default_args.keys():

		var value = default_args[arg]

		_check_arg(arg, value, args, possible_args)

	return args

func _fix_arg(arg, value, args, possible_args):

	if possible_args[arg] == TYPE_REAL and typeof(value) == TYPE_INT:

		var converted_value = float(value)

		args[arg] = converted_value

func _check_arg(arg, value, args, possible_args):

	if possible_args[arg] == TYPE_STRING and typeof(value) != TYPE_STRING:

		print_warning("An arg should be a String: "+str(arg))
		breakpoint

	elif possible_args[arg] == TYPE_INT and typeof(value) != TYPE_INT:

		if typeof(value) == TYPE_REAL:

			print_warning("Using Float as an Int: "+str(arg))

		else:

			print_warning("An arg should be an Int: "+str(arg))
			breakpoint

	elif possible_args[arg] == TYPE_REAL and typeof(value) != TYPE_REAL:

		if typeof(value) == TYPE_INT:

			print_warning("Using Int as a Float: "+str(arg))

		else:

			print_warning("An arg should be a Float: "+str(arg))
			breakpoint

	elif possible_args[arg] == TYPE_VECTOR2 and typeof(value) != TYPE_VECTOR2:

		print_warning("An arg should be a Vector2: "+str(arg))
		breakpoint

	elif possible_args[arg] == TYPE_ARRAY and typeof(value) != TYPE_ARRAY:

		print_warning("An arg should be an Array: "+str(arg))
		breakpoint

	elif possible_args[arg] == TYPE_DICTIONARY and typeof(value) != TYPE_DICTIONARY:

		print_warning("An arg should be a Dict: "+str(arg))
		breakpoint

	elif possible_args[arg] == TYPE_BOOL and typeof(value) != TYPE_BOOL:

		print_warning("An arg should be a Bool: "+str(arg))
		breakpoint

func set_default_arguments(inc_args, inc_default_args):

	var args = copy_dict(inc_args)
	var default_args = copy_dict(inc_default_args)

	args = merge_dict(default_args, args)

	return args