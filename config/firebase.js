// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getStorage } from "firebase/storage";
//import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: "dopamine-c2608.firebaseapp.com",
  projectId: "dopamine-c2608",
  storageBucket: "dopamine-c2608.appspot.com",
  messagingSenderId: "618776264173",
  appId: "1:618776264173:web:ed923e619d4c552cd23be4",
  measurementId: "G-F6PBXRN1P5"
};

// Initialize Firebase
  const app = initializeApp(firebaseConfig);
 export  const storage = getStorage(app);
//const analytics = getAnalytics(app);