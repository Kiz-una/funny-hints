if not CustomHints.downed then
    CustomHints.downed = {
        name_tank_mini = { "I'm surprised you're still in one piece.", "You can't outsmart bullet.", "You've got quite a few holes in you...", "Nothing to be ashamed of. He just has the bigger gun.", "You're gonna need some serious plastic surgery.", "You think he's overcompensating for something?" },
        name_tank_hw = { "Spooky.", "He has no weakness!", "Scary.", "Horrifying.", "Frightening.", "Eerie.", "Can't shoot his head, can't shoot his back...", "You need absolute brute force.", "I can see his tounge...", "Disgusting creature." },
        name_hector_boss = { "Hector, how could you?", "You're supposed to kill the rat, not get killed by him!" },
        name_drug_lord_boss = { "Sosa made Sauce outta you." },
        name_swat_turret = { "You chose to get downed.", "That thing can't chase you.", "You weren't ready to take that thing on.", "Humanity is overrated.", "It did exactly what it was build for.", "It was pointed at you.", "Target eliminated.", "Hasta la vista, baby.", "Use more gun." },
        name_phalanx_vip = { "You got downed by that pussy?", "Shot by Captain Neville Winters himself? What an honor!", "That one was personal." },
        name_phalanx_minion = { "Can't he fuck off like his boss?", "He's not following the Captain's lead.", "His boss doesn't deserve him.", "He's not supposed to be an independent thinker!", "His boss bails on him and he just keeps fighting?", "Is he getting paid overtime for this?" },
        phalanx_formation = { "Dealing with those guys is so fun, isn't it?", "I hate those guys.", "Did they find these guys at a battle reenactment?", "I thought legionaries used spears not submachine guns.", "Ring around the rosie, a pocket full of posies.", "If I was you, I'd always bring a piercing gun to deal with these guys." },
        tag_dozer = { "You hit a wall.", "Fatman wins!", "Ouch.", "That guy hits hard!", "He's got the better armor.", "His confidence: justified.", "He's gonna brag about this.", "He's clearly the bigger man.", "You need a better plan than that next time.", "Come on, you're better than that man-child.", "BULLDOZER! :D", "You look like you got hit by a Truck.", "Tenderized.", "WAKEY WAKEY LITTLE BABY!" },
        tag_cloaker = { "He didn't even kick you!", "Cloakers shouldn't even have guns.", "Guess a bullet works just as well as a boot." },
        tag_taser = { "So much for non-lethal.", "Guess he had enough of your shit.", "He compromised his principles just for you." },
        tag_medic = { "You got downed by a nurse.", "He defintiely doesn't have healing bullets.", "What happened to \"do no harm\"?", "That guy didn't even come here to fight!", "Guess he's not a pacifist.", "You need a medic. How ironic.", "He's gonna have to heal you once they bring you in." },
        tag_sniper = { "Meet the Sniper.", "It's over. He has the high ground.", "He has a laser to let you find him easier.", "Tell him to face you like a man.", "Bullseye.", "Now that's a lot of damage!", "He's professional. You're amateurish.", "Does that count as working remotely?" },
        tag_marshalstun = { "My fucking eyes.", "At least he can stop now." },
        cuffed = { "What the fuck are you doing?", "...", "I lost some respect for you." },
        tased = { "Fried heister.", "Where are your teammates when you need them?", "Some friends you have." },
        tased_assist = { "Unfair.", "So much for non-lethal.", "I thought teamwork was our thing!", "You chose a bad place to get tased.", "That Tazer had support.", "That's one way to guarantee an easy target.", "Now that was underhanded." },
        SPOOCed = { "Nice reaction time.", "Show-off.", "Bully.", "You weren't ready for that!", "Too slow!", "It's your good old friend!", "Pay attention!", "Fuck.", "You'll get him next time.", "Happens to the best of us.", "Woof.", "You could have easily stopped him." },
        SPOOCed_kick = { "My condolences to your face.", "Let's hope you didn't get head trauma.", "Police brutality! Police brutality!", "I think your nose is crooked now.", "Not your beautiful face!", "Why are his kicks so harsh? Because of training.", "Come on, that kick was weak. Are you doing this for insurance money?" },
        SPOOCed_cuffed = { "Oh look, he brought a gift.", "I guess at least this hurts less.", "This is out of character.", "Look at him. He's already looking for the next one.", "Let's hope your friends are quicker." },
        fall_damage = { "Clumsy.", "You can't fly.", "Your poor legs.", "This is your own fault.", "Do I need to child-proof your jump button?", "I have a fear of heights. You could use it too." },

        hint_custody_visit = { "Right to jail.", "Do not pass go, do not collect $200.", "Now your teammates will have to pick up the slack." },
        hint_custody_visit_last_life = { "You ran out of chances.", "You're not a cat. You have many lives but not nine." },
    }
    InsertMessages({
        { ids = { "SPOOCed_cuffed" }, messages = CustomHints.downed.SPOOCed },
        { ids = { "hint_custody_visit_last_life" }, messages = { CustomHints.downed.hint_custody_visit } }
    }, "downed")
    InsertMessages({{ ids = { "SPOOCed" }, messages = CustomHints.downed.SPOOCed_kick }}, "downed")
end

