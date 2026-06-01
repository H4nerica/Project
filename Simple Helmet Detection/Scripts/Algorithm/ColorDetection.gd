extends Node
class_name colorDetection

#PIXEL STUFF
var totalPixel: int = 0
var segmentColor = []
var sum_color: Color #ADDING all color into one 
var average: Color

#SEGMENT STUFF
var counter: int = 0
var pic_width: int = 0
var IsFound: bool = false

#MINIMUM PIXEL
const tolerance: float = 0.15


#--- Extracting Color ---
func get_colorInPixel(imgORI: Image, targetColor: Vector4, differenceColor: Vector3):
	#Clear totalPixel first so it doesnt stack
	sum_color = Color(0, 0, 0, 0)
	totalPixel = 0
	
	if imgORI == null:
		return
	
	var result_IMG: Image
	var size = imgORI.get_size()
	result_IMG = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	result_IMG.fill(Color(0, 0, 0, 0)) # Start transparent
	
	#TO be used in other code
	pic_width = size.x
	counter = 0
	
	var color: Color
	var colorVec: Vector4
	var found_px
	var draw_color: Color
	
	var red_px
	var green_px
	var blue_px
	var alpha_px
	
	for x in range(size.x):
		for y in range(size.y):
			color = imgORI.get_pixel(x,y) * 255
			
			# -- Colour --
			red_px = color.r
			green_px = color.g
			blue_px = color.b
			alpha_px = color.a
			
			colorVec = Vector4(red_px, green_px, blue_px, alpha_px)
			found_px = scan_color(colorVec, targetColor, Vector2i(x,y), differenceColor)
			
			if found_px != null:
				draw_color = Color(found_px.x / 255.0, found_px.y / 255.0, found_px.z / 255.0, 1.0)
				result_IMG.set_pixel(x, y, draw_color) #put color to x,y in the image
				sum_color += draw_color
				totalPixel += 1
				
	#Averaging the color per segment than saved them into array
	if totalPixel > SaveData.minPixel * (size.x * size.y):
		average = sum_color / totalPixel
		segmentColor.append(average)
	else:
		segmentColor.append(Color(0,0,0,0))
	return result_IMG

func scan_color(colorVec: Vector4, targetColor: Vector4, _pos: Vector2i, differenceColor: Vector3):
	var r_diff = abs(colorVec.x - targetColor.x)
	var g_diff = abs(colorVec.y - targetColor.y)
	var b_diff = abs(colorVec.z - targetColor.z)

	if r_diff <= int(differenceColor.x) and g_diff <= int(differenceColor.y) and b_diff <= int(differenceColor.z):
		return colorVec
	return null


#--- Color Matching Stuff ---
func matchMaking():
	var dataset = SaveData.Dataset_Target
	for index_data in range(dataset.size()):
		for index_segment in range(segmentColor.size()):
			if IsFound == false:
				Istarget_OrNO(dataset[index_data], segmentColor[index_segment])
			else:
				#stop looking for a match if already found
				return

func Istarget_OrNO(colorToCompare: Color, perSegmentColor: Color):
	var r_diff = abs(perSegmentColor.r - colorToCompare.r)
	var g_diff = abs(perSegmentColor.g - colorToCompare.g)
	var b_diff = abs(perSegmentColor.b - colorToCompare.b)
	
	if r_diff < tolerance and g_diff < tolerance and b_diff < tolerance:
		#print("FOOND TARGET")
		SaveData.matchFoond += 1
		IsFound = true
	else: 
		#print("Not Match")
		SaveData.matchNotF += 1

func scanHorizontal(imgORI: Image, StartingY: int, targetColor: Vector4, differenceColor: Vector3):
	#Clear totalPixel first so it doesnt stack
	sum_color = Color(0, 0, 0, 0)
	totalPixel = 0
	
	if imgORI == null:
		return
	
	var size = imgORI.get_size()
	
	#TO be used in other code
	pic_width = size.x
	counter = 0
	
	var color: Color
	var colorVec: Vector4
	var found_px
	var draw_color: Color
	
	var red_px
	var green_px
	var blue_px
	var alpha_px
	
	for x in range(size.x):
		color = imgORI.get_pixel(x, StartingY) * 255
		
		# -- Colour --
		red_px = color.r
		green_px = color.g
		blue_px = color.b
		alpha_px = color.a
		
		colorVec = Vector4(red_px, green_px, blue_px, alpha_px)
		found_px = scan_color(colorVec, targetColor, Vector2i(x, StartingY), differenceColor)
		
		if found_px != null:
			draw_color = Color(found_px.x / 255.0, found_px.y / 255.0, found_px.z / 255.0, 1.0)
			imgORI.set_pixel(x, StartingY, draw_color)
			sum_color += draw_color
			totalPixel += 1

	return imgORI
