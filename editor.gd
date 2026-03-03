@tool
extends Control

var editor_interface: Object
var editor_plugin: EditorPlugin

var current_node: Node
var current_property: String

var source_node: SourceNode
var nodes: Array[ResourceNode]

#region built-in_functions
func _ready() -> void:
	# Attach header controls
	%LoadButton.pressed.connect(_on_load_pressed)
	%PropertySelect.item_selected.connect(_on_property_selected)
	%SaveButton.pressed.connect(_on_save_pressed)
#endregion built-in_functions


#region public_functions
#endregion public_functions


#region private_functions
func _on_load_pressed() -> void:
	%PropertySelect.clear()

	var selected_nodes = editor_interface.get_selection().get_selected_nodes()

	if len(selected_nodes) > 1:
		_show_error("Cannot load more than one node!\nEnsure only one node is selected.")
		return
	elif len(selected_nodes) == 0:
		_show_error("No nodes selected!\nSelect a node in the Scene tree before loading.")
		return

	# Retrieve valid properties from the node
	var valid_properties: Array = []
	current_node = selected_nodes[0]
	for property in current_node.get_property_list():
		if property["hint"] != PROPERTY_HINT_RESOURCE_TYPE:
			continue

		if not property["usage"] & PROPERTY_USAGE_EDITOR:
			continue

		var value = current_node.get(property["name"])
		if value and typeof(value) != typeof(Resource):
			continue

		valid_properties.append(property)

	for property in valid_properties:
		$%PropertySelect.add_item(property["name"])

	%PropertySelect.disabled = false


## Creates the initial source node and its first resource node.
## Additional nodes are created recursively via the first resource node.
func _on_property_selected(index: int) -> void:
	current_property = %PropertySelect.get_item_text(index)
	%PropertySelect.disabled = true
	%LoadButton.disabled = true

	source_node = SourceNode.new()
	%ResourceGraphEditor.add_child(source_node)
	source_node.set_source(current_node, current_property)

	# Create first node, this will cascade to create the remaining nodes
	var resource = current_node.get(current_property)
	if not resource:
		return

	var new_node: ResourceNode = ResourceNode.new()
	%ResourceGraphEditor.add_child(new_node)
	nodes.append(new_node)

	new_node.set_resource(resource, %ResourceGraphEditor)

	# Attach initial resource and source node
	%ResourceGraphEditor.connect_node(source_node.name, 0, new_node.name, 0)

	%ResourceGraphEditor.arrange_nodes()

func _on_save_pressed() -> void:
	pass


func _show_error(message: String) -> void:
	$ErrorDialog.dialog_text = message
	$ErrorDialog.show()


func _convert_resource() -> void:

	pass
#endregion private_functions
