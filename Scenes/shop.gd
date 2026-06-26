extends Control

var spins = 0
var FasterWalkingPrice = 2
var TighterCirclePrice = 10
var TreatStickPrice = 50
var PedPrice = 500
var BetterTreatsPrice = 1000
var ChinesePeptidesPrice = 5000
var TcPermaDisabled = false
var TreatStickMultiplier = 1.0
var PedMultiplier = 1.0
var TreatStickBaseAmount = 3.0
var PedBaseAmount = 10.0
var TreatSticksPurchased = 0
var PedsPurchased = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not %Path3D:
		return
	spins = %Path3D.spins
	if spins >= FasterWalkingPrice:
		%FwButton.show()
		%FwButton.disabled = false
	else:
		%FwButton.disabled = true
	if spins >= TighterCirclePrice and not TcPermaDisabled:
		%TcButton.show()
		%TcButton.disabled = false
	else:
		%TcButton.disabled = true
	if spins >= TreatStickPrice:
		%TreatStickButton.show()
		%TreatStickButton.disabled = false
	else:
		%TreatStickButton.disabled = true
	if spins >= PedPrice:
		%PedButton.show()
		%PedButton.disabled = false
	else:
		%PedButton.disabled = true
	if spins >= BetterTreatsPrice:
		%BetterTreatsButton.show()
		%BetterTreatsButton.disabled = false
	else:
		%BetterTreatsButton.disabled = true
	if spins >= ChinesePeptidesPrice:
		%ChinesePeptidesButton.show()
		%ChinesePeptidesButton.disabled = false
	else:
		%ChinesePeptidesButton.disabled = true


func _on_fw_button_pressed() -> void:
	if spins > FasterWalkingPrice:
		%Path3D.update_spins(-1 * FasterWalkingPrice)
		%Path3D.move_speed += 0.05
		FasterWalkingPrice = int(FasterWalkingPrice * 1.5)
		%ButtonClickAudioStreamPlayer.play()


func _on_tc_button_pressed() -> void:
	if spins > TighterCirclePrice:
		if %Path3D.radius <= 0.6:
			%TcButton.disabled = true
			TcPermaDisabled = true
			return
		%Path3D.update_spins(-1 * TighterCirclePrice)
		%Path3D.radius -= 0.5
		%Path3D.create_circle_path()
		TighterCirclePrice = int(TighterCirclePrice * 1.3)
		%ButtonClickAudioStreamPlayer.play()


func _on_treat_stick_button_pressed() -> void:
	if spins > TreatStickPrice:
		%Path3D.update_spins(-1 * TreatStickPrice)
		%Path3D.move_speed += TreatStickBaseAmount * TreatStickMultiplier
		TreatSticksPurchased += 1
		TreatStickPrice = int(TreatStickPrice * 1.3)
		%ButtonClickAudioStreamPlayer.play()


func _on_ped_button_pressed() -> void:
	if spins > PedPrice:
		%Path3D.update_spins(-1 * PedPrice)
		%Path3D.move_speed += PedBaseAmount * PedMultiplier
		PedsPurchased += 1
		PedPrice = int(PedPrice * 1.3)
		%ButtonClickAudioStreamPlayer.play()


func _on_better_treats_button_pressed() -> void:
	if spins > BetterTreatsPrice:
		%Path3D.update_spins(-1 * BetterTreatsPrice)
		# Retroactively apply the doubled effectiveness to all past treat stick purchases
		# Each past purchase only gave base_amount * old_multiplier.
		# With the multiplier doubled, each should have given base_amount * new_multiplier.
		# So we add the difference: base_amount * old_multiplier for each past purchase.
		var old_multiplier = TreatStickMultiplier
		TreatStickMultiplier *= 2.0
		var bonus_per_purchase = TreatStickBaseAmount * old_multiplier
		%Path3D.move_speed += bonus_per_purchase * TreatSticksPurchased
		BetterTreatsPrice = int(BetterTreatsPrice * 1.3)
		%ButtonClickAudioStreamPlayer.play()


func _on_chinese_peptides_button_pressed() -> void:
	if spins > ChinesePeptidesPrice:
		%Path3D.update_spins(-1 * ChinesePeptidesPrice)
		# Retroactively apply the doubled effectiveness to all past PED purchases
		var old_multiplier = PedMultiplier
		PedMultiplier *= 2.0
		var bonus_per_purchase = PedBaseAmount * old_multiplier
		%Path3D.move_speed += bonus_per_purchase * PedsPurchased
		ChinesePeptidesPrice = int(ChinesePeptidesPrice * 1.3)
		%ButtonClickAudioStreamPlayer.play()
