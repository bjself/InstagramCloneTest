import { getFocusedRouteNameFromRoute, NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import 'expo-asset';
import * as firebase from 'firebase';
import _ from 'lodash';
import React, { Component } from 'react';
import { Image, LogBox, View } from 'react-native';
import { Provider } from 'react-redux';
import { applyMiddleware, createStore } from 'redux';
import thunk from 'redux-thunk';
import LoginScreen from './components/auth/Login';
import RegisterScreen from './components/auth/Register';
import HeaderTitle from './components/HeaderTitle';
import MainScreen from './components/Main';
import SaveScreen from './components/main/add/Save';
import ChatScreen from './components/main/chat/Chat';
import ChatListScreen from './components/main/chat/List';
import CommentScreen from './components/main/post/Comment';
import PostScreen from './components/main/post/Post';
import EditScreen from './components/main/profile/Edit';
import ProfileScreen from './components/main/profile/Profile';
import BlockedScreen from './components/main/random/Blocked';
import { container } from './components/styles';
import rootReducer from './redux/reducers';
import { setUserOnline, setUserOffline } from './redux/actions/index';

const store = createStore(rootReducer, applyMiddleware(thunk))

LogBox.ignoreLogs(['Setting a timer']);
const _console = _.clone(console);
console.warn = message => {
  if (message.indexOf('Setting a timer') <= -1) {
    _console.warn(message);
  }
};

const firebaseConfig = {
  apiKey: "****",
  authDomain: "****",
  databaseURL: "****",
  projectId: "****",
  storageBucket: "****",
  messagingSenderId: "****",
  appId: "****",
  measurementId: "****"
};

const logo = require('./assets/logo.png')

if (firebase.apps.length === 0) {
  firebase.initializeApp(firebaseConfig)
}

const Stack = createStackNavigator();

export class App extends Component {
  constructor(props) {
    super()
    this.state = {
      loaded: false,
    }
  }

  componentDidMount() {
    firebase.auth().onAuthStateChanged((user) => {
      if (!user) {
        this.setState({
          loggedIn: false,
          loaded: true,
        })
      } else {
        this.setState({
          loggedIn: true,
          loaded: true,
        })
        // Set user online when app launches
        store.dispatch(setUserOnline())
      }
    })

    // Handle app background/foreground
    this.appStateSubscription = firebase.firestore().enableNetwork()
  }

  componentWillUnmount() {
    // Set user offline when app closes or component unmounts
    store.dispatch(setUserOffline())
  }
  render() {
    const { loggedIn, loaded } = this.state;
    if (!loaded) {
      return (
        <Image style={container.splash} source={logo} />
      )
    }

    if (!loggedIn) {
      return (
        <NavigationContainer>
          <Stack.Navigator initialRouteName="Login">
            <Stack.Screen name="Register" component={RegisterScreen} navigation={this.props.navigation} options={{ headerShown: false }} />
            <Stack.Screen name="Login" navigation={this.props.navigation} component={LoginScreen} options={{ headerShown: false }} />
          </Stack.Navigator>
        </NavigationContainer>
      );
    }

    return (
      <Provider store={store}>
        <NavigationContainer >
          <Stack.Navigator 
            initialRouteName="Main"
            screenOptions={{
              headerTitleStyle: {
                display: 'flex',
                flexDirection: 'row',
                alignItems: 'center',
              }
            }}
          >
            <Stack.Screen 
              key={Date.now()} 
              name="Main" 
              component={MainScreen} 
              navigation={this.props.navigation} 
              options={({ route, navigation }) => {
                const routeName = getFocusedRouteNameFromRoute(route) ?? 'Feed';

                const getHeaderTitle = () => {
                  switch (routeName) {
                    case 'Camera':
                      return 'Camera';
                    case 'chat':
                      return 'Chat';
                    case 'Profile':
                      return 'Profile';
                    case 'Search':
                      return 'Search';
                    case 'Feed':
                    default:
                      return 'Instagram';
                  }
                };

                return {
                  headerTitle: () => (
                    <HeaderTitle title={getHeaderTitle()} />
                  ),
                };
              }}
            />
            <Stack.Screen key={Date.now()} name="Save" component={SaveScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="video" component={SaveScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Post" component={PostScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Chat" component={ChatScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="ChatList" component={ChatListScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Edit" component={EditScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Profile" component={ProfileScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Comment" component={CommentScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="ProfileOther" component={ProfileScreen} navigation={this.props.navigation} />
            <Stack.Screen key={Date.now()} name="Blocked" component={BlockedScreen} navigation={this.props.navigation} options={{ headerShown: false }} />
          </Stack.Navigator>
        </NavigationContainer>
      </Provider>
    )
  }
}

export default App
