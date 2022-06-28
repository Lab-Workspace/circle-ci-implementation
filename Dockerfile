FROM golang:1.17
COPY ./app /go/bin/app
EXPOSE 8080
CMD ["/go/bin/app"]
