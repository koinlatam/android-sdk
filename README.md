# KoinFingerprinter

KoinFingerprinter is a device information gathering library for Android, written in Kotlin. It collects device, application, connectivity, behavioral, and integrity signals and sends them to Koin's fingerprint API using a session identifier.

**Repository:** [github.com/koinlatam/android-sdk](https://github.com/koinlatam/android-sdk)

---

## Requirements

- Android `minSdk` 19 or higher
- Kotlin or Java app module
- Internet access (`INTERNET` is declared by the SDK)

---

## Installation

### Option A — Release AAR (recommended)

1. Open [Releases](https://github.com/koinlatam/android-sdk/releases) and download `fingerprint-sdk-release.aar` from the version you need (latest: **[KoinFingerprinter-1.0.1](https://github.com/koinlatam/android-sdk/releases)**).
2. Copy the file into your app module's `libs/` folder.
3. Add the dependency in `app/build.gradle`:

```gradle
dependencies {
    implementation files('libs/fingerprint-sdk-release.aar')
}
```

4. Sync Gradle.

> A copy of the AAR may also exist at the [repository root](https://github.com/koinlatam/android-sdk/blob/main/fingerprint-sdk-release.aar) for convenience. Prefer the asset attached to the [release](https://github.com/koinlatam/android-sdk/releases) that matches your integration version.

---

### Option B — GitHub Packages (Maven)

If your organization publishes and grants access to the Maven package, you can depend on it without copying the AAR manually.

| Field | Value |
|--------|--------|
| Group ID | `br.com.koin` |
| Artifact ID | `android-sdk` |
| Repository URL | `https://maven.pkg.github.com/koinlatam/android-sdk` |

#### 1. Authentication

Create a GitHub Personal Access Token (classic) with at least the **`read:packages`** scope.

Store credentials locally (**do not commit tokens to git**).

In `~/.gradle/gradle.properties` or a local, gitignored `gradle.properties`:

```properties
gpr.user=YOUR_GITHUB_USERNAME
gpr.key=YOUR_GITHUB_PAT
```

For CI, use environment variables `GITHUB_ACTOR` and `GITHUB_TOKEN` (or a dedicated PAT with `read:packages`).

#### 2. Register the Maven repository

In `settings.gradle` (Gradle 7+):

```gradle
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
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

If your project uses `allprojects { repositories { ... } }` in the root `build.gradle`, add the same `maven { ... }` block there instead.

#### 3. Add the dependency

Use the version that matches your release (e.g. `1.0.1`):

```gradle
dependencies {
    implementation "br.com.koin:android-sdk:1.0.1"
}
```

Sync Gradle.

If dependency resolution fails, confirm with your Koin contact that the package is published and that your token has `read:packages`. Until then, use **Option A**.

---

### Transitive dependencies

If Gradle reports missing classes, add these to your **app** module:

```gradle
dependencies {
    implementation 'com.android.volley:volley:1.2.1'
    implementation 'com.google.android.gms:play-services-location:21.3.0'
    implementation 'com.google.android.gms:play-services-ads-identifier:18.2.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.1'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1'
}
```

These are the minimum versions required for the library to work; newer compatible versions are usually acceptable.

---

## Quick start

```kotlin
import br.com.koin.android_sdk.KoinFingerprinter

// Once per app launch (e.g. Application.onCreate)
KoinFingerprinter.register(applicationContext, "YOUR_ORGANIZATION_ID")

// Once per app lifecycle (recommended)
val sessionId = KoinFingerprinter.profile(applicationContext)
```

Replace `YOUR_ORGANIZATION_ID` with the value provided by Koin.

---

## Usage

### Register

Always call `register` before `profile`. Use `applicationContext` when possible.

```kotlin
KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)
```

**Custom API endpoint** (optional third parameter):

```kotlin
KoinFingerprinter.register(
    applicationContext,
    ORGANIZATION_ID,
    "https://api-sandbox.koin.com.br/fingerprint/session/mobile"
)
```

If omitted, the default endpoint is:

`https://api-sandbox.koin.com.br/fingerprint/session/mobile`

**Additional options** (optional):

```kotlin
import br.com.koin.android_sdk.config.FingerprintConfig

KoinFingerprinter.register(
    c = applicationContext,
    organizationId = ORGANIZATION_ID,
    url = "https://api-sandbox.koin.com.br/fingerprint/session/mobile",
    disableGeo = true,              // default: true
    timeout = 1.0,                  // seconds; minimum 1.0
    config = FingerprintConfig(),   // optional: enable/disable data categories
    customTargetApps = emptyList()  // optional: package names for app targeting
)
```

| Parameter | Description |
|-----------|-------------|
| `disableGeo` | Default `true`. Set to `false` only if your app already granted location permission. The SDK does **not** show permission dialogs. |
| `timeout` | Maximum harvest time in seconds (minimum `1.0`). |
| `config` | Fine-grained control of collected fields (`FingerprintConfig`). |
| `customTargetApps` | Package names used by the installed-apps harvester. |

### Profile

There are two ways to start information gathering.

**Let the SDK create or reuse a session ID** (returns a UUID v4 string):

```kotlin
val sessionId = KoinFingerprinter.profile(applicationContext)
```

- Reuses a stored session when still valid.
- Sessions expire after **2 hours**; a new ID is created on the next call without a custom ID.
- Data collection and upload run in the **background**; the returned `sessionId` is available immediately.

**Use your own session ID:**

```kotlin
KoinFingerprinter.profile(applicationContext, "YOUR_SESSION_ID")
```

This overload does not return a value.

### Placing calls in your app

1. Call **`register` once** before any `profile` call (`KoinFingerprinter.register(applicationContext, ORGANIZATION_ID)`).
2. Call **`profile` once per app lifecycle** when you are ready to send data. Multiple calls send multiple payloads.
3. You may call `register` in `Application.onCreate()` and `profile` at any later point, as long as you pass `applicationContext`.
4. The SDK **does not** request permissions. Your app should request them if you need richer data:
   - `ACCESS_WIFI_STATE`
   - `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (only relevant if `disableGeo = false`)

If your app already asks for location or Wi‑Fi permissions, consider calling `profile` after the user grants them.

### Example: Application class

```kotlin
class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        KoinFingerprinter.register(
            c = this,
            organizationId = BuildConfig.KOIN_ORG_ID,
            url = BuildConfig.KOIN_FINGERPRINT_URL,
            disableGeo = false // only if your app handles location permission
        )
        KoinFingerprinter.profile(this)
    }
}
```

### Configuration (`FingerprintConfig`)

Import types from `br.com.koin.android_sdk.config`. By default, all harvester categories and fields are enabled. You can disable entire categories or individual fields:

```kotlin
import br.com.koin.android_sdk.config.FingerprintConfig
import br.com.koin.android_sdk.config.BehavioralConfig
import br.com.koin.android_sdk.config.LocationConfig

