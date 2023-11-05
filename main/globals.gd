extends Control

signal scene_config_changed

enum ScaleMode {
	NONE,
	BILINEAR,
	FSR1,
	FSR2,
}
enum IndirectLight {
	NONE,
	LIGHTMAP,
	SDFGI,
}

const display_debug := {
	Viewport.DEBUG_DRAW_DISABLED : "DEBUG_DRAW_DISABLED",
	Viewport.DEBUG_DRAW_UNSHADED : "DEBUG_DRAW_UNSHADED",
	Viewport.DEBUG_DRAW_LIGHTING : "DEBUG_DRAW_LIGHTING",
	Viewport.DEBUG_DRAW_OVERDRAW : "DEBUG_DRAW_OVERDRAW",
	Viewport.DEBUG_DRAW_WIREFRAME : "DEBUG_DRAW_WIREFRAME",
	Viewport.DEBUG_DRAW_NORMAL_BUFFER : "DEBUG_DRAW_NORMAL_BUFFER",
	Viewport.DEBUG_DRAW_VOXEL_GI_ALBEDO : "DEBUG_DRAW_VOXEL_GI_ALBEDO",
	Viewport.DEBUG_DRAW_VOXEL_GI_LIGHTING : "DEBUG_DRAW_VOXEL_GI_LIGHTING",
	Viewport.DEBUG_DRAW_VOXEL_GI_EMISSION : "DEBUG_DRAW_VOXEL_GI_EMISSION",
	Viewport.DEBUG_DRAW_SHADOW_ATLAS : "DEBUG_DRAW_SHADOW_ATLAS",
	Viewport.DEBUG_DRAW_DIRECTIONAL_SHADOW_ATLAS : "DEBUG_DRAW_DIRECTIONAL_SHADOW_ATLAS",
	Viewport.DEBUG_DRAW_SCENE_LUMINANCE : "DEBUG_DRAW_SCENE_LUMINANCE",
	Viewport.DEBUG_DRAW_SSAO : "DEBUG_DRAW_SSAO",
	Viewport.DEBUG_DRAW_SSIL : "DEBUG_DRAW_SSIL",
	Viewport.DEBUG_DRAW_PSSM_SPLITS : "DEBUG_DRAW_PSSM_SPLITS",
	Viewport.DEBUG_DRAW_DECAL_ATLAS : "DEBUG_DRAW_DECAL_ATLAS",
	Viewport.DEBUG_DRAW_SDFGI : "DEBUG_DRAW_SDFGI",
	Viewport.DEBUG_DRAW_SDFGI_PROBES : "DEBUG_DRAW_SDFGI_PROBES",
	Viewport.DEBUG_DRAW_GI_BUFFER : "DEBUG_DRAW_GI_BUFFER",
	Viewport.DEBUG_DRAW_DISABLE_LOD : "DEBUG_DRAW_DISABLE_LOD",
	Viewport.DEBUG_DRAW_CLUSTER_OMNI_LIGHTS : "DEBUG_DRAW_CLUSTER_OMNI_LIGHTS",
	Viewport.DEBUG_DRAW_CLUSTER_SPOT_LIGHTS : "DEBUG_DRAW_CLUSTER_SPOT_LIGHTS",
	Viewport.DEBUG_DRAW_CLUSTER_DECALS : "DEBUG_DRAW_CLUSTER_DECALS",
	Viewport.DEBUG_DRAW_CLUSTER_REFLECTION_PROBES : "DEBUG_DRAW_CLUSTER_REFLECTION_PROBES",
	Viewport.DEBUG_DRAW_OCCLUDERS : "DEBUG_DRAW_OCCLUDERS",
	Viewport.DEBUG_DRAW_MOTION_VECTORS : "DEBUG_DRAW_MOTION_VECTORS",
	Viewport.DEBUG_DRAW_INTERNAL_BUFFER : "DEBUG_DRAW_INTERNAL_BUFFER",
}

var config_show_fps := true : set = _on_set_config_show_fps
var config_show_sys_info := false : set = _on_set_config_show_sys_info
var config_show_config := false : set = _on_set_config_show_config
var config_screen := 0 : set = _on_set_config_screen
var config_display_mode := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN : set = _on_set_config_display_mode
var config_vsync_mode := DisplayServer.VSYNC_ENABLED : set = _on_set_vsync_mode
var config_scale_mode := ScaleMode.NONE : set = _on_set_scale_mode
var config_scale_3d := 1.0 : set = _on_set_scale_3d
var config_use_fsr2aa := true : set = _on_set_use_fsr2aa
var config_msaa := Viewport.MSAA_DISABLED : set = _on_set_config_msaa
var config_ssaa := false : set = _on_set_config_ssaa
var config_use_taa := false : set = _on_set_config_use_taa
var config_use_debanding := false : set = _on_set_config_use_debanding
var config_indirect_light := IndirectLight.LIGHTMAP :
	set(value):
		config_indirect_light = value
		scene_config_changed.emit()
		update_config_info()
