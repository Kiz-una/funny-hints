-- mod init start
DevPath = ModPath .. "dev.json"
WeightsPath = SavePath .. "FunnyHints_Weights.json"
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

if not CustomHints then
    CustomHints = {} -- Needs to be declared before declaring other tables inside it.
end
if not Global.hint_weights then
    Global.hint_weights = io.load_as_json(WeightsPath) or {}
else
    io.save_as_json(Global.hint_weights, WeightsPath)
end

local function HowManyMessagesDoWeHave()
    local all_messages = {}
    local message_count = 0
    for list_id, hint_ids in pairs(CustomHints) do
        --if list_id == "welcome" then
        for hint_id, messages in pairs(hint_ids) do
            for _, message in pairs(messages) do
                if not all_messages[message] then
                    all_messages[message] = true
                    message_count = message_count + 1
                end
            end
        end
        --end
    end
    LogConsole(message_count)
end

function IsPlayerAlive()
    local unit = managers.player and managers.player:player_unit()
    return unit and unit:character_damage() and unit:character_damage().dead and not unit:character_damage():dead()
end

local heist_specific_overrides = {
	four_stores = {
		main = {
			hud_hint_grabbed_small_loot = { "Progress!", "This stuff isn't worth much, but Vlad doesn't care.", "This is the greatest heist.", "This is totally worth it.", "If only I was justified to insult you for this.", "Useful for once.", "Munnie!", "Holla Holla get Dollar.", "These stores have so little money.", "Four Stores? More like Four Dollars!", "I'd rather rob a 7-Eleven.", "Cha-Ching!", "Cash is Queen.", "Greed is Good!", "Look at that wad!", "It ain't much, but it's honest work." }
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
                CustomHints[list_id][hint_id] = messages
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
				table.insert(CustomHints[list_id][hint_id], message)
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
    --HowManyMessagesDoWeHave()
    local message = HintRandom(hint_id, CustomHints[list_id][hint_id])
    LastHint = {
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

local on_heist_start_finished = false
local function on_heist_start()
    if on_heist_start_finished then
        return
    end

    CustomHints.welcome = {
        welcome_chill_combat --[[Safe House Raid]] = { "Get them off your property!", "Trespassers must be shot.", "The cops decided to step into the spider's nest." },
        welcome_crojob3 --[[The Bomb: Forest]] = { "I feel a pit in my stomach looking at this forest...", "Be careful when jumping here.", "Do you not like yourself today?" },
        welcome_skm_big2 --[[Holdout: The Big Bank]] = { "Holding out here is easy mode." },
        welcome_pex --[[Breakfast in Tijuana]] = { "I was promised breakfast.", "Are we getting donuts for breakfast?" },
        welcome_pal --[[Counterfeit]] = { "Are you finally leaving the life of crime behind?", "Where are the alligators?", "This time Florida Man is the victim." },
        welcome_help --[[Prison Nightmare]] = {  },
        welcome_haunted --[[Safe house Nightmare]] = { "Oh, this old place.", "Did you prepare yourself for this?", "I see death." },
        welcome_run --[[Heat Street]] = { "You wouldn't need the laundromat if Hoxton didn't burn the old place down.", "What's the chance of you both meeting at the same laundromat at the same time?" },
        welcome_hox_1 --[[The Breakout]] = { "I never liked Houston.", "I'm sure Hox won't be too upset about his face." },
        welcome_spa --[[Brooklyn 10-10]] = {  },
        welcome_vit --[[The White House]] = { "THE BIG ONE!" },
        welcome_mia_2 --[[Four Floors]] = { "Imma living in a box. Imma living in a cardboard box.", "You're not Snake!" },
        welcome_ranc --[[Midland Ranch]] = { "Yeehaw!", "Say the line Dallas!" },
        welcome_big --[[The Big Bank]] = {  },
        welcome_brb --[[Brooklyn Bank]] = {  },
        welcome_skm_run --[[Holdout: Heat Street]] = { "I miss the gasoline smell." },
        welcome_cane --[[Santa's Workshop]] = { "Merry Christmas!", "This isn't what I imagined Santa's Workshop to look like.", "These aren't elves!", "Do they... accept visitors from the public...?", "So is this like... their cover?" },
        welcome_gallery --[[Art Gallery]] = {  },
        welcome_fex --[[Buluc's Mansion]] = { "Can you bring me back a Churro?" },
        welcome_skm_mus --[[Holdout: The Diamond]] = { "They took The Diamond out of The Diamond! :(" },
        welcome_bex --[[San Martin Bank]] = { "Mariachi!", "You could just sit here and enjoy the vibes." },
        welcome_arm --[[Transport: Any (expect train)]] = { "You'd think they'd stop using this route by now.", "You think they'll eventually start using tanks?", "GenSec hates you.", "It's the boys in red!", "You're definitely GenSec's mortal enemy." },
        welcome_watchdogs_1 --[[Truck Load]] = { "You're fish in a barrel. Yet they will still fail.", "Canned Heisters.", "Hector would never set us up." },
        welcome_skm_bex --[[Holdout: San Martin Bank]] = {  },
        welcome_rvd1 --[[Highland Mortuary]] = { "Hey look, it's like that one movie!" },
        welcome_mex --[[Southern Border]] = {  },
        welcome_arm_for --[[Transport: Train Heist]] = {  },
        welcome_corp --[[Hostile Takeover]] = {  },
        welcome_four_stores --[[Four Stores]] = { "I can't insult you for picking up small loot here." },
        welcome_escape --[[All Escapes]] = { "Nice driving.", "One less person to share the take with.", "We could have been home by now." },
        welcome_election_day_2 --[[Swing Vote]] = {  },
        welcome_nightclub --[[Nightclub]] = { "That music's loud. But your guns are louder." },
        welcome_pent --[[Mountain Master]] = { "Time to take over as king of the hill." },
        welcome_ukrainian_job --[[Ukrainian Job]] = { "I can have the tiara?", "The tiara is for me. :)" },
        welcome_skm_mallcrasher --[[Holdout: Mallcrasher]] = { "Now it's just Mall.", "They took the crasher out of Mallcrasher!" },
        welcome_kosugi --[[Shadow Raid]] = {  },
        welcome_wwh --[[Alaskan Deal]] = { "Does nobody ever learn? You can't ambush the Payday Gang." },
        welcome_skm_cas --[[Holdout: Golden Grin Casino]] = {  },
        welcome_firestarter_3 --[[Trustee Bank]] = {  },
        welcome_peta --[[This was not the deal]] = { "This is a new low.", "I hope you're an experienced rustler." },
        welcome_deep --[[Crude Awakening]] = { "Tactical espionage action.", "Now this is Big Oil!" },
        welcome_alex_3 --[[Bus Stop]] = { "End of the line, fellas!", "Last stop!" },
        welcome_rat --[[Cook Off]] = { "How long are you planning to stay this time?", "Didn't get enough of this place?" },
        welcome_arena --[[The Alesso Heist]] = { "You can set this as your menu music.", "This guy is for real. As in he exists.", "Have you ever asked yourself why the concert above, muffles the explosions three floors down?", "They have really thin walls here." },
        welcome_red2 --[[First World Bank]] = { "This is where it all started.", "Is there a Third World Bank?", "Is this the first bank in the world?" },
        welcome_jolly --[[Aftershock]] = { "Doing this, makes you are partly responsible for lootboxes.", "I love Vlad, but fuck him for these safes.", "You're gonna need a chiropractor after this." },
        welcome_framing_frame_3 --[[Framing]] = { "Make sure to steal his wine." },
        welcome_firestarter_2 --[[FBI Server]] = {  },
        welcome_framing_frame_1 --[[Art Gallery]] = { "The senator needs his porn in painting form.", "Good thing the senator never heard of PornHub." },
        welcome_des --[[Henry's Rock]] = { "Welcome to Area 51.", "Indy was here." },
        welcome_alex_1 --[[Cook Off]] = { "We need to cook." },
        welcome_tag --[[Breakin' Feds]] = {  },
        welcome_hox_2 --[[The Search]] = { "Payday Gang! Open up!" },
        welcome_mad --[[Boiling Point]] = { "Welcome to the motherland!", "I hate gravity!" },
        welcome_welcome_to_the_jungle_2 --[[Engine Problem]] = { "Don't forget to search for the engine notes.", "Were about to undo years of progress." },
        welcome_skm_red2 --[[Holdout: First World Bank]] = {  },
        welcome_short1_stage1 --[[Stealth - Flash Drive]] = {  },
        welcome_hox_3 --[[The Revenge]] = { "Let's see what kind of trouble we can get ourselves into." },
        welcome_mex_cooking --[[Coyopa Compound]] = { "This is just cook off but harder.", "Why did you come back here?" },
        welcome_shoutout_raid --[[Meltdown]] = {  },
        welcome_chew --[[Interception]] = { "Choo Choo!" },
        welcome_kenaz --[[Golden Grin Casino]] = { "Let's go gambling!", "If gambling is a disease, is this a hospital?" },
        welcome_cage --[[Car Shop]] = {  },
        welcome_trai --[[Lost in Transit]] = {  },
        welcome_firestarter_1 --[[Airport]] = {  },
        welcome_jewelry_store --[[Jewelry Store]] = {  },
        welcome_moon --[[Stealing Xmas]] = { "Hajrudin...", "Not Hajrudin again...", "Can Hajrudin not do anything right?" },
        welcome_sand --[[The Ukrainian Prisoner]] = { "I want my Vlad back!", "You can't just let Vlad rot in there! Get in!" },
        welcome_testing_map --[[Any map used for modding only]] = { "Back for more testing?", "Welcome back!", "I missed you.", "What are you working on today?", "I know someone who'd love to watch this.", "I bet I'm a very basic mod compared to what you're making.", "It's always a treat to see what you make.", "I'd try to be more serious while you're testing but I just can't help myself.", "I hope you're having fun modding!", ":)", "What did you cook up this time?", "I appreciate your work.", "I think you've very cool." },
        welcome_chca --[[Black Cat]] = {  },
        welcome_born --[[Lion's Den]] = { "This is their plan?", "I think these guys huffed too much gasoline.", "Poor guy. Let's help him." },
        welcome_nmh --[[No Mercy (Flashback)]] = { "I have a bad feeling about this.", "I don't think this is a good idea.", "Someone called Shade is the client. Wonder why she wants this virus.", "How much money are you being paid to end humanity?" },
        welcome_chas --[[Dragon Heist]] = {  },
        welcome_glace --[[Green Bridge]] = { "This is straight terrorism.", "GTA III reference?", "That's an overkill way to stop them." },
        welcome_dark --[[Murky Station]] = {  },
        welcome_dah --[[Diamond Heist]] = { "We should join the birthday party.", "They're playing Viklund's first songs at the party.", "Don't kill the birthday boy!", "If you kill the birthday boy, Payday 3 doesn't happen." },
        welcome_watchdogs_2 --[[Boat Load]] = {  },
        welcome_election_day_1 --[[Right Track]] = { "Speedrun?" },
        welcome_bph --[[Hell's Island]] = { "I will be so upset if something happens to Bain.", "We're gonna save Bain and he's gonna live happily ever after." },
        welcome_branchbank --[[Bank Heist]] = { "The classic.", "This one's so boring." },
        welcome_election_day_3 --[[Breaking Ballot]] = { "McKendrick better still appreciate this." },
        welcome_framing_frame_2 --[[Train Trade]] = {  },
        welcome_sah --[[Shacklethorne Auction]] = { "Where's your umbrella?" },
        welcome_chill --[[Safe House]] = { "Home sweet home." },
        welcome_mallcrasher --[[Mallcrasher]] = { "Welcome to the Shield Rage Room.", "Finally, you can let your intrusive thoughts win." },
        welcome_roberts --[[GO Bank]] = { "Rush Bank.", "Did you bring the bomb?" },
        welcome_short1_stage2 --[[Stealth - Erasing History]] = {  },
        welcome_mus --[[The Diamond]] = { "The Diamond." },
        welcome_alex_2 --[[Code for Meth]] = { "Keep it civil guys.", "You gonna make them nervous waving that gun around.", "Can we have a nice and peaceful transaction?" },
        welcome_dinner --[[Slaughterhouse]] = { "Did Bain organise that traffic jam?" },
        welcome_crojob2 --[[The Bomb: Dockyard]] = { "Why didn't we just bring a ladder? We could board the Moretta already." },
        welcome_skm_arena --[[Holdout: The Alesso Heist]] = { "Did the conecert finish? I don't hear his music." },
        welcome_pbr --[[Beneath the Mountain]] = { "See? They have a mountain base. We're not the evil ones." },
        welcome_pbr2 --[[Birth of Sky]] = { "It's kinda cramped in here.", "Are we there yet? My back hurts.", "There better not be any motherfucking snakes on this motherfucking plane!" },
        welcome_nail --[[Lab Rats]] = { "Rats, rats, we're the rats.", "We prey at night, we stalk at night, we're the rats." },
        welcome_peta2 --[[Dirty work]] = { "o.o", "Do we... have to be here?", "Please. Someone stop him.", "I didn't sign up for biology class!" },
        welcome_mia_1 --[[Hotline Miami]] = { "Does this count as a sequel to Mallcrasher?" },
        welcome_fish --[[The Yacht Heist]] = { "We get McKendrick into office and he repays us by siccing Commissioner Garrett on us. What an asshole.", "Fucking McKendrick. He's the reason we gotta deal with Captain Winters now.", "Make him pay for giving us Captain Winters." },
        welcome_welcome_to_the_jungle_1 --[[Club House]] = { "Touch the fence.", "Watch out for land mines." },
        welcome_hvh --[[Cursed Kill Room]] = { "This isn't our Safehouse...", "Can you open the door? I have Claustrophobia." },
        welcome_friend --[[Scarface Mansion]] = { "If this was my place... well I would sell it and live somewhere else." },
        welcome_short2_stage1 --[[Loud - Get The Coke]] = {  },
        welcome_flat --[[Panic Room]] = { "At least you can't fuck up this deal since it's supposed to end in gunfire." },
        welcome_rvd2 --[[Garnet Group Boutique]] = { "It's rewind time.", "I'm sure nothing will go wrong. :)" },
        welcome_pines --[[White Xmas]] = { "That's not snow..." },
        welcome_short2_stage2b --[[Loud - Plan B]] = {  },
        welcome_man --[[Undercover]] = { "IRS bad." },
        welcome_skm_watchdogs_stage2 --[[Holdout: Boat Load]] = {  },
        welcome_family --[[Diamond Store]] = {  },
    }
    local multi_heist_welcome_hints = {
        {
            ids = { "welcome_chca", "welcome_fish" },
            messages = { "I'm getting sea sick already..." }
        },
        {
            ids = { "welcome_jewelry_store", "welcome_ukrainian_job" },
            messages = { "Did you know this place was open since before World War II?" }
        },
    }
    InsertMessages(multi_heist_welcome_hints, "welcome")
    local shared_level_id = {
        welcome_to_the_jungle_1_night = "welcome_to_the_jungle_1",
        watchdogs_1_night = "watchdogs_1",
        watchdogs_2_day = "watchdogs_2",
        election_day_3_skip1 = "election_day_3",
        election_day_3_skip2 = "election_day_3",
        crojob3_night = "crojob3",

        arm_hcm = "arm",
        arm_und = "arm",
        arm_fac = "arm",
        arm_par = "arm",
        arm_cro = "arm",

        escape_garage = "escape",
        escape_overpass = "escape",
        escape_cafe = "escape",
        escape_park = "escape",
        escape_street = "escape",
        escape_cafe_day = "escape",
        escape_park_day = "escape",
        escape_overpass_night = "escape",

        safehouse = "testing_map",
        empty = "testing_map",
        enemy_test = "testing_map",
        modders_devmap = "testing_map"
    }
    if not Global.hint_weights.welcome_hint_modifiers then
        Global.hint_weights.welcome_hint_modifiers = {}
    end
    local level_id = shared_level_id[Global.game_settings.level_id] or Global.game_settings.level_id
    local is_testing_map = level_id == "testing_map"
    local hint_id = "welcome_" .. level_id
    if CustomHints.welcome[hint_id] and #CustomHints.welcome[hint_id] > 0 then
        local modifier = Global.hint_weights.welcome_hint_modifiers[hint_id] or 0
        local chance = #CustomHints.welcome[hint_id] / 20 + modifier
        if is_testing_map then
            chance = 0.05
        end
        --LogPrivateChat("Welcome hint chance is " .. chance * 100 .. "%. Modifier: +" .. modifier * 100 .. "%.")
        if math.random() < chance then
            --LogPrivateChat("Showing welcome hint...")
            DelayedCalls:Add("welcome_hint", 5, function()
                ShowHintCustom(hint_id, "welcome")
            end)
            Global.hint_weights.welcome_hint_modifiers[hint_id] = 0
        elseif not is_testing_map then
            local function increase_modifier()
                Global.hint_weights.welcome_hint_modifiers[hint_id] = modifier + 0.075
                modifier = Global.hint_weights.welcome_hint_modifiers[hint_id]
                --LogPrivateChat("Inceased modifier to " .. modifier * 100 .. "%.")
            end
            DelayedCalls:Add("welcome_hint_modifier1", 240, function()
                increase_modifier()
            end)
            DelayedCalls:Add("welcome_hint_modifier2", 1200, function()
                increase_modifier()
            end)
        end
    else
        LogPrivateChat("This heist has no welcome hint messages.")
    end

    on_heist_start_finished = true
end

CustomHints.effects = {
    hint_last_life_replenished_0 = { "That was close.", "Living on a razor's edge ain't fun.", "Aw, you took the suspense out!", "You're outta the danger zone.", "The bullets inside you disappear.", "All better now.", "Wow, you stitch fast!", "Almost dying is a risky move." },

    hint_last_life_replenished_1 = { "If you get out of custody, they also give you ammo.", "Are you done fucking around now?", "If you need it again, that'll be truly embarrassing.", "Come on, you really need this crutch?", "Real heisters don't use Doctor Bags." },

    hint_last_life_replenished_2 = { "You really need to up your game.", "You should use cover, not a Doctor Bag!", "Are you just not paying attention?", "Please tell me you're using a joke loadout.", "You're really dragging the team down.", "How are you getting downed this much?", "Are you hugging the enemies?", "At this point it's more cost effective for you to go into custody instead." },

    hint_easteregg = { "I'm wasting my breath on you.", "You're godawful. I'm leaving.", "I've seen enough of you. Goodbye." },

    hint_flash = { "SEGA", "You have a little private time with me now. :)", "I can hear a horse carriage.", "That's embarrassing.", "That's going in my cringe compilation.", "Right in the optics!", "That wasn't a nice present.", "There there. I'm here for you.", "You poor thing.", "Damn gas makes me cry.", "Just wear a blindfold.", "Look away from those.", "Think faster chucklenut.", "Your opinion, my choice.", "Get 'banged! That doesn't sound right...", "Isn't flashing someone illegal?", "My eyes!", "We'll be right back.", "A minor setback.", "They're so tacticool.", "They got you good.", "Pocket sand!", "You took the full brunt of that.", "You like eating flashes?", "It's possible to avoid getting flashed this badly, you know.", "That was avoidable.", "Did you not see that coming?", "How're you gonna know what you're aiming at like this?", ":(", "Well this sucks.", "Bang the flash before it bangs you.", "Just close your eyes, dumbass." }
}
InsertMessages({{ ids = { "hint_last_life_replenished_1" }, messages = CustomHints.effects.hint_last_life_replenished_0 }}, "effects")

local previous_last_life_state = false
local saved_by_doctorbag = 0
if not Global.doctorbag_overuse then
    Global.doctorbag_overuse = 0
end
Global.misplays = 0
LastLifeToCustody = false
Hooks:PostHook(CoreEnvironmentControllerManager, "set_last_life", "FunnyHints_last_life", function(self, last_life_effect)
    if previous_last_life_state and not last_life_effect and IsPlayerAlive() then
        if Global.game_settings.one_down then
            ShowHintCustom("hint_last_life_replenished_0", "effects")
        else
            saved_by_doctorbag = saved_by_doctorbag + 1
            Global.misplays = Global.misplays + 1
            if saved_by_doctorbag > 1 or Global.misplays > 1 then
                local infamy = managers.experience:current_rank()
                if infamy and infamy > 0 then
                    Global.doctorbag_overuse = Global.doctorbag_overuse + 1
                end
            end
            if saved_by_doctorbag > 3 or Global.doctorbag_overuse > 1 or Global.misplays > 2 then
                ShowHintCustom("hint_easteregg", "effects")
                Global.hint_easteregg = true
                managers.hud.show_hint = function(_)end

            elseif saved_by_doctorbag < 2 then -- 1 uses only
                ShowHintCustom("hint_last_life_replenished_1", "effects")

            elseif saved_by_doctorbag < 4 then -- 2 and 3 uses
                ShowHintCustom("hint_last_life_replenished_2", "effects")

            end
        end
    end

    if previous_last_life_state and not IsPlayerAlive() then
        LastLifeToCustody = true
    end

    previous_last_life_state = last_life_effect

    --This is here because set_last_life always gets set to false on heist start. making this an on heist start function.
    on_heist_start()
end)
Hooks:PostHook(CoreEnvironmentControllerManager, "set_flashbang", "FunnyHints_flash", function(self)
    local flash_strength = math.pow(math.min(self._current_flashbang, 1), 16) + math.min(self._current_flashbang_flash, 1)
    if flash_strength >= 2 then -- flash_strength 2 is max
        ShowHintCustom("hint_flash", "effects")
    end
end)