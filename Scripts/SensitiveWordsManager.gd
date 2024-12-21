extends Node

var sensitive_words: PackedStringArray

func check_text(text: String) -> PackedStringArray:
	var sensitive_word: PackedStringArray
	for word: String in sensitive_words:
		if text.find(word) != -1:
			sensitive_word.append(word)
	return sensitive_word
