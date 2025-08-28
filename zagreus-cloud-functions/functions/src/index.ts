import * as admin from 'firebase-admin';
import { deleteUserController } from './controllers';

admin.initializeApp();
export { deleteUserController };