var config_vfog := true :
	set(value):
		config_vfog = value
		scene_config_changed.emit()
		update_config_info()
var config_ssao := true :
	set(value):
		config_ssao = value
		scene_config_changed.emit()
		update_config_info()
var config_ssil := false :
	set(value):
		config_ssil = value
		scene_config_changed.emit()
		update_config_info()
var config_glow := true :
	set(value):
		config_glow = value
		scene_config_changed.emit()
		update_config_info()

var settings_visible := false

var _tween_gui : Tween = null
var _current_debug_view := 0


func _ready():
	apply_config()
	%Gui.modulate.a = 0
	%SettingsButton.grab_focus()
	%SysInfoLabel.text = "Godot version: " + Engine.get_version_info().string
	%SysInfoLabel.text += "\nDebug build: " + str(OS.is_debug_build())
	%SysInfoLabel.text += "\nDisplay server: " + DisplayServer.get_name()
	%SysInfoLabel.text += "\nDevice vendor: " + RenderingServer.get_rendering_device().get_device_vendor_name()
	%SysInfoLabel.text += "\nAdapter name: " + RenderingServer.get_video_adapter_name()
	match RenderingServer.get_video_adapter_type():
		RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU:
			%SysInfoLabel.text += "\nVideo adapter type: Integrated GPU"
		RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
			%SysInfoLabel.text += "\nVideo adapter type: Discrete GPU"
		RenderingDevice.DEVICE_TYPE_VIRTUAL_GPU:
			%SysInfoLabel.text += "\nVideo adapter type: Virtual GPU"
		RenderingDevice.DEVICE_TYPE_CPU:
			%SysInfoLabel.text += "\nVideo adapter type: Software"
		_:
			%SysInfoLabel.text += "\nVideo adapter type: Unknown"
	%SysInfoLabel.text += "\nApi version: " + RenderingServer.get_video_adapter_api_version()


func _process(_delta):
	%FPSLabel.text = str(Engine.get_frames_per_second())


func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		_on_settings_button_pressed()
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_T:
			_current_debug_view += 1
			if _current_debug_view == display_debug.size():
				_current_debug_view = 0
			get_viewport().debug_draw = display_debug.keys()[_current_debug_view]
			%DebugViewLabel.text = display_debug[get_viewport().debug_draw]
			%Gui.modulate.a = 1
			auto_hide_gui()
	if event is InputEventMouseMotion:
		%Gui.modulate.a = 1
		auto_hide_gui()


func auto_hide_gui():
	if _tween_gui:
		_tween_gui.kill()
	_tween_gui = create_tween()
	_tween_gui.tween_interval(2.5)
	_tween_gui.tween_property(%Gui, "modulate:a", 0.0, 1.5)


func apply_config():
	self.config_show_fps = config_show_fps
	self.config_screen = config_screen
	self.config_display_mode = config_display_mode
	self.config_vsync_mode = config_vsync_mode
	self.config_scale_mode = config_scale_mode
	self.config_scale_3d = config_scale_3d
	self.config_use_fsr2aa = config_use_fsr2aa
	self.config_msaa = config_msaa
	self.config_ssaa = config_ssaa
	self.config_use_taa = config_use_taa
	self.config_use_debanding = config_use_debanding
	update_config_info()


func update_config_info():
	var text := ""
	text += "Screen: " + str(config_screen)
	match config_display_mode:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			text += "\nDisplay mode: Exclusive fullscreen"
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			text += "\nDisplay mode: Fullscreen"
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			text += "\nDisplay mode: Maximized"
		DisplayServer.WINDOW_MODE_WINDOWED:
			text += "\nDisplay mode: Windowed"
		_:
			text += "\nDisplay mode: Unknown"
	match config_vsync_mode:
		DisplayServer.VSYNC_ENABLED:
			text += "\nDisplay mode: Enabled"
		DisplayServer.VSYNC_DISABLED:
			text += "\nDisplay mode: Disabled"
		DisplayServer.VSYNC_ADAPTIVE:
			text += "\nDisplay mode: Adaptive"
		DisplayServer.VSYNC_MAILBOX:
			text += "\nDisplay mode: Mailbox"
		_:
			text += "\nDisplay mode: Unknown"
	match config_scale_mode:
		ScaleMode.NONE:
			text += "\nScale mode: None"
		ScaleMode.BILINEAR:
			text += "\nScale mode: Bilinear"
		ScaleMode.FSR1:
			text += "\nScale mode: FSR 1.0"
		ScaleMode.FSR2:
			text += "\nScale mode: FSR 2.2"
		_:
			text += "\nScale mode: Unknown"
	text += "\nScale 3D: %0.02f" % [config_scale_3d]
	text += "\nUse FSR AA: " + str(config_use_fsr2aa)
	match config_msaa:
		Viewport.MSAA_DISABLED:
			text += "\nMSAA: Disabled"
		Viewport.MSAA_2X:
			text += "\nMSAA: 2X"
		Viewport.MSAA_4X:
			text += "\nMSAA: 4X"
		Viewport.MSAA_8X:
			text += "\nMSAA: 8X"
		_:
			text += "\nMSAA: Unknown"
	text += "\nScreen space Anti-Aliasing: " + str(config_ssaa)
	text += "\nTAA: " + str(config_use_taa)
	text += "\nDebanding: " + str(config_use_debanding)
	match config_indirect_light:
		IndirectLight.NONE:
			text += "\nIndirect light: None"
		IndirectLight.LIGHTMAP:
			text += "\nIndirect light: Ligtmap"
		IndirectLight.SDFGI:
			text += "\nIndirect light: SDFGI"
		_:
			text += "\nIndirect light: Unknown"
	text += "\nVolumetric fog: " + str(config_vfog)
	text += "\nSSAO: " + str(config_ssao)
	text += "\nSSIL: " + str(config_ssil)
	text += "\nGlow: " + str(config_glow)
	%ConfigLabel.text = text


