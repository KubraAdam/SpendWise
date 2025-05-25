const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.migrateTransaction = functions.firestore
  .document("transactions/{oldUid}/{docId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const uid = data.uid;

    if (!uid) {
      console.log("❌ UID alanı eksik.");
      return null;
    }

    const targetRef = admin
      .firestore()
      .collection("transactions")
      .doc(uid)
      .collection("transactions")
      .doc();

    await targetRef.set(data);
    console.log(`✅ Veri taşındı: transactions/${uid}/transactions/${targetRef.id}`);
    return null;
  });
