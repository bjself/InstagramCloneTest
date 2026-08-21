import { getDefaultLanguage } from '../../localization';

const initialState = {
  language: getDefaultLanguage(),
};

export const localization = (state = initialState, action) => {
  switch (action.type) {
    case 'SET_LANGUAGE':
      return {
        ...state,
        language: action.payload,
      };
    case 'GET_LANGUAGE':
      return state;
    default:
      return state;
  }
};
