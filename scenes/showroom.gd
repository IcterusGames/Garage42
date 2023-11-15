extends Node3D

var _cam_auto_rotate := true
var _front_lights := false
var _blinking_left := false
var _blinking_right := false
var _tween_front_lights : Tween


func _ready():
	Globals.scene_config_changed.connect(apply_config)
	await get_tree().process_frame
	apply_config()


func _process(delta):
	if not Globals.settings_visible:
		$CamAxisY.rotate_y(Input.get_axis(&"ui_left", &"ui_right") * delta * 0.25)
		$CamAxisY/CamAxisX.rotate_x(Input.get_axis(&"ui_up", &"ui_down") * delta * 0.25)
		if $CamAxisY/CamAxisX.rotation.x > 0.15708:
			$CamAxisY/CamAxisX.rotation.x = 0.15708
		if $CamAxisY/CamAxisX.rotation.x < -1.55334:
			$CamAxisY/CamAxisX.rotation.x = -1.55334
	if _cam_auto_rotate:
		$CamAxisY.rotate_y(delta * 0.1)


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_P:
			_cam_auto_rotate = not _cam_auto_rotate


func _unhandled_key_input(event : InputEvent):
	if not event.pressed:
		return
	match event.keycode:
		KEY_1:
			$CamAxisY.rotation.y = deg_to_rad(39)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
			_cam_auto_rotate = false
		KEY_2:
			$CamAxisY.rotation.y = deg_to_rad(130)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
			_cam_auto_rotate = false
		KEY_3:
			$CamAxisY.rotation.y = deg_to_rad(220)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
			_cam_auto_rotate = false
		KEY_4:
			$CamAxisY.rotation.y = deg_to_rad(330)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-10.8)
			_cam_auto_rotate = false
		KEY_5:
			$CamAxisY.rotation.y = deg_to_rad(22.23)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-4.47)
			_cam_auto_rotate = false
		KEY_6:
			$CamAxisY.rotation.y = deg_to_rad(-155.15)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(2.75)
			_cam_auto_rotate = false
		KEY_7:
			$CamAxisY.rotation.y = deg_to_rad(86.14)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-21.59)
			_cam_auto_rotate = false
		KEY_8:
			$CamAxisY.rotation.y = deg_to_rad(-53.24)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-28.83)
			_cam_auto_rotate = false
		KEY_9:
			$CamAxisY.rotation.y = deg_to_rad(0)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-12.12)
			_cam_auto_rotate = false
		KEY_0:
			$CamAxisY.rotation.y = deg_to_rad(180)
			$CamAxisY/CamAxisX.rotation.x = deg_to_rad(-12.12)
			_cam_auto_rotate = false
		KEY_L:
			turn_front_lights(not _front_lights)
		KEY_BRACKETLEFT, KEY_Q:
			_blinking_left = not _blinking_left
			if _blinking_left:
				_blinking_right = false
				%BlinkerRight.visible = false
				%BlinkerLeftTimer.start()
				%BlinkerRightTimer.stop()
			else:
				%BlinkerLeft.visible = false
				%BlinkerLeftTimer.stop()
				%BlinkerRightTimer.stop()
		KEY_BRACKETRIGHT, KEY_E:
			_blinking_right = not _blinking_right
			if _blinking_right:
				_blinking_left = false
				%BlinkerLeft.visible = false
				%BlinkerLeftTimer.stop()
				%BlinkerRightTimer.start()
			else:
				%BlinkerRight.visible = false
				%BlinkerLeftTimer.stop()
				%BlinkerRightTimer.stop()


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


func turn_front_lights(on : bool):
	_front_lights = on
	if on:
		if _tween_front_lights:
			_tween_front_lights.kill()
		%FrontLights.visible = true
		_tween_front_lights = create_tween()
		_tween_front_lights.set_parallel(true)
		_tween_front_lights.tween_property(%OmniLightLeft, "light_energy", 7.0, 0.75)
		_tween_front_lights.tween_property(%OmniLightRight, "light_energy", 7.0, 0.75)
		_tween_front_lights.tween_property(%LightLeft, "light_energy", 7.0, 0.1)
		_tween_front_lights.tween_property(%LightRight, "light_energy", 7.0, 0.1)
	else:
		if _tween_front_lights:
			_tween_front_lights.kill()
		_tween_front_lights = create_tween()
		_tween_front_lights.set_parallel(true)
		_tween_front_lights.tween_property(%OmniLightLeft, "light_energy", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC)
		_tween_front_lights.tween_property(%OmniLightRight, "light_energy", 0.0, 0.75).set_trans(Tween.TRANS_CUBIC)
		_tween_front_lights.tween_property(%LightLeft, "light_energy", 0.0, 0.1)
		_tween_front_lights.tween_property(%LightRight, "light_energy", 0.0, 0.1)
		_tween_front_lights.set_parallel(false)
		_tween_front_lights.tween_property(%FrontLights, "visible", false, 0.0)


func _on_blinker_left_timer_timeout():
	%BlinkerLeft.visible = not %BlinkerLeft.visible


func _on_blinker_right_timer_timeout():
	%BlinkerRight.visible = not %BlinkerRight.visible
