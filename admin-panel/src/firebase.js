import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyAmT3-o6EbRKPBx4pohSA5DOAdMAfRIN6g',
  authDomain: 'dppproject-1998e.firebaseapp.com',
  projectId: 'dppproject-1998e',
  storageBucket: 'dppproject-1998e.firebasestorage.app',
  messagingSenderId: '511361480049',
  appId: '1:511361480049:android:6189a4c0ee2fb245e1f2d0',
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
