const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendUserNotification = onDocumentCreated(
  {
    document: "appNotifications/{id}",
    region: "europe-west4",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const receiverId = data.receiverId;
    if (!receiverId) return console.log("❌ No receiverId in notification");

    try {
      // Pobierz usera
      const userDoc = await admin.firestore().collection("users").doc(receiverId).get();
      if (!userDoc.exists) return console.log(`❌ User not found: ${receiverId}`);

      const tokens = userDoc.data().fcmTokens || [];
      if (tokens.length === 0) return console.log(`⚠️ No FCM tokens for ${receiverId}`);

      for (const token of tokens) {
        const message = {
          token: token,
          notification: {
            title: data.content,
            body: data.type,
          },
          data: {
            notificationId: snap.id,
          },
        };

        try {
          await admin.messaging().send(message);
          console.log(`✅ Sent notification to token: ${token}`);
        } catch (err) {
          console.error(`❌ Failed to send to token: ${token}`, err);
        }
      }
    } catch (err) {
      console.error("❌ Error fetching user or sending notification:", err);
    }
  }
);