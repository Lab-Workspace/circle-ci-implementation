APP_NAME=app

app: src/main.go
	go build -o $(APP_NAME) src/main.go

clean:
	rm $(APP_NAME)