if PlayerDamage then
    local boss_units = { "mobster_boss", "hector_boss", "biker_boss", "chavez_boss", "drug_lord_boss", "triad_boss", "deep_boss" }
    local tag_rules = {
        tag_dozer = { has = { "law", "tank" } },
        tag_cloaker = { has = { "spooc" } },
        tag_taser = { has = { "taser" } },
        tag_medic = { has = { "medic" }, lacks = { "tank" } },
        tag_sniper = { has = { "sniper" } },
        tag_marshalstun = { has = { "law", "special" }, lacks = { "medic", "sniper", "marksman", "shield", "tank", "spooc", "taser" } },
    }

    local pre_state = nil
    Hooks:PreHook(PlayerDamage, "_calc_health_damage", "funnyhints_damage_pre", function(self, attack_data)
        pre_state = self._unit:movement():current_state_name()
    end)

    Hooks:PostHook(PlayerDamage, "_calc_health_damage", "funnyhints_damage_post", function(self, attack_data)
        if pre_state ~= "bleed_out" and self._bleed_out and self._unit:alive() then
            if pre_state == "tased" then
                ShowHintCustom("tased_assist", "downed")
                return
            end

            local unit = attack_data.attacker_unit
            if not unit or not unit:alive() then
                LogPrivateChat("ERROR: Downed by an invalid unit: " .. tostring(unit))
                return
            end
            local unit_base = unit.base and unit:base()
            local unit_name = unit_base.char_tweak_name and unit_base:char_tweak_name()
            local unit_type = unit_base.get_type and unit_base:get_type()
            local attacker_name = unit_name or unit_type

            if attacker_name == "phalanx_minion" and Global.game_settings.gamemode == "crime_spree" then
                attacker_name = "phalanx_crime_spree"
            end

            if unit_name and unit_type then
                LogPrivateChat("Downed by a " .. unit_type .. " named " .. unit_name)
            else
                LogPrivateChat("Downed by " .. tostring(attacker_name))
            end

            if managers.hud._hud_assault_corner._assault_mode == "phalanx" and (attacker_name == "phalanx_minion" or attacker_name == "phalanx_vip") then
                ShowHintCustom("phalanx_formation", "downed")
            elseif attacker_name and CustomHints.downed["name_" .. attacker_name] then
                if boss_units[attacker_name] and math.random() < 0.5 then
                    --do nothing but don't return
                else
                    ShowHintCustom("name_" .. attacker_name, "downed")
                    return
                end
            elseif unit_base._tags then
                for hint_id, rules in pairs(tag_rules) do
                    if unit_base:has_all_tags(rules.has) and (not rules.lacks or not unit_base:has_any_tag(rules.lacks)) then
                        ShowHintCustom(hint_id, "downed")
                        return
                    end
                end
            end
        end
    end)

    Hooks:PreHook(PlayerDamage, "damage_fall", "funnyhints_damage_fall_pre", function(self)
        pre_state = self._unit:movement():current_state_name()
    end)

    Hooks:PostHook(PlayerDamage, "damage_fall", "funnyhints_damage_fall_post", function(self)
        if pre_state ~= "bleed_out" and self._bleed_out and self._unit:alive() then
            ShowHintCustom("fall_damage", "downed")
        end
    end)
end

if PlayerMovement then
    Hooks:PostHook(PlayerMovement, "on_cuffed", "funnyhints_cuffed", function(self)
        if self._current_state_name == "arrested" then
            ShowHintCustom("cuffed", "downed")
        end
    end)
    Hooks:PostHook(PlayerMovement, "on_SPOOCed", "funnyhints_SPOOCed", function(self)
        local state_ids = { arrested = "SPOOCed_cuffed", incapacitated = "SPOOCed" }
        local hint_id = state_ids[self._current_state_name]
        if hint_id and math.random() < 0.5 then
            ShowHintCustom(hint_id, "downed")
        end
    end)
    Hooks:PostHook(PlayerTased, "clbk_exit_to_fatal", "funnyhints_tased", function()
        ShowHintCustom("tased", "downed")
    end)
end

if PlayerManager then
    local custody_points = 0
    if not Global.custody_overvisits then
        Global.custody_overvisits = 0
    end
    Hooks:PostHook(PlayerManager, "on_enter_custody", "funnyhints_custody_post", function(self, _player, already_dead)
        if not already_dead then
            if LastLifeToCustody then
                LogPrivateChat("Triggered LastLifeToCustody.")
                custody_points = custody_points + 1
                Global.misplays = Global.misplays + 1
            end
            custody_points = custody_points + 1
            if custody_points > 2 or Global.misplays > 1 then
                local infamy = managers.experience:current_rank()
                if infamy and infamy > 0 then
                    Global.custody_overvisits = Global.custody_overvisits + 1
                end
            end
            if custody_points > 3 or Global.custody_overvisits > 1 or Global.misplays > 2 then
                ShowHintCustom("hint_easteregg", "effects")
                Global.hint_easteregg = true
                managers.hud.show_hint = function(_)end

            elseif LastLifeToCustody then
                ShowHintCustom("hint_custody_visit_last_life", "downed")
            else
                ShowHintCustom("hint_custody_visit", "downed")
            end
            LastLifeToCustody = false
        end
    end)
end