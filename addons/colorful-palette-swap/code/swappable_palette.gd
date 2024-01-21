tool
extends Node
# Takes a base palette and swap palettes and generates palettes to use with palette_swap.shader.
# Source:
# https://www.reddit.com/r/godot/comments/pqtqmh/palette_swaps_without_making_every_sprite/

const sizeX = 100

onready var primary_palette_path_node := $Paths/BasePalette/Value as LineEdit
onready var input_path_node := $Paths/Input/Value as LineEdit
onready var output_path_node := $Paths/Output/Value as LineEdit

var colorData := {}


func _ready():
	$Button.connect("pressed", self, "_button_pressed")


func _button_pressed():
	if not primary_palette_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Base requires a png file.")
	elif not input_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Input requires an existing directory.")
	elif not output_path_node.is_valid():
		$"%InvalidPathPopup".show_complaint("Output requires an existing directory.")
	else:
		return _generate_palettes(
			primary_palette_path_node.get_path(),
			input_path_node.get_path(),
			output_path_node.get_path())


func ensure_folder(path: String):
	if not path.ends_with("/"):
		path += "/"
	return path


func _generate_palettes(
		primary_palette_path: String,
		input_path: String,
		output_path: String):

	input_path = ensure_folder(input_path)
	output_path = ensure_folder(output_path)

	var image = Image.new()
	image.load(primary_palette_path)
	image.lock()

	var centers := []
	var lastGrey = grey(image.get_pixel(0, 0))
	centers.append(lastGrey)
	for x in range(1, image.get_width()):
		var c = image.get_pixel(x, 0)
		var currentGrey = grey(c)
		if currentGrey != lastGrey:
			centers.append(currentGrey)
			lastGrey = currentGrey

	var dir = Directory.new()
	dir.open(input_path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and file.ends_with(".png"):
			createPalette(file, centers, input_path, output_path)

	dir.list_dir_end()

	var save = File.new()
	var err = save.open(output_path +"/data.json", File.WRITE)
	if err == 0:
		save.store_string(JSON.print(colorData))
		save.close()
	else:
		print("failed to save color data file")

	print("finished generating palettes")

func grey(c:Color)->float:
	return (c.r * 1.0 + c.g * 1.0 + c.b * 1.0) / 3.0


func createPalette(file:String, centers:Array, input_path: String, output_path: String):
	var image = Image.new()
	image.load(input_path + file)
	var colors := getColors(image)
	colorData[file] = colors

	var out := Image.new()
	var sizeY := 1
	out.create(sizeX, sizeY, false, Image.FORMAT_RGB8)
	out.lock()
	var lastBorder := 0.0
	for i in range(0, colors.size()):
		var nextBorder = 0.5 * (centers[i] + centers[i+1]) if i < centers.size() - 1 else 1.0
		for ox in range(lastBorder*sizeX, nextBorder*sizeX):
			for oy in range(0, sizeY):
				out.set_pixel(ox, oy, colors[i])
		lastBorder = nextBorder
	out.unlock()
	out.save_png(output_path + file.substr(0, file.find("."))+".png")

func getColors(image:Image)->Array:
	image.lock()
	var colors := []
	colors.append(image.get_pixel(0, 0))
	var lastGrey = grey(image.get_pixel(0, 0))
	for x in range(1, image.get_width()):
		var c = image.get_pixel(x, 0)
		var currentGrey = grey(c)
		if currentGrey != lastGrey:
			colors.append(c)
			lastGrey = currentGrey
	image.unlock()
	return colors


func _on_ExecuteButton_pressed():
	print("_on_ExecuteButton_pressed", self)
	pass # Replace with function body.
