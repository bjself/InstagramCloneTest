import React from 'react'
import { View, TouchableOpacity, Text } from 'react-native'
import { useDispatch, useSelector } from 'react-redux'
import { setTheme } from '../redux/actions'

export const ThemeToggle = () => {
    const dispatch = useDispatch()
    const darkMode = useSelector(state => state.themeState.darkMode)
    
    const toggleTheme = () => {
        dispatch(setTheme(!darkMode))
    }
    
    return (
        <TouchableOpacity 
            onPress={toggleTheme}
            style={{
                padding: 10,
                backgroundColor: darkMode ? '#404040' : '#e0e0e0',
                borderRadius: 8,
                marginHorizontal: 10,
                marginVertical: 5
            }}
        >
            <Text style={{ 
                color: darkMode ? '#e0e0e0' : '#1a1a1a',
                textAlign: 'center',
                fontWeight: '600'
            }}>
                {darkMode ? '☀️ Light' : '🌙 Dark'}
            </Text>
        </TouchableOpacity>
    )
}
