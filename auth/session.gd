extends Node

var appwriteUrl = "https://fra.cloud.appwrite.io/v1"
var appwriteProject = "69e2298f0015b69ad3d5"

var headers = ["Content-Type: application/json", "X-Appwrite-Project: " + appwriteProject]

var authenticated = false
var path = "user://session.dat"
var user

var cookies: Array[String] = []

var http: HTTPRequest

func _ready() -> void:	
	http = HTTPRequest.new()
	add_child(http)
	
	_get_cookies()

func save(c: Array[String]):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(c)
	file.close()
	_get_cookies()

func get_user():
	if user: return user
	
	if not len(cookies) > 0:
		return null
	
	http.request_completed.connect(_on_get_user)
	http.request(appwriteUrl + "/account", headers)

func _on_get_user(_res, code, _headers, body):
	if not code == 201: return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	user = json

func _get_cookies() -> Array[String]:
	if len(cookies) > 0:
		return cookies
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var c = file.get_var()
		file.close()
		cookies = c
		headers.append_array(c)
		get_user()
		return c

	return []
