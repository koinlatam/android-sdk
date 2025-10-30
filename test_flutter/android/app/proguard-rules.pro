# ============================================
# Koin Fingerprint SDK - Production Rules
# ============================================
# Only keep public API methods that are called from the app
-keep class br.com.koin.android_sdk.KoinFingerprinter {
    public static void register(android.content.Context, java.lang.String);
    public static void register(android.content.Context, java.lang.String, java.lang.String);
    public static java.lang.String profile(android.content.Context);
}

# Keep SDK model classes if they're returned/passed to the app
-keep class br.com.koin.android_sdk.model.** { *; }

# Keep SDK internal classes from being removed (but allow obfuscation)
-keep,allowobfuscation class br.com.koin.android_sdk.** { *; }

# ============================================
# Google Play Services
# ============================================
# Most Google libraries include their own ProGuard rules
# Only add specific rules if you encounter issues
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient { *; }
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info { *; }
-keep class com.google.android.gms.location.FusedLocationProviderClient { *; }

# ============================================
# Volley
# ============================================
-keep class com.android.volley.Request { *; }
-keep class com.android.volley.RequestQueue { *; }
-keep class com.android.volley.Response { *; }
-keep class com.android.volley.toolbox.** { *; }

# ============================================
# Kotlin & Coroutines
# ============================================
# Kotlin metadata for reflection
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }

# Coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}

# ============================================
# Production-only rules
# ============================================
# Keep crash information but remove source file names for security
-keepattributes LineNumberTable
-renamesourcefileattribute SourceFile

# ============================================
# General Android
# ============================================
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
