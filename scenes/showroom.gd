extends Node3D

var _cam_auto_rotate := true


func _ready():
	Globals.scene_config_changed.connect(apply_config)
	await get_tree().process_frame
	apply_config()
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_SSAO


func _process(delta):
	if not Globals.settings_visible:
		$CamAxisY.rotate_y(Input.get_axis(&"ui_left", &"ui_right") * delta * 0.25)
		$CamAxisY/CamAxisX.rotate_x(Input.get_axis(&"ui_up", &"ui_down") * delta * 0.25)
	if _cam_auto_rotate:
		$CamAxisY.rotate_y(delta * 0.1)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_P:
			_cam_auto_rotate = not _cam_auto_rotate


func apply_config():
	match Globals.config_indirect_light:
		Globals.IndirectLight.NONE:
			if find_child("LightmapGI", false, false):
				$LightmapGI.queue_free()
			$WorldEnvironment.environment.sdfgi_enabled = false
		Globals.IndirectLight.LIGHTMAP:
			$WorldEnvironment.environment.sdfgi_enabled = false
			if not find_child("LightmapGI", false, false):
				var lmap := LightmapGI.new()
				lmap.light_data = load("res://scenes/showroom.lmbake")
				lmap.name = "LightmapGI"
				add_child(lmap)
		Globals.IndirectLight.SDFGI:
			if find_child("LightmapGI", false, false):
				$LightmapGI.queue_free()
			$WorldEnvironment.environment.sdfgi_enabled = true
	$WorldEnvironment.environment.volumetric_fog_enabled = Globals.config_vfog
	$WorldEnvironment.environment.ssao_enabled = Globals.config_ssao
	$WorldEnvironment.environment.ssil_enabled = Globals.config_ssil
	$WorldEnvironment.environment.glow_enabled = Globals.config_glow
