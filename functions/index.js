const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getMessaging} = require("firebase-admin/messaging");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

exports.sendBookingNotification = onDocumentUpdated(
    "bookings/{bookingId}",
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();

      if (before.status === after.status) {
        return;
      }

      const userId = after.userId;
      const status = after.status;

      const userDoc = await getFirestore()
          .collection("users").doc(userId).get();
      const fcmToken = userDoc.data().fcmToken;

      if (!fcmToken) {
        console.log("User does not have an FCM token.");
        return;
      }

      let notificationBody;
      if (status === "approved") {
        notificationBody = "Your booking request has been approved!";
      } else if (status === "rejected") {
        const reason = after.rejectionReason || "No reason provided.";
        notificationBody = `Your booking was rejected. Reason: ${reason}`;
      } else {
        return;
      }

      const payload = {
        notification: {
          title: "Booking Status Update",
          body: notificationBody,
        },
        token: fcmToken,
      };

      try {
        await getMessaging().send(payload);
        console.log("Notification sent successfully!");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });
