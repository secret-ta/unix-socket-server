package main

import (
	"github.com/labstack/echo/v4"
	"log"
	"net/http"
	"os/exec"
)

func getEntryPoint(imageName string) (string, error) {
	out, err := exec.Command("bash", "get-entrypoint.sh", imageName).Output()

	return string(out), err
}

func main() {
	e := echo.New()
	e.GET("/containers/entrypoints", func(c echo.Context) error {

		imageName := c.QueryParam("image_name")

		if imageName != "" {
			entrypoint, err := getEntryPoint(imageName)

			if err != nil {
				log.Fatal(err)
			}

			return c.String(http.StatusOK, entrypoint)
		}
		return c.String(http.StatusOK, "")
	})
	e.Logger.Fatal(e.Start(":1729"))
}
