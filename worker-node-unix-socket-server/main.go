package main

import (
	"log"
	"net"
	"os/exec"
)

func getEntryPoint(imageName string) (string, error) {
	out, err := exec.Command("bash", "get-entrypoint.sh", imageName).Output()

	return string(out), err
}

func entrypointServer(c net.Conn) {
	for {
		buf := make([]byte, 512)
		nr, err := c.Read(buf)
		if err != nil {
			return
		}

		data := buf[0:nr]
		println("Server got:", string(data))
		imageName := string(data)
		entrypoint, err := getEntryPoint(imageName)

		_, err = c.Write([]byte(entrypoint))
		if err != nil {
			log.Fatal("Write:", entrypoint)
		}
	}
}

func main() {
	l, err := net.Listen("unix", "/tmp/entrypoint.sock")
	if err != nil {
		log.Fatal("listen error:", err)
	}

	for {
		fd, err := l.Accept()
		if err != nil {
			log.Fatal("accept error:", err)
		}

		go entrypointServer(fd)
	}
}
