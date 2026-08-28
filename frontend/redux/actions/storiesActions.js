import firebase from 'firebase'
import { STORIES_CURRENT_USER_STATE_CHANGE, STORIES_STATE_CHANGE, STORIES_VIEWED_STATE_CHANGE } from '../constants/index'
require('firebase/firestore')
require('firebase/firebase-storage')

// ─── Helpers ───────────────────────────────────────────────────────────────────

const STORY_TTL_MS = 24 * 60 * 60 * 1000 // 24 hours

function isStoryActive(story) {
    if (!story.creation) return false
    const createdAt = story.creation.toDate ? story.creation.toDate() : new Date(story.creation)
    return Date.now() - createdAt.getTime() < STORY_TTL_MS
}

async function uploadToStorage(uri, storagePath) {
    const fileRef = firebase.storage().ref().child(storagePath)
    const response = await fetch(uri)
    const blob = await response.blob()
    const task = await fileRef.put(blob)
    return task.ref.getDownloadURL()
}

// ─── Action Creators ───────────────────────────────────────────────────────────

/**
 * Upload a photo or video as a new story for the current user.
 * @param {string} uri       Local URI of the media file
 * @param {number} mediaType 1 = photo, 0 = video  (matches Camera.js convention)
 */
export function uploadStory(uri, mediaType) {
    return async (dispatch) => {
        const uid = firebase.auth().currentUser.uid
        const storyId = Math.random().toString(36).slice(2)
        const ext = mediaType === 1 ? 'jpg' : 'mp4'
        const storagePath = `posts/${uid}/stories/${storyId}/media.${ext}`

        const downloadURL = await uploadToStorage(uri, storagePath)

        const storyDoc = {
            type: mediaType,
            creation: firebase.firestore.FieldValue.serverTimestamp(),
            viewCount: 0,
            ...(mediaType === 1 ? { photoUrl: downloadURL } : { videoUrl: downloadURL }),
        }

        await firebase.firestore()
            .collection('stories')
            .doc(uid)
            .collection('userStories')
            .doc(storyId)
            .set(storyDoc)

        // Update the storyIndicators collection so followers' feeds refresh
        await firebase.firestore()
            .collection('storyIndicators')
            .doc(uid)
            .set({
                hasActiveStories: true,
                lastStoryTime: firebase.firestore.FieldValue.serverTimestamp(),
            })

        // Refresh the current user's own stories in state
        dispatch(fetchCurrentUserStories())
    }
}

/**
 * Fetch active stories for all users the current user follows.
 * Relies on storyIndicators to find who has active stories, then fetches
 * the actual story documents.
 */
export function fetchStoriesForFollowing() {
    return async (dispatch, getState) => {
        const following = getState().userState.following
        if (!following || following.length === 0) {
            dispatch({ type: STORIES_STATE_CHANGE, followingStories: [] })
            return
        }

        const results = []

        for (const uid of following) {
            try {
                const snapshot = await firebase.firestore()
                    .collection('stories')
                    .doc(uid)
                    .collection('userStories')
                    .orderBy('creation', 'asc')
                    .get()

                const stories = snapshot.docs
                    .map(doc => ({ id: doc.id, ...doc.data() }))
                    .filter(isStoryActive)

                if (stories.length === 0) continue

                // Fetch user profile data
                const userSnap = await firebase.firestore()
                    .collection('users')
                    .doc(uid)
                    .get()

                const userData = userSnap.exists
                    ? { uid, ...userSnap.data() }
                    : { uid }

                results.push({ uid, user: userData, stories })
            } catch (_err) {
                // Skip users whose story data is inaccessible
            }
        }

        dispatch({ type: STORIES_STATE_CHANGE, followingStories: results })
    }
}

/**
 * Record that the current user viewed a specific story and increment its
 * server-side view count by writing a view document (Cloud Function handles count).
 */
export function markStoryViewed(storyUserId, storyId) {
    return async (dispatch) => {
        const viewerId = firebase.auth().currentUser.uid

        // Optimistically mark as viewed in local state
        dispatch({ type: STORIES_VIEWED_STATE_CHANGE, storyId })

        try {
            await firebase.firestore()
                .collection('stories')
                .doc(storyUserId)
                .collection('userStories')
                .doc(storyId)
                .collection('views')
                .doc(viewerId)
                .set({ viewedAt: firebase.firestore.FieldValue.serverTimestamp() })
        } catch (_err) {
            // View write failures are non-critical; local state is already updated
        }
    }
}

/**
 * Fetch the current user's own stories.
 */
export function fetchCurrentUserStories() {
    return async (dispatch) => {
        const uid = firebase.auth().currentUser.uid
        try {
            const snapshot = await firebase.firestore()
                .collection('stories')
                .doc(uid)
                .collection('userStories')
                .orderBy('creation', 'asc')
                .get()

            const stories = snapshot.docs
                .map(doc => ({ id: doc.id, ...doc.data() }))
                .filter(isStoryActive)

            dispatch({ type: STORIES_CURRENT_USER_STATE_CHANGE, stories })
        } catch (_err) {
            dispatch({ type: STORIES_CURRENT_USER_STATE_CHANGE, stories: [] })
        }
    }
}
