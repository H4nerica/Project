extends Node

class_name clearing2NDpass

func scanHorizontal(ImgORI: Image, startingHeight: int):
	var size:Vector2 = ImgORI.get_size()
	var colorORI: Color
	var colorAFTER: Color
	
	var after_IMG: Image = ImgORI.duplicate()
	
	for width in range(size.x):
		colorORI = after_IMG.get_pixel(width, startingHeight)
		
		if colorORI.r > 0.5 and colorORI. g > 0.5:
			if colorORI.r < colorORI.g:
				after_IMG.set_pixel(width, startingHeight, Color(0,0,0,0))
			else:
				after_IMG.set_pixel(width, startingHeight, Color(1,1,1,1))
		else: 
			after_IMG.set_pixel(width, startingHeight, Color(0,0,0,0))
	return after_IMG

func removeNoise(img: Image, i: int):
	var size = img.get_size()
	var imgINPUT: Image = img
	var counter:int = 0
		
	for x in range(size.x):
		for y in range(size.y):
			var color: Color = imgINPUT.get_pixel(x,y)
			if color.a == 1:
				counter += 1
		
	if counter < ((size.x * size.y) * 0.04):
		for x in range(size.x):
			for y in range(size.y):
				imgINPUT.set_pixel(x,y, Color(0,0,0,0))
	return imgINPUT
	
