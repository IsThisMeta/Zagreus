import * as admin from 'firebase-admin';
import * as Cache from './cache';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging, MulticastMessage } from 'firebase-admin/messaging';
import { Environment, Logger, Notifications } from '../../utils';

const logger = Logger.child({ module: 'firebase' });
let firebase: admin.app.App;

export const initialize = (): void => {
  firebase = admin.initializeApp({
    credential: admin.credential.cert(<admin.ServiceAccount>{
      clientEmail: Environment.FIREBASE_CLIENT_EMAIL.read(),
      projectId: Environment.FIREBASE_PROJECT_ID.read(),
      privateKey: Environment.FIREBASE_PRIVATE_KEY.read().replace(/\\n/gm, '\n'),
    }),
    databaseURL: Environment.FIREBASE_DATABASE_URL.read(),
  });
};

export const hasUserID = async (uid: string): Promise<boolean> => {
  try {
    if (!uid) return false;
    return await getAuth(firebase)
      .getUser(uid)
      .then((user) => {
        if (user) return true;
        return false;
      });
  } catch (error) {
    logger.error(error);
    return false;
  }
};

export const getUserDevices = async (uid: string): Promise<string[]> => {
  try {
    // Invalid UID
    if (!uid) return [];

    // Cache
    const cache = await Cache.getDeviceList(uid);
    if (cache) return cache;

    // Firestore
    return await getFirestore(firebase)
      .doc(`users/${uid}`)
      .get()
      .then((document) => {
        const data = document.data();
        if (data) {
          const devices = data['devices'] ?? [];
          Cache.setDeviceList(uid, devices);
          return devices;
        }
        return [];
      });
  } catch (error) {
    logger.error(error);
    return [];
  }
};

export const sendNotification = async (
  tokens: string[],
  payload: Notifications.Payload,
  settings: Notifications.Settings,
): Promise<boolean> => {
  try {
    const message: MulticastMessage = Notifications.buildMulticastMessage(
      tokens,
      payload,
      settings,
    );

    return await getMessaging(firebase)
      .sendEachForMulticast(message)
      .then((response) => {
        logger.debug(
          {
            success: response.successCount,
            failure: response.failureCount,
          },
          'Sent notification(s)',
        );
        return response.successCount > 0;
      });
  } catch (error) {
    logger.error(error);
    return false;
  }
};
