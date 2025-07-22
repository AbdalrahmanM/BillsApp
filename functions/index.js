/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

const gmailEmail = 'abdodj9425@gmail.com';
const gmailPassword = 'csoy ydrw isga bdrt';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

exports.sendBillRequestEmail = onDocumentCreated("bill_requests/{requestId}", async (event) => {
  const snap = event.data;
  if (!snap) return;
  const data = snap.data();
  const mailOptions = {
    from: gmailEmail,
    to: 'abdodj9421@gmail.com',
    subject: `طلب فاتورة جديدة / New Bill Request`,
    text: `
طلب فاتورة جديدة من المستخدم:
الاسم: ${data.userName} ${data.userLastName}
رقم الهاتف: ${data.userPhone}

بيانات الفاتورة:
--------------------------
${Object.entries(data.bill).map(([k, v]) => `${k}: ${v}`).join('\n')}

--------------------------
New bill request from user:
Name: ${data.userName} ${data.userLastName}
Phone: ${data.userPhone}

Bill details:
--------------------------
${Object.entries(data.bill).map(([k, v]) => `${k}: ${v}`).join('\n')}
    `,
  };
  await transporter.sendMail(mailOptions);
  return null;
});
