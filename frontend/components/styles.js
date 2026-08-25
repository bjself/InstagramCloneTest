
import { StyleSheet } from 'react-native'

const colors = {
    light: {
        white: 'white',
        whitesmoke: 'whitesmoke',
        grey: 'grey',
        lightgrey: 'lightgrey',
        black: 'black',
        dodgerblue: 'dodgerblue',
        deepskyblue: 'deepskyblue',
        lightgreen: 'lightgreen',
        gray: 'gray',
    },
    dark: {
        white: '#1a1a1a',
        whitesmoke: '#2a2a2a',
        grey: '#b0b0b0',
        lightgrey: '#404040',
        black: '#e0e0e0',
        dodgerblue: '#4db8ff',
        deepskyblue: '#66c2ff',
        lightgreen: '#66ff66',
        gray: '#505050',
    }
}

const getColors = (isDarkMode) => isDarkMode ? colors.dark : colors.light


const getUtils = (c) => StyleSheet.create({
    centerHorizontal: {
        alignItems: 'center',
    },
    marginBottom: {
        marginBottom: 20,
    },
    marginBottomBar: {
        marginBottom: 330,
    },
    marginBottomSmall: {
        marginBottom: 10,
    },
    profileImageBig: {
        width: 80,
        height: 80,
        borderRadius: 80 / 2,
    },
    profileImage: {
        marginRight: 15,
        width: 50,
        height: 50,
        borderRadius: 50 / 2,
    },
    profileImageSmall: {
        marginRight: 15,
        width: 35,
        height: 35,
        borderRadius: 35 / 2,
    },
    searchBar: {
        backgroundColor: c.whitesmoke,
        color: c.grey,
        paddingLeft: 10,
        borderRadius: 8,
        height: 40,
        marginTop: -5
    },
    justifyCenter: {
        justifyContent: 'center',
    },
    alignItemsCenter: {
        alignItems: 'center'
    },
    padding15: {
        paddingTop: 15,
        paddingRight: 15,
        paddingLeft: 15,
    },
    padding10Top: {
        paddingTop: 10

    },
    padding10: {
        padding: 10
    },
    margin15: {
        margin: 15
    },
    padding10Sides: {
        paddingRight: 10,
        paddingLeft: 10,
    },
    margin15Left: {
        marginLeft: 15,
    },
    margin15Right: {
        marginRight: 15,
    },
    margin5Bottom: {
        marginBottom: 5,
    },
    backgroundWhite: {
        backgroundColor: c.white,
    },
    borderTopGray: {
        borderTopWidth: 1,
        borderColor: c.lightgrey
    },
    borderWhite: {
        borderLeftWidth: 2,
        borderRightWidth: 2,
        borderTopWidth: 2,
        borderColor: c.white
    },
    buttonOutlined: {
        padding: 8,
        color: c.white,
        borderWidth: 1,
        borderColor: c.lightgrey,
        borderRadius: 8,
        textAlign: 'center',
    },

    fixedRatio: {
        flex: 1,
        aspectRatio: 1
    }
})

const getNavbar = (c) => StyleSheet.create({

    image: {
        padding: 20
    },
    custom: {
        marginTop: 30,
        height: 60,
        backgroundColor: c.white,
        padding: 15,
        borderBottomWidth: 1,
        borderColor: c.lightgrey
    },

    title: {
        fontWeight: '700',
        fontSize: 20//'larger',
    }
})

const getContainer = (c) => StyleSheet.create({
    container: {
        flex: 1,
    },
    camera: {
        flex: 1,
        flexDirection: 'row'
    },
    input: {
        flexWrap: "wrap"
    },
    containerPadding: {
        flex: 1,
        padding: 15
    },
    center: {
        flex: 1,
    },
    horizontal: {
        flexDirection: 'row',
        display: 'flex',
    },
    form: {
        flex: 1,
        margin: 25
    },
    profileInfo: {
        padding: 25,
        flexDirection: 'column',
    },
    row: {
        flexDirection: 'row',
        alignItems: 'center',
        height: 'auto',

    },
    formCenter: {
        justifyContent: 'center',
        flex: 1,
        margin: 25
    },
    containerImage: {
        flex: 1 / 3

    },
    image: {
        aspectRatio: 1 / 1,
    },
    fillHorizontal: {
        flexGrow: 1,
        paddingBottom: 0
    },
    imageSmall: {
        aspectRatio: 1 / 1,
        height: 70
    },
    gallery: {

        borderWidth: 1,
        borderColor: c.gray,
    },
    splash: {
        padding: 200,
        height: '100%',
        width: '100%'
    },
    chatRight: {
        margin: 10,
        marginBottom: 10,
        backgroundColor: c.dodgerblue,
        padding: 10,
        borderRadius: 8,
        alignSelf: 'flex-end'

    },
    chatLeft: {
        margin: 10,
        marginBottom: 10,
        backgroundColor: c.grey,
        padding: 10,
        borderRadius: 8,
        alignItems: 'flex-end',
        textAlign: 'right',
        alignSelf: 'flex-start'
    }
})

const getForm = (c) => StyleSheet.create({
    textInput: {
        marginBottom: 10,
        borderColor: c.gray,
        backgroundColor: c.whitesmoke,
        padding: 10,
        borderWidth: 1,
        borderRadius: 8
    },
    bottomButton: {
        alignContent: 'center',
        borderTopColor: c.gray,
        borderTopWidth: 1,
        padding: 10,
        textAlign: 'center',
    },
    roundImage: {
        width: 100,
        height: 100,
        borderRadius: 100 / 2
    }

})

const getText = (c) => StyleSheet.create({
    center: {
        textAlign: 'center',
    },
    notAvailable: {
        textAlign: 'center',
        fontWeight: '700',//'bolder',
        fontSize: 20//'large',
    },
    profileDescription: {
        fontWeight: '300'
    },
    changePhoto: {
        marginTop: 5,
        color: c.deepskyblue,
    },
    deepskyblue: {
        color: c.deepskyblue,
    },
    username: {
        fontWeight: '600',
        color: c.black,
    },
    name: {
        color: c.grey,
    },
    bold: {
        fontWeight: '700',
    },
    large: {
        fontSize: 20//'large'
    },
    small: {
        fontSize: 10//'large'
    },
    medium: {
        fontSize: 15, //'large'
        marginBottom: 10
    },
    grey: {
        color: c.grey
    },
    green: {
        color: c.lightgreen
    },
    white: {
        color: c.white
    },
    whitesmoke: {
        color: c.whitesmoke
    }



})


export { getContainer, getForm, getText, getUtils, getNavbar, colors, getColors }

// Create default light theme exports for backward compatibility
const defaultColors = getColors(false)
const container = getContainer(defaultColors)
const form = getForm(defaultColors)
const text = getText(defaultColors)
const utils = getUtils(defaultColors)
const navbar = getNavbar(defaultColors)

export { container, form, text, utils, navbar }
