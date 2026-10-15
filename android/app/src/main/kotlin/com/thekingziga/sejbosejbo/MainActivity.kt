package com.thekingziga.sejbosejbo

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createPostsChannel()
    }

    /// The manifest names `sejbosejbo_posts` as FCM's default channel, but
    /// FCM does not create it - when it is missing, messages fall back to
    /// Firebase's generic "Miscellaneous" channel, so the user's per-channel
    /// settings never apply. Created here, on every launch (a no-op once it
    /// exists): no push can arrive before the first launch anyway, because the
    /// token is only registered with the server from inside the app.
    private fun createPostsChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val channel = NotificationChannel(
            POSTS_CHANNEL_ID,
            getString(R.string.notification_channel_posts),
            NotificationManager.IMPORTANCE_DEFAULT,
        )
        channel.description = getString(R.string.notification_channel_posts_description)
        manager.createNotificationChannel(channel)
    }

    private companion object {
        /// Must match `default_notification_channel_id` in AndroidManifest.xml.
        const val POSTS_CHANNEL_ID = "sejbosejbo_posts"
    }
}
