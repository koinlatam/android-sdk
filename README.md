# KoinFingerprinter

KoinFingerprinter is a device information gathering library for Android written in Kotlin.

**readme in progress...**

## Installation

There are many ways to install the provided fingerprint-sdk.arr file.

We recomend for you to install the github package [`br.com.koin.android-sdk`](https://github.com/koinlatam/android-sdk/packages/1914404/) from the project.

The other way, not recommended, is to copy the android-sdk-v.0.0.1.arr file into the libs folder in your app.

Add the line `implementation files('libs/android-sdk-v.0.0.1.aar')`to your project's dependencies.

It should look something like this:

```gradle
dependencies {
    ...
    implementation files('libs/android-sdk-v.0.0.1.aar')
    ...
}
```

Now you should sync your gradle files.

### Dependencies

If you get a message error about permissions related to the library, try adding the following dependencies to the build.gradle for your app

```gradle
dependencies {
    implementation 'com.android.volley:volley:1.1.+'
    implementation 'com.google.android.gms:play-services-location:15.0.+'
    implementation 'com.google.android.gms:play-services-ads-identifier:15.0.+'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.2.+'
}
```

Note: These libraries have the minimum version needed for the library to work.


## Usage

To start using the library you need at least to register your organizationId and then call one of the profile funtions.`

```kotlin
KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)
val sessionID = DeviceFingerprint().profile(applicationContext)
```

You can register an endpoint url as well.
```kotlin
DeviceFingerprint.register(applicationContext, ORGANIZATION_ID, "https://api-sandbox.koin.com.br/fingerprint/session/mobile")
DeviceFingerprint.profile(applicationContext)
```
This url will replace the default.

### Placing within the app

A couple considerations to place the library calls in your code.
You should always register your organization ID before making other calls of this library. (`DeviceFingerprint.register(applicationContext, ORGANIZATION_ID)`)
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
val sessionID = DeviceFingerprint.profile(applicationContext)
```

This will return a sessionID as a UUIDv4.

If you have a sessionID you can use 
```kotlin
DeviceFingerprint.profile(applicationContext, "YOUR_SESSION_ID")
```


