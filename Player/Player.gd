extends Area2D

enum States {READY, ALIVE, DEAD}
onready var state = States.ALIVE

const MAX_SPEED = 300
const BORDER_MARGIN = 80 # Margin size of edges outside viewport
const BULLET_SPEED = 512

signal life_lost(remaining_lives)

onready var normal_bullet = load("res://Player/PlayerBullet.tscn")
onready var cloud_explosion_effect = load("res://VFX/Cloud/CloudEffect.tscn")

onready var bullet_charge_sprite = $BulletCharge

onready var recoil_force = 64

onready var lives = 3

onready var shoot_input_pressed
onready var can_shoot = true
onready var invulnerable = false

onready var velocity = Vector2()

func _ready():
	bullet_charge_sprite.hide()
	$AnimationPlayer.play("idle")
	state = States.READY

func _process(delta):
	if _can_shoot():
		if Input.is_action_pressed("shoot"):
			look_at(get_global_mouse_position())
			shoot_input_pressed = true
			bullet_charge_sprite.show()
		if Input.is_action_just_released("shoot"):
			shoot()
			shoot_input_pressed = false
			bullet_charge_sprite.hide()

func _physics_process(delta):
	if _can_move():
		position += velocity * delta
	
	# Borders wrap
	var map_size = get_viewport_rect().size
	if position.x < -BORDER_MARGIN:
		position.x = map_size.x + BORDER_MARGIN
	if position.x > map_size.x + BORDER_MARGIN:
		position.x = -BORDER_MARGIN
	if position.y < -BORDER_MARGIN:
		position.y = map_size.y + BORDER_MARGIN
	if position.y > map_size.y + BORDER_MARGIN:
		position.y = -BORDER_MARGIN
	
	# Bullet charge effect
	if shoot_input_pressed:
		bullet_charge_sprite.rotate(0.1)

func _can_move() -> bool:
	return state == States.ALIVE

func _can_shoot() -> bool:
	return state == States.ALIVE

# Touchscreen handling
func _unhandled_input(event):
	if _can_shoot():
		if event is InputEventScreenTouch:
			if event.is_pressed():
				look_at(get_global_mouse_position())
				shoot_input_pressed = true
				bullet_charge_sprite.show()
			elif not event.is_pressed():  # touch released.
				shoot()
				shoot_input_pressed = false
				bullet_charge_sprite.hide()
		elif event is InputEventScreenDrag:
			look_at(event.position)

func shoot() -> void:
	if not can_shoot:
		return
	
	can_shoot = false
	$ShootCooldownTimer.start()
	$LaserSound.play()
	
	var bullet = normal_bullet.instance()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.velocity = Vector2(BULLET_SPEED, 0).rotated(rotation)
	bullet.rotation = rotation
	
	# Instant velocity change
	#velocity = Vector2(-recoil_force, 0).rotated(rotation).clamped(MAX_SPEED)
	# Additive velocity change
	velocity += Vector2(-recoil_force, 0).rotated(rotation)
	velocity = velocity.clamped(MAX_SPEED)

func is_invulnerable() -> bool:
	return invulnerable

func hit() -> void:
	if invulnerable:
		return
	
	state = States.DEAD
	lives -= 1
	emit_signal("life_lost", lives)
	invulnerable = true
	hide()
	velocity = Vector2.ZERO
	_spawn_death_effects()
	$ExplodeSound.play()
	if lives < 0:
		pass # Dead
	else:
		$RespawnTimer.start()

func _spawn_death_effects() -> void:
	var explosion_vfx = cloud_explosion_effect.instance()
	get_parent().add_child(explosion_vfx)
	explosion_vfx.global_position = global_position
	explosion_vfx.scale = Vector2(2, 2)
	explosion_vfx.play_effect()

func _on_Player_body_entered(body):
	if state == States.DEAD:
		return
	
	if body.has_method("hit"):
		body.hit(10) # The player's ship should deal big damage
	if !invulnerable and body is Asteroid:
		self.hit()

func _on_ShieldArea_body_entered(body):
	if not invulnerable:
		return
	if state == States.DEAD:
		return
	
	if body.has_method("hit"):
		body.hit(10) # Shield also deals big damage

func _on_ShootCooldownTimer_timeout():
	can_shoot = true

func _on_InvulnerableTimer_timeout():
	invulnerable = false
	$AnimationPlayer.play("idle")

func _on_RespawnTimer_timeout():
	var map_size = get_viewport_rect().size
	position = map_size / 2
	show()
	state = States.ALIVE
	$InvulnerableTimer.start()
	$AnimationPlayer.play("invulnerable")
	$ShieldUpSound.play()
