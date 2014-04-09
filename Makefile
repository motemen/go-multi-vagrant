TARGET = build/main.$(shell hostname --fqdn 2> /dev/null || uname -n 2> /dev/null)

all: test build

test: deps
	go test ./...

build: deps
	go build -o $(TARGET) ./...

clean:
	go clean -r

deps:
	go get -d ./...

.PHONY: test build clean deps
