class_name ResourceNode
extends GraphNode

## Holds the resource of this node.
var _resource: Resource

#region built-in_functions
func _ready() -> void:
	self.node_selected.connect(_on_focused)

	scaling_menus = true
	resizable = false

	# Always add a left slot (to parent)
	var slot_label = Label.new()
	slot_label.name = "parent_resource"
	slot_label.text = "Parent Resource"
	self.add_child(slot_label)
	set_slot(0, true, 0, Color.DARK_RED, false, 0, Color.DARK_RED)
#endregion built-in_functions


#region public_functions
## Set the resource for this node, will recursively generate nodes
## for custom properties from the resource that have an existing resource.
func set_resource(resource: Resource, graph: GraphEdit) -> void:
	_resource = resource
	title = _resource.get_script().get_global_name()

	var slot_index = 1 # Starts after parent slot (0)
	var connection_index = 0 # Starts based on the number of right slots

	# Add right-side outputs to children based on resource properties
	var properties = _resource.get_script().get_script_property_list()
	for property in properties:
		if property["hint"] != PROPERTY_HINT_RESOURCE_TYPE:
			continue

		if not property["usage"] & PROPERTY_USAGE_EDITOR:
			continue

		# Add a slot/label based on the property
		set_slot(slot_index, false, 0, Color.WHITE, true, 0, Color.WHITE)
		var slot_label = Label.new()
		self.add_child(slot_label)

		slot_label.name = property["name"]
		slot_label.text = property["name"].to_pascal_case()
		slot_label.set_position(Vector2(0, slot_index * 20))

		# Generate child resource
		var new_resource: Resource = _resource.get(property["name"])
		if new_resource:
			var new_node: ResourceNode = ResourceNode.new()
			graph.add_child(new_node)
			new_node.set_resource(new_resource, graph)
			graph.connect_node(name, connection_index, new_node.name, 0)

		slot_index += 1
		connection_index += 1
#endregion public_functions


#region private_functions
# Runs when the node becomes the focus. Sets the node's resource to the focus in the inspector.
func _on_focused() -> void:
	EditorInterface.edit_resource(_resource)
#endregion private_functions
