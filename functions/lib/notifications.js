"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkAndSendNotifications = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
// Bildirim gönderme fonksiyonu
async function sendNotification(token, title, body, data) {
    const message = {
        notification: {
            title,
            body,
        },
        data,
        token,
    };
    try {
        const response = await admin.messaging().send(message);
        console.log('Bildirim başarıyla gönderildi:', response);
        return true;
    }
    catch (error) {
        console.error('Bildirim gönderilirken hata oluştu:', error);
        return false;
    }
}
// Her dakika çalışacak fonksiyon
exports.checkAndSendNotifications = functions.pubsub
    .schedule('* * * * *')
    .timeZone('Europe/Istanbul')
    .onRun(async (context) => {
    try {
        const db = admin.firestore();
        const now = new Date();
        const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now
            .getMinutes()
            .toString()
            .padStart(2, '0')}`;
        // Burç yorumu bildirimleri
        const horoscopeSettings = await db
            .collection('notification_settings')
            .where('horoscope_reminder_enabled', '==', true)
            .where('horoscope_reminder_time', '==', currentTime)
            .get();
        for (const doc of horoscopeSettings.docs) {
            const settings = doc.data();
            const userId = settings.user_id;
            // Kullanıcının FCM token'ını al
            const tokenDoc = await db
                .collection('fcm_tokens')
                .where('user_id', '==', userId)
                .limit(1)
                .get();
            if (!tokenDoc.empty) {
                const token = tokenDoc.docs[0].data().token;
                await sendNotification(token, 'Günlük Burç Yorumunuz Hazır!', 'Bugün sizin için neler olacağını öğrenmek için tıklayın.', {
                    type: 'horoscope_reminder',
                    userId,
                });
                // Bildirimi veritabanına kaydet
                await db.collection('notifications').add({
                    user_id: userId,
                    type: 'horoscope_reminder',
                    title: 'Günlük Burç Yorumunuz Hazır!',
                    body: 'Bugün sizin için neler olacağını öğrenmek için tıklayın.',
                    is_read: false,
                    created_at: admin.firestore.FieldValue.serverTimestamp(),
                    updated_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
        // Kahve falı bildirimleri
        const coffeeSettings = await db
            .collection('notification_settings')
            .where('coffee_reminder_enabled', '==', true)
            .where('coffee_reminder_time', 'array-contains', currentTime)
            .get();
        for (const doc of coffeeSettings.docs) {
            const settings = doc.data();
            const userId = settings.user_id;
            // Kullanıcının FCM token'ını al
            const tokenDoc = await db
                .collection('fcm_tokens')
                .where('user_id', '==', userId)
                .limit(1)
                .get();
            if (!tokenDoc.empty) {
                const token = tokenDoc.docs[0].data().token;
                await sendNotification(token, 'Kahve Falı Zamanı!', 'Şimdi kahvenizi içip falınıza baktırabilirsiniz.', {
                    type: 'coffee_reminder',
                    userId,
                });
                // Bildirimi veritabanına kaydet
                await db.collection('notifications').add({
                    user_id: userId,
                    type: 'coffee_reminder',
                    title: 'Kahve Falı Zamanı!',
                    body: 'Şimdi kahvenizi içip falınıza baktırabilirsiniz.',
                    is_read: false,
                    created_at: admin.firestore.FieldValue.serverTimestamp(),
                    updated_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
        console.log('Bildirim kontrolleri tamamlandı:', currentTime);
    }
    catch (error) {
        console.error('Bildirim kontrolleri sırasında hata:', error);
    }
});
//# sourceMappingURL=notifications.js.map