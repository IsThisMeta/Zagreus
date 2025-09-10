package main

import (
	"context"
	"database/sql"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var (
	db    *sql.DB
	rdb   *redis.Client
	ctx   = context.Background()
)

func init() {
	// Initialize PostgreSQL if DATABASE_URL is set
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL != "" {
		var err error
		db, err = sql.Open("postgres", dbURL)
		if err != nil {
			log.Printf("Failed to connect to database: %v", err)
			// Don't fatal, let the app run without DB for now
		} else {
			db.SetMaxOpenConns(10)
			db.SetMaxIdleConns(5)
			db.SetConnMaxLifetime(5 * time.Minute)

			if err = db.Ping(); err != nil {
				log.Printf("Failed to ping database: %v", err)
				// Don't fatal, let the app run without DB for now
			} else {
				log.Println("Database connection initialized")
			}
		}
	} else {
		log.Println("DATABASE_URL not set, running without database")
	}

	// Initialize Redis if REDIS_URL is set
	redisURL := os.Getenv("REDIS_URL")
	if redisURL != "" {
		opt, err := redis.ParseURL(redisURL)
		if err != nil {
			log.Printf("Failed to parse Redis URL: %v", err)
		} else {
			rdb = redis.NewClient(opt)
			
			if err = rdb.Ping(ctx).Err(); err != nil {
				log.Printf("Failed to connect to Redis: %v", err)
			} else {
				log.Println("Redis connection initialized")
			}
		}
	} else {
		log.Println("REDIS_URL not set, running without Redis")
	}
}

// Device registration
type DeviceRegistration struct {
	UserID      string `json:"user_id"`
	DeviceToken string `json:"device_token"`
	DeviceType  string `json:"device_type"`
}

func handleRegister(c *gin.Context) {
	var req DeviceRegistration
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	if db == nil {
		log.Printf("Device registration request received but database not connected")
		c.JSON(200, gin.H{
			"success": true,
			"device_id": "mock-device-id",
			"message": "Database not connected, registration simulated",
		})
		return
	}

	// Check if device exists
	var deviceID string
	err := db.QueryRow(`
		SELECT id FROM notification_devices 
		WHERE user_id = $1 AND device_token = $2
	`, req.UserID, req.DeviceToken).Scan(&deviceID)

	if err == sql.ErrNoRows {
		// Insert new device
		err = db.QueryRow(`
			INSERT INTO notification_devices (user_id, device_token, device_type)
			VALUES ($1, $2, $3)
			RETURNING id
		`, req.UserID, req.DeviceToken, req.DeviceType).Scan(&deviceID)
		
		if err != nil {
			log.Printf("Failed to insert device: %v", err)
			c.JSON(500, gin.H{"error": "Failed to register device"})
			return
		}
	} else if err != nil {
		log.Printf("Database error: %v", err)
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	// Update last seen
	_, err = db.Exec(`
		UPDATE notification_devices 
		SET last_seen_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`, deviceID)

	if err != nil {
		log.Printf("Failed to update last seen: %v", err)
	}

	log.Printf("Device registered: %s for user %s", deviceID, req.UserID)
	
	c.JSON(200, gin.H{
		"success": true,
		"device_id": deviceID,
	})
}

// Get device tokens for a user
func getDeviceTokensForUser(userID string) ([]string, error) {
	if db == nil {
		log.Printf("getDeviceTokensForUser called but database not connected")
		return []string{}, nil
	}
	
	rows, err := db.Query(`
		SELECT device_token FROM notification_devices
		WHERE user_id = $1 AND is_active = true
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tokens []string
	for rows.Next() {
		var token string
		if err := rows.Scan(&token); err != nil {
			continue
		}
		tokens = append(tokens, token)
	}

	return tokens, nil
}

