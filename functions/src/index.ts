import {onRequest} from "firebase-functions/v2/https";
import {
  onDocumentCreated,
  onDocumentWritten,
} from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {readFileSync} from "fs";
import {join} from "path";

admin.initializeApp();

export const ogPreview = onRequest(async (request, response) => {
  logger.info("OG Preview function called!", {structuredData: true});

  // eventId from /rsvp/:eventId or /events/:eventId
  const eventId = request.params[0].split("/")[1];
  const guestId = request.query.guestId as string;

  if (!eventId) {
    logger.error(
      `Missing eventId in request parameters: ${JSON.stringify(request.params)}`
    );
    response.status(400).send("Missing eventId");
    return;
  }

  if (!guestId) {
    logger.error(
      `Missing guestId in request query: ${JSON.stringify(request.query)}`
    );
    response.status(400).send("Missing guestId");
    return;
  }

  try {
    const eventDoc = await admin.firestore()
      .collection("events")
      .doc(eventId)
      .get();

    if (!eventDoc.exists) {
      response.status(404).send("Event not found");
      return;
    }

    const eventData = eventDoc.data();

    if (!eventData) {
      response.status(500).send("Event data is empty");
      return;
    }

    const title = eventData.title || "Event Invitation";
    const description = eventData.description || "You're invited to an event!";
    const imageUrl = eventData.invitationImageThumbnailUrl || ""; // default ?
    const url = eventData.settings.rsvpRequired ?
      `https://${process.env.GCLOUD_PROJECT}.web.app/rsvp/${eventId}?guestId=${guestId}` :
      `https://${process.env.GCLOUD_PROJECT}.web.app/events/${eventId}?guestId=${guestId}`;

    const ogTags = `
      <meta property="og:title" content="${title}" />
      <meta property="og:description" content="${description}" />
      <meta property="og:image" content="${imageUrl}" />
      <meta property="og:url" content="${url}" />
      <meta property="og:type" content="website" />
    `;

    // Read the index.html file
    const indexPath = join(
      __dirname,
      "../../workspace/public",
      "index.html"
    );
    let indexHtml = readFileSync(indexPath, "utf8");

    // Inject OG tags into the head section
    indexHtml = indexHtml.replace("<head>", `<head>${ogTags}`);

    response.send(indexHtml);
  } catch (error) {
    logger.error("Error fetching event or generating OG tags:", error);
    response.status(500).send("Internal Server Error");
  }
});

// Notify host of new/updated RSVP
export const sendRsvpNotification = onDocumentWritten(
  "events/{eventId}/rsvps/{rsvpId}",
  async (event) => {
    logger.info("Event updated!");

    if (!event.data) {
      logger.info("No data associated with the event");
      return;
    }

    const beforeRsvp = event.data.before.data();
    const rsvpData = event.data.after.data();
    if (!rsvpData) {
      logger.info(`RSVP Deleted for ${event.params.rsvpId}`);
      return;
    }

    // Update event counts
    const eventDoc = await admin
      .firestore()
      .collection("events")
      .doc(event.params.eventId)
      .get();

    if (!eventDoc.exists) {
      logger.error("Event not found");
      return;
    }

    const eventData = eventDoc.data();
    if (!eventData) {
      logger.error("Event data is empty");
      return;
    }

    let attendingCount = eventData.attendingCount || 0;
    let notAttendingCount = eventData.notAttendingCount || 0;
    let maybeCount = eventData.maybeCount || 0;

    if (rsvpData.status === 0) {
      attendingCount++;
    } else if (rsvpData.status === 1) {
      notAttendingCount++;
    } else if (rsvpData.status === 2) {
      maybeCount++;
    }

    if (beforeRsvp) {
      if (beforeRsvp.status === 0) {
        attendingCount--;
      } else if (beforeRsvp.status === 1) {
        notAttendingCount--;
      } else if (beforeRsvp.status === 2) {
        maybeCount--;
      }
    }

    // Update event counts
    await admin
      .firestore()
      .collection("events")
      .doc(event.params.eventId)
      .update({
        attendingCount,
        notAttendingCount,
        maybeCount,
      });

    // Get guest data
    const guestDoc = await admin
      .firestore()
      .collection(`events/${event.params.eventId}/guestList`)
      .doc(rsvpData.id)
      .get();

    if (!guestDoc.exists) {
      logger.error("Guest not found");
      return;
    }
    const guestData = guestDoc.data();
    if (!guestData) {
      logger.error("Guest data is empty");
      return;
    }

    // Get host's FCM token
    const hostId = rsvpData.createdBy;
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(hostId)
      .get();

    if (!userDoc.exists) {
      logger.error("Host not found");
      return;
    }

    const userData = userDoc.data();
    if (!userData || !userData.fcmToken) {
      logger.error("Host has no FCM token");
      return;
    }
    const title = beforeRsvp ?
      `RSVP Updated for ${rsvpData.title}` :
      `New RSVP for ${rsvpData.title}`;

    const user = `${guestData.firstName} ${guestData.lastName}`;
    const body = beforeRsvp ?
      `${user} has updated their RSVP to ${rsvpData.status}` :
      `${user} has responded: ${rsvpData.status}`;

    const notification = {title, body};
    // Send the notification
    try {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification,
      });
      logger.info("Notification sent successfully");
    } catch (error) {
      logger.error("Error sending notification:", error);
    }
  }
);

export const sendCommentNotification = onDocumentCreated(
  "events/{eventId}/comments/{commentId}",
  async (event) => {
    logger.info("New comment added!");

    if (!event.data) {
      logger.info("No data associated with the event");
      return;
    }

    const commentData = event.data.data();
    if (!commentData) {
      logger.info("Comment data is empty");
      return;
    }

    // Get event data
    const eventDoc = await admin
      .firestore()
      .collection("events")
      .doc(event.params.eventId)
      .get();

    if (!eventDoc.exists) {
      logger.error("Event not found");
      return;
    }

    const eventData = eventDoc.data();
    if (!eventData) {
      logger.error("Event data is empty");
      return;
    }

    // Get host's FCM token
    const hostId = eventData.createdBy;
    const userDoc = await admin.firestore()
      .collection("users")
      .doc(hostId)
      .get();

    if (!userDoc.exists) {
      logger.error("Host not found");
      return;
    }

    const userData = userDoc.data();
    if (!userData || !userData.fcmToken) {
      logger.error("Host has no FCM token");
      return;
    }

    const notification = {
      title: `${eventData.title}`,
      body: `${commentData.author} has commented: ${commentData.text}`,
    };

    // Send the notification
    try {
      await admin.messaging().send({
        token: userData.fcmToken,
        notification,
      });
      logger.info("Notification sent successfully");
    } catch (error) {
      logger.error("Error sending notification:", error);
    }
  }
);
