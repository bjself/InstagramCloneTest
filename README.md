![Version](https://img.shields.io/badge/version-1.0-blue.svg?cacheSeconds=2592000)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![runs with expo](https://img.shields.io/badge/Runs%20with%20Expo-000.svg?style=flat-square&logo=EXPO&labelColor=f3f3f3&logoColor=000)](https://expo.io/)
[![image](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/simcoder_here)
[![image](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/simcoder_here/)
[![image](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCQ5xY26cw5Noh6poIE-VBog)
[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/simcoder)

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/SimCoderYoutube/InstagramClone">
    <img src="images/simcoder.png" alt="Logo" width="120" height="120">
  </a>

  <h3 align="center">Instagram Clone</h3>

  <p align="center">
    A Instagram clone app made with React Native and firebase
    <br />
    <a href="https://github.com/SimCoderYoutube/InstagramClone/wiki"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/SimCoderYoutube/InstagramClone/issues">Report Bug</a>
    ·
    <a href="https://github.com/SimCoderYoutube/InstagramClone/issues">Request Feature</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#development-environment">Development Environment</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#support">Support</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## ℹ️ About The Project

![alt text](images/mockup.png "Title")

This repo contains the project made in my youtube chanel called simcoder. This project is a clone of the Instagram android app.

It is made using React Native with Expo using firebase services (authentication, firestore and storage).
The admin panel is made with ReactJS.
The backend is all NodeJS

In the [master](https://github.com/SimCoderYoutube/InstagramClone/tree/master) branch you have the redesign project which I was previously selling in my website, however you still have access to the youtube series repo in the [youtube_series](https://github.com/SimCoderYoutube/InstagramClone/tree/youtube_series)

You can follow the youtube series in the following [link](https://www.youtube.com/watch?v=xE8UEX7vXVQ&list=PLxabZQCAe5fgatwOQny9wKJVs4YD6xkf1)

## 🆕 Getting Started

- ### **Prerequisites**

  - [React Native](https://reactnative.dev/)
  - [Expo](https://expo.dev/)
  - [Firebase](https://firebase.google.com/)

<!-- GETTING STARTED -->

- ### **Installation**

  In order to deploy the project you'll need to follow the [wiki page](https://github.com/SimCoderYoutube/InstagramClone/wiki/Setup-your-project) dedicated to this effect.

## 💻 Development Environment

This project has three parts that each need their own setup. Here's what you need and how to run each one.

### What you need installed

| Tool | Purpose |
|------|---------|
| [Node.js](https://nodejs.org/) (v14 or later) | Required by all three parts |
| [Expo CLI](https://docs.expo.dev/get-started/installation/) (`npm install -g expo-cli`) | Runs the mobile app |
| [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`) | Deploys the backend Cloud Functions |
| A [Firebase project](https://console.firebase.google.com/) | Provides the database, auth, and storage |

### Running the mobile app

```bash
cd frontend
npm install
expo start
```

This opens the Expo developer tools in your browser. You can then run the app on a physical device using the Expo Go app, or on an iOS/Android emulator.

### Running the admin panel

```bash
cd admin
npm install
npm start
```

This starts a local web server and opens the admin dashboard in your browser automatically.

### Deploying the backend

```bash
cd backend/functions
npm install
firebase deploy --only functions
```

This publishes the Cloud Functions to your Firebase project.

### Firebase configuration

Each part of the project needs your own Firebase credentials to connect to your Firebase project. These files are **not included** in the repository for security reasons. Follow the [setup wiki page](https://github.com/SimCoderYoutube/InstagramClone/wiki/Setup-your-project) for instructions on creating and placing these files.

### Key versions

| Technology | Version |
|-----------|---------|
| React Native | 16.13.1 |
| Expo | 42.0.3 |
| React (admin panel) | 17.0.1 |
| Firebase SDK | 8.x |

## 🚧 Roadmap

See the [open issues](https://github.com/SimCoderYoutube/InstagramClone/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->

## ➕ Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**. Please check the [Wiki](https://github.com/SimCoderYoutube/InstagramClone/wiki/How-to-Contribute)

## 🌟 Show your support

Give a ⭐️ if this project helped you!

And don't forget to subscribe to the [youtube chanel](https://www.youtube.com/c/SimpleCoder?sub_confirmation=1)

## 📝 License

Copyright © 2021 [SimCoder](https://github.com/simcoderYoutube).

This project is [Apache License 2.0](https://github.com/SimCoderYoutube/InstagramClone/blob/master/LICENSE) licensed. Some of the dependencies are licensed differently.

<!-- CONTACT -->

## 👤 Contact

**SimCoder**

- Website: www.simcoder.com
- Twitter: [@simcoder_here](https://twitter.com/simcoder_here)
- Github: [@simcoderYoutube](https://github.com/simcoderYoutube)
- Youtube: [SimCoder](https://www.youtube.com/channel/UCQ5xY26cw5Noh6poIE-VBog)
