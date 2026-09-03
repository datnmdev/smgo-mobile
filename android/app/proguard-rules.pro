# ==============================================================================
# 1. FLUTTER ENGINE RULES
# ==============================================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.fullScreen.** { *; }
-keep class io.flutter.customView.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.agent.** { *; }

# Giữ lại các annotation của Flutter
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ==============================================================================
# 2. GOOGLE PLAY BILLING API RULES
# ==============================================================================
-keep class com.android.vending.billing.** { *; }
-keep class com.google.android.gms.internal.play_billing.** { *; }
-keep class com.android.billingclient.api.** { *; }

# ==============================================================================
# 3. KOTLIN & COROUTINES (Nếu có dùng code Native)
# ==============================================================================
-dontwarn kotlin.**
-dontwarn kotlinx.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ==============================================================================
# 4. GENERAL NETWORK & JSON MODEL RULES (Tránh lỗi parse JSON)
# ==============================================================================
# Giữ lại tên thuộc tính khi Serialize/Deserialize JSON
-keepattributes SerializedName
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**

# ==============================================================================
# 1. Bỏ qua cảnh báo thiếu Class của Play Core (Play Store Split/Deferred Components)
# ==============================================================================
-dontwarn com.google.android.play.core.**

# ==============================================================================
# 2. Bỏ qua cảnh báo thiếu Class các ngôn ngữ không dùng của ML Kit Text Recognition
# ==============================================================================
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**