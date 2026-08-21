export const setLanguage = (language) => {
  return (dispatch) => {
    dispatch({
      type: 'SET_LANGUAGE',
      payload: language,
    });
  };
};

export const getLanguage = () => {
  return (dispatch) => {
    dispatch({
      type: 'GET_LANGUAGE',
    });
  };
};
