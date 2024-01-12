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

static func find_largest_saturation(color_list):
	var max_color = color_list[0]
	for c in color_list:
		if c.s > max_color.s:
			max_color = c
	return max_color

func _ready():
	var image := Image.new()
	Validate.ok(image.load(target_image))
	image.lock()

	var size = image.get_size()

	var colors := {}
	var hues := {}
	for x in size.x:
		for y in size.y:
			var c = image.get_pixel(x, y)
			colors[c] = c
			hues[c.h] = hues.get(c.h, [])
			hues[c.h].append(c)

	var color_list := []

	# TODO: make an exported dropdown for this.
	var filter_by_grey = true

	if hues.size() < 200:
		# Include all colours (pixel art).
		for k in colors:
			var c = colors[k]
			color_list.append(c)

	elif filter_by_grey:
		var greys := []
		for k in colors:
			var c = colors[k]
			greys.append(c)

		greys.sort_custom(ColorSort, "sort_ascending")
		var last_grey := -1.0
		for c in greys:
			var g = ColorSort.grey(c)
			var delta = g - last_grey
			if delta > 0.1:
				color_list.append(c)
				last_grey = g

	else:
		# Limit hues
		var last_hue := -1.0
		for h in hues:
			var delta = h - last_hue
			if delta > 0.005:
				var c = find_largest_saturation(hues[h])
				color_list.append(c)
				last_hue = h


	color_list.sort_custom(ColorSort, "sort_ascending")

	create_palette("palette.png", color_list)

	print("finished extracting palette")


func create_palette(file: String, colors: Array):
	var out := Image.new()
	var box_width := 1
	var size_x := colors.size() * box_width
	var size_y := box_width
	out.create(size_x, size_y, false, Image.FORMAT_RGB8)

	out.lock()
	var i := 0
	for c in colors:
		var box_offset := box_width * i
		for x in range(box_width):
			for y in range(size_y):
				out.set_pixel(box_offset + x, y, c)
		i += 1
	out.unlock()

	Validate.ok(out.save_png("res://palette/" + file))