KoinFingerprinter.register(
    applicationContext,
    ORGANIZATION_ID,
    config = FingerprintConfig(
        behavioral = BehavioralConfig(
            enabled = true,
            touchPatterns = false
        ),
        location = LocationConfig(enabled = false)
    )
)
```

Categories: `application`, `behavioral`, `connectivity`, `device`, `environment`, `hardware`, `installedApps`, `integrity`, `location`, `operativeSystem`, `screen`, `security`, `sensors`.

Each category data class exposes `enabled` plus field-level `Boolean` flags.

---

## Flutter integration

If you are using Flutter, see the [**Flutter SDK Integration Example**](https://github.com/koinlatam/android-sdk/tree/main/test_flutter) in this repository.

It demonstrates how to integrate the SDK in a Flutter project, including dependency management and native communication via `MethodChannel`.

---

## Permissions and privacy

- The SDK declares only `INTERNET` in its manifest.
- It **never** calls `requestPermissions`; the host app is responsible for permission UX.
- Without grants, affected fields are omitted or empty — no crash and no permission dialog from the SDK.

---

## Troubleshooting

| Symptom | What to check |
|---------|----------------|
| Could not resolve `br.com.koin:android-sdk` | Package not published or token missing `read:packages`; use the Release AAR instead |
| Log: `No organizationId provided` | Call `register` before `profile` |
| Log: `No sessionId provided` | Use `profile(context)` or pass a non-empty session ID |
| Missing Volley / Play Services classes | Add transitive dependencies listed above |
| No location in payload | Set `disableGeo = false` and grant location permission in **your** app |

---

## Versioning

See [Releases](https://github.com/koinlatam/android-sdk/releases) for changelog and downloadable artifacts.

| Release | Notes |
|---------|--------|
| [KoinFingerprinter-1.0.1](https://github.com/koinlatam/android-sdk/releases) | Latest |

For organization IDs and production endpoints, contact your Koin representative.
