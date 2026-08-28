const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.addLike = functions.firestore.document('/posts/{creatorId}/userPosts/{postId}/likes/{userId}')
    .onCreate((snap, context) => {
        return db
            .collection("posts")
            .doc(context.params.creatorId)
            .collection("userPosts")
            .doc(context.params.postId)
            .update({
                likesCount: admin.firestore.FieldValue.increment(1)
            })
    });
exports.removeLike = functions.firestore.document('/posts/{creatorId}/userPosts/{postId}/likes/{userId}')
    .onDelete((snap, context) => {
        return db
            .collection('posts')
            .doc(context.params.creatorId)
            .collection('userPosts')
            .doc(context.params.postId)
            .update({
                likesCount: admin.firestore.FieldValue.increment(-1)
            })
    })


exports.addFollower = functions.firestore.document('/following/{userId}/userFollowing/{FollowingId}')
    .onCreate((snap, context) => {
        return db
            .collection('users')
            .doc(context.params.FollowingId)
            .update({
                followersCount: admin.firestore.FieldValue.increment(1)
            }).then(() => {
                return db
                    .collection('users')
                    .doc(context.params.userId)
                    .update({
                        followingCount: admin.firestore.FieldValue.increment(1)
                    })
            })
    })

exports.removeFollower = functions.firestore.document('/following/{userId}/userFollowing/{FollowingId}')
    .onDelete((snap, context) => {
        return db
            .collection('users')
            .doc(context.params.FollowingId)
            .update({
                followersCount: admin.firestore.FieldValue.increment(-1)
            }).then(() => {
                return db
                    .collection('users')
                    .doc(context.params.userId)
                    .update({
                        followingCount: admin.firestore.FieldValue.increment(-1)
                    })
            })
    })

exports.addComment = functions.firestore.document('/posts/{creatorId}/userPosts/{postId}/comments/{userId}')
    .onCreate((snap, context) => {
        return db
            .collection("posts")
            .doc(context.params.creatorId)
            .collection("userPosts")
            .doc(context.params.postId)
            .update({
                commentsCount: admin.firestore.FieldValue.increment(1)
            })
    })

// ─── Stories ──────────────────────────────────────────────────────────────────

/**
 * addStoryView — increment view count when any user views a story.
 * Triggered when a view document is created at:
 *   stories/{storyUserId}/userStories/{storyId}/views/{viewerId}
 */
exports.addStoryView = functions.firestore
    .document('stories/{storyUserId}/userStories/{storyId}/views/{viewerId}')
    .onCreate((snap, context) => {
        return db
            .collection('stories')
            .doc(context.params.storyUserId)
            .collection('userStories')
            .doc(context.params.storyId)
            .update({
                viewCount: admin.firestore.FieldValue.increment(1)
            })
    })

/**
 * updateStoryIndicators — when a new story is created, mark the author as
 * having active stories so followers' StoriesBar refreshes.
 * Triggered when a story document is created at:
 *   stories/{userId}/userStories/{storyId}
 */
exports.updateStoryIndicators = functions.firestore
    .document('stories/{userId}/userStories/{storyId}')
    .onCreate((snap, context) => {
        return db
            .collection('storyIndicators')
            .doc(context.params.userId)
            .set({
                hasActiveStories: true,
                lastStoryTime: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true })
    })

/**
 * expireStories — runs every hour to delete stories older than 24 hours and
 * update storyIndicators when a user has no remaining active stories.
 */
exports.expireStories = functions.pubsub
    .schedule('every 60 minutes')
    .onRun(async (_context) => {
        const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000)
        const usersSnap = await db.collection('stories').get()

        const tasks = usersSnap.docs.map(async (userDoc) => {
            const storiesSnap = await userDoc.ref
                .collection('userStories')
                .where('creation', '<', cutoff)
                .get()

            const deleteOps = storiesSnap.docs.map(doc => doc.ref.delete())
            await Promise.all(deleteOps)

            // Check if this user still has any active stories
            const remaining = await userDoc.ref
                .collection('userStories')
                .where('creation', '>=', cutoff)
                .limit(1)
                .get()

            if (remaining.empty) {
                return db
                    .collection('storyIndicators')
                    .doc(userDoc.id)
                    .set({ hasActiveStories: false }, { merge: true })
            }
        })

        return Promise.all(tasks)
    })
