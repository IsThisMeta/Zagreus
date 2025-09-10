package main

import (
	"encoding/base64"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

// Sonarr webhook structures
type SonarrWebhook struct {
	EventType string        `json:"eventType"`
	Series    SonarrSeries  `json:"series"`
	Episodes  []SonarrEpisode `json:"episodes"`
}

type SonarrSeries struct {
	Title    string `json:"title"`
	Year     int    `json:"year"`
	TvdbID   int    `json:"tvdbId"`
	TvMazeID int    `json:"tvMazeId"`
	ImdbID   string `json:"imdbId"`
}

type SonarrEpisode struct {
	Title         string `json:"title"`
	SeasonNumber  int    `json:"seasonNumber"`
	EpisodeNumber int    `json:"episodeNumber"`
	Quality       string `json:"quality"`
}

// Radarr webhook structures
type RadarrWebhook struct {
	EventType string      `json:"eventType"`
	Movie     RadarrMovie `json:"movie"`
}

type RadarrMovie struct {
	Title  string `json:"title"`
	Year   int    `json:"year"`
	ImdbID string `json:"imdbId"`
	TmdbID int    `json:"tmdbId"`
}

// Generic webhook response
type WebhookResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

func handleSonarrWebhook(c *gin.Context) {
	var webhook SonarrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	// Get user ID from headers (this is how the Node.js version does it)
	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	log.Printf("Received Sonarr webhook: %s for user %s", webhook.EventType, userID)

	// Handle different event types
	var title, body string
	
	switch webhook.EventType {
	case "Grab":
		if len(webhook.Episodes) > 0 {
			ep := webhook.Episodes[0]
			title = "Episode Grabbed"
			body = fmt.Sprintf("%s S%02dE%02d has been grabbed", 
				webhook.Series.Title, ep.SeasonNumber, ep.EpisodeNumber)
		}
		
	case "Download":
		if len(webhook.Episodes) > 0 {
			ep := webhook.Episodes[0]
			title = "Episode Downloaded"
			body = fmt.Sprintf("%s S%02dE%02d is ready to watch", 
				webhook.Series.Title, ep.SeasonNumber, ep.EpisodeNumber)
		}
		
	case "Rename":
		title = "Episodes Renamed"
		body = fmt.Sprintf("%d episodes of %s have been renamed", 
			len(webhook.Episodes), webhook.Series.Title)
		
	case "SeriesDelete":
		title = "Series Deleted"
		body = fmt.Sprintf("%s has been removed from your library", webhook.Series.Title)
		
	default:
		log.Printf("Unknown Sonarr event type: %s", webhook.EventType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	// Send notification
	if title != "" && body != "" {
		if err := sendNotificationToUser(userID, title, body); err != nil {
			log.Printf("Failed to send notification: %v", err)
			c.JSON(500, gin.H{"error": "Failed to send notification"})
			return
		}
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Webhook processed successfully",
	})
}

func handleRadarrWebhook(c *gin.Context) {
	var webhook RadarrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}

	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	log.Printf("Received Radarr webhook: %s for user %s", webhook.EventType, userID)

	var title, body string
	
	switch webhook.EventType {
	case "Grab":
		title = "Movie Grabbed"
		body = fmt.Sprintf("%s (%d) has been grabbed", webhook.Movie.Title, webhook.Movie.Year)
		
	case "Download":
		title = "Movie Downloaded"
		body = fmt.Sprintf("%s (%d) is ready to watch", webhook.Movie.Title, webhook.Movie.Year)
		
	case "Rename":
		title = "Movie Renamed"
		body = fmt.Sprintf("%s has been renamed", webhook.Movie.Title)
		
	case "MovieDelete":
		title = "Movie Deleted"
		body = fmt.Sprintf("%s has been removed from your library", webhook.Movie.Title)
		
	case "Test":
		title = "Zagreus Test"
		body = "Test notification from Zagreus"
		
	default:
		log.Printf("Unknown Radarr event type: %s", webhook.EventType)
		c.JSON(200, WebhookResponse{Success: true, Message: "Event ignored"})
		return
	}

	if title != "" && body != "" {
		if err := sendNotificationToUser(userID, title, body); err != nil {
			log.Printf("Failed to send notification: %v", err)
			c.JSON(500, gin.H{"error": "Failed to send notification"})
			return
		}
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Webhook processed successfully",
	})
}

// Custom webhook handler
func handleCustomWebhook(c *gin.Context) {
	var data map[string]interface{}
	if err := c.ShouldBindJSON(&data); err != nil {
		c.JSON(400, gin.H{"error": "Invalid JSON"})
		return
	}

	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(401, gin.H{"error": "Missing user ID"})
		return
	}

	// Extract title and body from custom webhook
	title, _ := data["title"].(string)
	body, _ := data["body"].(string)
	
	if title == "" {
		title = "Custom Notification"
	}
	if body == "" {
		body = "You have a new notification"
	}

	log.Printf("Received custom webhook for user %s: %s - %s", userID, title, body)

	if err := sendNotificationToUser(userID, title, body); err != nil {
		log.Printf("Failed to send notification: %v", err)
		c.JSON(500, gin.H{"error": "Failed to send notification"})
		return
	}

	c.JSON(200, WebhookResponse{
		Success: true,
		Message: "Custom notification sent",
	})
}

// Helper to validate webhook auth
func validateWebhookAuth(c *gin.Context) bool {
	// For now, just check for user ID
	// In production, you'd want proper webhook secrets
	return c.GetHeader("X-User-Id") != ""
}

// Other webhook handlers remain as stubs for now
func handleLidarrWebhook(c *gin.Context) {
	// Similar to Sonarr/Radarr
	c.JSON(200, gin.H{"message": "Lidarr webhook received"})
}

func handleOverseerrWebhook(c *gin.Context) {
	// Similar structure
	c.JSON(200, gin.H{"message": "Overseerr webhook received"})
}

func handleTautulliWebhook(c *gin.Context) {
	// Similar structure
	c.JSON(200, gin.H{"message": "Tautulli webhook received"})
}

// Handle webhook with user ID in URL path (Flutter app compatibility)
func handleWebhookWithPayload(c *gin.Context) {
	payload := c.Param("payload")
	
	// Decode the base64 user ID
	userIDBytes, err := base64.StdEncoding.DecodeString(payload)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid payload"})
		return
	}
	userID := string(userIDBytes)
	
	// Try to parse as Radarr webhook (since that's what the Flutter app sends)
	var webhook RadarrWebhook
	if err := c.ShouldBindJSON(&webhook); err != nil {
		c.JSON(400, gin.H{"error": "Invalid webhook data"})
		return
	}
	
	log.Printf("Received webhook via payload URL: %s for user %s", webhook.EventType, userID)
	
	var title, body string
	
	switch webhook.EventType {
	case "Test":
		title = "Zagreus Test"
		body = "Test notification from Zagreus"
		
		// Send the notification without delay since user controls timing from app
		if err := sendNotificationToUser(userID, title, body); err != nil {
			log.Printf("Failed to send notification: %v", err)
			c.JSON(500, gin.H{"error": "Failed to send notification"})
			return
		}
		
		c.JSON(200, gin.H{
			"success": true,
			"message": "Test notification sent",
		})
		return
		
	default:
		// If not a test, set the user ID header and forward to normal Radarr handler
		c.Request.Header.Set("X-User-Id", userID)
		handleRadarrWebhook(c)
	}
}