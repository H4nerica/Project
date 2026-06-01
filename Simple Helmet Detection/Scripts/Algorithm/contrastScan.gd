extends Node
class_name contrastSCAN

func convertGrayscale(imgORI: Image, startingHeight: int):
	var imgAFTER: Image = imgORI.duplicate()
	var imgSIZE: Vector2i = imgAFTER.get_size()
	
	var currentColor: Color
	var currentGray: Color
	var GrayCalculation: float
	var whiteTEMP: Color = Color(1,1,1,1)
	
	var bestColor: Color
	var bestGray: Color = Color(0,0,0,1)
	
	for width in range(imgSIZE.x):
		for height in range(imgSIZE.y):
			currentColor = imgAFTER.get_pixel(width, height)
			
			if currentColor.a != 0:
				GrayCalculation = currentColor.r * 0.299 + currentColor.g * 0.587 + currentColor.b * 0.114
				currentGray = Color(GrayCalculation, GrayCalculation, GrayCalculation, 1)
				
				if currentGray.r > bestGray.r or currentGray.g > bestGray.g or currentGray.b > bestGray.b:
					bestGray = currentGray
					bestColor = currentColor
				imgAFTER.set_pixel(width, height, Color(1, 1, 1, 1))
				
	for width in range(imgSIZE.x):
		for height in range(imgSIZE.y):
			currentColor = imgAFTER.get_pixel(width, height)
			if currentColor.a != 0:
				imgAFTER.set_pixel(width, height, bestColor)
	
	print("Gray: ", bestGray)
	print("Color: ", bestColor)
	return imgAFTER
		
