package ai.spatius.avatarkit

import ai.spatius.avatarkit.player.AnimationPlayer
import kotlin.test.Test
import kotlin.test.assertEquals

internal class AvatarKitPluginTest {
    @Test
    fun `conversation state mapping includes paused`() {
        assertEquals("idle", conversationStateToFlutterValue(AnimationPlayer.ConversationState.Idle))
        assertEquals("paused", conversationStateToFlutterValue(AnimationPlayer.ConversationState.Paused))
        assertEquals("playing", conversationStateToFlutterValue(AnimationPlayer.ConversationState.Playing))
    }

    @Test
    fun `active maps to playing for flutter semantics`() {
        assertEquals("playing", conversationStateToFlutterValue(AnimationPlayer.ConversationState.Active))
    }
}
