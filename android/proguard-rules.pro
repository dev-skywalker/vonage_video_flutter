# Vonage Video API ProGuard Rules
# Official documentation: https://tokbox.com/developer/sdks/android/

# Keep package names to prevent conflicts with other libraries
-keeppackagenames

# Keep all Vonage/OpenTok SDK classes and methods
-keep class com.opentok.** { *; }
-keep class com.vonage.** { *; }

# Suppress warnings for optional dependencies
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.net.ssl.OpenJSSE

# Keep WebRTC related classes
-keep class org.webrtc.** { *; }
-dontwarn org.webrtc.**

# Keep plugin classes
-keep class com.example.vonage_video_flutter.** { *; }

# Permission Handler ProGuard Rules
# Required for permission_handler to work in release builds
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes Annotation
-keepattributes *Annotation*
-keep class com.baseflow.permissionhandler.** { *; }

# Gson specific classes
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
