import * as admin from 'firebase-admin';
import { getBackupBucket } from './';

export const deleteUser = async (user: admin.auth.UserRecord) => {
  try {
    const bucket = getBackupBucket();
    if (await bucket.exists()) {
      bucket
        .deleteFiles({
          prefix: `${user.uid}/`,
        })
        .then(() => console.log(`Storage: ${user.uid} Deleted`));
    }
  } catch (error) {
    console.error(error);
  }
};
