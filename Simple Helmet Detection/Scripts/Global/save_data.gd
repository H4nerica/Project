extends Node
#COLOR
var targetColor: Vector4 = Vector4(255, 218, 67, 255)
const Defaulttargetcolor: Vector4 = Vector4(255, 218, 67, 255)
var objTargetColor: Color = Color(1.0, 0.85, 0.26, 1.0)

#DATASET
var Dataset_Target = []
var matchFoond: int
var matchNotF: int

var DefaultPath = "user://DatasetJSON/dataset.json"

#STATUS
var isLoaded: bool = false

#IMG LOGIC STUFF
var minPixel: float = 0.02
var Default_MinPixel: float = 0.02

#IMG SAVED
var ColorExtract_IMG: Array = []
var FeatureExt: Array = []
var ClearingIMG: Array = []
var ClearingIMG_totalpixel: Array = []
var objectCOUNT: Array = []

#UI
@onready var debug_txt: Label

#OBJECT
var objectShapeArray0: Array = []
var objectShapeArray1: Array = []
var objectShapeArray2: Array = []
var objectShapeArray3: Array = []
var objectShapeArray4: Array = []
var objectShapeArray5: Array = []
