import React, { createContext, useContext } from 'react'
import { useSelector } from 'react-redux'
import { getUtils, getNavbar, getContainer, getForm, getText, getColors } from './styles'

const ThemeContext = createContext()

export const ThemeProvider = ({ children }) => {
    const darkMode = useSelector(state => state.themeState.darkMode)
    
    const currentColors = getColors(darkMode)
    const utils = getUtils(currentColors)
    const navbar = getNavbar(currentColors)
    const container = getContainer(currentColors)
    const form = getForm(currentColors)
    const text = getText(currentColors)
    
    const value = {
        darkMode,
        colors: currentColors,
        utils,
        navbar,
        container,
        form,
        text
    }
    
    return (
        <ThemeContext.Provider value={value}>
            {children}
        </ThemeContext.Provider>
    )
}

export const useTheme = () => {
    const context = useContext(ThemeContext)
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider')
    }
    return context
}
