extends Control

const MAX_ROUNDS := 10
const HAND_SIZE := 3

var rng := RandomNumberGenerator.new()
var deck: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var round_number := 0
var fun_score := 0
var money_score := 0

var round_label: Label
var fun_label: Label
var money_label: Label
var hand_row: HBoxContainer
var log_label: Label
var ending_panel: PanelContainer
var ending_title: Label
var ending_body: Label


func _ready() -> void:
	rng.randomize()
	_build_ui()
	_start_game()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#171714")
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 20)
	layout.add_child(header)

	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_stack)

	var title := Label.new()
	title.text = "PATCH NOTES"
	title.add_theme_color_override("font_color", Color("#f4efe3"))
	title.add_theme_font_size_override("font_size", 42)
	title_stack.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Ship updates. Please everyone. Watch the numbers explain why that was funny."
	subtitle.add_theme_color_override("font_color", Color("#b8b0a0"))
	subtitle.add_theme_font_size_override("font_size", 16)
	title_stack.add_child(subtitle)

	var score_bar := HBoxContainer.new()
	score_bar.add_theme_constant_override("separation", 12)
	header.add_child(score_bar)

	round_label = _score_label()
	fun_label = _score_label()
	money_label = _score_label()
	score_bar.add_child(round_label)
	score_bar.add_child(fun_label)
	score_bar.add_child(money_label)

	hand_row = HBoxContainer.new()
	hand_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_row.add_theme_constant_override("separation", 14)
	layout.add_child(hand_row)

	log_label = Label.new()
	log_label.custom_minimum_size = Vector2(0, 54)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", Color("#d7cfbf"))
	log_label.add_theme_font_size_override("font_size", 17)
	layout.add_child(log_label)

	ending_panel = _panel()
	ending_panel.visible = false
	ending_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(ending_panel)

	var ending_margin := MarginContainer.new()
	ending_margin.add_theme_constant_override("margin_left", 24)
	ending_margin.add_theme_constant_override("margin_top", 22)
	ending_margin.add_theme_constant_override("margin_right", 24)
	ending_margin.add_theme_constant_override("margin_bottom", 22)
	ending_panel.add_child(ending_margin)

	var ending_layout := VBoxContainer.new()
	ending_layout.add_theme_constant_override("separation", 16)
	ending_margin.add_child(ending_layout)

	ending_title = Label.new()
	ending_title.add_theme_color_override("font_color", Color("#f4efe3"))
	ending_title.add_theme_font_size_override("font_size", 34)
	ending_layout.add_child(ending_title)

	ending_body = Label.new()
	ending_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_body.add_theme_color_override("font_color", Color("#d7cfbf"))
	ending_body.add_theme_font_size_override("font_size", 19)
	ending_layout.add_child(ending_body)

	var restart := Button.new()
	restart.text = "New Roadmap"
	restart.pressed.connect(_start_game)
	ending_layout.add_child(restart)


func _start_game() -> void:
	deck = _build_deck()
	deck.shuffle()
	round_number = 0
	fun_score = 0
	money_score = 0
	ending_panel.visible = false
	hand_row.visible = true
	log_label.text = "The board wants progress. The community wants a game. You have ten updates."
	_next_round()


func _next_round() -> void:
	round_number += 1
	if round_number > MAX_ROUNDS:
		_finish_game()
		return

	hand.clear()
	for i in range(min(HAND_SIZE, deck.size())):
		hand.append(deck.pop_back())

	_update_scores()
	_render_hand()


func _render_hand() -> void:
	for child in hand_row.get_children():
		child.queue_free()

	for card in hand:
		hand_row.add_child(_card_view(card))


