tool
extends EditorPlugin

const ExtractPalettePopup = preload("res://addons/colorful-palette-swap/panel/popup_extract_palette.tscn")
const SwappablePalettePopup = preload("res://addons/colorful-palette-swap/panel/popup_swappable_palette.tscn")
const bar_scene = preload("res://addons/colorful-palette-swap/panel/palette_commands.tscn")

const MENUITEM_EXTRACT_PALETTE := "Extract Palette"
const MENUITEM_SWAPPABLE_PALETTE := "Create Swap Palettes"

var bar
var bar_btn: ToolButton


func _enter_tree():
	# Don't add the bottom bar because this isn't a frequent enough action to
	# require having it around all the time.
	#~ bar = bar_scene.instance()
	#~ bar.plugin = self
	#~ bar_btn = add_control_to_bottom_panel(bar, "Colorful Swap")
	#~ # Need extra space to push above toolbar buttons. Bottom margin didn't work.
	#~ bar.rect_min_size.y = bar.rect_size.y + 50

	add_tool_menu_item(MENUITEM_EXTRACT_PALETTE, self, "_extract_palette")
	add_tool_menu_item(MENUITEM_SWAPPABLE_PALETTE, self, "_swappable_palette")


func _show_popup(popup: WindowDialog, title: String) -> WindowDialog:
	# Godot4: Use EditorInterface.popup_dialog_centered()
	get_editor_interface().get_base_control().add_child(popup)
	popup.popup_centered()
	popup.set_as_minsize()
	popup.window_title = title
	popup.connect("popup_hide", self, "_rescan_filesystem")
	return popup
	

func _extract_palette(__):
	var source_image_path := get_editor_interface().get_current_path()
	var output_path := "res://extracted-palette.png"

	var popup := _show_popup(ExtractPalettePopup.instance(), MENUITEM_EXTRACT_PALETTE)
	var extract_palette = popup.get_node("%ExtractPalette")
	extract_palette.source_image_path_node.set_text_and_validate(source_image_path)
	extract_palette.output_path_node.set_text_and_validate(output_path)


func _swappable_palette(__):
	var source_image_path := get_editor_interface().get_current_path()
	var input_path := "res://colorfulpalette-input/"
	var output_path := "res://colorfulpalette-output/"
	var popup := _show_popup(SwappablePalettePopup.instance(), MENUITEM_SWAPPABLE_PALETTE)
	var swappable_palette = popup.get_node("%GenerateSwapPalettes")
	swappable_palette.primary_palette_path_node.set_text_and_validate(source_image_path)
	swappable_palette.input_path_node.set_text_and_validate(input_path)
	swappable_palette.output_path_node.set_text_and_validate(output_path)


func _exit_tree():
	if bar:
		remove_control_from_bottom_panel(bar)
		bar.queue_free()
	remove_tool_menu_item(MENUITEM_EXTRACT_PALETTE)
	remove_tool_menu_item(MENUITEM_SWAPPABLE_PALETTE)


func _rescan_filesystem():
	get_editor_interface().get_resource_filesystem().scan()

