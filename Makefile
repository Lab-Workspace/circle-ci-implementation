APP_NAME=app

app: main.go
	go build -o $(APP_NAME) main.go

clean:
	rm $(APP_NAME)
