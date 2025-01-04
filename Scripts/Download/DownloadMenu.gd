extends Control

@onready var kitten_4_request = %Kitten4Request

var downloading: bool

func _ready():
	kitten_4_request.download_file = "C:/Users/%s/Downloads/app.exe" %OS.get_environment("USERNAME")
	kitten_4_request.request("https://kn-cdn.codemao.cn/kitten4/application/%E6%BA%90%E7%A0%81%E7%BC%96%E8%BE%91%E5%99%A84.0-x32-4.11.14.exe", \
			["accept-ranges: bytes"], \
			HTTPClient.METHOD_GET)
	downloading = true

func _process(_delta):
	if downloading:
		print("%s--%s" %[kitten_4_request.get_downloaded_bytes(), kitten_4_request.get_body_size()])

func _on_kitten_4_request_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		print("文件下载成功，保存路径: " + kitten_4_request.download_file)
	else:
		print("下载失败，错误码: " + str(result))
	downloading = false
