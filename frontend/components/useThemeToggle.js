import { useDispatch } from 'react-redux'
import { useColorScheme } from 'react-native'
import { useEffect } from 'react'
import { setTheme } from '../redux/actions'

export const useThemeToggle = () => {
    const dispatch = useDispatch()
    const colorScheme = useColorScheme()
    
    useEffect(() => {
        // Initialize theme from device color scheme on mount
        if (colorScheme) {
            dispatch(setTheme(colorScheme === 'dark'))
        }
    }, [])
    
    const toggleTheme = (isDark) => {
        dispatch(setTheme(isDark))
    }
    
    return { toggleTheme }
}
