import express from 'express';
import { Notification, Provider } from '@parse/node-apn';
import { Environment, Logger } from './utils';

const logger = Logger.child({ module: 'test-notification' });

export const testRouter = express.Router();

// Simple test endpoint
testRouter.get('/test-push/:token', async (req, res) => {
  try {
    const token = req.params.token;
    logger.info({ token }, 'Sending test notification');

    // Initialize provider
    const provider = new Provider({
      token: {
        key: Environment.APNS_AUTH_KEY.read(),
        keyId: Environment.APNS_KEY_ID.read(),
        teamId: Environment.APNS_TEAM_ID.read(),
      },
      production: true, // Use production with production key
    });

    // Create notification
    const notification = new Notification();
    notification.topic = 'com.zebrralabs.zagreus';
    notification.alert = {
      title: 'Test Notification',
      body: 'This is a direct test! Can you see this?',
    };
    notification.sound = 'default';
    notification.badge = 1;
    notification.priority = 10;
    notification.pushType = 'alert';
    notification.contentAvailable = true;
    notification.mutableContent = true;
    notification.expiry = Math.floor(Date.now() / 1000) + 3600;
    
    // Add interruption level for iOS 15+
    notification.payload['interruption-level'] = 'time-sensitive';

    // Log the full notification payload
    logger.info({ 
      notification: {
        topic: notification.topic,
        alert: notification.alert,
        badge: notification.badge,
        sound: notification.sound,
        priority: notification.priority,
        pushType: notification.pushType,
        payload: notification.payload
      }
    }, 'Sending notification with payload');
    
    // Send it
    const result = await provider.send(notification, token);
    
    logger.info({ 
      result,
      sent: result.sent,
      failed: result.failed,
      failedDetails: result.failed.map(f => ({ 
        device: f.device, 
        status: f.status, 
        response: f.response
      }))
    }, 'Notification result with details');
    
    res.json({ 
      success: true, 
      result: {
        sent: result.sent.length,
        failed: result.failed,
      }
    });

    await provider.shutdown();
  } catch (error) {
    logger.error({ error }, 'Test notification failed');
    res.status(500).json({ error: String(error) });
  }
});