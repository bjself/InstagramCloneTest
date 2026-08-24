import { CLEAR_DATA, WEATHER_ERROR, WEATHER_LOADING, WEATHER_STATE_CHANGE } from '../constants';

const initialState = {
    data: null,        // { temperature, unit, condition, icon }
    loading: false,
    error: null,
    lastFetched: null, // timestamp (ms) — used for caching
};

export const weather = (state = initialState, action) => {
    switch (action.type) {
        case WEATHER_LOADING:
            return { ...state, loading: true, error: null };
        case WEATHER_STATE_CHANGE:
            return {
                ...state,
                loading: false,
                error: null,
                data: action.data,
                lastFetched: action.lastFetched,
            };
        case WEATHER_ERROR:
            return { ...state, loading: false, error: action.error };
        case CLEAR_DATA:
            return initialState;
        default:
            return state;
    }
};
