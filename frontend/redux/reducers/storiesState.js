import { CLEAR_DATA, STORIES_CURRENT_USER_STATE_CHANGE, STORIES_STATE_CHANGE, STORIES_VIEWED_STATE_CHANGE } from '../constants'

const initialState = {
    // Stories from followed users: array of { uid, stories: [...] }
    followingStories: [],
    // Story IDs the current user has viewed: Set serialised as plain object { [storyId]: true }
    viewedStories: {},
    // Stories uploaded by the current user
    currentUserStories: [],
}

export const storiesState = (state = initialState, action) => {
    switch (action.type) {
        case STORIES_STATE_CHANGE:
            return {
                ...state,
                followingStories: action.followingStories,
            }
        case STORIES_VIEWED_STATE_CHANGE:
            return {
                ...state,
                viewedStories: {
                    ...state.viewedStories,
                    [action.storyId]: true,
                },
            }
        case STORIES_CURRENT_USER_STATE_CHANGE:
            return {
                ...state,
                currentUserStories: action.stories,
            }
        case CLEAR_DATA:
            return initialState
        default:
            return state
    }
}
