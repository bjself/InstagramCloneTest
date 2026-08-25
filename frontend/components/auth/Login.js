import firebase from 'firebase';
import React, { useState } from 'react';
import { Button, Text, TextInput, View } from 'react-native';
import { useTheme } from '../ThemeContext';
import { ThemeToggle } from '../ThemeToggle';

export default function Login(props) {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { container, form, colors } = useTheme();

    const onSignUp = () => {
        firebase.auth().signInWithEmailAndPassword(email, password)
    }

    return (
        <View style={[container.center, { backgroundColor: colors.white }]}>
            <ThemeToggle />
            <View style={container.formCenter}>
                <TextInput
                    style={[form.textInput, { color: colors.black, placeholderTextColor: colors.grey }]}
                    placeholder="email"
                    onChangeText={(email) => setEmail(email)}
                />
                <TextInput
                    style={[form.textInput, { color: colors.black, placeholderTextColor: colors.grey }]}
                    placeholder="password"
                    secureTextEntry={true}
                    onChangeText={(password) => setPassword(password)}
                />

                <Button
                    style={form.button}
                    onPress={() => onSignUp()}
                    title="Sign In"
                />
            </View>


            <View style={[form.bottomButton, { borderTopColor: colors.gray, backgroundColor: colors.white }]} >
                <Text
                    title="Register"
                    onPress={() => props.navigation.navigate("Register")}
                    style={{ color: colors.black }} >
                    Don't have an account? SignUp.
                </Text>
            </View>
        </View>
    )
}

