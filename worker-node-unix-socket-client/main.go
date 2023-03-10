package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
)

func reader(r io.Reader) {
	buf := make([]byte, 1024)
	for {
		_, err := r.Read(buf[:])
		if err != nil {
			return
		}
	}
}

func main() {
	flag.Parse()
	c, err := net.Dial("unix", "/tmp/entrypoint.sock")

	if err != nil {
		panic(err)
	}
	defer c.Close()

	go reader(c)

	_, err = c.Write([]byte(os.Args[1]))
	if err != nil {
		log.Fatal("write error:", os.Args[1])
	}

	scanner := bufio.NewScanner(c)
	if scanner.Scan() {
		fmt.Print(scanner.Text())
	}
}
