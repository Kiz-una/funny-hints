Global.custom_hints.flash = {
    hint_flash = { "SEGA", "You have a little private time with me now. :)", "I can hear a horse carriage.", "That's embarrassing.", "That's going in my cringe compilation.", "Right in the optics!", "That wasn't a nice present.", "There there. I'm here for you.", "You poor thing.", "Damn gas makes me cry.", "Just wear a blindfold.", "Look away from those.", "Think faster chucklenut.", "Your opinion, my choice.", "Get 'banged! That doesn't sound right...", "Isn't flashing someone illegal?", "My eyes!", "We'll be right back." }
}
Hooks:PostHook(PlayerDamage, "on_flashbanged", "FunnyHints_flash", function ()
    SetHeistSpecificHints()

    local flash_strength = math.pow(math.min(managers.environment_controller._current_flashbang, 1), 16) + math.min(managers.environment_controller._current_flashbang_flash, 1)
    if flash_strength >= 2 then
        local message = HintRandom("hint_flash", Global.custom_hints.flash.hint_flash)
        Global.last_hint = {
            time = Application:time(),
            list = "flash",
            id = "hint_flash",
            text = message
        }
        managers.hud:show_hint({ text = message })
    end
end)