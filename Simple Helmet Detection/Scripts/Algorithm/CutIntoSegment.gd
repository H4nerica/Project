extends Node

class_name CutIntoSegment

func Cut(img: Image, partSIZE: int):
	if img == null:
		#print("CHOOSE AN IMG!!")
		SaveData.debug_txt.text = "CHOOSE AN IMG!!"
		return
	
	img.convert(Image.FORMAT_RGBA8)
	var result_IMG = []
	var size_Img: Vector2i = Vector2i(img.get_width(), img.get_height())
	var segment_height = int(size_Img.y / partSIZE)
	
	print("Segment Height: ", segment_height)
	print("IMG Size: ", size_Img)
	
	for i in range(partSIZE):
		var partStartPoint_y = int(i * segment_height)
		#print(partStartPoint_y)
		
		if i == partSIZE - 1:
			segment_height = size_Img.y - partStartPoint_y
			#print(segment_height)
			
		var IMG_segment = Image.create(size_Img.x, segment_height, false, Image.FORMAT_RGBA8)
		IMG_segment.blit_rect(img, Rect2i(0, partStartPoint_y, size_Img.x, segment_height), Vector2i(0,0))
		result_IMG.append(IMG_segment)
	return result_IMG
