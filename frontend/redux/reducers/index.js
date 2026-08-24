import { combineReducers } from 'redux'
import { user } from './user'
import { users } from './users'
import { weather } from './weather'

const Reducers = combineReducers({
    userState: user,
    usersState: users,
    weatherState: weather,
})

export default Reducers