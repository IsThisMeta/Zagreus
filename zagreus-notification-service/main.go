package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Initialize APNs
	if err := initAPNs(); err != nil {
		log.Fatal("Failed to initialize APNs:", err)
	}

	// Setup Gin
	r := gin.Default()
	
	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "OK",
			"version": "2.0.0", // Go version baby!
		})
	})

	// Docs redirect
	r.GET("/", func(c *gin.Context) {
		c.Redirect(301, "https://docs.zagreus.app/zagreus/notifications")
	})

	// API routes
	v1 := r.Group("/v1")
	{
		// Auth routes
		auth := v1.Group("/auth")
		{
			auth.POST("/login", handleLogin)
			auth.POST("/register", handleRegister)
		}

		// Webhook routes
		webhook := v1.Group("/webhook")
		{
			webhook.POST("/sonarr", handleSonarrWebhook)
			webhook.POST("/radarr", handleRadarrWebhook)
			webhook.POST("/lidarr", handleLidarrWebhook)
			webhook.POST("/overseerr", handleOverseerrWebhook)
			webhook.POST("/tautulli", handleTautulliWebhook)
			webhook.POST("/custom", handleCustomWebhook)
		}
		
		// Notifications webhook (for Flutter app compatibility)
		notifications := v1.Group("/notifications/webhook")
		{
			notifications.POST("/:payload", handleWebhookWithPayload)
		}
	}

	// Test routes
	test := r.Group("/test")
	{
		test.GET("/test-push/:token", handleTestPush)
	}

	// Direct test routes (our working implementation!)
	direct := r.Group("/direct")
	{
		direct.GET("/test-direct/:token", handleDirectTest)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

// handleLogin stub for now
func handleLogin(c *gin.Context) {
	c.JSON(200, gin.H{"message": "login endpoint"})
}

// handleRegister delegates to database.go
// This is here to satisfy the router setup