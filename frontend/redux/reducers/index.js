import { combineReducers } from 'redux'
import { user } from './user'
import { users } from './users'
import { theme } from './theme'

const Reducers = combineReducers({
    userState: user,
    usersState: users,
    themeState: theme
})

export default Reducers