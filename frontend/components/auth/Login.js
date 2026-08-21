import firebase from 'firebase';
import React, { useState } from 'react';
import { Button, Text, TextInput, View } from 'react-native';
import { connect } from 'react-redux';
import { container, form } from '../styles';
import { t } from '../../localization';

function Login(props) {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const language = props.localization?.language || 'en';

    const onSignUp = () => {
        firebase.auth().signInWithEmailAndPassword(email, password)
    }

    return (
        <View style={container.center}>
            <View style={container.formCenter}>
                <TextInput
                    style={form.textInput}
                    placeholder={t('auth.email', language)}
                    onChangeText={(email) => setEmail(email)}
                />
                <TextInput
                    style={form.textInput}
                    placeholder={t('auth.password', language)}
                    secureTextEntry={true}
                    onChangeText={(password) => setPassword(password)}
                />

                <Button
                    style={form.button}
                    onPress={() => onSignUp()}
                    title={t('auth.signIn', language)}
                />
            </View>


            <View style={form.bottomButton} >
                <Text
                    title={t('auth.register', language)}
                    onPress={() => props.navigation.navigate("Register")} >
                    {t('auth.dontHaveAccount', language)}
                </Text>
            </View>
        </View>
    )
}

const mapStateToProps = (store) => ({
    localization: store.localization,
});

export default connect(mapStateToProps)(Login);


