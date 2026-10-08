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
    if (!snap) {
      console.log("⚠️ No snapshot data");
      return;
    }

    const notification = snap.data();
    const receiverId = notification.receiverId;

    if (!receiverId) {
      console.log("❌ Missing receiverId in appNotification");
      return;
    }

    console.log("📩 New appNotification:", {
      id: snap.id,
      type: notification.type,
      receiverId,
    });

    try {
      // 1️⃣ Load receiver
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(receiverId)
        .get();

      if (!userDoc.exists) {
        console.log(`❌ User not found: ${receiverId}`);
        return;
      }

      const tokens = userDoc.data().fcmTokens ?? [];
      if (tokens.length === 0) {
        console.log(`⚠️ No FCM tokens for user ${receiverId}`);
        return;
      }

      // 3️⃣ Send to each token (safe + debuggable)
      for (const token of tokens) {
        const message = {
          token,
          notification: {
            title: notification.title,
            body: notification.content,
          },
          data: {
            notificationId: snap.id,
            type: notification.type,
          },
        };

        try {
          await admin.messaging().send(message);
          console.log("✅ Push sent to token:", token);
        } catch (err) {
          console.error("❌ Failed to send push to token:", token, err);
        }
      }
    } catch (err) {
      console.error("❌ Fatal error while sending push:", err);
    }
  }
);