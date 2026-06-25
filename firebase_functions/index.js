const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Cloud Function triggered whenever a document in the 'users' collection is deleted.
 * 1. Deletes the user account from Firebase Authentication.
 * 2. Recursively deletes the user's document (to clean up the 'weight_history' subcollection).
 * 3. Recursively deletes the user's chats document ('chats/{userId}') and 'messages'.
 * 4. Recursively deletes the user's logs document ('logs/{userId}') and 'food_entries'.
 */
exports.onUserDeleted = functions.firestore
  .document('users/{userId}')
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    console.log(`[users] Document deleted for UID: ${userId}. Initiating full cleanup...`);

    const firestore = admin.firestore();

    try {
      // 1. Delete from Firebase Authentication
      try {
        await admin.auth().deleteUser(userId);
        console.log(`[users] Successfully deleted Firebase Auth user: ${userId}`);
      } catch (authError) {
        if (authError.code === 'auth/user-not-found') {
          console.log(`[users] Firebase Auth user ${userId} already deleted or not found.`);
        } else {
          console.error(`[users] Error deleting Firebase Auth user ${userId}:`, authError);
        }
      }

      // 2. Recursively delete the user's document to catch orphaned subcollections (like weight_history)
      // We pass the document reference itself to recursiveDelete
      const userDocRef = firestore.collection('users').doc(userId);
      await firestore.recursiveDelete(userDocRef);
      console.log(`[users] Successfully recursively deleted users/${userId} subcollections.`);

      // 3. Recursively delete chats
      const chatDocRef = firestore.collection('chats').doc(userId);
      await firestore.recursiveDelete(chatDocRef);
      console.log(`[users] Successfully deleted chats document and all messages for UID: ${userId}`);

      // 4. Recursively delete logs
      const logDocRef = firestore.collection('logs').doc(userId);
      await firestore.recursiveDelete(logDocRef);
      console.log(`[users] Successfully deleted logs document and all food_entries for UID: ${userId}`);

    } catch (error) {
      console.error(`[users] Global error during cleanup for UID: ${userId}:`, error);
    }
  });

/**
 * Cloud Function triggered whenever a document in the 'coaches' collection is deleted.
 * 1. Deletes the coach account from Firebase Authentication.
 * 2. Queries all patients assigned to this coach and resets their assignedCoachId.
 */
exports.onCoachDeleted = functions.firestore
  .document('coaches/{coachId}')
  .onDelete(async (snap, context) => {
    const coachId = context.params.coachId;
    console.log(`[coaches] Document deleted for Coach ID: ${coachId}. Initiating full cleanup...`);

    const firestore = admin.firestore();

    try {
      // 1. Delete from Firebase Authentication
      try {
        await admin.auth().deleteUser(coachId);
        console.log(`[coaches] Successfully deleted Firebase Auth coach: ${coachId}`);
      } catch (authError) {
        if (authError.code === 'auth/user-not-found') {
          console.log(`[coaches] Firebase Auth coach ${coachId} already deleted or not found.`);
        } else {
          console.error(`[coaches] Error deleting Firebase Auth coach ${coachId}:`, authError);
        }
      }

      // 2. Unassign patients who were assigned to this coach
      console.log(`[coaches] Looking for patients assigned to coach ${coachId}...`);
      const usersQuery = await firestore.collection('users')
          .where('assignedCoachId', '==', coachId)
          .get();

      if (!usersQuery.empty) {
        const batch = firestore.batch();
        usersQuery.docs.forEach((doc) => {
          // Reset to ADMIN_PENDING so they appear back in the admin panel to be assigned
          batch.update(doc.ref, { assignedCoachId: 'ADMIN_PENDING' });
        });
        await batch.commit();
        console.log(`[coaches] Successfully unassigned ${usersQuery.size} patients from coach ${coachId}.`);
      } else {
        console.log(`[coaches] No patients were assigned to coach ${coachId}.`);
      }

    } catch (error) {
      console.error(`[coaches] Global error during cleanup for Coach ID: ${coachId}:`, error);
    }
  });
