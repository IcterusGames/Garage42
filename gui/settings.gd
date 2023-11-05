extends Control


func _ready():
	%TabContainer.get_tab_bar().grab_focus()
	%ScreenOption.clear()
	for i in DisplayServer.get_screen_count():
		%ScreenOption.add_item("Screen " + str(i + 1), i)
	
	%DisplayOption.clear()
	%DisplayOption.add_item("Windowed", DisplayServer.WINDOW_MODE_WINDOWED)
	%DisplayOption.add_item("Maximized", DisplayServer.WINDOW_MODE_MAXIMIZED)
	%DisplayOption.add_item("Fullscreen", DisplayServer.WINDOW_MODE_FULLSCREEN)
	%DisplayOption.add_item("Exclusive fullscreen", DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	%VSyncOption.clear()
	%VSyncOption.add_item("Disabled", DisplayServer.VSYNC_DISABLED)
	%VSyncOption.add_item("Enabled", DisplayServer.VSYNC_ENABLED)
	%VSyncOption.add_item("Adaptive", DisplayServer.VSYNC_ADAPTIVE)
	%VSyncOption.add_item("Mailbox", DisplayServer.VSYNC_MAILBOX)
	
	%ScaleOption.clear()
	%ScaleOption.add_item("None", Globals.ScaleMode.NONE)
	%ScaleOption.add_item("Bilinear", Globals.ScaleMode.BILINEAR)
	%ScaleOption.add_item("FSR 1.0", Globals.ScaleMode.FSR1)
	%ScaleOption.add_item("FSR 2.2", Globals.ScaleMode.FSR2)
	
	%ScaleQualityOption.clear()
	%ScaleQualityOption.add_item("Quality", 1)
	%ScaleQualityOption.add_item("Balanced", 2)
	%ScaleQualityOption.add_item("Performance", 3)
	%ScaleQualityOption.add_item("Ultra Performance", 4)
	
	%FPSCheck.button_pressed = Globals.config_show_fps
	%ShowConfigCheck.button_pressed = Globals.config_show_config
	%ShowSysInfoCheck.button_pressed = Globals.config_show_sys_info
	%ScreenOption.select(%ScreenOption.get_item_index(Globals.config_screen))
	%DisplayOption.select(%DisplayOption.get_item_index(Globals.config_display_mode))
	%VSyncOption.select(%VSyncOption.get_item_index(Globals.config_vsync_mode))
	%ScaleOption.select(%ScaleOption.get_item_index(Globals.config_scale_mode))
	%FSR2AACheck.button_pressed = Globals.config_use_fsr2aa
	%ScreenSpaceAACheck.button_pressed = Globals.config_ssaa
	%UseTAACheck.button_pressed = Globals.config_use_taa
	%DebandingCheck.button_pressed = Globals.config_use_debanding
	match Globals.config_msaa:
		Viewport.MSAA_DISABLED:
			%MSAAOption.select(%MSAAOption.get_item_index(0))
		Viewport.MSAA_2X:
			%MSAAOption.select(%MSAAOption.get_item_index(1))
		Viewport.MSAA_4X:
			%MSAAOption.select(%MSAAOption.get_item_index(2))
		Viewport.MSAA_8X:
			%MSAAOption.select(%MSAAOption.get_item_index(3))
	match Globals.config_indirect_light:
		Globals.IndirectLight.NONE:
			%ILOption.select(%ILOption.get_item_index(0))
		Globals.IndirectLight.LIGHTMAP:
			%ILOption.select(%ILOption.get_item_index(1))
		Globals.IndirectLight.SDFGI:
			%ILOption.select(%ILOption.get_item_index(2))
	%VolumetricFogCheck.button_pressed = Globals.config_vfog
	%SSAOCheck.button_pressed = Globals.config_ssao
	%SSILCheck.button_pressed = Globals.config_ssil
	%GlowCheck.button_pressed = Globals.config_glow
	update_gui()


func _enter_tree():
	Globals.settings_visible = true


func _exit_tree():
	Globals.settings_visible = false


func update_gui():
	%ScaleQualityOption.set_block_signals(true)
	%ScaleSlider.set_block_signals(true)
	match Globals.config_scale_mode:
		Globals.ScaleMode.NONE:
			%ScaleQualityOption.disabled = true
			%ScaleQualityOption.visible = false
			%ScaleSlider.visible = false
			%ScaleLabel.visible = false
			%FSR2AACheck.disabled = false
			%FSR2AACheck.visible = true
			%AAContainer.visible = true
		Globals.ScaleMode.BILINEAR:
			%ScaleQualityOption.disabled = true
			%ScaleQualityOption.visible = false
			%ScaleSlider.visible = true
			%ScaleLabel.visible = true
			%ScaleSlider.value = Globals.config_scale_3d
			%ScaleLabel.text = "%0.02f" % [Globals.config_scale_3d]
			%FSR2AACheck.disabled = true
			%FSR2AACheck.visible = false
			%AAContainer.visible = true
		Globals.ScaleMode.FSR1:
			%ScaleQualityOption.disabled = false
			%ScaleQualityOption.visible = true
			%ScaleSlider.visible = false
			%ScaleLabel.visible = false
			%FSR2AACheck.disabled = true
			%FSR2AACheck.visible = false
			%AAContainer.visible = true
			if is_equal_approx(Globals.config_scale_3d, 0.77):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(1))
			elif is_equal_approx(Globals.config_scale_3d, 0.67):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(2))
			elif is_equal_approx(Globals.config_scale_3d, 0.59):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(3))
			else:
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(4))
		Globals.ScaleMode.FSR2:
			%ScaleQualityOption.disabled = false
			%ScaleQualityOption.visible = true
			%ScaleSlider.visible = false
			%ScaleLabel.visible = false
			%AAContainer.visible = false
			if is_equal_approx(Globals.config_scale_3d, 0.67):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(1))
			elif is_equal_approx(Globals.config_scale_3d, 0.59):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(2))
			elif is_equal_approx(Globals.config_scale_3d, 0.5):
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(3))
			else:
				%ScaleQualityOption.select(%ScaleQualityOption.get_item_index(4))
	if Globals.config_use_fsr2aa:
		%UseTAACheck.disabled = true
		%UseTAACheck.visible = false
	else:
		%UseTAACheck.disabled = false
		%UseTAACheck.visible = true
	%ScaleQualityOption.set_block_signals(false)
	%ScaleSlider.set_block_signals(false)


