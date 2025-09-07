import { Provider, Notification } from '@parse/node-apn';
import * as Cache from '../firebase/cache'; // Reuse the same cache logic
import { Environment, Logger } from '../../utils';
import * as APNSNotifications from '../../utils/apns-notifications';
import { DatabaseService } from '../database'; // New service for user management

const logger = Logger.child({ module: 'apns' });
let apnsProvider: Provider;

/**
 * Initialize APNS Provider with certificates and configuration
 */
export const initialize = (): void => {
  const options = {
    // Certificate-based authentication
    cert: Environment.APNS_CERT_PATH.read(),
    key: Environment.APNS_KEY_PATH.read(),
    
    // Or token-based authentication (recommended)
    token: {
      key: Environment.APNS_AUTH_KEY.read(),
      keyId: Environment.APNS_KEY_ID.read(),
      teamId: Environment.APNS_TEAM_ID.read(),
    },
    
    // Environment
    production: Environment.NODE_ENV.read() === 'production',
    
    // Connection settings
    connectionRetryLimit: 10,
  };

  apnsProvider = new Provider(options);

  // Handle provider events
  apnsProvider.on('error', (error: Error) => {
    logger.error({ error }, 'APNS Provider error');
  });

  apnsProvider.on('socketError', (error: Error) => {
    logger.error({ error }, 'APNS Socket error');
  });

  apnsProvider.on('transmissionError', (errCode: number, notification: any, device: string) => {
    logger.error(
      { errorCode: errCode, device, notification },
      'APNS Transmission error'
    );
  });
};

/**
 * Check if user exists in the database
 */
export const hasUserID = async (uid: string): Promise<boolean> => {
  try {
    if (!uid) return false;
    
    // Check in your own database instead of Firebase
    const user = await DatabaseService.getUser(uid);
    return !!user;
  } catch (error) {
    logger.error(error);
    return false;
  }
};

/**
 * Get user's registered device tokens
 */
export const getUserDevices = async (uid: string): Promise<string[]> => {
  try {
    // Invalid UID
    if (!uid) return [];

    // Check cache first
    const cache = await Cache.getDeviceList(uid);
    if (cache) return cache;

    // Get from database
    const devices = await DatabaseService.getUserDevices(uid);
    
    // Cache the results
    if (devices.length > 0) {
      await Cache.setDeviceList(uid, devices);
    }
    
    return devices;
  } catch (error) {
    logger.error(error);
    return [];
  }
};

/**
 * Send notifications via APNS
 */
export const sendNotification = async (
  tokens: string[],
  payload: APNSNotifications.APNSPayload,
  settings: APNSNotifications.APNSSettings,
): Promise<boolean> => {
  try {
    // Validate and group tokens
    const { valid: validTokens, invalid: invalidTokens } = 
      APNSNotifications.groupTokensByValidity(tokens);
    
    if (invalidTokens.length > 0) {
      logger.warn(
        { count: invalidTokens.length, tokens: invalidTokens },
        'Invalid tokens detected'
      );
    }

    if (validTokens.length === 0) {
      logger.warn('No valid tokens to send notifications to');
      return false;
    }

    // Build notification
    const notification = APNSNotifications.buildAPNSNotification(payload, settings);
    
    // Send to all valid tokens
    const result = await apnsProvider.send(notification, validTokens);
    
    // Process results
    let successCount = 0;
    let failureCount = 0;

    result.sent.forEach((sentResult: any) => {
      successCount++;
      logger.debug({ device: sentResult.device }, 'Notification sent successfully');
    });

    result.failed.forEach((failedResult: any) => {
      failureCount++;
      logger.error(
        {
          device: failedResult.device,
          status: failedResult.status,
          response: failedResult.response,
        },
        'Notification failed'
      );

      // Handle specific errors
      if (failedResult.status === 410) {
        // Token is no longer valid, remove from database
        DatabaseService.removeDeviceToken(failedResult.device).catch((err) => {
          logger.error({ error: err }, 'Failed to remove invalid token');
        });
      }
    });

    logger.info(
      {
        success: successCount,
        failure: failureCount,
        total: validTokens.length,
      },
      'Notification batch completed'
    );

    return successCount > 0;
  } catch (error) {
    logger.error({ error }, 'Failed to send APNS notification');
    return false;
  }
};

/**
 * Cleanup provider connections
 */
export const shutdown = async (): Promise<void> => {
  if (apnsProvider) {
    await apnsProvider.shutdown();
    logger.info('APNS Provider shut down');
  }
};