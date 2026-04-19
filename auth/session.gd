extends Node

var appwriteUrl = "https://fra.cloud.appwrite.io/v1"
var appwriteProject = "69e2298f0015b69ad3d5"

var headers = ["Content-Type: application/json", "X-Appwrite-Project: " + appwriteProject]

var loaded = false
var authenticated = false
var path = "user://session.dat"
var user: User

var cookies: String

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
	
	if cookies.is_empty():
		return null
	
	http.request_completed.connect(_on_get_user)
	http.request(appwriteUrl + "/account", headers)

func _on_get_user(_res, _code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	user = _user_from_dict(json)
	print(user.email)
	
	loaded = true

func _get_cookies() -> String:
	if not cookies.is_empty():
		return cookies
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var c: Array[String] = file.get_var()
		file.close()

		cookies =  "Cookie: " + "; ".join(c)
		headers.append(cookies)
		get_user()
		return cookies

	return ""
	
static func _user_from_dict(data: Dictionary) -> User:
	var u = User.new()
	u.id = data.get("$id", "")
	u.name = data.get("name", "")
	u.registration = data.get("registration", "")
	u.password_update = data.get("passwordUpdate", "")
	u.email = data.get("email", "")
	u.email_verification = data.get("emailVerification", false)
	u.mfa = data.get("mfa", false)
	u.prefs = data.get("prefs", {})
	u.accessed_at = data.get("accessedAt", "")
	return u
