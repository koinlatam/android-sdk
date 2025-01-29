# KoinFingerprinter

KoinFingerprinter is a device information gathering library for Android written in Kotlin.

# Flutter SDK Integration Example

If you are using Flutter, you can check this **proof of concept (PoC)** where the example SDK is integrated:

🔗 [Flutter SDK Integration Example](https://github.com/koinlatam/android-sdk/tree/main/test_flutter)

This project demonstrates how to integrate the SDK within a Flutter project, including dependency management and native communication via `MethodChannel`.

Feel free to explore the project and adapt it to your needs.

## Installation

Download the .aar file of the corresponding release and place it on the project "libs" directory

Add the line `implementation files('libs/fingerprint-sdk-release.aar')`to your project's dependencies.

It should look something like this:

```gradle
dependencies {
    ...
    implementation files('libs/fingerprint-sdk-release.aar')
    ...
}
```

Now you should sync your gradle files.

### Dependencies

If you get a message error about permissions related to the library, try adding the following dependencies to the build.gradle for your app

```gradle
dependencies {
    implementation 'com.android.volley:volley:1.2.1'
    implementation 'com.google.android.gms:play-services-location:21.3.0'
    implementation 'com.google.android.gms:play-services-ads-identifier:18.2.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.1'
}
```

Note: These libraries have the minimum version needed for the library to work.


## Usage

To start using the library you need at least to register your organizationId and then call one of the profile funtions.`

```kotlin
KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)
val sessionID = KoinFingerprinter.profile(applicationContext)
```

You can register an endpoint url as well.
```kotlin
KoinFingerprinter.register(applicationContext, ORGANIZATION_ID, "https://api-sandbox.koin.com.br/fingerprint/session/mobile")
KoinFingerprinter.profile(applicationContext)
```
This url will replace the default.

### Placing within the app

A couple considerations to place the library calls in your code.
You should always register your organization ID before making other calls of this library. (`KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)`)
The `profile()` methods will start gathering information and send it as soon as this is complete, making multiple calls to these methods will send information multiple times. 
We recomend to have a single call to a `profile()` method within the apps life cycle.
You can place it right at the `Application.onCreate()` or at any later point, as long as you have an `applicationContext` to pass to it.
You may want to consider to make the profile calls after getting some permissions.
The library does not ask the user nor need special permissions to work, but it will benefit from having access to 
`ACCESS_WIFI_STATE`, `ACCESS_FINE_LOCATION`, and `ACCESS_COARSE_LOCATION`, so, if you are asking for any of these permissions already, you may want to consider to place the profile calls after asking for permissions within your app.

### Profile functions

There are two way of start the information gathering.

If you need a sessionID you should use:

```kotlin
val sessionID = KoinFingerprinter.profile(applicationContext)
```

This will return a sessionID as a UUIDv4.

If you have a sessionID you can use 
```kotlin
KoinFingerprinter.profile(applicationContext, "YOUR_SESSION_ID")
```