func _card_view(card: Dictionary) -> Control:
	var panel := _panel()
	panel.custom_minimum_size = Vector2(260, 420)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var title := Label.new()
	title.text = card["title"]
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_color_override("font_color", Color("#f4efe3"))
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)

	var description := Label.new()
	description.text = card["description"]
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_color_override("font_color", Color("#d7cfbf"))
	description.add_theme_font_size_override("font_size", 15)
	layout.add_child(description)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)

	var signal_label := Label.new()
	signal_label.text = "SIGNAL\n%s" % card["signal"]
	signal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	signal_label.add_theme_color_override("font_color", Color("#c6b37a"))
	signal_label.add_theme_font_size_override("font_size", 15)
	layout.add_child(signal_label)

	var effects := Label.new()
	effects.text = "%s\n%s" % [_effect_line("Fun", card["fun_level"], card["fun_node"], card["fun_delta"]), _effect_line("Money", card["money_level"], card["money_node"], card["money_delta"])]
	effects.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effects.add_theme_color_override("font_color", Color("#b8b0a0"))
	effects.add_theme_font_size_override("font_size", 14)
	layout.add_child(effects)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	layout.add_child(buttons)

	var reject := Button.new()
	reject.text = "Reject"
	reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reject.pressed.connect(_reject_card.bind(card))
	buttons.add_child(reject)

	var ship := Button.new()
	ship.text = "Ship"
	ship.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ship.pressed.connect(_ship_card.bind(card))
	buttons.add_child(ship)

	return panel


func _ship_card(card: Dictionary) -> void:
	fun_score += card["fun_delta"]
	money_score += card["money_delta"]
	log_label.text = "Shipped: %s. %s" % [card["title"], card["signal"]]
	_next_round()


func _reject_card(card: Dictionary) -> void:
	log_label.text = "Rejected: %s. The roadmap absorbed the discussion and produced no evidence." % card["title"]
	_next_round()


func _finish_game() -> void:
	_update_scores()
	hand_row.visible = false
	ending_panel.visible = true

	var ending := _ending()
	ending_title.text = ending["title"]
	ending_body.text = ending["body"]
	log_label.text = "Final score: Fun %s, Money %s." % [fun_score, money_score]


func _update_scores() -> void:
	round_label.text = "Round %d/%d" % [min(round_number, MAX_ROUNDS), MAX_ROUNDS]
	fun_label.text = "Fun %s" % _signed(fun_score)
	money_label.text = "Money %s" % _signed(money_score)


func _score_label() -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(130, 42)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#171714"))
	label.add_theme_color_override("font_shadow_color", Color("#00000000"))
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_stylebox_override("normal", _style(Color("#f4efe3"), Color("#f4efe3")))
	return label


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color("#24231f"), Color("#514b3c")))
	return panel


func _style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style


func _effect_line(track: String, level: int, node: String, delta: int) -> String:
	var direction := "Positive" if delta >= 0 else "Negative"
	return "%s - Level %d - %s - %s (%s)" % [track, level, node, direction, _signed(delta)]


func _signed(value: int) -> String:
	return "+%d" % value if value >= 0 else str(value)


func _ending() -> Dictionary:
	if fun_score >= 8 and money_score >= 8:
		return {
			"title": "IMPOSSIBLE QUARTER",
			"body": "Players were happy, investors were happy, and several analysts described the result as suspicious. The team was praised for listening, which management documented as a scalable process. Nobody could reproduce it next sprint. A committee was formed immediately."
		}
	if money_score >= 8 and fun_score <= -4:
		return {
			"title": "WHALE FARM",
			"body": "Most players left within the first week, loudly and permanently. The few who stayed spent enough money to make the dashboard look beautiful. Investors called it a focused high-value audience. The community called it something less printable."
		}
	if fun_score >= 8 and money_score <= -4:
		return {
			"title": "CULT CLASSIC",
			"body": "Players loved the game with the intensity usually reserved for discontinued snacks. Revenue failed to participate. Investors admired the passion, then asked whether passion could be billed monthly. It could not."
		}
	if fun_score <= -6 and money_score <= -6:
		return {
			"title": "SUNSET ANNOUNCEMENT",
			"body": "The final update thanked the community for an incredible journey and carefully avoided describing the destination. Players had already left, and investors had already learned a new acronym. The servers remained online just long enough to look responsible."
		}
	if fun_score >= money_score:
		return {
			"title": "PATCH ACCEPTED",
			"body": "The game survived on goodwill, screenshots, and a suspicious number of forum essays. Investors wanted a cleaner graph, but the players kept showing up. Nobody agreed on whether this was success. That made it feel authentic."
		}
	return {
		"title": "ROADMAP COMPLETE",
		"body": "The numbers improved in the way numbers often do when nobody asks what they mean. Players complained, converted, churned, returned, and complained again. Investors saw movement and called it momentum. The game became a business with loading screens."
	}


