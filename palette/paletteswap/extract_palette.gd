extends Node
# To run, add to scene and run scene.
#
# Takes an image and generates a palette from its pixels, sorted by brightness.
export var target_image := "res://games/dreamer_dice/art/breakdown/facility_tiles.png"

const Validate = preload("res://games/dreamer_dice/code/util/validate.gd")



class ColorSort:
	static func grey(c: Color) -> float:
		return (c.r * 1.0 + c.g * 1.0 + c.b * 1.0) / 3.0


	static func sort_ascending(a, b):
		# Sort by grey because I think that matches what paletter is expecting.
		return grey(a) < grey(b)


func _ready():
	var image = Image.new()
	image.load(target_image)
	image.lock()

	var size = image.get_size()

	var colors = {}

	for x in size.x:
		for y in size.y:
			var c = image.get_pixel(x, y)
			colors[c] = true

	var color_list = []
	for c in colors:
		color_list.append(c)

	color_list.sort_custom(ColorSort, "sort_ascending")

	create_palette("palette.png", color_list)

	print("finished extracting palette")


func create_palette(file: String, colors: Array):
	var out := Image.new()
	out.create(colors.size(), 1, false, Image.FORMAT_RGB8)

	out.lock()
	var i := 0
	for c in colors:
		out.set_pixel(i, 0, c)
		i += 1
	out.unlock()

	Validate.ok(out.save_png("res://palette/" + file))


