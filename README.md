# Koin Android Fingerprint SDK

KoinFingerprinter is an Android library written in Kotlin. It gathers configurable device, app, network, behavioral, and integrity signals, then sends the resulting fingerprint payload to the configured Koin endpoint.

**Current source version:** `1.3.1`  
**Minimum Android version:** API 24 (Android 7.0)  
**Source repository:** [github.com/koinlatam/android-sdk](https://github.com/koinlatam/android-sdk)

## Installation

### AAR

Copy the `fingerprint-sdk-release.aar` supplied for the version you are integrating into your app module's `libs/` directory, then add:

```gradle
dependencies {
    implementation files('libs/fingerprint-sdk-release.aar')
}
```

If the AAR distribution does not provide transitive dependency metadata, also add the runtime libraries used by the SDK:

```gradle
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'androidx.biometric:biometric:1.1.0'
    implementation 'com.android.volley:volley:1.2.+'
    implementation 'com.google.android.gms:play-services-location:15.0.+'
    implementation 'com.google.android.gms:play-services-ads-identifier:15.0.+'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.3'
}
```

These coordinates and versions match the current SDK module build. Resolve any dependency conflicts using versions compatible with your app.

### GitHub Packages

If version `1.3.1` is published to your organization's GitHub Packages registry, configure the repository with a GitHub token that has `read:packages` access. Keep the token in local Gradle properties or CI secrets; do not commit it.

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.pkg.github.com/koinlatam/android-sdk")
            credentials {
                username = findProperty("gpr.user") ?: System.getenv("GITHUB_ACTOR")
                password = findProperty("gpr.key") ?: System.getenv("GITHUB_TOKEN")
            }
        }
    }
}
```

Then add the SDK dependency:

```gradle
dependencies {
    implementation "br.com.koin:android-sdk:1.3.1"
}
```

Ask your Koin contact whether the package version is available to your account. If Gradle cannot resolve it, use the AAR distribution.

## Quick start

Register the SDK during app startup, then call `profile` when the app is ready to send a fingerprint. Use an `Application` context where possible.

```kotlin
import android.app.Application
import br.com.koin.android_sdk.KoinFingerprinter

class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()

        KoinFingerprinter.register(
            c = this,
            organizationId = BuildConfig.KOIN_ORGANIZATION_ID
        )

        val sessionId = KoinFingerprinter.profile(this)
    }
}
```

The default endpoint in the source is the Koin sandbox endpoint:

`https://api-sandbox.koin.com.br/fingerprint/session/mobile`

Pass the endpoint provided by Koin when your integration should use a different environment. The `profile` call returns immediately; collection and the HTTP POST run asynchronously, and the SDK does not provide a completion callback.

## Registration options

`register` must run before `profile`. Its parameters are:

| Parameter | Behavior |
| --- | --- |
| `c` | Android `Context`; use the `Application` when available so lifecycle tracking can be initialized. |
| `organizationId` | Organization identifier sent with the fingerprint payload. |
| `url` | API endpoint; defaults to the sandbox URL above. |
| `geoLocationEnabled` | Master switch for collecting last-known geographic coordinates; defaults to `false`. The app must also have location permission and `config.location.geoLocationEnabled` enabled. |
| `timeout` | Harvester timeout in seconds; defaults to `1.0`. Values below `1.0` are raised to the minimum. |
| `config` | `FingerprintConfig` instance for enabling/disabling data categories and individual fields. |
| `customTargetApps` | Optional package names to include in installed-app targeting. On Android 11+, the host app may need matching `<queries>` declarations for custom packages. |

Example with explicit settings:

```kotlin
import br.com.koin.android_sdk.config.FingerprintConfig
import br.com.koin.android_sdk.config.LocationConfig

KoinFingerprinter.register(
    c = application,
    organizationId = BuildConfig.KOIN_ORGANIZATION_ID,
    url = BuildConfig.KOIN_FINGERPRINT_URL,
    geoLocationEnabled = true,
    timeout = 2.0,
    config = FingerprintConfig(
        location = LocationConfig(geoLocationEnabled = true)
    ),
    customTargetApps = listOf("com.example.bank")
)
```

## Sessions and profiling

The SDK offers two `profile` overloads:

```kotlin
// SDK creates or reuses a session ID and returns it immediately.
val sessionId: String = KoinFingerprinter.profile(applicationContext)

// Use a session ID managed by the host app.
KoinFingerprinter.profile(applicationContext, "YOUR_SESSION_ID")
```

