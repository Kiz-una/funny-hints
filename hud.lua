local function log_private_chat(message, title)
    if not title then
        title = "Funny Hints"
    end
    managers.chat:_receive_message(1, title, message, tweak_data.system_chat_color)
end
if not Global.custom_hints then
    Global.custom_hints = {} -- Needs to be declared before declaring other tables inside it. This file loads first going into a heist.
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
    if heist_hints_checked then
        return
    end
    local job_id = managers.job:current_job_id()
    if heist_specific_overrides[job_id] then
        for list, _ in pairs(heist_specific_overrides[job_id]) do
            for string_id, _ in pairs(list) do
                Global.custom_hints[list][string_id] = string_id
            end
        end
        log("[Funny Hints] Heist specific messages set.")
    end
    -- Todo: if heist_specific_additions gets used, add a way of attaching its messages onto existing tables.
    heist_hints_checked = true
end

function InsertMessages(data, list)
	for _, message_data in pairs(data) do
		for _, string_id in pairs(message_data.ids) do
			for _, message in pairs(message_data.messages) do
				table.insert(Global.custom_hints[list][string_id], message)
			end
		end
	end
end

function HintRandom(string_id, messages)
    if not Global.hint_weights[string_id] then
        log_private_chat("Dectected a new hint in HintRandom. (" .. string_id .. ")")
    end
    local selector = WeightedSelector:new()
    for _, message in pairs(messages) do
        local weight = Utils:GetNestedValue(Global, "hint_weights", string_id, message) or 1
        selector:add(message, weight)
    end
    return selector:select()
end

local function set_weights(last_hint)
    local string_id = last_hint.id
    if not Global.hint_weights[string_id] then
        log_private_chat("Dectected a new hint in set_weights. (" .. string_id .. ")")
    end
    local messages = Global.custom_hints[last_hint.list][string_id]
    if #messages <= 1 then
        return
    end
    local text = last_hint.text
    local hint_weight = Utils:GetNestedValue(Global, "hint_weights", string_id, text) or 1
    Utils:SetNestedValue(Global, 0, "hint_weights", string_id, text) -- second variable is to set the end value
    for _, message in pairs(messages) do
        if message ~= text then
            Global.hint_weights[string_id][message] = (Global.hint_weights[string_id][message] or 1) + hint_weight / (#messages - 1)
        end
    end
end

local function get_string_id(custom_hints, text)
    if text then
        for string_id, _ in pairs(custom_hints) do
            if managers.localization:text(string_id) == text then
                return string_id
            end
        end
    end
end

Global.custom_hints.hud = {
    hud_hint_bipod_nomount = { "Your bipod doesn't fit here.", "You can't find a place to put it down.", "That won't do.", "You can't put it here.", "It needs something to rest on.", "The bipod is complaining.", "The bipod doesn't like that spot.", "The bipod cries as you try to put it down.", "User Error.", "The bipod is unhappy.", "Not there!", "That's not a good place for a bipod." },
}
Hooks:PreHook(HUDManager, "show_hint", "FunnyHints_hud", function(self, params)
    SetHeistSpecificHints()

    local string_id = get_string_id(Global.custom_hints.hud, params.text)
    if string_id then
        params.text = HintRandom(string_id, Global.custom_hints.hud[string_id])
        Global.last_hint = {
            time = Application:time(),
            list = "hud",
            id = string_id,
            text = params.text
        }
    end
    if Global.last_hint and Application:time() == Global.last_hint.time then
        set_weights(Global.last_hint)
    end
end)

Global.custom_hints.mid_text = {
    hud_civilian_killed_title = { "Wow, uncalled for.", "What did they do to you?", "No Russian.", "Oops.", "Itchy trigger finger.", "That's not an enemy!", "You're disappointing Bain.", "They had a family!", "Oh no!", "We'll need you to fill out some paperwork for that.", "You should not be trusted with a gun.", "Do you know how to aim that thing?", "I'm sure they just ran into that.", "Do you need the blood of the innocents?", "Rude.", "You've made an orphan.", "Now get the other parent!", "This is a pretty cheap mistake.", "Maybe that one was just undercover.", "You're a monster.", "You were just denfending yourself, right?", "Accidents happen.", "Killing a cop with a family is one thing, but this is just sick.", "Watch where you point that thing!", "You're infamous, not famous! You can't get away with that!", "Despicable You.", "Think of the children!", "I hope this isn't a kink of yours.", "You sicken me.", "Are we the baddies?", "You're totally not evil.", "Aim better.", "Civilians can't hurt you.", "They're more scared of you than you are of them." },

    hud_loot_secured_title = { "Is that enough?", "Get all of it!", "Still got some left?", "Bring more!", "Sing a song of six pence, a pocket full of dosh!", "Money makes the world go around.", "Whaaa, loadsamoney.", "Bosh bosh, shoom shoom wallop, dosh!", "lods of emone.", "Made a right load of perishing lolly this week.", "Fill it to the brim!", "You are made for heisting and that was meant for hauling what you heist.", "I want some more.", "All this stealing's making us rich!", "And they say crime doesn't pay.", "There's room for more.", "You deserve this.", "It's better in your hands.", "Take from the rich, give to yourself.", "You worked hard for this.", "Fuck yeah! We're doing it!", "Get that bread!", "Greed is Good! Greed is Good!", "Keep looting!", "Clean the place out!", "Don't you dare leave with only some of the loot!", "One!", "Clean them out at all cost!", "Steal anything that isn't nailed down.", "You're totally Robin Hood.", "I bet they didn't need this anyway.", "That's yours now.", "Let me just find a nice place for this.", "Good Heister.", "This one looks weird.", "Did you sweat on this?", "This one smells off.", "Can I have some of this?", "Keep 'em coming!", "Let's keep this going!", "Risk your life if you have to!", "This is becoming routine.", "Music to my ears." },
}
local last_mid_text_hint_time = -10
Hooks:PreHook(HUDManager, "present_mid_text", "FunnyHints_mid_text" , function (self, params)
    SetHeistSpecificHints()

    local current_time = managers.game_play_central:get_heist_timer()
    local string_id = get_string_id(Global.custom_hints.mid_text, params.title)
    if string_id and current_time - last_mid_text_hint_time > 10 then
        local message = HintRandom(string_id, Global.custom_hints.mid_text[string_id])
        Global.last_hint = {
            time = Application:time(),
            list = "mid_text",
            id = string_id,
            text = message
        }
        self:show_hint({ text = message })
        last_mid_text_hint_time = current_time
    end
end)