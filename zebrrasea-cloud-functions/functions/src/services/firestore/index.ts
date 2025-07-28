import * as admin from 'firebase-admin';
import { deleteUser } from './delete_user';

const getUserRootPath = (user: admin.auth.UserRecord) => `users/${user.uid}`;

export { deleteUser, getUserRootPath };
