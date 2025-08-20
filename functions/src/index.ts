import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

admin.initializeApp();

export const ogPreview = onRequest(async (request, response) => {
  logger.info("OG Preview function called!", {structuredData: true});

  fs.readdir("../../workspace", (err, files) => {
    if (err) {
      logger.error("Error reading directory:", err);
      return;
    }
    logger.info("Directory contents:", files);
  });
  const eventId = request.query.eventId as string;
  const guestId = request.query.guestId as string;

  if (!eventId || !guestId) {
    response.status(400).send("Missing eventId or guestId");
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
    const url = `https://${process.env.GCLOUD_PROJECT}.web.app/rsvp/${eventId}?guestId=${guestId}`;

    const ogTags = `
      <meta property="og:title" content="${title}" />
      <meta property="og:description" content="${description}" />
      <meta property="og:image" content="${imageUrl}" />
      <meta property="og:url" content="${url}" />
      <meta property="og:type" content="website" />
    `;

    // Read the index.html file
    const indexPath = path.join(
      __dirname,
      "../../workspace/public",
      "index.html"
    );
    let indexHtml = fs.readFileSync(indexPath, "utf8");

    // Inject OG tags into the head section
    indexHtml = indexHtml.replace("<head>", `<head>${ogTags}`);

    response.send(indexHtml);
  } catch (error) {
    logger.error("Error fetching event or generating OG tags:", error);
    response.status(500).send("Internal Server Error");
  }
});
