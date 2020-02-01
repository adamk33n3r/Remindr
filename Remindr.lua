local name, _Remindr = ...;

local frame = CreateFrame("Frame")

local COLOR_MAIZE = "|cffffd700"
local COLOR_ORANGE = "|cffff8c00"
local COLOR_ERROR = "|cffee3333"
local COLOR_REMINDR = "|cff3bd0ed"

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
function frame:OnEvent(event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == "Remindr" then
        if RemindrDB == nil then
            RemindrDB = {}
        end
        local version = GetAddOnMetadata(name, "version")
        print(COLOR_REMINDR .. "<Remindr>|r Version " .. version .. " has been loaded!")
        print("    Use "..COLOR_MAIZE.."/remindr add|r to add a new reminder!")
        print("    Or use "..COLOR_MAIZE.."/remindr addr|r to add a repeating reminder!")
    end

    -- arg1: isInitialLogin, arg2: isReloadingUi
    if event == "PLAYER_ENTERING_WORLD" and arg1 then
        -- Reset the t variables to interval
        for name, obj in pairs(RemindrDB) do
            obj.t = obj.interval
        end
    end
end
frame:SetScript("OnEvent", frame.OnEvent);

frame:SetScript("OnUpdate", function(self, elapsed)
    for name, obj in pairs(RemindrDB) do
        obj.t = obj.t - elapsed
        if obj.t <= 0 then
            print(string.format(COLOR_REMINDR .. "<Remindr>|r %s", obj.msg))
            RaidNotice_AddMessage(RaidBossEmoteFrame, obj.msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
            PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2)
            if obj.recurring then
                obj.t = obj.interval
            else
                RemindrDB[name] = nil
            end
        end
    end
end)

SLASH_REMINDR1 = '/remindr'

function SlashCmdList.REMINDR(msg, editbox)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == "add" or cmd == "addr" then
        local isRecurring = cmd == "addr"
        if args ~= "" then
            local _, _, timerName, interval, msg = string.find(args, "(%w+)%s+(%d+)%s+(.*)")
            if timerName == "" or interval == "" or tonumber(interval) == nil or msg == "" then
                print(COLOR_ERROR .. "Syntax: /remindr add" .. (isRecurring and "r" or "") .. " <name> <minutes> <message>")
            else
                if RemindrDB[timerName] then
                    print(COLOR_ERROR .. "Reminder already exists with the name: " .. timerName)
                    return
                end
                local minutes = tonumber(interval)
                interval = interval * 60
                RemindrDB[timerName] = { interval=interval, msg=msg, recurring=isRecurring, t=interval }
                print("Successfully added reminder!")
                print(string.format("We will remind you %s %s minute%s to %s%s", isRecurring and "every" or "in", minutes, minutes == 1 and "" or "s", COLOR_MAIZE, msg))
            end
        else
            print(string.format(COLOR_ERROR .. "Syntax: /remindr add%s <name> <minutes> <message>", isRecurring and "r" or ""))
        end
    elseif cmd == "remove" then
        if args ~= "" then
            local _, _, timerName = string.find(args, "(%w+).*")
            if RemindrDB[timerName] then
                RemindrDB[timerName] = nil
                print("Successfully removed reminder!")
            else
                print(COLOR_ERROR .. "Couldn't find reminder with name: " .. timerName)
            end
        else
            print(COLOR_ERROR .. "Syntax: /remindr remove <name>") 
        end
    elseif cmd == "list" then
        count = 0
        for _ in pairs(RemindrDB) do count = count + 1 end
        if count == 0 then
            print("No current active reminders!")
        else
            print("Current active reminders:")
            for name, obj in pairs(RemindrDB) do
                local interval = obj.interval / 60;
                print(string.format("    [%s] Reminder %s %s minute%s to %s%s", name, obj.recurring and "every" or "in", interval, interval == 1 and "" or "s", COLOR_MAIZE, obj.msg))
            end
        end
    -- elseif cmd == "help" then
    else
        print("Available commands:")
        print("    /remindr add |cffaaaaaa<name> <minutes> <message>|r - Add reminder")
        print("    /remindr addr |cffaaaaaa<name> <minutes> <message>|r - Add repeating reminder")
        print("    /remindr remove |cffaaaaaa<name>|r - Remove reminder by name")
        print("    /remindr list - Show a list of active reminders")
        print("Examples:")
        print("    /remindr add |cffaaaaaahydrate 15 Take a drink of water!|r")
        print("    /remindr remove |cffaaaaaahydrate|r")
    end
end
