extends Area2D

var speed = 1500
var direction = Vector2.RIGHT
var lifetime = 2.0
var shooter = null

func _ready():
	print("Projectile created at: ", position, " direction: ", direction)
	# Auto-destroy after lifetime expires
	await get_tree().create_timer(lifetime).timeout
	print("Projectile destroyed")
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	# Don't collide with the shooter
	if body == shooter:
		return
	print("Projectile hit: ", body.name)
	# Handle collision if needed
	queue_free()
