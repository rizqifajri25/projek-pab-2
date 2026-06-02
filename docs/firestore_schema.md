# Firestore Schema PadelFinder

- `users/{uid}`: uid, name, email, photoUrl, role (`user`/`admin`), status, createdAt.
- `courts/{courtId}`: name, description, address, latitude, longitude, imageUrl, facilities, createdBy, status (`pending`/`approved`/`rejected`), favoritesCount, commentsCount, createdAt.
- `favorites/{favoriteId}`: favoriteId, userId, courtId, createdAt.
- `comments/{commentId}`: commentId, courtId, userId, comment, createdAt.
- `reports/{reportId}`: reportId, reporterId, courtId, commentId, reason, status (`open`/`in progress`/`resolved`), createdAt.
- `notifications/{notificationId}`: notificationId, userId, title, body, isRead, createdAt.
