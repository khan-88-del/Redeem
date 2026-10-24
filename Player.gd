func _attach_mp40_to_skeleton(skel: Skeleton3D):
	# Exact Right Hand bone dhundhna (ForeArm ko chhod kar)
	var hand_bone_name = ""
	for b in range(skel.get_bone_count()):
		var b_low = skel.get_bone_name(b).to_lower()
		if ("hand" in b_low or "wrist" in b_low) and not "arm" in b_low and ("r" in b_low or "right" in b_low):
			hand_bone_name = skel.get_bone_name(b)
			break

	# Fallback agar naam alag ho
	if hand_bone_name == "":
		for b in range(skel.get_bone_count()):
			var b_low = skel.get_bone_name(b).to_lower()
			if "righthand" in b_low or "right_hand" in b_low or "hand.r" in b_low:
				hand_bone_name = skel.get_bone_name(b)
				break

	if hand_bone_name == "" and skel.get_bone_count() > 0:
		hand_bone_name = skel.get_bone_name(skel.get_bone_count() - 1)

	bone_attachment = BoneAttachment3D.new()
	bone_attachment.bone_name = hand_bone_name
	skel.add_child(bone_attachment)

	# MP40 load aur position/rotation align karna
	var gun_path = ""
	if ResourceLoader.exists("res://mp40.glb"):
		gun_path = "res://mp40.glb"
	elif ResourceLoader.exists("res://MP40.glb"):
		gun_path = "res://MP40.glb"

	if gun_path != "":
		var g_res = load(gun_path)
		if g_res:
			gun_instance = g_res.instantiate()
			bone_attachment.add_child(gun_instance)
			
			# Gun ka exact alignment haath me seedha aage ki taraf
			gun_instance.scale = Vector3(40.0, 40.0, 40.0)
			gun_instance.position = Vector3(0.0, 0.1, -0.05)
			gun_instance.rotation_degrees = Vector3(0, -90, -90)
			gun_instance.visible = false
