
# LangSync

<p align="center">
<img src="https://docs.langsync.app/img/brand/colored_bg.png" style="border-radius:100%;width:125px;height:125px;"/>
</p>

<br>

<a href="https://langsync.app" target="_blank">
  LangSync
</a> is an AI powered Command Line Interface (CLI) tool that allows your software
(apps, websites, games, projects...) to target the global market by expanding your
original JSON localization file(s), And, with the help of a powerful set of AI engines,
it generates very accurate & effective new laungages localizations files that matches
the context of your original one(s).

</br>
</br>

**As example**, taking a mobile app that supports only the English laungage, which saves all its English texts & strings in a `en.json` file, <a href="https://langsync.app" target="_blank">LangSync</a> can literally take it, Then provides any other languages localization & translations like `ar.json`, `zh.json`, `ru.json`... and setting it in your project by runinng only a single command.

## Key Features

- **AI Powered**: LangSync harnesses the immense power of AI to provide you with unparalleled localization capabilities. Our AI-powered solution ensures that your software seamlessly adapts to its specific context, making your software truly global.

- **Accurate & precise**: LangSync stands out for its exceptional accuracy and precision. Our cutting-edge technology guarantees not only accurate translations but also an unmatched contextual fit. We ensure that translations seamlessly integrate with the context of your content.

- **Quick and Flawless**: LangSync boasts exceptional speed, enabling rapid translation of your software within seconds to minutes, depending on its size. This agility empowers your development process, making it more flexible and efficient.

- **Easy to use**: LangSync is a developer-centric solution crafted by developers for developers. We prioritize efficiency by offering direct, no-nonsense commands to achieve your goals without any unnecessary clutter.

## Why <a href="https://langsync.app" target="_blank">LangSync</a>

The world is getting smaller and smaller, but the global market is getting bigger, and so, the need for your software to support more languages is getting bigger too. But, the problem is that the process of localizing your software is not that easy, it requires a lot of time, effort and budget, here are some of the most common issues that you may face when you want to localize your software:

- **Time**: Localizing your software is a time-consuming process, it requires a lot of time to translate all the texts & strings of your software, especially when your software is under development and you are adding, modifying features and texts every day.

- **Effort**: Localizing your software is not only about translating the texts, it's also about making sure that the translated texts matches the context of the original ones, and that's a very hard task to do, especially when you are not familiar with the language you are translating to or when you are not a native speaker.

- **Budget**: Localizing your software is not a cheap process, it requires a lot of money to hire a professional translator or many, and that's not a one-time process, you will need to repeat the process on any new update of your software.

- **Accuracy**: When switching to a new language, you want to make sure that the translated texts matches the context of the original ones and not to have a direct translation.

- **Availability**: <a href="https://langsync.app" target="_blank">LangSync</a> is available to use 24/7, you can use it anytime and anywhere, don't tie yourself to a specific time or place yo ship your software.

## How it works

Let's take a real-world use case to demonstrate what you will really get and how it will benefit you. And so, let's say you're a developer who works on a server-side project with NodeJS, Asuuming this project file structure:

```txt

my-project
│
├── .node_modules
│   └── ...
│
├── locales
# highlight-next-line
│   └── en.json
│
├── src
│   └── server.js
│
└── package.json

```

This server intends to receive some request as example, and returns a localization file content to the client side, this server-side app is really just for demonstrating purpose and the project can be anything else, like Flutter, Javascript, Electron, Laravel, Rust, C, Android... projects, the usage remains the same.

</br>

Let's see what the `en.json` file contains:

```json
{
  "hello": "Hello",
  "world": "World",
  "welcome": "Welcome to my NodeJS project"
  ...
}
```

Now, we want our project to target more people, which mean you will need to support those people launguages.

</br>

let's say that the languages are **Spanish**, **Arabic**, **German**, **italian** and **Chinese** languages, that means that we need to have `es.json`, `ar.json`, `de.json`, `it.json` and `zh.json` files under the `locales` folder, and each file will contain the translated texts of the original `en.json` file, this is a single command away with <a href="https://langsync.app" target="_blank">LangSync</a>, in your terminal, cmd, powershell.. etc, run the following command:

```bash
langsync start
```

</br>

That's it, now all what you need to do is to wait for the process to finish, maybe you want to work on your other tasks or to take a coffee break. When you come back, you will find a success message like this:

```langsync
Localizing process starting..
✓ Your langsync.yaml file and configuration are valid. (1ms)
✓ Your source file has been saved successfully. (1.4s)
[WARN] The ID of this operation is: 24332154-668f-4b5d-9a12-173d5ffa252c. in case of any issues, please contact us providing this ID so we can help.
✓ Localization operation is completed successfully. (94.6s)


Generating localization files: es.json, ar.json, de.json, it.json, zh.json:
✓ file es.json is created successfully, ./locales/es.json (1ms)
✓ file ar.json is created successfully, ./locales/ar.json (1ms)
✓ file de.json is created successfully, ./locales/de.json (0ms)
✓ file it.json is created successfully, ./locales/it.json (1ms)
✓ file zh.json is created successfully, ./locales/zh.json (0ms)
All files are created successfully.
All done!
```

Congratulations, You're done. This was a success message and you have now a new langauge localization under the `locales` folder, go check them out.

Your project folder structure will be now:

```txt

myProject
│
├── .node_modules
│   └── ...
│
├── locales
│   ├── en.json
# highlight-start
│   ├── es.json
│   ├── ar.json
│   ├── de.json
│   ├── it.json
│   └── zh.json
# highlight-end
│
├── src
│   └── index.js
│
└── package.json

```

These are the content of the new localization files:

#### en.json

```json
{
  "hello": "Hello",
  "world": "World",
  "welcome": "Welcome to my NodeJS project"
  ...
}
```

#### es.json

```json
{
  "hello": "Hola",
  "world": "Mundo",
  "welcome": "Bienvenido a mi proyecto de NodeJS"
  ...
}
```

#### ar.json

```json
{
  "hello": "مرحبا",
  "world": "العالم",
  "welcome": "مرحبا بك في مشروعي NodeJS"
  ...
}
```

#### de.json

```json
{
  "hello": "Hallo",
  "world": "Welt",
  "welcome": "Willkommen zu meinem NodeJS Projekt"
  ...
}
```

#### it.json

```json
{
  "hello": "Ciao",
  "world": "Mondo",
  "welcome": "Benvenuto al mio progetto NodeJS"
  ...
}
```

#### zh.json

```json
{
  "hello": "你好",
  "world": "世界",
  "welcome": "欢迎来到我的NodeJS项目"
  ...
}
```

</br>