func _on_close_button_pressed():
	queue_free()


func _on_fps_check_toggled(toggled_on):
	Globals.config_show_fps = toggled_on


func _on_show_sys_info_check_toggled(toggled_on):
	Globals.config_show_sys_info = toggled_on


func _on_show_config_check_toggled(toggled_on):
	Globals.config_show_config = toggled_on


func _on_screen_option_item_selected(index):
	Globals.config_screen = %ScreenOption.get_item_id(index)


func _on_display_option_item_selected(index):
	Globals.config_display_mode = %DisplayOption.get_item_id(index)


func _on_v_sync_option_item_selected(index):
	Globals.config_vsync_mode = %VSyncOption.get_item_id(index)


func _on_scale_option_item_selected(index):
	Globals.config_scale_mode = %ScaleOption.get_item_id(index)
	match Globals.config_scale_mode:
		Globals.ScaleMode.NONE:
			Globals.config_scale_3d = 1.0
		Globals.ScaleMode.BILINEAR:
			Globals.config_scale_3d = 1.0
		Globals.ScaleMode.FSR1:
			Globals.config_scale_3d = 0.77
		Globals.ScaleMode.FSR2:
			Globals.config_scale_3d = 0.67
	update_gui()


func _on_scale_quality_option_item_selected(index):
	if Globals.config_scale_mode == Globals.ScaleMode.FSR1:
		match %ScaleQualityOption.get_item_id(index):
			1:
				Globals.config_scale_3d = 0.77
			2:
				Globals.config_scale_3d = 0.67
			3:
				Globals.config_scale_3d = 0.59
			4:
				Globals.config_scale_3d = 0.5
	elif Globals.config_scale_mode == Globals.ScaleMode.FSR2:
		match %ScaleQualityOption.get_item_id(index):
			1:
				Globals.config_scale_3d = 0.67
			2:
				Globals.config_scale_3d = 0.59
			3:
				Globals.config_scale_3d = 0.5
			4:
				Globals.config_scale_3d = 0.33


func _on_scale_slider_value_changed(value):
	if Globals.config_scale_mode != Globals.ScaleMode.BILINEAR:
		return
	Globals.config_scale_3d = value
	%ScaleLabel.text = "%0.02f" % [value]


func _on_fsr_2aa_check_toggled(toggled_on):
	Globals.config_use_fsr2aa = toggled_on
	update_gui()


func _on_msaa_option_item_selected(index):
	match %MSAAOption.get_item_id(index):
		0:
			Globals.config_msaa = Viewport.MSAA_DISABLED
		1:
			Globals.config_msaa = Viewport.MSAA_2X
		2:
			Globals.config_msaa = Viewport.MSAA_4X
		3:
			Globals.config_msaa = Viewport.MSAA_8X


func _on_screen_space_aa_check_toggled(toggled_on):
	Globals.config_ssaa = toggled_on


func _on_use_taa_check_toggled(toggled_on):
	Globals.config_use_taa = toggled_on


func _on_debanding_check_toggled(toggled_on):
	Globals.config_use_debanding = toggled_on


func _on_exit_button_pressed():
	get_tree().quit()


func _on_il_option_item_selected(index):
	match %ILOption.get_item_id(index):
		0:
			Globals.config_indirect_light = Globals.IndirectLight.NONE
		1:
			Globals.config_indirect_light = Globals.IndirectLight.LIGHTMAP
		2:
			Globals.config_indirect_light = Globals.IndirectLight.SDFGI


func _on_volumetric_fog_check_toggled(toggled_on):
	Globals.config_vfog = toggled_on


func _on_ssao_check_toggled(toggled_on):
	Globals.config_ssao = toggled_on


func _on_ssil_check_toggled(toggled_on):
	Globals.config_ssil = toggled_on


func _on_glow_check_toggled(toggled_on):
	Globals.config_glow = toggled_on


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(meta)
