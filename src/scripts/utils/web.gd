class_name Web


static func is_touch_web() -> bool:
	if not OS.has_feature("web"):
		return false

	if DisplayServer.is_touchscreen_available():
		return true

	var max_touch_points: Variant = JavaScriptBridge.eval("navigator.maxTouchPoints || 0")
	return int(max_touch_points) > 0