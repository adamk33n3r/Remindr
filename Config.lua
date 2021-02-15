local SOUNDS = {
    { name = 'Alarm 1', val = SOUNDKIT.ALARM_CLOCK_WARNING_1 },
    { name = 'Alarm 2', val = SOUNDKIT.ALARM_CLOCK_WARNING_2 },
    { name = 'Alarm 3', val = SOUNDKIT.ALARM_CLOCK_WARNING_3 },
    { name = 'Abandon Quest', val = SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST },
    { name = 'Quest Complete', val = SOUNDKIT.IG_QUEST_LIST_COMPLETE },
    { name = 'Player Invite', val = SOUNDKIT.IG_PLAYER_INVITE },
    { name = 'Auction Window Open', val = SOUNDKIT.AUCTION_WINDOW_OPEN },
    { name = 'Auction Window Close', val = SOUNDKIT.AUCTION_WINDOW_CLOSE },
    { name = 'Raid Warning', val = SOUNDKIT.RAID_WARNING },
    { name = 'Ready Check', val = SOUNDKIT.READY_CHECK },
    { name = 'Item Repair', val = SOUNDKIT.ITEM_REPAIR },
    -- PlaySoundFile("Sound\\Spells\\AbolishMagic.ogg")
    -- sound/spells/heal_low_base.ogg
}

local function HandleUpgrade(version)
    -- Upgrading from 1.0.0
    if RemindrDB.version == nil then
        local newDB = {}
        newDB.reminders = RemindrDB
        RemindrDB = newDB
        RemindrDB.version = version
    end
end

function CreateConfig(version)
    HandleUpgrade(version)

    RemindrDB.AlarmSound = RemindrDB.AlarmSound or SOUNDS[2].val

	local panel = CreateFrame("Frame", nil, UIParent)
	panel.name = 'Remindr'
	-- panel.okay = function (frame)frame.originalValue = MY_VARIABLE end    -- [[ When the player clicks okay, set the original value to the current setting ]] --
	-- panel.cancel = function (frame) MY_VARIABLE = frame.originalValue end    -- [[ When the player clicks cancel, set the current setting to the original value ]] --
    InterfaceOptions_AddCategory(panel)
    local function OnChangeSound(newSound)
        PlaySound(newSound)
        RemindrDB.AlarmSound = newSound
    end
    local soundOpts = {}
    local selected = nil
    for i, sound in ipairs(SOUNDS) do
        if RemindrDB.AlarmSound == sound.val then
            selected = i
        end
        table.insert(soundOpts, { name = sound.name, val = sound.val, func = OnChangeSound })
    end

	local TitleText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	TitleText:SetJustifyH("LEFT")
	TitleText:SetPoint("TOPLEFT", 16, -16)
	TitleText:SetText('Remindr')
	local TitleSubText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	TitleSubText:SetJustifyH("LEFT")
	TitleSubText:SetPoint("TOPLEFT", TitleText, 'BOTTOMLEFT', 0, -8)
	TitleSubText:SetText('These are general options for Remindr.')
	TitleSubText:SetTextColor(1,1,1,1) 
    
	local AlarmText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AlarmText:SetJustifyH("LEFT")
	AlarmText:SetPoint("TOPLEFT", TitleSubText, 'BOTTOMLEFT', 0, -8)
    AlarmText:SetText("Alarm Sound")

    local wrapper, dropdown = CreateDropdown(panel, AlarmText, soundOpts)
    UIDropDownMenu_SetSelectedID(dropdown, selected)
    CreateFrame("Button", "PlaySoundButton", panel, "GameMenuButtonTemplate")
	PlaySoundButton:SetWidth(64)
	-- PlaySoundButton:SetHeight(22)
    PlaySoundButton:SetPoint('TOPLEFT', dropdown, 'TOPRIGHT', 0, -4)
    PlaySoundButton:SetText('Play')
    PlaySoundButton:SetScript('OnClick', function(self, button)
        PlaySound(RemindrDB.AlarmSound or SOUNDS['Alarm 2'])
    end)

    -- local check = CreateCheck(panel, wrapper, 'tooltip', 'This is a checkbox')
    -- check.SetValue = function (self, val) print(val) end
    -- check = CreateCheck(panel, check, 'tooltip', 'This is a checkbox')
end

function CreateCheck(parent, prevRegion, tip, text)
	local check = CreateFrame("CheckButton", nil, parent, "OptionsCheckButtonTemplate")
	check:SetPoint("TOPLEFT", prevRegion, "BOTTOMLEFT", 0, 0)
	check.tooltipText = tip
	check.Text = check:CreateFontString(nil, "BACKGROUND","GameFontNormal")
	check.Text:SetPoint("LEFT", check, "RIGHT", 0)
	check.Text:SetText(text)
	return check
end

local selectedID = nil

function CreateDropdown(parent, prevRegion, opts)
    local wrapper = CreateFrame('Frame', nil, parent)
    wrapper:SetSize(1, 32)
    wrapper:SetPoint('TOPLEFT', prevRegion, 'BOTTOMLEFT')
    local dropDown = CreateFrame('Frame', nil, wrapper, 'UIDropDownMenuTemplate')
    dropDown:SetPoint('TOPLEFT', wrapper, 'TOPLEFT', -16, -4)
    UIDropDownMenu_SetWidth(dropDown, 156)
    UIDropDownMenu_SetButtonWidth(dropDown, 156 + 20)
    -- UIDropDownMenu_SetText(dropDown, "Audio: " .. favoriteNumber)

    local function OnSelect(cb)
        return function(self, newValue)
            selectedID = newValue
            if cb then
                cb(newValue)
            end
            UIDropDownMenu_SetSelectedID(dropDown, self:GetID())
            CloseDropDownMenus()
        end
    end

    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        -- Display a nested group of 10 favorite number options

        for i, opt in ipairs(opts) do
            info.text = opt.name
            info.func = OnSelect(opt.func)
            info.arg1 = opt.val
            info.checked = opt.selected
            UIDropDownMenu_AddButton(info, level)
        end

    end)

    return wrapper, dropDown
end
