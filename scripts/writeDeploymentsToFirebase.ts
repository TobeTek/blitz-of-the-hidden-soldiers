// import { getDatabase, set, ref} from "firebase/database";
import {
    doc,
    getFirestore,
    setDoc
} from "firebase/firestore";

import { configDotenv } from "dotenv";
import { initializeApp } from "firebase/app";

configDotenv();

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID,
};

const app = initializeApp(firebaseConfig);

async function main() {
  const deployments = require("deployments.json");
  const db = getFirestore(app);

  const docRef = doc(db, "eth-deployments/smart-contracts/");
  setDoc(docRef, deployments);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
