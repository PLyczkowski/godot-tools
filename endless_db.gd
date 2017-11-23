tool
extends Node

# Can store and save node trees, and lists of objects
# Each object added receives a unique id, stored here and using set_meta("id", id)
# When saving a node tree, the tree's hierarchy is saved as a nested dict of node id's

onready var tools = preload("tools.gd").new()

const discarded_properties = ["_import_path", "pause_mode", "editor/display_folded", "script", "Node", "Pause", "Script Variables", "node"]

var dir

var dbslots # {id = dbslot}
var nodes_to_ids # {node = slot_id}
var slots_by_filename # {filename = {id = dbslot}} #TODO

func _init():
	dbslots = {}
	nodes_to_ids = {}

func add_node(node, properties_to_save = null, id = null): #add dbslot with node properties stored
	var dbslot = DbSlot.new()
	dbslot.class_name = node.get_class()

	# Id
	if id != null:
		node.set_meta("id", id)
		dbslot.id = id
	elif Array(node.get_meta_list()).has("id") and node.get_meta("id") != null:
		dbslot.id = node.get_meta("id")
	else:
		dbslot.id = _generate_id()
		node.set_meta("id", dbslot.id)

	# Script/scene path
	if node.get_filename() != null and node.get_filename() != "":
		dbslot.path = node.get_filename()
	else:
		var node_script
		if node.get_script() != null:
			dbslot.path = node.get_script().get_path()
			node_script = node.get_script()
		if node_script != null:
			dbslot.path = node_script.resource_path
		
	# Properties
	dbslot.node = node
	if properties_to_save == null:
		properties_to_save = []
		var properties_array = node.get_property_list()
		for property in properties_array:
			if not property.name in discarded_properties:
				properties_to_save.append(property.name)
	else:
		var node_property_names = tools.get_property_names(node)
		for property in properties_to_save:
			if not property in node_property_names:
				print("Db error: Tried to save a non existing property: ", property)
	var properties = {}
	for property in properties_to_save:
		# add conversions here (ex script to source)
		properties[property] = node.get(property)
	dbslot.props = properties
	
	# Register
	dbslots[dbslot.id] = dbslot
	nodes_to_ids[node] = dbslot.id

func remove_node(node):
	var dbslot = get_slot_by_node(node)
	if dbslot != null:
		_delete_slot(dbslot)
	# _delete_node(node)

	#update all id_trees
	#TODO only update affected hierarchies
	for id_tree in _get_slots("id_tree.gd"):
		var node_tree_root = get_node_by_slot(dbslots[id_tree.get_root_id()])
		id_tree.id_tree_dict = _node_tree_to_id_tree(node_tree_root)

func get_node_by_id(id):
	var dbslot = get_slot(id)
	if dbslot != null:
		if dbslot.get("node") != null and dbslot.node != null:
			return dbslot.node
		else:
			print("Db error: dbslot doesn't have a node")
	else:
		print("Db error: dbslot by id not found")

func get_size():
	return dbslots.size()

func _delete_slot(dbslot):
	# var node = dbslot.node
	dbslots.erase(dbslot.id)
	if dbslot.node != null:
		nodes_to_ids.erase(dbslot.node)
	# var all_children = tools.get_all_children(dbslot.node)
	# for child in all_children:
	# 	_delete_slot(child)
	# node.get_parent().remove_child(node)
	# node.queue_free()

func delete_slot_by_id(slot_id):
	delete_node(get_slot(slot_id))

func get_slot(id):
	if dbslots.keys().has(id):
		return dbslots[id]
	else:
		print("Error: dbslot not found")

func _get_slots(filename):
	var found_slots = []
	for id in dbslots.keys():
		if dbslots[id].get_filename() == filename:
			found_slots.append(dbslots[id])
	return found_slots

func get_nodes_by_filename(filename):
	pass

func get_all_nodes():
	return nodes_to_ids.keys()

func get_node_tree(name): # returns root node
	var target_root_slot

	var target_id_tree
	var id_trees_slots = _get_slots("id_tree.gd")
	for id_tree in id_trees_slots:
		if id_tree.node.name == name:
			target_id_tree = id_tree.node
			break
	
	if target_id_tree != null:
		var id_tree_dict = target_id_tree.id_tree_dict
		if id_tree_dict != null:
			var target_root_id = target_id_tree.get_root_id()
			target_root_slot = dbslots[target_root_id]
			_restore_hierarchy(target_root_slot.node, id_tree_dict[target_root_id])
	
	var target_root_node = get_node_by_slot(target_root_slot)
	if target_root_node != null:
		return target_root_node
	else:
		print("Db error: Retrieving dbslot tree failed")

