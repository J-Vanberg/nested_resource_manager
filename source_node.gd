class_name SourceNode
extends GraphNode

## Holds the editor interface, used to interact with the inspector.
var editor_interface: EditorInterface

## Holds the source node for this chain
var _source_node: Node
## Tracks the index for the next slot to be added.
var _slot_index: int = 0

#region built-in_functions
func _ready() -> void:
	self.node_selected.connect(_on_focused)

	scaling_menus = true
	resizable = false
#endregion built-in_functions


#region public_functions
func set_source(source_node: Node, resource_property: String) -> void:
	_source_node = source_node
	title = _source_node.name

	# Add a label for the slot
	set_slot(_slot_index, false, 0, Color.WHITE, true, 0, Color.WHITE)
	var slot_label = Label.new()
	slot_label.name = resource_property
	slot_label.text = resource_property.to_pascal_case()
	self.add_child(slot_label)
	_slot_index += 1
#endregion public_functions


#region private_functions
# Runs when the node becomes the focus. Sets the node's source to the focus in the inspector.
func _on_focused() -> void:
	EditorInterface.edit_node(_source_node)
#endregion private_functions
