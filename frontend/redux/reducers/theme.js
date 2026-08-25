import { THEME_CHANGE } from '../constants/index'

const initialState = {
    darkMode: false
}

export const theme = (state = initialState, action) => {
    switch (action.type) {
        case THEME_CHANGE:
            return {
                ...state,
                darkMode: action.payload
            }
        default:
            return state
    }
}