func _build_deck() -> Array[Dictionary]:
	return [
		_card("Hit Reaction Pass", "Every attack gets cleaner impact frames and less interpretive animation.", "The combat finally admits when it has happened.", 3, "Feel", 1, 2, "Retention", -3),
		_card("Readable Boss Telegraphs", "Boss attacks now tell the truth roughly one second before ruining someone.", "Players begin blaming themselves, which is dangerous progress.", 3, "Clarity", 1, 2, "Spending", -3),
		_card("Quest Log Rewrite", "Objectives now describe where to go instead of preserving mystery through clerical negligence.", "The wiki loses traffic and gains dignity.", 3, "Clarity", 1, 2, "Conversion", -3),
		_card("Relationship Scenes", "Companions receive optional camp scenes about fear, loyalty, and inventory management.", "Attachment rises. Skip-rate analytics become spiritually troubling.", 3, "Meaning", 1, 2, "Reach", -3),
		_card("Apology Patch", "A bug that deleted saves is fixed with an apology that contains verbs.", "Trust returns wearing a hard hat.", 3, "Trust", 1, 2, "Conversion", -3),
		_card("Offline Mode", "The game can now be played without asking a server for emotional permission.", "Players call it basic. The metrics team calls it a disappearance.", 2, "Experience", 3, 2, "Retention", -3),
		_card("Cosmetic Shop Refresh", "The store opens two tabs earlier and remembers which bundle made you hesitate.", "The interface smiles with too many teeth.", 3, "Trust", -1, 2, "Spending", 3),
		_card("Starter Pack Timer", "New accounts receive a discount that expires before confidence can form.", "Conversion improves. So does the smell of wet cardboard.", 3, "Clarity", -1, 2, "Conversion", 3),
		_card("Daily Login Chain", "Rewards now punish absence with the soft violence of missed progress.", "Retention climbs on a ladder made of obligation.", 3, "Meaning", -1, 2, "Retention", 3),
		_card("Influencer Drop", "A limited cape appears on streams hosted by people who pronounce the title incorrectly.", "Reach expands. The forum develops a rash.", 3, "Trust", -1, 2, "Reach", 3),
		_card("Battle Pass Extension", "The pass gains twenty levels, three currencies, and one apology emote.", "The spreadsheet is magnificent. The game is nearby.", 2, "Attachment", -3, 2, "Spending", 3),
		_card("Friction Audit", "Menus are shorter, confirmations clearer, and accidental purchases less ambitious.", "Players relax. Revenue notices immediately.", 2, "Experience", 3, 2, "Spending", -3),
		_card("Matchmaking Honesty", "Queue estimates now use measured time instead of optimism with a badge.", "Trust improves because the lie got fired.", 3, "Trust", 1, 2, "Retention", -3),
		_card("Founder Statue", "Early backers receive a tasteful monument in the capital square.", "Meaning increases until everyone else sees the price history.", 3, "Meaning", 1, 2, "Conversion", -3),
		_card("Loot Flash Upgrade", "Rare drops now explode with sound, light, and a purchase-adjacent thrill.", "Feel improves in the part of the brain legal reviewed.", 3, "Feel", 1, 2, "Spending", 3),
		_card("Regional Price Fix", "Store prices now account for local economies instead of vibes.", "Reach improves. Finance requests a chair.", 3, "Trust", 1, 2, "Reach", -3),
		_card("Inventory Auto-Sort", "Items stop arranging themselves like evidence after a burglary.", "Clarity rises. Nobody buys the extra bag quite as urgently.", 3, "Clarity", 1, 2, "Spending", -3),
		_card("Limited-Time Dungeon", "A new dungeon disappears in six days for reasons described as seasonal.", "The clock becomes a designer.", 3, "Meaning", -1, 2, "Retention", 3),
		_card("Patch Notes With Numbers", "Balance changes include actual values instead of adjectives wearing armor.", "Trust increases. Speculation content suffers.", 3, "Trust", 1, 2, "Reach", -3),
		_card("New User Funnel", "The tutorial is shorter, louder, and significantly more convinced of itself.", "Conversion improves before comprehension arrives.", 3, "Clarity", -1, 2, "Conversion", 3),
		_card("Crafting Cleanup", "Recipes now show missing ingredients without requiring a pilgrimage through menus.", "Experience improves. The economy quietly loses a pressure point.", 2, "Experience", 3, 2, "Spending", -3),
		_card("Prestige Reset", "Max-level players can start over for a border, a number, and a complex feeling.", "Retention rises. Meaning files a complaint.", 3, "Meaning", -1, 2, "Retention", 3),
		_card("Community Quest", "Everyone contributes to a shared goal with rewards suspiciously tuned to finish Sunday night.", "Reach improves as players become unpaid weather.", 2, "Attachment", 3, 2, "Reach", 3),
		_card("Ad Reward Button", "Players can watch a short ad to double rewards and halve the room temperature.", "Money improves. Fun leaves for a minute.", 3, "Feel", -1, 2, "Spending", 3),
		_card("Accessibility Pass", "Text size, contrast, remapping, and subtitle controls stop being future work.", "Clarity rises because more people can actually read the game.", 2, "Experience", 3, 2, "Reach", 3),
		_card("Drop Rate Disclosure", "The loot table now says exactly how little hope costs.", "Trust improves. Spending pretends not to hear.", 3, "Trust", 1, 2, "Spending", -3),
		_card("Guild Rent", "Guild halls now require upkeep to encourage social investment.", "Attachment becomes a utility bill.", 3, "Meaning", -1, 2, "Retention", 3),
		_card("Server Tick Upgrade", "Movement stops rubber-banding players into moral philosophy.", "Feel improves so directly it looks expensive.", 3, "Feel", 1, 2, "Conversion", -3),
		_card("Bundle Math Simplified", "The store now explains bundle value without requiring a hostage negotiator.", "Clarity improves. Conversion does not enjoy sunlight.", 3, "Clarity", 1, 2, "Conversion", -3),
		_card("Anniversary Giveaway", "Everyone gets a generous gift that was forecast as marketing spend.", "Trust spikes. Money accepts the meeting invite.", 3, "Trust", 1, 2, "Reach", 3),
		_card("Energy System", "Players receive a limited number of meaningful actions per day, for health.", "Retention improves through rationing. Fun reads the statement twice.", 2, "Experience", -3, 2, "Retention", 3),
		_card("Ending Added", "The campaign now concludes with authored consequences instead of a door marked soon.", "Meaning rises. The live-service roadmap coughs.", 3, "Meaning", 1, 2, "Retention", -3)
	]


func _card(title: String, description: String, signal: String, fun_level: int, fun_node: String, fun_delta: int, money_level: int, money_node: String, money_delta: int) -> Dictionary:
	return {
		"title": title,
		"description": description,
		"signal": signal,
		"fun_level": fun_level,
		"fun_node": fun_node,
		"fun_delta": fun_delta,
		"money_level": money_level,
		"money_node": money_node,
		"money_delta": money_delta
	}
