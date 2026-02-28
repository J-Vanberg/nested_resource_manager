@tool
extends EditorPlugin

var editor : Control
var undo_redo : EditorUndoRedoManager


func _enter_tree() -> void:
	editor = load(get_script().resource_path.get_base_dir() + "/editor.tscn").instantiate()
	editor.editor_interface = get_editor_interface()
	if editor.editor_interface == null:
		editor.editor_interface = Engine.get_singleton("EditorInterface")

	editor.editor_plugin = self
	undo_redo = get_undo_redo()
	get_editor_interface().get_editor_main_screen().add_child(editor)
	_make_visible(false)


func _exit_tree() -> void:
	if is_instance_valid(editor):
		editor.queue_free()


func _get_plugin_name():
	return "VisualResourceEditor"


func _make_visible(visible):
	if is_instance_valid(editor):
		editor.visible = visible


func _has_main_screen():
	return true


func _get_plugin_icon():
	# Until I add an actual icon, this'll do.
	return get_editor_interface().get_base_control().get_theme_icon("GraphEdit", "EditorIcons")
