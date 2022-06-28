package main

import (
	"fmt"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, "{\"hello\": \"%d\"}", times(5, 10))
}

func main() {
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func times(a int, b int) int {
	return a * b
}

func divide(a int, b int) (int, error) {
	if b == 0 {
		return 0, fmt.Errorf("Can't divide by zero")
	}
	return a / b, nil
}
