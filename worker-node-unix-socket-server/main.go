package main

import (
	"log"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"syscall"
)

func transformImageNameToFullName(imageName string) string {
	imageNames := strings.Split(imageName, "/")
	if len(imageNames) == 1 {
		imageName = "docker.io/" + "library/" + imageName
	} else if len(imageNames) == 2 {
		imageName = "docker.io/" + imageName
	}
	println("Full image name:", imageName)

	return imageName
}

func getEntryPoint(imageName string) (string, error) {
	imageName = transformImageNameToFullName(imageName)
	out, err := exec.Command("bash", "/var/lib/entrypoint/get-entrypoint-v2.sh", imageName, "2>", "/dev/null").Output()

	if err != nil {
		log.Printf("Error getting entry point for image %s: %v", imageName, err)
		return "", err
	}

	return string(out), err
}

func entrypointServer(c net.Conn) {
	defer c.Close()

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
	socketFile := "/tmp/entrypoint.sock"
	l, err := net.Listen("unix", socketFile)
	if err != nil {
		log.Fatal("listen error:", err)
	}

	defer func() {
		err := l.Close()
		if err != nil {
			log.Printf("Error closing listener: %v", err)
		}
		err = os.Remove(socketFile)
		if err != nil {
			log.Printf("Error removing socket file: %v", err)
		}
	}()

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sig
		log.Printf("Received signal, shutting down...")
		err := l.Close()
		if err != nil {
			log.Printf("Error closing listener: %v", err)
		}
	}()

	for {
		conn, err := l.Accept()
		if err != nil {
			log.Fatal("accept error:", err)
		}

		go entrypointServer(conn)
	}
}
