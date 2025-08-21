import {onRequest} from "firebase-functions/v2/https";
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
      `https://${process.env.GCLOUD_PROJECT}.web.app/rsvp/${eventId}?guestId=${guestId}`:
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
