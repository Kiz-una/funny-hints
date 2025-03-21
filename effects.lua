-- mod init start
DevPath = ModPath .. "dev.json"
if io.file_is_readable(DevPath) then
    LogFile = io.load_as_json(DevPath) or {}
end
local function check_for_errors()
    if LogFile and LogFile.errors then
        for _, entry in pairs(LogFile.errors) do
            if entry.checked == false then
                LogConsole("You have issues you have not marked as checked in dev.json. Mark all problems as checked to stop this message.")
                break
            end
        end
    end
end
function LogConsole(message)
    log("[Funny Hints] " .. message)
end
function LogPrivateChat(message)
    if not LogFile then
        return
    end
    managers.chat:_receive_message(1, "Funny Hints", message, tweak_data.system_chat_color)
end

if not Global.custom_hints then
    Global.custom_hints = {} -- Needs to be declared before declaring other tables inside it.
end
if not Global.hint_weights then
    Global.hint_weights = io.load_as_json(SavePath .. "FunnyHints_Weights.json") or {}
else
    io.save_as_json(Global.hint_weights, SavePath .. "FunnyHints_Weights.json")
end
if Global.hint_easteregg then
    managers.hud.show_hint = function(_)end
end

function IsPlayerAlive()
    local unit = managers.player and managers.player:player_unit()
    return unit and unit:character_damage() and unit:character_damage().dead and not unit:character_damage():dead()
end

local heist_specific_overrides = {
	four_stores = {
		main = {
			hud_hint_grabbed_small_loot = { "Progress!", "This stuff isn't worth much, but Vlad doesn't care.", "This is the greatest heist.", "This is totally worth it.", "If only I was justified to insult you for this.", "Useful for once.", "Munnie!", "Holla Holla get Dollar.", "These stores have so little money.", "Four Stores? More like Four Dollars!", "I'd rather rob a 7-Eleven.", "Cha-Ching!", "Cash is Queen.", "Greed is Good!", "Look at that wad!" }
		}
	}
}
--local heist_specific_additions = {}

local heist_hints_checked = false
function SetHeistSpecificHints()
    check_for_errors()
    if heist_hints_checked then
        return
    end
    local job_id = managers.job:current_job_id()
    if heist_specific_overrides[job_id] then
        for list_id, hint_ids in pairs(heist_specific_overrides[job_id]) do
            for hint_id, messages in pairs(hint_ids) do
                Global.custom_hints[list_id][hint_id] = messages
            end
        end
    end
    -- Todo: if heist_specific_additions gets used, add a way of attaching its messages onto existing tables.
    heist_hints_checked = true
end

function InsertMessages(data, list_id)
	for _, message_data in pairs(data) do
		for _, hint_id in pairs(message_data.ids) do
			for _, message in pairs(message_data.messages) do
				table.insert(Global.custom_hints[list_id][hint_id], message)
                check_for_errors()
			end
		end
	end
end

function HintRandom(hint_id, messages)
    local selector = WeightedSelector:new()
    for _, message in pairs(messages) do
        local weight = Utils:GetNestedValue(Global, "hint_weights", hint_id, message) or 1
        selector:add(message, weight)
    end
    return selector:select()
end

function SetHint(hint_id, list_id)
    SetHeistSpecificHints()
    local message = HintRandom(hint_id, Global.custom_hints[list_id][hint_id])
    Global.last_hint = {
        time = Application:time(),
        hint_id = hint_id,
        list_id = list_id,
        text = message
    }
    return message
end

local last_hint_time = -math.huge
function ShowHintCustom(hint_id, list_id, cooldown)
    if Application:time() - last_hint_time > (cooldown or 2) then
        local message = SetHint(hint_id, list_id)
        managers.hud:show_hint({ text = message })
        last_hint_time = Application:time()
    end
end
-- mod init end

Global.custom_hints.effects = {
    hint_last_life_replenished_0 = { "That was close.", "Living on a razor's edge ain't fun.", "Aw, you took the suspense out!", "You're outta the danger zone.", "The bullets inside you disappear.", "All better now.", "Wow, you stitch fast!", "Almost dying is a risky move." },

    hint_last_life_replenished_1 = { "If you get out of custody, they also give you ammo.", "Are you done fucking around now?", "If you need it again, that'll be truly embarrassing.", "Come on, you really need this crutch?", "Real heisters don't use Doctor Bags." },

    hint_last_life_replenished_2 = { "You really need to up your game.", "You should use cover, not a Doctor Bag!", "Are you just not paying attention?", "Please tell me you're using a joke loadout.", "You're really dragging the team down.", "How are you getting downed this much?", "Are you hugging the enemies?", "At this point it's more cost effective for you to go into custody instead." },

    hint_last_life_replenished_end = { "I'm wasting my breath on you.", "You're godawful. I'm leaving.", "I've seen enough of you. Goodbye." },

    hint_flash = { "SEGA", "You have a little private time with me now. :)", "I can hear a horse carriage.", "That's embarrassing.", "That's going in my cringe compilation.", "Right in the optics!", "That wasn't a nice present.", "There there. I'm here for you.", "You poor thing.", "Damn gas makes me cry.", "Just wear a blindfold.", "Look away from those.", "Think faster chucklenut.", "Your opinion, my choice.", "Get 'banged! That doesn't sound right...", "Isn't flashing someone illegal?", "My eyes!", "We'll be right back.", "A minor setback.", "They're so tacticool.", "They got you good.", "Pocket sand!", "You took the full brunt of that.", "You like eating flashes?", "It's possible to avoid getting flashed this badly, you know.", "That was avoidable.", "Did you not see that coming?", "How're you gonna know what you're aiming at like this?", ":(", "Well this sucks." }
}
InsertMessages({{ids = {"hint_last_life_replenished_1"}, messages = Global.custom_hints.effects.hint_last_life_replenished_0}}, "effects")

local previous_last_life_state = false
local saved_by_doctorbag = 0
if not Global.doctorbag_overuse then
    Global.doctorbag_overuse = 0
end
Hooks:PostHook(CoreEnvironmentControllerManager, "set_last_life", "FunnyHints_last_life", function(self, last_life_effect)
    if previous_last_life_state and not last_life_effect and IsPlayerAlive() then
        if Global.game_settings.one_down then
            ShowHintCustom("hint_last_life_replenished_0", "effects")
        else
            saved_by_doctorbag = saved_by_doctorbag + 1
            if saved_by_doctorbag > 1 then
                local infamy = managers.experience:current_rank()
                if infamy and infamy > 0 then
                    Global.doctorbag_overuse = Global.doctorbag_overuse + 1
                end
            end
            if saved_by_doctorbag > 3 or Global.doctorbag_overuse > 1 then -- 4 uses or 2 overuses across heists
                ShowHintCustom("hint_last_life_replenished_end", "effects")
                Global.hint_easteregg = true
                managers.hud.show_hint = function(_)end

            elseif saved_by_doctorbag < 2 then -- 1 uses only
                ShowHintCustom("hint_last_life_replenished_1", "effects")

            elseif saved_by_doctorbag < 4 then -- 2 and 3 uses
                ShowHintCustom("hint_last_life_replenished_2", "effects")

            end
        end
    end
    previous_last_life_state = last_life_effect
end)
Hooks:PostHook(CoreEnvironmentControllerManager, "set_flashbang", "FunnyHints_flash", function(self)
    local flash_strength = math.pow(math.min(self._current_flashbang, 1), 16) + math.min(self._current_flashbang_flash, 1)
    if flash_strength >= 2 then -- flash_strength 2 is max
        ShowHintCustom("hint_flash", "effects")
    end
end)