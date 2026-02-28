class_name ResourceNode
extends GraphNode

## Holds the editor interface, used to interact with the inspector.
var editor_interface: EditorInterface

## Holds the resource of this node.
var _resource: Resource

## Holds the properties of the resource.
var _inspector: EditorInspector

var _inspector_plugin: EditorInspectorPlugin

var _container: VBoxContainer

#region built-in_functions

func _ready() -> void:
	self.node_selected.connect(_on_focused)

	scaling_menus = true
	resizable = false

	_container = VBoxContainer.new()
	add_child(_container)

	# Always add a left slot (to parent), this slot attaches itself to _container
	set_slot(0, true, 0, Color.BLACK, false, 0, Color.BLACK)

	## Configure inspector for the managed resource
	#_inspector_plugin = EditorInspectorPlugin.new()
	#_inspector = EditorInspector.new()
	#self.add_child(_inspector)
	#_inspector.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
#endregion built-in_functions


#region public_functions
func set_resource(resource: Resource) -> void:
	_resource = resource
	title = resource.get_script().get_global_name()

	# Add right-side outputs to children based on resource properties
	var slot_index = 1
	var properties = _resource.get_script().get_script_property_list()
	for property in properties:
		if property["hint"] != PROPERTY_HINT_RESOURCE_TYPE:
			continue

		if not property["usage"] & PROPERTY_USAGE_EDITOR:
			continue

		# Add a label for the slot, name it after the property for identification
		print("Adding slot {}".format(property["name"]))
		set_slot(slot_index, false, 0, Color.WHITE, true, 0, Color.WHITE)
		var slot_label = Label.new()
		slot_label.name = property["name"]
		slot_label.text = property["name"].to_pascal_case().replace("_", " ")
		self.add_child(slot_label)

		slot_index += 1

	var min_height = 0
	var count = 0

	_container.custom_minimum_size = Vector2(200, 300)

	## this section is for custom inspector widgets
	#for property in properties:
		#if not property["usage"] & PROPERTY_USAGE_EDITOR:
			#continue
#
		#var property_editor = _inspector.instantiate_property_editor(
			#_resource,
			#property["type"],
			#_resource.resource_path,
			#property["hint"],
			#property["hint_string"],
			#property["usage"]
		#)
#
		##_inspector_plugin.add_property_editor(property["name"], property_editor, true)
		##add_child(property_editor)
#
		#property_editor.set_position(Vector2(0, min_height), true)
		#min_height += property_editor.size.y

	## This section is for using the automatic inspector for an object
	#_inspector.edit(_resource)
	#print(_inspector.get_child_count())
	#var y_size = 0
	#for child in _inspector.get_children():
		#y_size += _recursive_size(child)
	#print("Total size: " + str(y_size))
	#_inspector.custom_minimum_size = Vector2(100, min(y_size, 250))
#endregion public_functions


# Runs when the node becomes the focus. Sets the node's resource to the focus in the inspector.
func _on_focused() -> void:
	EditorInterface.edit_resource(_resource)


func _recursive_size(current_node: Node) -> float:
	var height_sum = 0
	for child in current_node.get_children():
		height_sum =+ _recursive_size(child)

	if current_node is not Control:
		return height_sum

	if current_node is not HBoxContainer and current_node is not VBoxContainer:
		return height_sum

	return height_sum + size.y
