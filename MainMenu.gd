extends Node2D

# Note: replace with the name of your deployed smart contract
const CONTRACT_NAME = "dev-1632885561797-99799145035137"

onready var login_button = $LoginButton
onready var player_name_label = $PlayerNameLabel

var config = {
	"network_id": "testnet",
	"node_url": "https://rpc.testnet.near.org",
	"wallet_url": "https://wallet.testnet.near.org",
}
var wallet_connection

func _ready():
	player_name_label.hide()
	if Near.near_connection == null:
		Near.start_connection(config)
	
	wallet_connection = WalletConnection.new(Near.near_connection)
	wallet_connection.connect("user_signed_in", self, "_on_user_signed_in")
	wallet_connection.connect("user_signed_out", self, "_on_user_signed_out")
	if wallet_connection.is_signed_in():
		_on_user_signed_in(wallet_connection)

func _on_user_signed_in(wallet: WalletConnection):
	login_button.set_text("Sign Out")
	player_name_label.show()
	player_name_label.set_text(wallet.get_account_id())

func _on_user_signed_out(wallet: WalletConnection):
	login_button.set_text("Sign In")
	player_name_label.hide()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_HighScoresButton_pressed():
	get_tree().change_scene("res://HighScoresMenu.tscn")

func _on_LoginButton_pressed():
	if wallet_connection.is_signed_in():
		wallet_connection.sign_out()
	else:
		wallet_connection.sign_in(CONTRACT_NAME)
