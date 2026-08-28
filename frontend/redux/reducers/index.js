import { combineReducers } from 'redux'
import { user } from './user'
import { users } from './users'
import { storiesState } from './storiesState'

const Reducers = combineReducers({
    userState: user,
    usersState: users,
    storiesState: storiesState,
})

export default Reducers