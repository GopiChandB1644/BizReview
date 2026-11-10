const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggers when a new review document is created in Firestore.
 * Automatically notifies the business owner via FCM push notification.
 */
exports.notifyOwnerOnNewReview = onDocumentCreated("reviews/{reviewId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  const review = snapshot.data();
  const businessId = review.businessId;
  const rating = review.rating || 5;
  const customerName = review.customerName || "A customer";
  const comment = review.comment || "";

  try {
    // 1. Fetch the business to get the ownerId and businessName
    const businessDoc = await admin.firestore().collection("businesses").doc(businessId).get();
    if (!businessDoc.exists) {
      console.log(`Business ${businessId} not found.`);
      return;
    }

    const businessData = businessDoc.data();
    const ownerId = businessData.ownerId;
    const businessName = businessData.businessName || businessData.name || "Your business";

    if (!ownerId) {
      console.log(`Business ${businessId} has no ownerId.`);
      return;
    }

    // 2. Craft clear dynamic notification
    const title = `⭐ New Review for ${businessName}!`;
    const snippet = comment.length > 0 ? `"${comment}"` : "No comment left.";
    const body = `${customerName} reviewed ${businessName} with ${Math.round(rating)} ⭐: ${snippet}`;

    // 3. Send FCM Push Notification to owner's topic and/or device token
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        businessId: businessId,
        reviewId: event.params.reviewId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      topic: `owner_${ownerId}`,
    };

    const response = await admin.messaging().send(message);
    console.log(`Successfully sent FCM review notification to topic owner_${ownerId}:`, response);
  } catch (error) {
    console.error("Error sending review notification to owner:", error);
  }
});
