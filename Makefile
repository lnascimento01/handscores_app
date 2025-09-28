APP_NAME=handscore
ORG=tech.appointment.handscore
PORT=8080

init:
	flutter create --org $(ORG) --project-name $(APP_NAME) --platforms android,ios,web .
	@echo "✅ Projeto criado"

get:
	flutter pub get

run-web:
	flutter run -d web-server --web-hostname 0.0.0.0 --web-port $(PORT)

devices:
	flutter devices

apk-debug:
	flutter build apk --debug

apk-release:
	flutter build apk --release

clean:
	flutter clean
