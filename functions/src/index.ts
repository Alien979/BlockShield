import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

exports.onThreatCreated = functions.firestore
    .document('threats/{threatId}')
    .onCreate((snap, context) => {
        const newThreat = snap.data();
        const notification = {
            title: 'New Threat Alert',
            body: `A new threat "${newThreat.type}" has been reported.`
        };
        
        return admin.messaging().sendToTopic('threatUpdates', { notification });
    });

exports.onThreatUpdated = functions.firestore
    .document('threats/{threatId}')
    .onUpdate((change, context) => {
        const updatedThreat = change.after.data();
        const notification = {
            title: 'Threat Update',
            body: `The threat "${updatedThreat.type}" has been updated.`
        };
        
        return admin.messaging().sendToTopic('threatUpdates', { notification });
    });