extends Node3D

var _cam_auto_rotate := true


func _ready():
	Globals.scene_config_changed.connect(apply_config)
	await get_tree().process_frame
	apply_config()


func _process(delta):
	if not Globals.settings_visible:
		$CamAxisY.rotate_y(Input.get_axis(&"ui_left", &"ui_right") * delta * 0.25)
		$CamAxisY/CamAxisX.rotate_x(Input.get_axis(&"ui_up", &"ui_down") * delta * 0.25)
	if _cam_auto_rotate:
		$CamAxisY.rotate_y(delta * 0.1)


func _unhandled_key_input(event : InputEvent):
	if event.pressed and event.keycode == KEY_1:
		$CamAxisY.rotation.y = deg_to_rad(39)
		$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
		_cam_auto_rotate = false
	if event.pressed and event.keycode == KEY_2:
		$CamAxisY.rotation.y = deg_to_rad(130)
		$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
		_cam_auto_rotate = false
	if event.pressed and event.keycode == KEY_3:
		$CamAxisY.rotation.y = deg_to_rad(220)
		$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
		_cam_auto_rotate = false
	if event.pressed and event.keycode == KEY_4:
		$CamAxisY.rotation.y = deg_to_rad(330)
		$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
		_cam_auto_rotate = false
	if event.pressed and event.keycode == KEY_5:
		$CamAxisY.rotation.y = deg_to_rad(22.23)
		$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-4.47)
		_cam_auto_rotate = false
	#if event.pressed and event.keycode == KEY_6:
		#$CamAxisY.rotation.y = deg_to_rad(180.0)
		#$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-4.47)
		#$CamAxisY/CamAxisX/Camera3D.position.z = 0
		#$CamAxisY.position.x = 0.4
		#$CamAxisY.position.y = 1.05
		#$CamAxisY.position.z = 0.0
		#_cam_auto_rotate = false


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
