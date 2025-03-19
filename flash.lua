-- mod init start
DevPath = ModPath .. "dev.json"
if io.file_is_readable(DevPath) then
    LogFile = io.load_as_json(DevPath) or {}
end
local function check_for_unattended_issues()
    if LogFile then
        for _, issue in pairs(LogFile) do
            if issue.checked == false then
                LogConsole("You have issues you have not marked as checked in dev.json. Mark all problems as checked to stop this message.")
                break
            end
        end
    end
end
function LogConsole(message)
    log("[Funny Hints] " .. message)
end
function LogPrivateChat(message, title)
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
    check_for_unattended_issues()
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
                check_for_unattended_issues()
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
-- mod init end

Global.custom_hints.flash = {
    hint_flash = { "SEGA", "You have a little private time with me now. :)", "I can hear a horse carriage.", "That's embarrassing.", "That's going in my cringe compilation.", "Right in the optics!", "That wasn't a nice present.", "There there. I'm here for you.", "You poor thing.", "Damn gas makes me cry.", "Just wear a blindfold.", "Look away from those.", "Think faster chucklenut.", "Your opinion, my choice.", "Get 'banged! That doesn't sound right...", "Isn't flashing someone illegal?", "My eyes!", "We'll be right back.", "A minor setback.", "They're so tacticool.", "They got you good.", "Pocket sand!", "You took the full brunt of that.", "You like eating flashes?", "It's possible to avoid getting flashed this badly, you know.", "That was avoidable.", "Did you not see that coming?", "How're you gonna know what you're aiming at like this?", ":(", "Well this sucks." }
}
local last_flash_hint_time = -math.huge
Hooks:PostHook(CoreEnvironmentControllerManager, "set_flashbang", "FunnyHints_flash", function (self)
    SetHeistSpecificHints()

    local current_time = managers.game_play_central:get_heist_timer()
    local flash_strength = math.pow(math.min(self._current_flashbang, 1), 16) + math.min(self._current_flashbang_flash, 1)
    if flash_strength >= 2 and current_time - last_flash_hint_time > 2 then -- flash_strength 2 is max
        local message = HintRandom("hint_flash", Global.custom_hints.flash.hint_flash)
        Global.last_hint = {
            time = Application:time(),
            list_id = "flash",
            hint_id = "hint_flash",
            text = message
        }
        managers.hud:show_hint({ text = message })
        last_flash_hint_time = current_time
    end
end)