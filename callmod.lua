Global.custom_hints.callmod = {
    hint_call = { "$PLAYER is trying to get your attention.", "Hey! $PLAYER wants something.", "$PLAYER is yelling at you.", "Go check what $PLAYER wants.", "$PLAYER is calling you.", "$PLAYER orders you to come.", "$PLAYER wants you at their heel.", "$PLAYER wants you.", "$PLAYER wants teamplay. What a weirdo.", "$PLAYER needs your cooperation.", "Your presence is needed by $PLAYER.", "$PLAYER needs you right now." }
}
Hooks:PreHook(UnitNetworkHandler, "long_dis_interaction", "FunnyHints_callmod", function()
    local message = SetHint("hint_call", "callmod")
    LocalizationManager:add_localized_strings({
        hint_follow_player = message,
        hint_uncuff_player = message,
        hint_help_player = message,
    })
end)