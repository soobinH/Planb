importScripts(
    "./view/assets/js/firebase/firebase-config.js",
    "https://www.gstatic.com/firebasejs/13.0.0/firebase-app-compat.js",
    "https://www.gstatic.com/firebasejs/13.0.0/firebase-messaging-compat.js"
);

firebase.initializeApp(self.planbFirebaseConfig);

const messaging = firebase.messaging();

// 다른 탭을 보고 있을 때 받은 메시지를 열린 Planb 화면에 전달
messaging.onBackgroundMessage(function () {
    return self.clients.matchAll({
        type: "window",
        includeUncontrolled: true
    }).then(function (clients) {
        clients.forEach(function (client) {
            if (client.url.startsWith(self.registration.scope)) {
                client.postMessage({
                    type: "PLANB_NOTIFICATION_REFRESH"
                });
            }
        });
    });
});