import * as functions from 'firebase-functions';
import { Firestore, Storage } from '../services';

export const deleteUserController = functions.auth
  .user()
  .onDelete(async (user: functions.auth.UserRecord) => {
    await Firestore.deleteUser(user);
    await Storage.deleteUser(user);
  });
