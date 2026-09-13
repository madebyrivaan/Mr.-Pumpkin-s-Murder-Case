extends Node

# Signal when evidence is added
signal evidence_collected(id: String)
signal suspect_updated(suspect_name: String)

# Evidence database
var evidence_db: Dictionary = {
	"champagne_bottle": {
		"name": "Champagne Bottle",
		"icon": "res://sprites/evidence/Champagne.png",
		"desc": "A vintage bottle... half empty."
	},
	"champagne_glass": {
		"name": "Champagne Glass",
		"icon": "res://sprites/evidence/Glass.png",
		"desc": "Why does the smell of this glass differ from the bottle?"
	},
	"shovel": {
		"name": "Garden Shovel",
		"icon": "res://sprites/evidence/Shovel.png",
		"desc": "The murder weapon has fingerprints belonging to...?"
	},
	"cigar_ash": {
		"name": "Cigar Ash",
		"icon": "res://sprites/evidence/Cigar ash.png",
		"desc": "A scorched mark left by cigar ash... Someone was smoking here, and it wasn't Mr. Pumpkin."
	},
	"diamond_ring": {
		"name": "Diamond Ring",
		"icon": "res://sprites/evidence/Glass.png",
		"desc": "This clearly belongs to a high - society lady."
	},
	"document_page": {
		"name": "Document Page",
		"icon": "res://sprites/evidence/Document page.png",
		"desc": "An important page left on the floor....."
	},
	"pumpkin_body": {
		"name": "Mr. Pumpkin's Body",
		"icon": "res://Assets/Art asset/Characters/pumpkin_die.png",
		"desc": "Victim... zero signs of a struggle?"
	}
}

# Suspect profiles database
var suspect_db: Dictionary = {
	"Mr. Pumpkin": {
		"role": "The Victim",
		"icon": "res://Assets/Art asset/Characters/pumpkin.png",
		"traits": "Wealthy, tyrannical farm tycoon. Controlled water and fertilizer supplies. Universally disliked.",
		"notes": ["Found dead in his private office pinned by a garden shovel.", "Curiously, showed zero defensive wounds or signs of struggle."]
	},
	"Lady Lemon": {
		"role": "Socialite Partner",
		"icon": "res://Assets/Art asset/Characters/lemon_dialog.png",
		"traits": "Haughty, flashy socialite. Inherited partnership from her late husband Green Lemon. Sour biological acidity.",
		"notes": []
	},
	"Mr. Chili": {
		"role": "Bank President",
		"icon": "res://Assets/Art asset/Characters/chili.png",
		"traits": "Hot-tempered, volatile banker. Smokes cigars. Turns bright red when pressured.",
		"notes": []
	},
	"Mr. Onion": {
		"role": "Underworld Broker",
		"icon": "res://Assets/Art asset/Characters/onion.png",
		"traits": "Mysterious, multi-layered criminal broker. Dapper suit, persistent smirk.",
		"notes": []
	}
}

var collected_evidence: Array[String] = []
var interrogated_suspects: Dictionary = {
	"Lady Lemon": false,
	"Mr. Chili": false,
	"Mr. Onion": false
}

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)

func reset_game() -> void:
	collected_evidence.clear()
	interrogated_suspects["Lady Lemon"] = false
	interrogated_suspects["Mr. Chili"] = false
	interrogated_suspects["Mr. Onion"] = false
	suspect_db["Lady Lemon"]["notes"] = []
	suspect_db["Mr. Chili"]["notes"] = []
	suspect_db["Mr. Onion"]["notes"] = []
	suspect_db["Mr. Pumpkin"]["notes"] = [
		"Found dead in his private office pinned by a garden shovel.",
		"Curiously, showed zero defensive wounds or signs of struggle."
	]

func collect_evidence(id: String) -> bool:
	if not collected_evidence.has(id):
		collected_evidence.append(id)
		evidence_collected.emit(id)
		return true
	return false

func has_evidence(id: String) -> bool:
	return collected_evidence.has(id)

func get_evidence_count() -> int:
	return collected_evidence.size()

func all_clues_found() -> bool:
	return collected_evidence.size() >= 5

func add_suspect_note(suspect_name: String, note: String) -> void:
	if suspect_db.has(suspect_name):
		if not suspect_db[suspect_name]["notes"].has(note):
			suspect_db[suspect_name]["notes"].append(note)
			suspect_updated.emit(suspect_name)

func mark_interrogated(suspect_name: String) -> void:
	if interrogated_suspects.has(suspect_name):
		interrogated_suspects[suspect_name] = true

func all_suspects_interrogated() -> bool:
	return (
		interrogated_suspects["Lady Lemon"] and
		interrogated_suspects["Mr. Chili"] and
		interrogated_suspects["Mr. Onion"]
	)

func play_bgm(track_type: String) -> void:
	var path := ""
	if track_type == "menu" or track_type == "investigation":
		path = "res://Assets/Music + SFX/mainmenu_song.ogg"
	elif track_type == "climax" or track_type == "interrogation" or track_type == "accusation":
		path = "res://Assets/Music + SFX/gameclimax_song.ogg"
	
	if path != "":
		var stream = load(path)
		if bgm_player.stream != stream or not bgm_player.playing:
			bgm_player.stream = stream
			bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()
