const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Cloud Function triggered whenever a document in the 'users' collection is deleted.
 * Automatically performs a recursive delete on the corresponding 'chats/{userId}' document
 * and its 'messages' subcollection to prevent orphaned data in Firestore.
 */
exports.onUserDeleted = functions.firestore
  .document('users/{userId}')
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    console.log(`User document deleted for UID: ${userId}. Initiating cleanup of chats collection...`);

    const firestore = admin.firestore();
    const chatDocRef = firestore.collection('chats').doc(userId);

    try {
      // Use recursiveDelete to ensure both the main chat document AND the 'messages' subcollection are fully deleted
      await firestore.recursiveDelete(chatDocRef);
      console.log(`Successfully deleted chats document and all messages for UID: ${userId}`);
    } catch (error) {
      console.error(`Error deleting chats for UID: ${userId}:`, error);
    }
  });
