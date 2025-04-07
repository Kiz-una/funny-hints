CustomHints.callmod = {
    hint_call = { "$PLAYER is trying to get your attention.", "Hey! $PLAYER wants something.", "$PLAYER is yelling at you.", "Go check what $PLAYER wants.", "$PLAYER is calling you.", "$PLAYER is trying to order you around.", "$PLAYER wants you at their heel.", "$PLAYER wants you.", "$PLAYER wants teamplay. What a weirdo.", "$PLAYER needs your cooperation.", "Your presence is needed by $PLAYER.", "$PLAYER needs you right now.", "$PLAYER is commanding you to come!", "Go to $PLAYER! That's an order!", "$PLAYER wants you to pay attention.", "Humor $PLAYER.", "$PLAYER needs a friend right now.", "Be a good friend and listen to $PLAYER.", "$PLAYER needs a comrade in arms.", "$PLAYER wants you to stick together.", "Go to $PLAYER.", "Just ignore $PLAYER.", "I'm sure $PLAYER didn't mean to call you.", "$PLAYER is desperate for your attention.", "$PLAYER is calling out to you.", "$PLAYER wants you to group up.", "$PLAYER thinks you need to use pack tactics right now.", "$PLAYER requests your presence.", "$PLAYER requires an audience.", "Better stick together. That's what $PLAYER says.", "I'm here because you don't listen. Go to $PLAYER.", "Wake up. $PLAYER needs you.", "You can figure it out yourself if you just listen.", "Let me remind you, this is a team activity.", "Listen to $PLAYER." }
}
Hooks:PreHook(UnitNetworkHandler, "long_dis_interaction", "FunnyHints_callmod", function()
    local message = SetHint("hint_call", "callmod")
    LocalizationManager:add_localized_strings({
        hint_follow_player = message,
        hint_uncuff_player = message,
        hint_help_player = message,
    })
end)