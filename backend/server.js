const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const twilio = require("twilio");

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// =====================================================
// MIDDLEWARE
// =====================================================

app.use(cors());
app.use(express.json());

// =====================================================
// TWILIO CONFIGURATION
// =====================================================

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

// Demo mode is ON by default.
// This prevents the Twilio Trial account from causing
// the SafeHer SOS to fail.
const DEMO_MODE =
  String(process.env.DEMO_MODE || "true").toLowerCase() === "true";

let twilioClient = null;

if (accountSid && authToken) {
  twilioClient = twilio(accountSid, authToken);
  console.log("Twilio configured successfully.");
} else {
  console.log("Twilio credentials not configured.");
}

console.log(
  `SafeHer Demo Mode: ${DEMO_MODE ? "ON" : "OFF"}`
);

// =====================================================
// HOME / HEALTH CHECK
// =====================================================

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "SafeHer backend is running!",
    demoMode: DEMO_MODE,
  });
});

// =====================================================
// SOS API
// =====================================================

app.post("/api/sos", async (req, res) => {
  console.log("");
  console.log("=================================");
  console.log("        SOS REQUEST");
  console.log("=================================");

  try {
    const {
      latitude,
      longitude,
      contacts,
      message,
    } = req.body;

    console.log("Latitude:", latitude);
    console.log("Longitude:", longitude);
    console.log("Contacts:", contacts);
    console.log("Message:", message);

    // -------------------------------------------------
    // VALIDATE LOCATION
    // -------------------------------------------------

    if (latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: "Location information is missing.",
      });
    }

    // -------------------------------------------------
    // NORMALIZE CONTACTS
    // -------------------------------------------------

    const emergencyContacts =
      Array.isArray(contacts) ? contacts : [];

    // -------------------------------------------------
    // GOOGLE MAPS LOCATION
    // -------------------------------------------------

    const locationUrl =
      `https://www.google.com/maps/search/?api=1&query=` +
      `${latitude},${longitude}`;

    // -------------------------------------------------
    // EMERGENCY MESSAGE
    // -------------------------------------------------

    const emergencyMessage =
      `SAFEHER EMERGENCY ALERT\n\n` +
      `The user may need immediate help.\n\n` +
      `Current Location:\n` +
      `${locationUrl}\n\n` +
      `Latitude: ${latitude}\n` +
      `Longitude: ${longitude}\n\n` +
      `Please contact the user immediately.`;

    // =================================================
    // DEMO MODE
    // =================================================

    if (DEMO_MODE) {
      console.log("");
      console.log("========== DEMO SOS ALERT ==========");

      console.log("STATUS: SOS ACTIVATED");

      console.log("");
      console.log("Emergency Message:");
      console.log(emergencyMessage);

      console.log("");
      console.log("Emergency Contacts:");

      if (emergencyContacts.length === 0) {
        console.log("No contacts saved.");
      } else {
        emergencyContacts.forEach((contact, index) => {
          console.log(
            `${index + 1}. ${contact.name || "Contact"} - ${
              contact.phone || "No phone number"
            }`
          );
        });
      }

      console.log("");
      console.log("====================================");
      console.log("");

      // Return SUCCESS so Flutter shows SOS ACTIVATED
      return res.status(200).json({
        success: true,
        demoMode: true,
        message: "SOS activated successfully.",
        alertMessage: emergencyMessage,
        latitude: latitude,
        longitude: longitude,
        location: locationUrl,
        contacts: emergencyContacts,
        smsSent: false,
        note:
          "Demo mode is active. No SMS was sent.",
      });
    }

    // =================================================
    // REAL TWILIO MODE
    // =================================================

    if (!twilioClient) {
      return res.status(500).json({
        success: false,
        message:
          "Twilio is not configured.",
      });
    }

    if (!twilioPhoneNumber) {
      return res.status(500).json({
        success: false,
        message:
          "Twilio phone number is missing.",
      });
    }

    if (emergencyContacts.length === 0) {
      return res.status(400).json({
        success: false,
        message:
          "No emergency contacts are available.",
      });
    }

    const results = [];

    // -------------------------------------------------
    // SEND SMS
    // -------------------------------------------------

    for (const contact of emergencyContacts) {
      const phone = contact.phone;

      if (!phone) {
        results.push({
          name: contact.name || "Unknown",
          success: false,
          error: "Phone number missing.",
        });

        continue;
      }

      try {
        console.log(
          `Sending SMS to ${contact.name || "Contact"} (${phone})...`
        );

        const sms = await twilioClient.messages.create({
          body: emergencyMessage,
          from: twilioPhoneNumber,
          to: phone,
        });

        console.log(
          `SMS sent successfully. SID: ${sms.sid}`
        );

        results.push({
          name: contact.name || "Contact",
          phone: phone,
          success: true,
          sid: sms.sid,
        });
      } catch (error) {
        console.log(
          `SMS failed for ${phone}: ${error.message}`
        );

        results.push({
          name: contact.name || "Contact",
          phone: phone,
          success: false,
          error: error.message,
        });
      }
    }

    // -------------------------------------------------
    // SMS RESULT
    // -------------------------------------------------

    const successfulMessages =
      results.filter(
        (result) => result.success
      ).length;

    const failedMessages =
      results.filter(
        (result) => !result.success
      ).length;

    console.log("");
    console.log("========== SMS SUMMARY ==========");
    console.log(
      `Successful SMS: ${successfulMessages}`
    );
    console.log(
      `Failed SMS: ${failedMessages}`
    );
    console.log("=================================");

    if (successfulMessages > 0) {
      return res.status(200).json({
        success: true,
        demoMode: false,
        message:
          "SOS activated and SMS sent.",
        latitude: latitude,
        longitude: longitude,
        location: locationUrl,
        results: results,
      });
    }

    return res.status(500).json({
      success: false,
      message:
        "SOS reached the backend, but SMS could not be sent.",
      results: results,
    });

  } catch (error) {
    console.error("");
    console.error("========== SOS SERVER ERROR ==========");
    console.error(error);
    console.error("======================================");

    return res.status(500).json({
      success: false,
      message:
        "Server error while processing SOS.",
      error: error.message,
    });
  }
});

// =====================================================
// START SERVER
// =====================================================

app.listen(PORT, "0.0.0.0", () => {
  console.log("");
  console.log("=================================");
  console.log("     SAFEHER BACKEND RUNNING");
  console.log("=================================");
  console.log(`Server: http://localhost:${PORT}`);
  console.log(
    `Demo Mode: ${DEMO_MODE ? "ON" : "OFF"}`
  );
  console.log("=================================");
  console.log("");
});