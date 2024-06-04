class_name BehaviourStatistics
extends Node3D

'''
Esta clase se encarga de las estadisticas de pollution, tiempo de juego y los años sobrevividos, tambien de la poblacion creada
'''

signal make_initial_puf

static var total_pufs: int = 0 # Hay una señal que se lanza cada vez que un puf nace
static var adult_pufs: int = 0
static var baby_pufs: int = 0
static var rich_pufs: int = 0
static var poor_pufs: int = 0

static var population: int = 0

static var current_year: int = 0

var time_passed: float = 0
func _ready():
	self.make_initial_puf.connect(_on_puf_spawn_initial_puf)

func _process(delta):
	time_passed += delta
	_total_pufs()
	if time_passed >= 3.0:
		# print("Puf totales: " + str(total_pufs))
		time_passed = 0.0
	$CurrentYears.start()

func _total_pufs():
	total_pufs = adult_pufs + baby_pufs

# Metodos conectados a señales
func _on_puf_spawn_initial_puf(new_puf):
	print(new_puf.jsonSerialize())
	print("Nasio un pufito")
	if new_puf != null:
		adult_pufs+=1
		match new_puf.Social_class:
			Puf.Social_class.RICH:
				rich_pufs+=1
			Puf.Social_class.POOR:
				poor_pufs+=1

func _on_current_years_timeout():
	current_year+=1
