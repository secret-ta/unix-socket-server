package main

import (
	"log"
	"net"
	"os/exec"
	"strings"
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
	out, err := exec.Command("bash", "get-entrypoint-v2.sh", imageName, "2>", "/dev/null").Output()

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
