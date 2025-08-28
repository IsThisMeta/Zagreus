import * as admin from 'firebase-admin';
import { getUserRootPath } from './';

export const deleteUser = async (user: admin.auth.UserRecord) => {
  try {
    const document = admin.firestore().doc(getUserRootPath(user));
    if ((await document.get()).exists) {
      document
        .listCollections()
        .then(_processCollections)
        .then(() => document.delete())
        .then(() => console.log(`Firestore: ${user.uid} Deleted`));
    }
  } catch (error) {
    console.error(error);
  }
};

const _processCollections = async (
  // eslint-disable-next-line max-len
  collections: admin.firestore.CollectionReference<admin.firestore.DocumentData>[],
): Promise<void> => {
  collections.forEach((collection) => {
    collection.listDocuments().then(_processDocuments);
  });
};

const _processDocuments = async (
  documents: admin.firestore.DocumentReference<admin.firestore.DocumentData>[],
): Promise<void> => {
  documents.forEach((document) => {
    document
      .listCollections()
      .then(_processCollections)
      .then(() => document.delete());
  });
};
