all: test build

test: deps
	go test ./...

build: deps
	go build ./...

clean:
	go clean -r

deps:
	go get -d ./...

.PHONY: test build clean deps
