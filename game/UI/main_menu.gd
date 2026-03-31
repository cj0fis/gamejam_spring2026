extends Control


@onready var start_button: StaticBody3D = $Panel/SubViewportContainer/SubViewport/StartButton
@onready var options_button: StaticBody3D = $Panel/SubViewportContainer/SubViewport/OptionsButton
@onready var level_select_button: StaticBody3D = $Panel/SubViewportContainer/SubViewport/LevelSelectButton
@onready var credits_button: StaticBody3D = $Panel/SubViewportContainer/SubViewport/CreditsButton
@onready var quit_button: StaticBody3D = $Panel/SubViewportContainer/SubViewport/QuitButton


const MAIN_UI = preload("uid://gnepenphw3ta")



func _ready() -> void:
	start_button.clicked.connect(start)
	options_button.clicked
	level_select_button.clicked
	credits_button.clicked
	quit_button.clicked.connect(quit)
	

func start() -> void:
	get_tree().change_scene_to_packed(MAIN_UI)
	

func quit() -> void:
	get_tree().quit()
