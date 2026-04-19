extends Node2D

var userId: String

func _ready() -> void:
	$Email.visible = true
	$Phrase.visible = false
	$Code.visible = false

func _send_token():
	var email: String = $Email/EmailInput.text
	
	if email.length() > 0 and email.contains("@"):
		$HTTPRequest.request_completed.connect(_on_token_request_completed)
	
		var json = JSON.stringify({
			"userId": "unique()",
			"email": email,
			"phrase": true
		})
		var headers = Session.headers
		$HTTPRequest.request(Session.appwriteUrl + "/account/tokens/email", headers, HTTPClient.METHOD_POST, json)
		
		return true
	
	return false

func _on_token_request_completed(_res, code, _headers, body):
	if not code == 201:
		return false
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	if not json["userId"] and not json["phrase"]:
		return false
	
	userId = json["userId"]
	
	$Email.visible = false
	
	$Phrase/Phrase.text = json["phrase"]
	$Phrase.visible = true

func _send_otp():
	var otp: String = $Code/CodeInput.text
	
	if otp.length() == 6 and otp.is_valid_int() and not otp.contains("+") and not otp.contains("-"):
		$HTTPRequest.request_completed.disconnect(_on_token_request_completed)
		$HTTPRequest.request_completed.connect(_on_otp_request_completed)
	
		var json = JSON.stringify({
			"userId": userId,
			"secret": otp,
		})
		var headers = Session.headers
		$HTTPRequest.request(Session.appwriteUrl + "/account/sessions/token", headers, HTTPClient.METHOD_POST, json)
		
		return true
		
	return false

func _on_otp_request_completed(_res, code, headers: Array[String], _body):
	if not code == 201:
		return false
	
	var cookies: Array[String] = []
	
	for h in headers:
		if h.begins_with("Set-Cookie:"):
			var cookie = h.substr("Set-Cookie: ".length())
			var pairs = cookie.split("; ")
			var value = pairs[0]
			cookies.append(value)
	
	Session.save(cookies)

func _on_login_button_pressed() -> void:
	var success = _send_token()
	$Email/LoginButton.disabled = success


func _on_yes_button_pressed() -> void:
	$Phrase.visible = false
	$Code.visible = true


func _on_submit_button_pressed() -> void:
	var success = _send_otp()
	$Code/SubmitButton.disabled = success
