class_name UUID


const CHARS = "0123456789abcdef"


static func generate_v4() -> String:
	var result := ""
	for i in range(32):
		if i in [8, 12, 16, 20]:
			result += "-"
		
		# Set version 4 identifier
		if i == 12:
			result += "4"
		# Set variant bits (must be 8, 9, a, or b)
		elif i == 16:
			var r := randi() % 4 + 8
			result += CHARS[r]
		else:
			var r := randi() % 16
			result += CHARS[r]
			
	return result