func get_node_by_slot(dbslot):
	if dbslot != null and dbslot.get("id") != null:
		for node in nodes_to_ids.keys():
			if nodes_to_ids[node] == dbslot.id:
				return node
	else:
		print("Not a dbslot! -> ", dbslot)			

func add_node_tree(node_tree_root, name, properties_to_save = null):
	add_node(node_tree_root, properties_to_save)
	_add_nodes_from_tree(node_tree_root)
	var id_tree = load("res://addons/endless_editor/data_classes/id_tree.gd").new()
	id_tree.name = name
	id_tree.id_tree_dict = {nodes_to_ids[node_tree_root] : _node_tree_to_id_tree(node_tree_root)}
	add_node(id_tree)

func _node_tree_to_id_tree(root_node):
	var children = {}
	for child in root_node.get_children():
		if child.get_child_count() > 0:
			children[nodes_to_ids[child]] = _node_tree_to_id_tree(child)
		else:
			children[nodes_to_ids[child]] = null
	return children

func get_slot_by_node(node):
	var dbslot
	if nodes_to_ids.has(node):
		var id = nodes_to_ids[node]
		dbslot = dbslots[id]
	return dbslot

# func get_slot_by_name(name):	print("get_slot_by_name")
# 	for id in dbslots.keys():
# 		if dbslots[id].name == name:
# 			return dbslots[id]
# 	print("Db error: dbslot not found")

func save():
	var file = File.new()
	var status = 0
	status = file.open(dir, File.WRITE)
	if status == OK:
		for id in dbslots.keys():
			var dbslot = dbslots[id]
			dbslot.save(file)
	else:
		print("Db error: File write failed: ", status)
	file.close()

func restore():
	var file = File.new()
	if !file.file_exists(dir):
		return null
	else:
		file.open(dir, File.READ)
		
		var dict_from_line = parse_json(file.get_line())
		while !file.eof_reached():
			if dict_from_line != null and dict_from_line.size() > 0:
				var new_object

				if dict_from_line.has("path") and dict_from_line["path"] != null and dict_from_line["path"].length() > 0:
					var path = dict_from_line["path"]
					if path.ends_with(".gd"):
						new_object = load(path).new()
					elif path.ends_with(".tscn"):
						new_object = load(path).instance()
					else:
						print("Db error: Path not recognized: ", path)
				elif dict_from_line.has("class_name") and dict_from_line["class_name"] != null and ClassDB.can_instance(dict_from_line["class_name"]):
					new_object = ClassDB.instance(dict_from_line["class_name"])

				if new_object == null:
					print("Db error: Couldn't instance object from line: ", dict_from_line)
				else:
					# Id
					new_object.set_meta("id", dict_from_line["id"])

					# Properties
					var properties
					if dict_from_line["props"] != null:
						properties = dict_from_line["props"]
						for property_name in properties.keys():
							new_object.set(property_name, properties[property_name])
					else:
						properties = {}
					
					# Register
					add_node(new_object, properties.keys(), dict_from_line["id"]) #todo this does things twice

			dict_from_line = parse_json(file.get_line())
		file.close()

func set_dir(dir):
	self.dir = dir

func print_db():
	print("Printing db:")
	print("")
	for dbslot in dbslots.values():
		prints(dbslot.id, "Class name:", dbslot.class_name, "Filename:", dbslot.get_filename())
		if dbslot.node != null:
			tools.analyze_node(dbslot.node)
		else:
			print("No node")
		print("")

func clear():
	dbslots = {}
	slots_by_filename = {}

# PRIVATE

func _generate_id():
	randomize()
	var id = str(randi())
	return id # TODO better method

func _restore_hierarchy(node, dict):
	for id in dict.keys():
		var child_node
		if get_slot(id).get("node") != null and get_slot(id).node != null:
			child_node = get_slot(id).node

		if child_node != null:
			node.add_child(child_node)
		else:
			print("Db error: Restoring hierarchy - node not found")
		if dict[id] != null:
			_restore_hierarchy(child_node, dict[id])

func _add_nodes_from_tree(node_tree_root):
	for child in node_tree_root.get_children():
		add_node(child)
		if child.get_child_count() > 0:
			_add_nodes_from_tree(child)

class DbSlot extends Object: # A dbslot holding an object the database stores

	var id
	var path # script path
	var class_name # for instance "GraphNode"
	var props # {"property_name":property_value}
	var node # node_ref, if it stores a node

	func get_filename():
		if path != null:
			return path.right(path.find_last("/") + 1)

	func save(file):
		var savedict = {}
		var props = get_property_list()
		for property in props:
			var value = self.get(property.name)
			if not property.name in discarded_properties:
				savedict[property.name] = value
		var line = to_json(savedict)
		if line.length() > 0:
			file.store_line(line)