func _on_set_config_show_fps(value : bool):
	config_show_fps = value
	%FPSLabel.visible = config_show_fps
	update_config_info()


func _on_set_config_show_sys_info(value : bool):
	config_show_sys_info = value
	%SysInfoLabel.visible = config_show_sys_info
	update_config_info()


func _on_set_config_show_config(value : bool):
	config_show_config = value
	%ConfigLabel.visible = config_show_config
	update_config_info()


func _on_set_config_screen(value : int):
	config_screen = value
	DisplayServer.window_set_current_screen(config_screen)
	update_config_info()


func _on_set_config_display_mode(value : DisplayServer.WindowMode):
	config_display_mode = value
	DisplayServer.window_set_mode(config_display_mode)
	update_config_info()


func _on_set_vsync_mode(value : DisplayServer.VSyncMode):
	config_vsync_mode = value
	DisplayServer.window_set_vsync_mode(config_vsync_mode)
	update_config_info()


func _on_set_scale_mode(value : ScaleMode):
	config_scale_mode = value
	match config_scale_mode:
		ScaleMode.NONE:
			if config_use_fsr2aa:
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
				get_viewport().use_taa = false
			else:
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
				get_viewport().use_taa = config_use_taa
			get_viewport().msaa_3d = config_msaa
			get_viewport().use_debanding = config_use_debanding
			_on_set_config_ssaa(config_ssaa)
			get_viewport().scaling_3d_scale = 1.0
		ScaleMode.BILINEAR:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
			get_viewport().msaa_3d = config_msaa
			get_viewport().use_taa = config_use_taa
			get_viewport().use_debanding = config_use_debanding
			_on_set_config_ssaa(config_ssaa)
			get_viewport().scaling_3d_scale = 1.0
		ScaleMode.FSR1:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
			get_viewport().msaa_3d = config_msaa
			get_viewport().use_taa = config_use_taa
			get_viewport().use_debanding = config_use_debanding
			_on_set_config_ssaa(config_ssaa)
			get_viewport().scaling_3d_scale = 0.77
		ScaleMode.FSR2:
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().use_taa = false
			get_viewport().use_debanding = false
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
			get_viewport().scaling_3d_scale = 0.67
	update_config_info()


func _on_set_scale_3d(value : float):
	config_scale_3d = value
	match config_scale_mode:
		ScaleMode.NONE:
			get_viewport().scaling_3d_scale = 1.0
		_:
			get_viewport().scaling_3d_scale = config_scale_3d
	update_config_info()


func _on_set_use_fsr2aa(value : bool):
	config_use_fsr2aa = value
	if config_scale_mode == ScaleMode.NONE:
		if config_use_fsr2aa:
			get_viewport().use_taa = false
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		else:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	update_config_info()


func _on_set_config_msaa(value : Viewport.MSAA):
	config_msaa = value
	get_viewport().msaa_3d = config_msaa
	update_config_info()


func _on_set_config_ssaa(value : bool):
	config_ssaa = value
	if config_ssaa:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	update_config_info()


func _on_set_config_use_taa(value : bool):
	config_use_taa = value
	if config_scale_mode == ScaleMode.FSR2 or (config_scale_mode == ScaleMode.NONE and config_use_fsr2aa):
		config_use_taa = false
	get_viewport().use_taa = config_use_taa
	update_config_info()


func _on_set_config_use_debanding(value : bool):
	config_use_debanding = value
	get_viewport().use_debanding = config_use_debanding
	update_config_info()


func _on_settings_button_pressed():
	if find_child("Settings", false, false) != null:
		return
	var gui_settings = load("res://gui/settings.tscn").instantiate()
	add_child(gui_settings)
