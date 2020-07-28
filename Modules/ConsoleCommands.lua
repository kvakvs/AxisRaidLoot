local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

MonDKP.ConsoleCommands = {};

--- Invoked when user calls /dkp bid <...>
MonDKP.ConsoleCommands.Bid = function(...)
  if core.Initialized then
    local item = strjoin(" ", ...)
    local isOfficer = MonDKP:IsOfficer()

    MonDKP:StatusVerify_Update()

    if isOfficer then
      if ... == nil then
        MonDKP.ToggleBidWindow()
      else
        local itemName, _link, _rarity, _lvl, _minLvl, _type, _subtype, _stackCount, _equipLoc, itemIcon = GetItemInfo(item)
        MonDKP.Print("Opening Bid Window for: " .. item)
        MonDKP:ToggleBidWindow(item, itemIcon, itemName)
      end
    end
    MonDKP:BidInterface_Toggle()
  else
    MonDKP.Print("Monolith DKP has not completed initialization.")
  end
end

MonDKP.ConsoleCommands.Config = function(...)
  if core.Initialized then
    local pass, err = pcall(MonDKP.Toggle)

    if not pass then
      MonDKP.Print(err)
      core.MonDKPUI:SetShown(false)
      StaticPopupDialogs["SUGGEST_RELOAD"] = {
        text = "|CFFFF0000" .. L["WARNING"] .. "|r: " .. L["MUSTRELOADUI"],
        button1 = L["YES"],
        button2 = L["NO"],
        OnAccept = function()
          ReloadUI();
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("SUGGEST_RELOAD")
    end
  else
    MonDKP.Print("Monolith DKP has not completed initialization.")
  end
end

MonDKP.ConsoleCommands.RepairTables = function(...)
  local cmd = ...
  if core.IsOfficer then
    if cmd == "true" then
      MonDKP:RepairTables(cmd)
    else
      MonDKP:RepairTables()
    end
  end
end

MonDKP.ConsoleCommands.Award = function(name, ...)
  if core.IsOfficer and core.Initialized then
    MonDKP:StatusVerify_Update()

    if not name or not strfind(name, ":::::") then
      MonDKP.Print(L["AWARDWARNING"])
      return
    end
    local item = strjoin(" ", ...)
    if not item then return end
    item = name .. " " .. item;

    MonDKP:AwardConfirm(nil, 0, MonDKP_DB.bossargs.LastKilledBoss, MonDKP_DB.bossargs.CurrentRaidZone, item)
  else
    MonDKP.Print(L["NOPERMISSION"])
  end
end

MonDKP.ConsoleCommands.Lockouts = function(...)
  lockouts:RegisterEvent("UPDATE_INSTANCE_INFO");
  lockouts:SetScript("OnEvent", MonDKP_OnEvent);
  RequestRaidInfo()
end

MonDKP.ConsoleCommands.Timer = function(time, ...)
  if time == nil then
    MonDKP:BroadcastTimer(1, "...")
  else
    local title = strjoin(" ", ...)
    MonDKP:BroadcastTimer(tonumber(time), title)
  end
end

MonDKP.ConsoleCommands.Modes = function(...)
  if core.Initialized then
    if MonDKP.IsOfficer() then
      MonDKP:ToggleDKPModesWindow()
    else
      MonDKP.Print(L["NOPERMISSION"])
    end
  else
    MonDKP.Print("Monolith DKP has not completed initialization.")
  end
end

MonDKP.ConsoleCommands.Help = function()
  MonDKP.Print(" ");
  MonDKP.Print(L["SLASHCOMMANDLIST"] .. ":")
  MonDKP.Print("|cff00cc66/dkp|r - " .. L["DKPLAUNCH"]);
  MonDKP.Print("|cff00cc66/dkp ?|r - " .. L["HELPINFO"]);
  MonDKP.Print("|cff00cc66/dkp reset|r - " .. L["DKPRESETPOS"]);
  MonDKP.Print("|cff00cc66/dkp lockouts|r - " .. L["DKPLOCKOUT"]);
  MonDKP.Print("|cff00cc66/dkp timer|r - " .. L["CREATERAIDTIMER"]);
  MonDKP.Print("|cff00cc66/dkp bid|r - " .. L["OPENBIDWINDOWHELP"]);
  MonDKP.Print("|cff00cc66/dkp bid [itemlink]|r - " .. L["OPENAUCWINHELP"]);
  MonDKP.Print("|cff00cc66/dkp award [item link]|r - " .. L["DKPAWARDHELP"]);
  MonDKP.Print("|cff00cc66/dkp modes|r - " .. L["DKPMODESHELP"]);
  MonDKP.Print("|cff00cc66/dkp export|r - " .. L["DKPEXPORTHELP"]);
  MonDKP.Print(" ");
  MonDKP.Print(L["WHISPERCMDSHELP"]);
  MonDKP.Print("|cff00cc66!bid (or !bid <" .. L["VALUE"] .. ">)|r - " .. L["BIDHELP"]);
  MonDKP.Print("|cff00cc66!dkp (or !dkp <" .. L["PLAYERNAME"] .. ">)|r - " .. L["DKPCMDHELP"]);
end
