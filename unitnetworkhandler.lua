Hooks:PreHook(UnitNetworkHandler, "long_dis_interaction", "FunnyHints_callmod", function ()
    Global.custom_hints_callmod = {
        hint_call = { "$PLAYER is trying to get your attention.", "Hey! $PLAYER wants something.", "$PLAYER is yelling at you.", "Go check what $PLAYER wants.", "$PLAYER is calling you.", "$PLAYER orders you to come.", "$PLAYER wants you at their heel.", "$PLAYER wants you." }
    }
    local hint_call_set = HintRandom("hint_call", Global.custom_hints_callmod.hint_call)
    LocalizationManager:add_localized_strings({
        hint_follow_player = hint_call_set,
        hint_uncuff_player = hint_call_set,
        hint_help_player = hint_call_set,
    })
    Global.last_hint = {
        time = Application:time(),
        table = "callmod",
        id = "hint_call",
        text = hint_call_set
    }
end)