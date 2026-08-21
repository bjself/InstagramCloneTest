import { combineReducers } from 'redux'
import { user } from './user'
import { users } from './users'
import { localization } from './localization'

const Reducers = combineReducers({
    userState: user,
    usersState: users,
    localization: localization
})

export default Reducers