extends Node
class_name FeatureExtract

func convertColorToHSV(inputColor: Color):
	var resultHsv: Color
	resultHsv.h = inputColor.r 
	resultHsv.s = inputColor.g 
	resultHsv.v = inputColor.b
	
	return resultHsv

func compareHsvNDifference(colorOri: Color, colorHSV: Color):
	var r_diff = abs(colorOri.r - colorHSV.r)
	var g_diff = abs(colorOri.g - colorHSV.g)
	var b_diff = abs(colorOri.b - colorHSV.b)
	var resultColor = Color(r_diff, g_diff, b_diff)
	var difference: float = 0.5
	
	if resultColor.r > difference or resultColor.g > difference and resultColor.b > difference:
		colorOri = resultColor #Color(1,1,1,1) 
		return colorOri

	return Color(0,0,0,0)

func scanHorizontal(ImgORI: Image, startingHeight: int):
	var size:Vector2 = ImgORI.get_size()
	var colorORI: Color
	var colorAFTER: Color
	
	var after_IMG: Image = ImgORI.duplicate()
	
	for width in range(size.x):
		colorORI = after_IMG.get_pixel(width, startingHeight)
		colorAFTER = compareHsvNDifference(colorORI, convertColorToHSV(colorORI))
		after_IMG.set_pixel(width, startingHeight, colorAFTER)
	return after_IMG
	
	
