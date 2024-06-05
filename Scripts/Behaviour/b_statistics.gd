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