The SDK persists its session ID and reuses it until it expires after two hours. The explicit-ID overload stores the supplied ID and returns no value. Each call starts a new asynchronous collection and send.

The outgoing payload contains the SDK and schema versions, organization and session IDs, execution metrics, and the collected mobile-application data.

## Data configuration

`FingerprintConfig` has configuration groups for `accounts`, `application`, `behavioral`, `calendar`, `connectivity`, `contacts`, `device`, `environment`, `hardware`, `installedApps`, `integrity`, `location`, `media`, `operativeSystem`, `screen`, `security`, `sensors`, and `telecom`. Each group provides an `enabled` switch and, for most groups, individual Boolean field switches.

Most groups and fields are enabled by default. `calendar` and `media` are disabled by default. Geographic coordinates are also disabled unless both the top-level `geoLocationEnabled` argument and `config.location.geoLocationEnabled` are true.

```kotlin
import br.com.koin.android_sdk.config.BehavioralConfig
import br.com.koin.android_sdk.config.DeviceConfig
import br.com.koin.android_sdk.config.FingerprintConfig

val config = FingerprintConfig(
    device = DeviceConfig(enabled = false),
    behavioral = BehavioralConfig(
        enabled = true,
        touchPatterns = false,
        typingCadence = false
    )
)

KoinFingerprinter.register(
    c = application,
    organizationId = BuildConfig.KOIN_ORGANIZATION_ID,
    config = config
)
```

### Typing cadence

Behavioral tracking is initialized by `register`. To provide typing cadence events from text fields, call `KoinFingerprinterTyping.trackTextChange` when the field value changes. The SDK uses the positive character-count delta; it does not need the field's text contents.

```kotlin
import br.com.koin.android_sdk.KoinFingerprinterTyping

KoinFingerprinterTyping.trackTextChange(oldValue, newValue)
```

## Java and .NET MAUI integration

For Java or .NET MAUI Slim Binding consumers, use the explicit-overload facade in `br.com.koin.android_sdk.interop`. It avoids Kotlin default-parameter interop:

```java
KoinFingerprintBridge.register(
    context,
    organizationId,
    KoinFingerprintBridge.DEFAULT_URL,
    false, // geoLocationEnabled
    KoinFingerprintBridge.MIN_TIMEOUT
);
String sessionId = KoinFingerprintBridge.profile(context);
```

`BridgeRegisterOptions` is available for property-based registration, including `customTargetApps`. The bridge validates that the organization ID, URL, and any caller-supplied session ID are not blank. Profiling remains fire-and-forget.

## Permissions and package visibility

The SDK does not show permission dialogs. The host app is responsible for declaring and requesting the Android permissions needed for the optional data it wants to collect. Without a grant, permission-dependent values are omitted or returned with safe defaults.

Common examples include:

| Data | Host-app permission (when needed) |
| --- | --- |
| Location | `ACCESS_FINE_LOCATION` or `ACCESS_COARSE_LOCATION` |
| Accounts | `GET_ACCOUNTS` |
| Calendar | `READ_CALENDAR` |
| Contacts | `READ_CONTACTS` |
| Media | `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` on newer Android versions, or `READ_EXTERNAL_STORAGE` on older versions |
| Call and SMS statistics | `READ_CALL_LOG` and/or `READ_SMS` |
| Network state | `ACCESS_NETWORK_STATE` |

The SDK manifest declares `INTERNET` and package-visibility `<queries>` used by installed-app and security checks. On Android 11 and later, add package queries in the host app for any custom target packages not already visible through the SDK's declarations.

## Build compatibility

The SDK module is built with compile SDK 36 and declares minimum SDK 24. A host app can use its own supported compile/target SDK settings, subject to the Android Gradle Plugin and dependency compatibility requirements.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `No organizationId provided` | Call `register` with a non-empty organization ID before `profile`. |
| `No sessionId provided` | Use `profile(context)` or pass a non-empty session ID. |
| No geographic coordinates | Set both geo switches to `true` and grant location permission in the host app. |
| Permission-dependent fields are missing | Declare and request the permission in the host app before profiling. |
| Custom target apps are not visible | Add matching `<queries>` declarations to the host app on Android 11+. |
| Maven dependency cannot be resolved | Confirm the package is published and that the GitHub token has `read:packages`; otherwise use the AAR. |

## Version

The current module source sets `sdkVersion` to `1.3.1`. Check with Koin for the published release or Maven package corresponding to the source you integrate.
