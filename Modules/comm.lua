--[[
  Usage so far:  MonDKP.Sync:SendData(prefix, core.WorkingTable)  --sends table through comm channel for updates
--]]

local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

MonDKP.Sync = LibStub("AceAddon-3.0"):NewAddon("MonDKP", "AceComm-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
--local LibCompress = LibStub:GetLi7brary("LibCompress")
--local LibCompressAddonEncodeTable = LibCompress:GetAddonEncodeTable()

function MonDKP:ValidateSender(sender) -- returns true if "sender" has permission to write officer notes. false if not or not found.
  local rankIndex = MonDKP:GetGuildRankIndex(sender);

  if rankIndex == 1 then -- automatically gives permissions above all settings if player is guild leader
    return true;
  end
  if #MonDKP_Whitelist > 0 then -- if a whitelist exists, checks that rather than officer note permissions
    for i = 1, #MonDKP_Whitelist do
      if MonDKP_Whitelist[i] == sender then
        return true;
      end
    end
    return false;
  else
    if rankIndex then
      return C_GuildInfo.GuildControlGetRankFlags(rankIndex)[12] -- returns true/false if player can write to officer notes
    else
      return false;
    end
  end
end

-------------------------------------------------
-- Register Broadcast Prefixs
-------------------------------------------------
function MonDKP.Sync:OnEnable()
  MonDKP.Sync:RegisterComm("MonDKPDelUsers", MonDKP.Sync:OnCommReceived()) -- Broadcasts deleted users (archived users not on the DKP table)
  MonDKP.Sync:RegisterComm("MonDKPMerge", MonDKP.Sync:OnCommReceived()) -- Broadcasts 2 weeks of data from officers (for merging)
  -- Normal broadcast Prefixs
  MonDKP.Sync:RegisterComm("MonDKPDecay", MonDKP.Sync:OnCommReceived()) -- Broadcasts a weekly decay adjustment
  MonDKP.Sync:RegisterComm("MonDKPBCastMsg", MonDKP.Sync:OnCommReceived()) -- broadcasts a message that is printed as is
  MonDKP.Sync:RegisterComm("MonDKPCommand", MonDKP.Sync:OnCommReceived()) -- broadcasts a command (ex. timers, bid timers, stop all timers etc.)
  MonDKP.Sync:RegisterComm("MonDKPLootDist", MonDKP.Sync:OnCommReceived()) -- broadcasts individual loot award to loot table
  MonDKP.Sync:RegisterComm("MonDKPDelLoot", MonDKP.Sync:OnCommReceived()) -- broadcasts deleted loot award entries
  MonDKP.Sync:RegisterComm("MonDKPDelSync", MonDKP.Sync:OnCommReceived()) -- broadcasts deleated DKP history entries
  MonDKP.Sync:RegisterComm("MonDKPDKPDist", MonDKP.Sync:OnCommReceived()) -- broadcasts individual DKP award to DKP history table
  MonDKP.Sync:RegisterComm("MonDKPMinBid", MonDKP.Sync:OnCommReceived()) -- broadcasts minimum dkp values (set in Options tab or custom values in bid window)
  MonDKP.Sync:RegisterComm("MonDKPMaxBid", MonDKP.Sync:OnCommReceived()) -- broadcasts maximum dkp values (set in Options tab or custom values in bid window)
  MonDKP.Sync:RegisterComm("MonDKPWhitelist", MonDKP.Sync:OnCommReceived()) -- broadcasts whitelist
  MonDKP.Sync:RegisterComm("MonDKPDKPModes", MonDKP.Sync:OnCommReceived()) -- broadcasts DKP Mode settings
  MonDKP.Sync:RegisterComm("MonDKPStand", MonDKP.Sync:OnCommReceived()) -- broadcasts standby list
  MonDKP.Sync:RegisterComm("MonDKPRaidTime", MonDKP.Sync:OnCommReceived()) -- broadcasts Raid Timer Commands
  MonDKP.Sync:RegisterComm("MonDKPZSumBank", MonDKP.Sync:OnCommReceived()) -- broadcasts ZeroSum Bank
  MonDKP.Sync:RegisterComm("MonDKPQuery", MonDKP.Sync:OnCommReceived()) -- Querys guild for spec/role data
  MonDKP.Sync:RegisterComm(MonDKP.SYNCMSG_BUILD, MonDKP.Sync:OnCommReceived()) -- broadcasts Addon build number to inform others an update is available.
  MonDKP.Sync:RegisterComm("MonDKPTalents", MonDKP.Sync:OnCommReceived()) -- broadcasts current spec
  MonDKP.Sync:RegisterComm("MonDKPRoles", MonDKP.Sync:OnCommReceived()) -- broadcasts current role info
  MonDKP.Sync:RegisterComm("MonDKPBossLoot", MonDKP.Sync:OnCommReceived()) -- broadcast current loot table
  MonDKP.Sync:RegisterComm("MonDKPBidShare", MonDKP.Sync:OnCommReceived()) -- broadcast accepted bids
  MonDKP.Sync:RegisterComm("MonDKPBidder", MonDKP.Sync:OnCommReceived()) -- Submit bids
  MonDKP.Sync:RegisterComm("MonDKPAllTabs", MonDKP.Sync:OnCommReceived()) -- Full table broadcast
  --MonDKP.Sync:RegisterComm("MonDKPEditLoot", MonDKP.Sync:OnCommReceived())    -- not in use
  --MonDKP.Sync:RegisterComm("MonDKPDataSync", MonDKP.Sync:OnCommReceived())    -- not in use
  --MonDKP.Sync:RegisterComm("MonDKPDKPLogSync", MonDKP.Sync:OnCommReceived())  -- not in use
  --MonDKP.Sync:RegisterComm("MonDKPLogSync", MonDKP.Sync:OnCommReceived())    -- not in use
end

local function OnCommReceived_MonDKPQuery(prefix, message, distribution, sender)
  -- set remote seed
  if sender ~= UnitName("player") and message ~= "start" then -- logs seed. Used to determine if the officer has entries required.
    local DKP, Loot = strsplit(",", message)
    local off1, date1 = strsplit("-", DKP)
    local off2, date2 = strsplit("-", Loot)

    if MonDKP:ValidateSender(off1) and MonDKP:ValidateSender(off2) and tonumber(date1) > MonDKP_DB.defaults.installed210 and tonumber(date2) > MonDKP_DB.defaults.installed210 then -- send only if posting officer validates and the post was made after 2.1s installation
      local search1 = MonDKP:Table_Search(MonDKP_DKPHistory, DKP, "index")
      local search2 = MonDKP:Table_Search(MonDKP_Loot, Loot, "index")

      if not search1 then
        MonDKP_DKPHistory.seed = DKP
      end
      if not search2 then
        MonDKP_Loot.seed = Loot
      end
    end
  end
  -- talents check
  local TalTrees = {}; table.insert(TalTrees, { GetTalentTabInfo(1) }); table.insert(TalTrees, { GetTalentTabInfo(2) }); table.insert(TalTrees, { GetTalentTabInfo(3) });
  local talBuild = "(" .. TalTrees[1][3] .. "/" .. TalTrees[2][3] .. "/" .. TalTrees[3][3] .. ")"
  local talRole;

  table.sort(TalTrees, function(a, b)
    return a[3] > b[3]
  end)

  talBuild = TalTrees[1][1] .. " " .. talBuild;
  talRole = TalTrees[1][4];

  MonDKP.Sync:SendData("MonDKPTalents", talBuild)
  MonDKP.Sync:SendData("MonDKPRoles", talRole)

  table.wipe(TalTrees);
  return;
end

local function OnCommReceived_MonDKPBidder(prefix, message, distribution, sender)
  if core.BidInProgress and core.IsOfficer then
    if message == "pass" then
      MonDKP.Print(sender .. " has passed.")
      return
    else
      MonDKP_CHAT_MSG_WHISPER(message, sender)
      return
    end
  else
    return
  end
end

local function OnCommReceived_MonDKPTalents(prefix, message, distribution, sender)
  local search = MonDKP:Table_Search(MonDKP_DKPTable, sender, "player")

  if search then
    local curSelection = MonDKP_DKPTable[search[1][1]]
    curSelection.spec = message;
  end
  return
end

local function OnCommReceived_MonDKPRoles(prefix, message, distribution, sender)
  local search = MonDKP:Table_Search(MonDKP_DKPTable, sender, "player")
  local curClass = "None";

  if search then
    local curSelection = MonDKP_DKPTable[search[1][1]]
    curClass = MonDKP_DKPTable[search[1][1]].class

    if curClass == "WARRIOR" then
      local a, b, c = strsplit("/", message)
      if strfind(message, "Protection") or (tonumber(c) and tonumber(strsub(c, 1, -2)) > 15) then
        curSelection.role = L["TANK"]
      else
        curSelection.role = L["MELEEDPS"]
      end
    elseif curClass == "PALADIN" then
      if strfind(message, "Protection") then
        curSelection.role = L["TANK"]
      elseif strfind(message, "Holy") then
        curSelection.role = L["HEALER"]
      else
        curSelection.role = L["MELEEDPS"]
      end
    elseif curClass == "HUNTER" then
      curSelection.role = L["RANGEDPS"]
    elseif curClass == "ROGUE" then
      curSelection.role = L["MELEEDPS"]
    elseif curClass == "PRIEST" then
      if strfind(message, "Shadow") then
        curSelection.role = L["CASTERDPS"]
      else
        curSelection.role = L["HEALER"]
      end
    elseif curClass == "SHAMAN" then
      if strfind(message, "Restoration") then
        curSelection.role = L["HEALER"]
      elseif strfind(message, "Elemental") then
        curSelection.role = L["CASTERDPS"]
      else
        curSelection.role = L["MELEEDPS"]
      end
    elseif curClass == "MAGE" then
      curSelection.role = L["CASTERDPS"]
    elseif curClass == "WARLOCK" then
      curSelection.role = L["CASTERDPS"]
    elseif curClass == "DRUID" then
      if strfind(message, "Feral") then
        curSelection.role = L["TANK"]
      elseif strfind(message, "Balance") then
        curSelection.role = L["CASTERDPS"]
      else
        curSelection.role = L["HEALER"]
      end
    else
      curSelection.role = L["NOROLEDETECTED"]
    end
  end
  return;
end

local function OnCommReceived_AxisBuildVersion(prefix, message, distribution, sender)
  local LastVerCheck = time() - core.LastVerCheck;

  if LastVerCheck > 3600 then -- limits the Out of Date message from firing more than every 1h
    if tonumber(message) > core.BuildNumber then
      core.LastVerCheck = time();
      MonDKP.Print(L["OUTOFDATEANNOUNCE"] .. ", have: " .. core.BuildNumber .. ", new: " .. message)
    end
  end

  if tonumber(message) < core.BuildNumber then -- returns build number if receiving party has a newer version
    MonDKP.Sync:SendData(MonDKP.SYNCMSG_BUILD, tostring(core.BuildNumber))
  end
  return;
end

local function OnCommReceived_MonDKPCommand_Officer(prefix, message, distribution, sender)
  local command, arg1, arg2, arg3, arg4 = strsplit(",", message);
  if sender ~= UnitName("player") then
    if command == "StartTimer" then
      MonDKP:StartTimer(arg1, arg2)
    elseif command == "StartBidTimer" then
      MonDKP:StartBidTimer(arg1, arg2, arg3)
      core.BiddingInProgress = true;
      if strfind(arg1, "{") then
        MonDKP.Print("Bid timer extended by " .. tonumber(strsub(arg1, strfind(arg1, "{") + 1)) .. " seconds.")
      end
    elseif command == "StopBidTimer" then
      if MonDKP.BidTimer then
        MonDKP.BidTimer:SetScript("OnUpdate", nil)
        MonDKP.BidTimer:Hide()
        core.BiddingInProgress = false;
      end
      if core.BidInterface and #core.BidInterface.LootTableButtons > 0 then
        for i = 1, #core.BidInterface.LootTableButtons do
          ActionButton_HideOverlayGlow(core.BidInterface.LootTableButtons[i])
        end
      end
      C_Timer.After(2, function()
        if core.BidInterface and core.BidInterface:IsShown() and not core.BiddingInProgress then
          core.BidInterface:Hide()
        end
      end)
    elseif command == "BidInfo" then
      if not core.BidInterface then
        core.BidInterface = core.BidInterface or MonDKP:BidInterface_Create() -- initiates bid window if it hasn't been created
      end
      if MonDKP_DB.defaults.AutoOpenBid and not core.BidInterface:IsShown() then -- toggles bid window if option is set to
        MonDKP:BidInterface_Toggle()
      end
      local subarg1, subarg2, subarg3, subarg4 = strsplit("#", arg1);
      MonDKP:CurrItem_Set(subarg1, subarg2, subarg3, subarg4) -- populates bid window
    end
  end
end

local function OnCommReceived_MonDKPRaidTime_Officer(prefix, message, distribution, sender)
  local command, args = strsplit(",", message);
  if command == "start" then
    local arg1, arg2, arg3, arg4, arg5, arg6 = strsplit(" ", args, 6)

    if arg1 == "true" then arg1 = true else arg1 = false end
    if arg4 == "true" then arg4 = true else arg4 = false end
    if arg5 == "true" then arg5 = true else arg5 = false end
    if arg6 == "true" then arg6 = true else arg6 = false end

    if arg2 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.interval:SetNumber(tonumber(arg2));
      MonDKP_DB.modes.increment = tonumber(arg2);
    end
    if arg3 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.bonusvalue:SetNumber(tonumber(arg3));
      MonDKP_DB.DKPBonus.IntervalBonus = tonumber(arg3);
    end
    if arg4 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.StartBonus:SetChecked(arg4);
      MonDKP_DB.DKPBonus.GiveRaidStart = arg4;
    end
    if arg5 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.EndRaidBonus:SetChecked(arg5);
      MonDKP_DB.DKPBonus.GiveRaidEnd = arg5;
    end
    if arg6 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.StandbyInclude:SetChecked(arg6);
      MonDKP_DB.DKPBonus.IncStandby = arg6;
    end

    MonDKP:StartRaidTimer(arg1)
  elseif command == "stop" then
    MonDKP:StopRaidTimer()
  elseif strfind(command, "sync", 1) then
    local _, syncTimer, syncSecondCount, syncMinuteCount, syncAward = strsplit(" ", command, 5)
    MonDKP:StartRaidTimer(nil, syncTimer, syncSecondCount, syncMinuteCount, syncAward)
    core.RaidInProgress = true
  end
end

local function OnCommReceived_Other_Officer(prefix, message, distribution, sender)
  local command, args = strsplit(",", message);
  if command == "start" then
    local arg1, arg2, arg3, arg4, arg5, arg6 = strsplit(" ", args, 6)

    if arg1 == "true" then arg1 = true else arg1 = false end
    if arg4 == "true" then arg4 = true else arg4 = false end
    if arg5 == "true" then arg5 = true else arg5 = false end
    if arg6 == "true" then arg6 = true else arg6 = false end

    if arg2 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.interval:SetNumber(tonumber(arg2));
      MonDKP_DB.modes.increment = tonumber(arg2);
    end
    if arg3 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.bonusvalue:SetNumber(tonumber(arg3));
      MonDKP_DB.DKPBonus.IntervalBonus = tonumber(arg3);
    end
    if arg4 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.StartBonus:SetChecked(arg4);
      MonDKP_DB.DKPBonus.GiveRaidStart = arg4;
    end
    if arg5 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.EndRaidBonus:SetChecked(arg5);
      MonDKP_DB.DKPBonus.GiveRaidEnd = arg5;
    end
    if arg6 ~= nil then
      MonDKP.ConfigTab2.RaidTimerContainer.StandbyInclude:SetChecked(arg6);
      MonDKP_DB.DKPBonus.IncStandby = arg6;
    end

    MonDKP:StartRaidTimer(arg1)
  elseif command == "stop" then
    MonDKP:StopRaidTimer()
  elseif strfind(command, "sync", 1) then
    local _, syncTimer, syncSecondCount, syncMinuteCount, syncAward = strsplit(" ", command, 5)
    MonDKP:StartRaidTimer(nil, syncTimer, syncSecondCount, syncMinuteCount, syncAward)
    core.RaidInProgress = true
  end
end

function MonDKP.Sync:OnCommReceived(prefix, message, distribution, sender)
  if not core.Initialized or core.IsOfficer == nil then return end
  if prefix then
    --if prefix ~= "MDKPProfile" then print("|cffff0000Received: "..prefix.." from "..sender.."|r") end
    if prefix == "MonDKPQuery" then
      return OnCommReceived_MonDKPQuery(prefix, message, distribution, sender);

    elseif prefix == "MonDKPBidder" then
      return OnCommReceived_MonDKPBidder(prefix, message, distribution, sender);

    elseif prefix == "MonDKPTalents" then
      return OnCommReceived_MonDKPTalents(prefix, message, distribution, sender);

    elseif prefix == "MonDKPRoles" then
      return OnCommReceived_MonDKPRoles(prefix, message, distribution, sender);

    elseif prefix == MonDKP.SYNCMSG_BUILD and sender ~= UnitName("player") then
      return OnCommReceived_AxisBuildVersion(prefix, message, distribution, sender);
    end

    -- validates sender as an officer. fail-safe to prevent addon alterations to manipulate DKP table
    if MonDKP:ValidateSender(sender) then
      if (prefix == "MonDKPBCastMsg") and sender ~= UnitName("player") then
        MonDKP.Print(message)

      elseif (prefix == "MonDKPCommand") then
        return OnCommReceived_MonDKPCommand_Officer(prefix, message, distribution, sender);

      elseif prefix == "MonDKPRaidTime" and
          sender ~= UnitName("player") and
          core.IsOfficer and MonDKP.ConfigTab2 then
        return OnCommReceived_MonDKPRaidTime_Officer(prefix, message, distribution, sender);
      end

      if (sender ~= UnitName("player")) then
        if prefix == "MonDKPLootDist" or prefix == "MonDKPDKPDist" or
            prefix == "MonDKPDelLoot" or prefix == "MonDKPDelSync" or
            prefix == "MonDKPMinBid" or prefix == "MonDKPWhitelist" or
            prefix == "MonDKPDKPModes" or prefix == "MonDKPStand" or
            prefix == "MonDKPZSumBank" or prefix == "MonDKPBossLoot" or
            prefix == "MonDKPDecay" or prefix == "MonDKPDelUsers" or
            prefix == "MonDKPAllTabs" or prefix == "MonDKPBidShare" or
            prefix == "MonDKPMerge" then
          return OnCommReceived_Other_Officer(prefix, message, distribution, sender);
        end
      end -- if not player
    end -- if validate sender
  end -- if prefix
end

function MonDKP.Sync:SendData(prefix, data, target)
  --if prefix ~= "MDKPProfile" then print("|cff00ff00Sent: "..prefix.."|r") end

  -- just in case, to prevent disconnects due to empty/nil string AddonMessages
  if data == nil or data == "" then data = " " end

  -- non officers / not encoded
  if IsInGuild() then
    if prefix == "MonDKPQuery" or
        prefix == MonDKP.SYNCMSG_BUILD or
        prefix == "MonDKPTalents" or 
        prefix == "MonDKPRoles" then
      MonDKP.Sync:SendCommMessage(prefix, data, "GUILD")
      return;

    elseif prefix == "MonDKPBidder" then -- bid submissions. Keep to raid.
      MonDKP.Sync:SendCommMessage(prefix, data, "RAID")
      return;
    end
  end

  -- officers
  if IsInGuild() and core.IsOfficer then
    local serialized;
    local packet;

    if prefix == "MonDKPCommand" or prefix == "MonDKPRaidTime" then
      MonDKP.Sync:SendCommMessage(prefix, data, "RAID")
      return;
    end

    if prefix == "MonDKPBCastMsg" then
      MonDKP.Sync:SendCommMessage(prefix, data, "GUILD")
      return;
    end

    if data then
      serialized = LibAceSerializer:Serialize(data); -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, { level = 9 })
    if compressed then
      packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end

    -- encoded
    if (prefix == "MonDKPZSumBank" or prefix == "MonDKPBossLoot" or prefix == "MonDKPBidShare") then -- Zero Sum bank/loot table/bid table data and bid submissions. Keep to raid.
      MonDKP.Sync:SendCommMessage(prefix, packet, "RAID")
      return;
    end

    if prefix == "MonDKPAllTabs" or prefix == "MonDKPMerge" then
      if target then
        MonDKP.Sync:SendCommMessage(prefix, packet, "WHISPER", target, "NORMAL", MonDKP_BroadcastFull_Callback, nil)
      else
        MonDKP.Sync:SendCommMessage(prefix, packet, "GUILD", nil, "NORMAL", MonDKP_BroadcastFull_Callback, nil)
      end
      return
    end

    if target then
      MonDKP.Sync:SendCommMessage(prefix, packet, "WHISPER", target)
    else
      MonDKP.Sync:SendCommMessage(prefix, packet, "GUILD")
    end
  end
end