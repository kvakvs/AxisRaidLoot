local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

local curReason;

function MonDKP:AdjustDKP(value)
  local adjustReason = curReason;
  local curTime = time()
  local c;
  local curOfficer = UnitName("player")

  if not IsInRaid() then
    c = MonDKP:GetCColors();
  end

  if (curReason == L["OTHER"]) then
    adjustReason = L["OTHER"] .. " - " .. MonDKP.ConfigTab2.otherReason:GetText();
  end

  if curReason == L["BOSSKILLBONUS"] then
    adjustReason = core.CurrentRaidZone .. ": " .. core.LastKilledBoss;
  end

  if curReason == L["NEWBOSSKILLBONUS"] then
    adjustReason = core.CurrentRaidZone .. ": " .. core.LastKilledBoss .. " (" .. L["FIRSTKILL"] .. ")"
  end

  if (#core.SelectedData > 0 and adjustReason and adjustReason ~= L["OTHER"] .. " - " .. L["ENTEROTHERREASONHERE"]) then
    if core.IsOfficer then
      local tempString = ""; -- stores list of changes
      local dkpHistoryString = "" -- stores list for MonDKP_DKPHistory
      for i = 1, #core.SelectedData do
        local current;
        local search = MonDKP:Table_Search(MonDKP_DKPTable, core.SelectedData[i]["player"])
        if search then
          if not IsInRaid() then
            if i < #core.SelectedData then
              tempString = tempString .. "|cff" .. c[core.SelectedData[i]["class"]].hex .. core.SelectedData[i]["player"] .. "|r, ";
            else
              tempString = tempString .. "|cff" .. c[core.SelectedData[i]["class"]].hex .. core.SelectedData[i]["player"] .. "|r";
            end
          end
          dkpHistoryString = dkpHistoryString .. core.SelectedData[i]["player"] .. ","
          current = MonDKP_DKPTable[search[1][1]].dkp
          MonDKP_DKPTable[search[1][1]].dkp = MonDKP_round(tonumber(current + value), MonDKP_DB.modes.rounding)
          if value > 0 then
            MonDKP_DKPTable[search[1][1]]["lifetime_gained"] = MonDKP_round(tonumber(MonDKP_DKPTable[search[1][1]]["lifetime_gained"] + value), MonDKP_DB.modes.rounding)
          end
        end
      end
      local newIndex = curOfficer .. "-" .. curTime
      tinsert(MonDKP_DKPHistory, 1, { players = dkpHistoryString, dkp = value, reason = adjustReason, date = curTime, index = newIndex })
      MonDKP.Sync:SendData("MonDKPDKPDist", MonDKP_DKPHistory[1])

      if MonDKP.ConfigTab6.history and MonDKP.ConfigTab6:IsShown() then
        MonDKP:DKPHistory_Update(true)
      end
      DKPTable_Update()
      if IsInRaid() then
        MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDDKPADJUSTBY"] .. " " .. value .. " " .. L["FORREASON"] .. ": " .. adjustReason)
      else
        MonDKP.Sync:SendData("MonDKPBCastMsg", L["DKPADJUSTBY"] .. " " .. value .. " " .. L["FORPLAYERS"] .. ": ")
        MonDKP.Sync:SendData("MonDKPBCastMsg", tempString)
        MonDKP.Sync:SendData("MonDKPBCastMsg", L["REASON"] .. ": " .. adjustReason)
      end
    end
  else
    local validation;
    if (#core.SelectedData == 0 and not adjustReason) then
      validation = L["PLAYERREASONVALIDATE"]
    elseif #core.SelectedData == 0 then
      validation = L["PLAYERVALIDATE"]
    elseif not adjustReason or MonDKP.ConfigTab2.otherReason:GetText() == "" or MonDKP.ConfigTab2.otherReason:GetText() == L["ENTEROTHERREASONHERE"] then
      validation = L["OTHERREASONVALIDATE"]
    end

    StaticPopupDialogs["VALIDATION_PROMPT"] = {
      text = validation,
      button1 = L["OK"],
      timeout = 5,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("VALIDATION_PROMPT")
  end
end

local function DecayDKP(amount, deductionType, GetSelections)
  local playerString = "";
  local dkpString = "";
  local curTime = time()
  local curOfficer = UnitName("player")

  for key, value in ipairs(MonDKP_DKPTable) do
    local dkp = tonumber(value["dkp"])
    local player = value["player"]
    local amount = amount;
    amount = tonumber(amount) / 100 -- converts percentage to a decimal
    if amount < 0 then
      amount = amount * -1 -- flips value to positive if officer accidently used negative number in editbox
    end
    local deducted;

    if (GetSelections and MonDKP:Table_Search(core.SelectedData, player)) or GetSelections == false then
      if dkp > 0 then
        if deductionType == "percent" then
          deducted = dkp * amount
          dkp = dkp - deducted
          value["dkp"] = MonDKP_round(tonumber(dkp), MonDKP_DB.modes.rounding);
          dkpString = dkpString .. "-" .. MonDKP_round(deducted, MonDKP_DB.modes.rounding) .. ",";
          playerString = playerString .. player .. ",";
        elseif deductionType == "points" then
          -- do stuff for flat point deductions
        end
      elseif dkp < 0 and MonDKP.ConfigTab2.AddNegative:GetChecked() then
        if deductionType == "percent" then
          deducted = dkp * amount
          dkp = (deducted - dkp) * -1
          value["dkp"] = MonDKP_round(tonumber(dkp), MonDKP_DB.modes.rounding)
          dkpString = dkpString .. MonDKP_round(-deducted, MonDKP_DB.modes.rounding) .. ",";
          playerString = playerString .. player .. ",";
        elseif deductionType == "points" then
          -- do stuff for flat point deductions
        end
      end
    end
  end
  dkpString = dkpString .. "-" .. amount .. "%";

  if tonumber(amount) < 0 then amount = amount * -1 end -- flips value to positive if officer accidently used a negative number

  local newIndex = curOfficer .. "-" .. curTime
  tinsert(MonDKP_DKPHistory, 1, { players = playerString, dkp = dkpString, reason = L["WEEKLYDECAY"], date = curTime, index = newIndex })
  MonDKP.Sync:SendData("MonDKPDecay", MonDKP_DKPHistory[1])
  if MonDKP.ConfigTab6.history then
    MonDKP:DKPHistory_Update(true)
  end
  DKPTable_Update()
end

local function RaidTimerPopout_Create()
  if not MonDKP.RaidTimerPopout then
    local rtPop = CreateFrame("Frame", "MonDKP_RaidTimerPopout", UIParent, "ShadowOverlaySmallTemplate");
    MonDKP.RaidTimerPopout = rtPop

    rtPop:SetPoint("RIGHT", UIParent, "RIGHT", -300, 100);
    rtPop:SetSize(100, 50);
    rtPop:SetBackdrop({
      bgFile = "Textures\\white.blp",
      tile = true, -- White backdrop allows for black background with 1.0 alpha on low alpha containers
      edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile.tga",
      tile = true,
      tileSize = 1,
      edgeSize = 3,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    rtPop:SetBackdropColor(0, 0, 0, 0.9);
    rtPop:SetBackdropBorderColor(1, 1, 1, 1)
    rtPop:SetFrameStrata("DIALOG")
    rtPop:SetFrameLevel(15)
    rtPop:SetMovable(true);
    rtPop:EnableMouse(true);
    rtPop:RegisterForDrag("LeftButton");
    rtPop:SetScript("OnDragStart", rtPop.StartMoving);
    rtPop:SetScript("OnDragStop", rtPop.StopMovingOrSizing);

    -- Popout Close Button
    rtPop.closeContainer = CreateFrame("Frame", "MonDKPChangeLogClose", rtPop)
    rtPop.closeContainer:SetPoint("CENTER", rtPop, "TOPRIGHT", -8, -4)
    rtPop.closeContainer:SetBackdrop({
      bgFile = "Textures\\white.blp",
      tile = true,
      edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile.tga",
      tile = true,
      tileSize = 1,
      edgeSize = 3,
    });
    rtPop.closeContainer:SetBackdropColor(0, 0, 0, 0.9)
    rtPop.closeContainer:SetBackdropBorderColor(1, 1, 1, 0.2)
    rtPop.closeContainer:SetScale(0.7)
    rtPop.closeContainer:SetSize(28, 28)

    rtPop.closeBtn = CreateFrame("Button", nil, rtPop, "UIPanelCloseButton")
    rtPop.closeBtn:SetPoint("CENTER", rtPop.closeContainer, "TOPRIGHT", -14, -14)
    rtPop.closeBtn:SetScale(0.7)
    rtPop.closeBtn:HookScript("OnClick", function()
      MonDKP.ConfigTab2.RaidTimerContainer.PopOut:SetText(">");
    end)

    -- Raid Timer Output
    rtPop.Output = rtPop:CreateFontString(nil, "OVERLAY")
    rtPop.Output:SetFontObject("MonDKPLargeLeft");
    rtPop.Output:SetScale(0.8)
    rtPop.Output:SetPoint("CENTER", rtPop, "CENTER", 0, 0);
    rtPop.Output:SetText("|cff00ff0000:00:00|r")
    rtPop:Hide();
  else
    rtPop:Show()
  end
end

function MonDKP:AdjustDKPTab_Create()
  local adjustTab = MonDKP.ConfigTab2
  adjustTab.header = adjustTab:CreateFontString(nil, "OVERLAY")
  adjustTab.header:SetPoint("TOPLEFT", adjustTab, "TOPLEFT", 15, -10);
  adjustTab.header:SetFontObject("MonDKPLargeCenter")
  adjustTab.header:SetText(L["ADJUSTDKP"]);
  adjustTab.header:SetScale(1.2)

  adjustTab.description = adjustTab:CreateFontString(nil, "OVERLAY")
  adjustTab.description:SetPoint("TOPLEFT", adjustTab.header, "BOTTOMLEFT", 7, -10);
  adjustTab.description:SetWidth(400)
  adjustTab.description:SetFontObject("MonDKPNormalLeft")
  adjustTab.description:SetText(L["ADJUSTDESC"]);

  -- Reason DROPDOWN box
  -- Create the dropdown, and configure its appearance
  adjustTab.reasonDropDown = CreateFrame("FRAME", "MonDKPConfigReasonDropDown", adjustTab, "MonolithDKPUIDropDownMenuTemplate")
  adjustTab.reasonDropDown:SetPoint("TOPLEFT", adjustTab.description, "BOTTOMLEFT", -23, -60)
  UIDropDownMenu_SetWidth(adjustTab.reasonDropDown, 150)
  UIDropDownMenu_SetText(adjustTab.reasonDropDown, L["SELECTREASON"])

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(adjustTab.reasonDropDown, function(self, level, menuList)
    local reason = UIDropDownMenu_CreateInfo()
    reason.func = self.SetValue
    reason.fontObject = "MonDKPSmallCenter"
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["ONTIMEBONUS"], L["ONTIMEBONUS"], L["ONTIMEBONUS"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["BOSSKILLBONUS"], L["BOSSKILLBONUS"], L["BOSSKILLBONUS"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["RAIDCOMPLETIONBONUS"], L["RAIDCOMPLETIONBONUS"], L["RAIDCOMPLETIONBONUS"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["NEWBOSSKILLBONUS"], L["NEWBOSSKILLBONUS"], L["NEWBOSSKILLBONUS"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["CORRECTINGERROR"], L["CORRECTINGERROR"], L["CORRECTINGERROR"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["DKPADJUST"], L["DKPADJUST"], L["DKPADJUST"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["UNEXCUSEDABSENCE"], L["UNEXCUSEDABSENCE"], L["UNEXCUSEDABSENCE"] == curReason, true
    UIDropDownMenu_AddButton(reason)
    reason.text, reason.arg1, reason.checked, reason.isNotRadio = L["OTHER"], L["OTHER"], L["OTHER"] == curReason, true
    UIDropDownMenu_AddButton(reason)
  end)

  -- Dropdown Menu Function
  function MonDKP.ConfigTab2.reasonDropDown:SetValue(newValue)
    if curReason ~= newValue then curReason = newValue else curReason = nil end

    local adjustTab = MonDKP.ConfigTab2
    UIDropDownMenu_SetText(adjustTab.reasonDropDown, curReason)

    if (curReason == L["ONTIMEBONUS"]) then adjustTab.addDKP:SetNumber(MonDKP_DB.DKPBonus.OnTimeBonus); adjustTab.BossKilledDropdown:Hide()
    elseif (curReason == L["BOSSKILLBONUS"]) then
      adjustTab.addDKP:SetNumber(MonDKP_DB.DKPBonus.BossKillBonus);
      adjustTab.BossKilledDropdown:Show()
      UIDropDownMenu_SetText(adjustTab.BossKilledDropdown, core.CurrentRaidZone .. ": " .. core.LastKilledBoss)
    elseif (curReason == L["RAIDCOMPLETIONBONUS"]) then adjustTab.addDKP:SetNumber(MonDKP_DB.DKPBonus.CompletionBonus); adjustTab.BossKilledDropdown:Hide()
    elseif (curReason == L["NEWBOSSKILLBONUS"]) then
      adjustTab.addDKP:SetNumber(MonDKP_DB.DKPBonus.NewBossKillBonus);
      adjustTab.BossKilledDropdown:Show()
      UIDropDownMenu_SetText(adjustTab.BossKilledDropdown, core.CurrentRaidZone .. ": " .. core.LastKilledBoss)
    elseif (curReason == L["UNEXCUSEDABSENCE"]) then adjustTab.addDKP:SetNumber(MonDKP_DB.DKPBonus.UnexcusedAbsence); adjustTab.BossKilledDropdown:Hide()
    else adjustTab.addDKP:SetText(""); adjustTab.BossKilledDropdown:Hide()
    end

    if (curReason == L["OTHER"]) then
      adjustTab.otherReason:Show();
      adjustTab.BossKilledDropdown:Hide()
    else
      adjustTab.otherReason:Hide();
    end

    CloseDropDownMenus()
  end

  adjustTab.reasonDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["REASON"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["REASONTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["REASONTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.reasonDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.reasonHeader = adjustTab:CreateFontString(nil, "OVERLAY")
  adjustTab.reasonHeader:SetPoint("BOTTOMLEFT", adjustTab.reasonDropDown, "TOPLEFT", 25, 0);
  adjustTab.reasonHeader:SetFontObject("MonDKPSmallLeft")
  adjustTab.reasonHeader:SetText(L["REASONFORADJUSTMENT"] .. ":")

  -- Other Reason Editbox. Hidden unless "Other" is selected in dropdown
  adjustTab.otherReason = CreateFrame("EditBox", nil, adjustTab)
  adjustTab.otherReason:SetPoint("TOPLEFT", adjustTab.reasonDropDown, "BOTTOMLEFT", 19, 2)
  adjustTab.otherReason:SetAutoFocus(false)
  adjustTab.otherReason:SetMultiLine(false)
  adjustTab.otherReason:SetSize(225, 24)
  adjustTab.otherReason:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile.tga",
    tile = true,
    tileSize = 1,
    edgeSize = 3,
  });
  adjustTab.otherReason:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.otherReason:SetBackdropBorderColor(1, 1, 1, 0.6)
  adjustTab.otherReason:SetMaxLetters(50)
  adjustTab.otherReason:SetTextColor(0.4, 0.4, 0.4, 1)
  adjustTab.otherReason:SetFontObject("MonDKPNormalLeft")
  adjustTab.otherReason:SetTextInsets(10, 10, 5, 5)
  adjustTab.otherReason:SetText(L["ENTEROTHERREASONHERE"])
  adjustTab.otherReason:SetScript("OnEscapePressed", function(self) -- clears text and focus on esc
    self:ClearFocus()
  end)
  adjustTab.otherReason:SetScript("OnEditFocusGained", function(self)
    if (self:GetText() == L["ENTEROTHERREASONHERE"]) then
      self:SetText("");
      self:SetTextColor(1, 1, 1, 1)
    end
  end)
  adjustTab.otherReason:SetScript("OnEditFocusLost", function(self)
    if (self:GetText() == "") then
      self:SetText(L["ENTEROTHERREASONHERE"])
      self:SetTextColor(0.4, 0.4, 0.4, 1)
    end
  end)
  adjustTab.otherReason:Hide();

  -- Boss Killed Dropdown - Hidden unless "Boss Kill Bonus" or "New Boss Kill Bonus" is selected
  -- Killing a boss on the list will auto select that boss
  adjustTab.BossKilledDropdown = CreateFrame("FRAME", "MonDKPBossKilledDropdown", adjustTab, "MonolithDKPUIDropDownMenuTemplate")
  adjustTab.BossKilledDropdown:SetPoint("TOPLEFT", adjustTab.reasonDropDown, "BOTTOMLEFT", 0, 2)
  adjustTab.BossKilledDropdown:Hide()
  UIDropDownMenu_SetWidth(adjustTab.BossKilledDropdown, 210)
  UIDropDownMenu_SetText(adjustTab.BossKilledDropdown, L["SELECTBOSS"])

  UIDropDownMenu_Initialize(adjustTab.BossKilledDropdown, function(self, level, menuList)
    local boss = UIDropDownMenu_CreateInfo()
    boss.fontObject = "MonDKPSmallCenter"
    if (level or 1) == 1 then
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[1], core.CurrentRaidZone == core.ZoneList[1], "MC", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[2], core.CurrentRaidZone == core.ZoneList[2], "BWL", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[3], core.CurrentRaidZone == core.ZoneList[3], "AQ", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[4], core.CurrentRaidZone == core.ZoneList[4], "NAXX", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[7], core.CurrentRaidZone == core.ZoneList[7], "ONYXIA", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[5], core.CurrentRaidZone == core.ZoneList[5], "ZG", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[6], core.CurrentRaidZone == core.ZoneList[6], "AQ20", true
      UIDropDownMenu_AddButton(boss)
      boss.text, boss.checked, boss.menuList, boss.hasArrow = core.ZoneList[8], core.CurrentRaidZone == core.ZoneList[8], "WORLD", true
      UIDropDownMenu_AddButton(boss)
    else
      boss.func = self.SetValue
      for i = 1, #core.BossList[menuList] do
        boss.text, boss.arg1, boss.checked = core.BossList[menuList][i], core.EncounterList[menuList][i], core.BossList[menuList][i] == core.LastKilledBoss
        UIDropDownMenu_AddButton(boss, level)
      end
    end
  end)

  function MonDKP.ConfigTab2.BossKilledDropdown:SetValue(newValue)
    local search = MonDKP:Table_Search(core.EncounterList, newValue);

    if MonDKP:Table_Search(core.EncounterList.MC, newValue) then
      core.CurrentRaidZone = core.ZoneList[1]
    elseif MonDKP:Table_Search(core.EncounterList.BWL, newValue) then
      core.CurrentRaidZone = core.ZoneList[2]
    elseif MonDKP:Table_Search(core.EncounterList.AQ, newValue) then
      core.CurrentRaidZone = core.ZoneList[3]
    elseif MonDKP:Table_Search(core.EncounterList.NAXX, newValue) then
      core.CurrentRaidZone = core.ZoneList[4]
    elseif MonDKP:Table_Search(core.EncounterList.ZG, newValue) then
      core.CurrentRaidZone = core.ZoneList[5]
    elseif MonDKP:Table_Search(core.EncounterList.AQ20, newValue) then
      core.CurrentRaidZone = core.ZoneList[6]
    elseif MonDKP:Table_Search(core.EncounterList.ONYXIA, newValue) then
      core.CurrentRaidZone = core.ZoneList[7]
      --elseif MonDKP:Table_Search(core.EncounterList.WORLD, newValue) then 		-- encounter IDs not known yet
      --core.CurrentRaidZone = core.ZoneList[8]
    end

    if search then
      core.LastKilledBoss = core.BossList[search[1][1]][search[1][2]]
    else
      return;
    end

    MonDKP_DB.bossargs["LastKilledBoss"] = core.LastKilledBoss;
    MonDKP_DB.bossargs["CurrentRaidZone"] = core.CurrentRaidZone;

    if curReason ~= L["BOSSKILLBONUS"] and curReason ~= L["NEWBOSSKILLBONUS"] then
      MonDKP.ConfigTab2.reasonDropDown:SetValue(L["BOSSKILLBONUS"])
    end
    UIDropDownMenu_SetText(MonDKP.ConfigTab2.BossKilledDropdown, core.CurrentRaidZone .. ": " .. core.LastKilledBoss)
    CloseDropDownMenus()
  end

  -- Add DKP Edit Box
  adjustTab.addDKP = CreateFrame("EditBox", nil, adjustTab)
  adjustTab.addDKP:SetPoint("TOPLEFT", adjustTab.reasonDropDown, "BOTTOMLEFT", 20, -44)
  adjustTab.addDKP:SetAutoFocus(false)
  adjustTab.addDKP:SetMultiLine(false)
  adjustTab.addDKP:SetSize(100, 24)
  adjustTab.addDKP:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  adjustTab.addDKP:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.addDKP:SetBackdropBorderColor(1, 1, 1, 0.6)
  adjustTab.addDKP:SetMaxLetters(10)
  adjustTab.addDKP:SetTextColor(1, 1, 1, 1)
  adjustTab.addDKP:SetFontObject("MonDKPNormalRight")
  adjustTab.addDKP:SetTextInsets(10, 10, 5, 5)
  adjustTab.addDKP:SetScript("OnEscapePressed", function(self) -- clears text and focus on esc
    self:SetText("")
    self:ClearFocus()
  end)
  adjustTab.addDKP:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["POINTS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["POINTSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["POINTSTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.addDKP:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.pointsHeader = adjustTab:CreateFontString(nil, "OVERLAY")
  adjustTab.pointsHeader:SetFontObject("GameFontHighlightLeft");
  adjustTab.pointsHeader:SetPoint("BOTTOMLEFT", adjustTab.addDKP, "TOPLEFT", 3, 3);
  adjustTab.pointsHeader:SetFontObject("MonDKPSmallLeft")
  adjustTab.pointsHeader:SetText(L["POINTS"] .. ":")

  -- Raid Only Checkbox
  adjustTab.RaidOnlyCheck = CreateFrame("CheckButton", nil, adjustTab, "UICheckButtonTemplate");
  adjustTab.RaidOnlyCheck:SetChecked(false)
  adjustTab.RaidOnlyCheck:SetScale(0.6);
  adjustTab.RaidOnlyCheck.text:SetText("  |cff999999Show Raid Only|r");
  adjustTab.RaidOnlyCheck.text:SetScale(1.5);
  adjustTab.RaidOnlyCheck.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.RaidOnlyCheck:SetPoint("LEFT", adjustTab.addDKP, "RIGHT", 15, 13);
  adjustTab.RaidOnlyCheck:Hide()


  -- Select All Checkbox
  adjustTab.selectAll = CreateFrame("CheckButton", nil, adjustTab, "UICheckButtonTemplate");
  adjustTab.selectAll:SetChecked(false)
  adjustTab.selectAll:SetScale(0.6);
  adjustTab.selectAll.text:SetText("  |cff999999" .. L["SELECTALLVISIBLE"] .. "|r");
  adjustTab.selectAll.text:SetScale(1.5);
  adjustTab.selectAll.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.selectAll:SetPoint("LEFT", adjustTab.addDKP, "RIGHT", 15, -13);
  adjustTab.selectAll:Hide();


  -- Adjust DKP Button
  adjustTab.adjustButton = self:CreateButton("TOPLEFT", adjustTab.addDKP, "BOTTOMLEFT", -1, -15, L["ADJUSTDKP"]);
  adjustTab.adjustButton:SetSize(90, 25)
  adjustTab.adjustButton:SetScript("OnClick", function()
    if #core.SelectedData > 0 and curReason and MonDKP.ConfigTab2.otherReason:GetText() then
      local selected = L["AREYOUSURE"] .. " " .. MonDKP_round(MonDKP.ConfigTab2.addDKP:GetNumber(), MonDKP_DB.modes.rounding) .. " " .. L["DKPTOFOLLOWING"] .. ": \n\n";

      for i = 1, #core.SelectedData do
        local classSearch = MonDKP:Table_Search(MonDKP_DKPTable, core.SelectedData[i].player)

        if classSearch then
          c = MonDKP:GetCColors(MonDKP_DKPTable[classSearch[1][1]].class)
        else
          c = { hex = "ffffff" }
        end
        if i == 1 then
          selected = selected .. "|cff" .. c.hex .. core.SelectedData[i].player .. "|r"
        else
          selected = selected .. ", |cff" .. c.hex .. core.SelectedData[i].player .. "|r"
        end
      end
      StaticPopupDialogs["ADJUST_DKP"] = {
        text = selected,
        button1 = L["YES"],
        button2 = L["NO"],
        OnAccept = function()
          MonDKP:AdjustDKP(MonDKP.ConfigTab2.addDKP:GetNumber())
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("ADJUST_DKP")
    else
      MonDKP:AdjustDKP(MonDKP.ConfigTab2.addDKP:GetNumber());
    end
  end)
  adjustTab.adjustButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ADJUSTDKP"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ADJUSTDKPTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["ADJUSTDKPTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.adjustButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- weekly decay Editbox
  adjustTab.decayDKP = CreateFrame("EditBox", nil, adjustTab)
  adjustTab.decayDKP:SetPoint("BOTTOMLEFT", adjustTab, "BOTTOMLEFT", 21, 70)
  adjustTab.decayDKP:SetAutoFocus(false)
  adjustTab.decayDKP:SetMultiLine(false)
  adjustTab.decayDKP:SetSize(100, 24)
  adjustTab.decayDKP:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  adjustTab.decayDKP:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.decayDKP:SetBackdropBorderColor(1, 1, 1, 0.6)
  adjustTab.decayDKP:SetMaxLetters(4)
  adjustTab.decayDKP:SetTextColor(1, 1, 1, 1)
  adjustTab.decayDKP:SetFontObject("MonDKPNormalRight")
  adjustTab.decayDKP:SetTextInsets(10, 15, 5, 5)
  adjustTab.decayDKP:SetNumber(tonumber(MonDKP_DB.DKPBonus.DecayPercentage))
  adjustTab.decayDKP:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)

  adjustTab.decayDKP:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["WEEKLYDKPDECAY"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["WEEKLYDECAYTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["WEEKLYDECAYTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.decayDKP:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.decayDKPHeader = adjustTab:CreateFontString(nil, "OVERLAY")
  adjustTab.decayDKPHeader:SetFontObject("GameFontHighlightLeft");
  adjustTab.decayDKPHeader:SetPoint("BOTTOMLEFT", adjustTab.decayDKP, "TOPLEFT", 3, 3);
  adjustTab.decayDKPHeader:SetFontObject("MonDKPSmallLeft")
  adjustTab.decayDKPHeader:SetText(L["WEEKLYDKPDECAY"] .. ":")

  adjustTab.decayDKPFooter = adjustTab.decayDKP:CreateFontString(nil, "OVERLAY")
  adjustTab.decayDKPFooter:SetFontObject("MonDKPNormalLeft");
  adjustTab.decayDKPFooter:SetPoint("LEFT", adjustTab.decayDKP, "RIGHT", -15, 0);
  adjustTab.decayDKPFooter:SetText("%")

  -- selected players only checkbox
  adjustTab.SelectedOnlyCheck = CreateFrame("CheckButton", nil, adjustTab, "UICheckButtonTemplate");
  adjustTab.SelectedOnlyCheck:SetChecked(false)
  adjustTab.SelectedOnlyCheck:SetScale(0.6);
  adjustTab.SelectedOnlyCheck.text:SetText("  |cff999999" .. L["SELPLAYERSONLY"] .. "|r");
  adjustTab.SelectedOnlyCheck.text:SetScale(1.5);
  adjustTab.SelectedOnlyCheck.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.SelectedOnlyCheck:SetPoint("TOP", adjustTab.decayDKP, "BOTTOMLEFT", 15, -13);
  adjustTab.SelectedOnlyCheck:SetScript("OnClick", function(self)
    PlaySound(808)
  end)
  adjustTab.SelectedOnlyCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["SELPLAYERSONLY"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["SELPLAYERSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["SELPLAYERSTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.SelectedOnlyCheck:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- add to negative dkp checkbox
  adjustTab.AddNegative = CreateFrame("CheckButton", nil, adjustTab, "UICheckButtonTemplate");
  adjustTab.AddNegative:SetChecked(MonDKP_DB.modes.AddToNegative)
  adjustTab.AddNegative:SetScale(0.6);
  adjustTab.AddNegative.text:SetText("  |cff999999" .. L["ADDNEGVALUES"] .. "|r");
  adjustTab.AddNegative.text:SetScale(1.5);
  adjustTab.AddNegative.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.AddNegative:SetPoint("TOP", adjustTab.SelectedOnlyCheck, "BOTTOM", 0, 0);
  adjustTab.AddNegative:SetScript("OnClick", function(self)
    MonDKP_DB.modes.AddToNegative = self:GetChecked();
    PlaySound(808)
  end)
  adjustTab.AddNegative:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ADDNEGVALUES"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ADDNEGTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["ADDNEGTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.AddNegative:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.decayButton = self:CreateButton("TOPLEFT", adjustTab.decayDKP, "TOPRIGHT", 20, 0, L["APPLYDECAY"]);
  adjustTab.decayButton:SetSize(90, 25)
  adjustTab.decayButton:SetScript("OnClick", function()
    local SelectedToggle;
    local selected;

    if MonDKP.ConfigTab2.SelectedOnlyCheck:GetChecked() then SelectedToggle = "|cffff0000" .. L["SELECTED"] .. "|r" else SelectedToggle = "|cffff0000" .. L["ALL"] .. "|r" end
    selected = L["CONFIRMDECAY"] .. " " .. SelectedToggle .. " " .. L["DKPENTRIESBY"] .. " " .. MonDKP.ConfigTab2.decayDKP:GetNumber() .. "%%";

    StaticPopupDialogs["ADJUST_DKP"] = {
      text = selected,
      button1 = L["YES"],
      button2 = L["NO"],
      OnAccept = function()
        DecayDKP(MonDKP.ConfigTab2.decayDKP:GetNumber(), "percent", MonDKP.ConfigTab2.SelectedOnlyCheck:GetChecked())
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("ADJUST_DKP")
  end)
  adjustTab.decayButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["WEEKLYDKPDECAY"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["APPDECAYTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["APPDECAYTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.decayButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Raid Timer Container
  adjustTab.RaidTimerContainer = CreateFrame("Frame", nil, adjustTab);
  adjustTab.RaidTimerContainer:SetSize(200, 360);
  adjustTab.RaidTimerContainer:SetPoint("RIGHT", adjustTab, "RIGHT", -25, -60)
  adjustTab.RaidTimerContainer:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  adjustTab.RaidTimerContainer:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.RaidTimerContainer:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)

  -- Pop out button
  adjustTab.RaidTimerContainer.PopOut = CreateFrame("Button", nil, adjustTab, "UIMenuButtonStretchTemplate")
  adjustTab.RaidTimerContainer.PopOut:SetPoint("TOPRIGHT", adjustTab.RaidTimerContainer, "TOPRIGHT", -5, -5)
  adjustTab.RaidTimerContainer.PopOut:SetHeight(22)
  adjustTab.RaidTimerContainer.PopOut:SetWidth(18)
  adjustTab.RaidTimerContainer.PopOut:SetNormalFontObject("MonDKPLargeCenter")
  adjustTab.RaidTimerContainer.PopOut:SetHighlightFontObject("MonDKPLargeCenter")
  adjustTab.RaidTimerContainer.PopOut:GetFontString():SetTextColor(0, 0.3, 0.7, 1)
  adjustTab.RaidTimerContainer.PopOut:SetScale(1.2)
  adjustTab.RaidTimerContainer.PopOut:SetFrameStrata("DIALOG")
  adjustTab.RaidTimerContainer.PopOut:SetFrameLevel(15)
  adjustTab.RaidTimerContainer.PopOut:SetText(">")
  adjustTab.RaidTimerContainer.PopOut:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["POPOUTTIMER"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["POPOUTTIMERDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.PopOut:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
  end)
  adjustTab.RaidTimerContainer.PopOut:SetScript("OnClick", function(self)
    if self:GetText() == ">" then
      self:SetText("<");
      RaidTimerPopout_Create()
    else
      self:SetText(">");
      MonDKP.RaidTimerPopout:Hide();
    end
  end)

  -- Raid Timer Header
  adjustTab.RaidTimerContainer.Header = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.Header:SetFontObject("MonDKPLargeLeft");
  adjustTab.RaidTimerContainer.Header:SetScale(0.6)
  adjustTab.RaidTimerContainer.Header:SetPoint("TOPLEFT", adjustTab.RaidTimerContainer, "TOPLEFT", 15, -15);
  adjustTab.RaidTimerContainer.Header:SetText(L["RAIDTIMER"])

  -- Raid Timer Output Header
  adjustTab.RaidTimerContainer.OutputHeader = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.OutputHeader:SetFontObject("MonDKPNormalRight");
  adjustTab.RaidTimerContainer.OutputHeader:SetPoint("TOP", adjustTab.RaidTimerContainer, "TOP", -20, -40);
  adjustTab.RaidTimerContainer.OutputHeader:SetText(L["TIMEELAPSED"] .. ":")
  adjustTab.RaidTimerContainer.OutputHeader:Hide();

  -- Raid Timer Output
  adjustTab.RaidTimerContainer.Output = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.Output:SetFontObject("MonDKPLargeLeft");
  adjustTab.RaidTimerContainer.Output:SetScale(0.8)
  adjustTab.RaidTimerContainer.Output:SetPoint("LEFT", adjustTab.RaidTimerContainer.OutputHeader, "RIGHT", 5, 0);

  -- Bonus Awarded Header
  adjustTab.RaidTimerContainer.BonusHeader = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.BonusHeader:SetFontObject("MonDKPNormalRight");
  adjustTab.RaidTimerContainer.BonusHeader:SetPoint("TOP", adjustTab.RaidTimerContainer, "TOP", -15, -60);
  adjustTab.RaidTimerContainer.BonusHeader:SetText(L["BONUSAWARDED"] .. ":")
  adjustTab.RaidTimerContainer.BonusHeader:Hide();

  -- Bonus Awarded Output
  adjustTab.RaidTimerContainer.Bonus = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.Bonus:SetFontObject("MonDKPLargeLeft");
  adjustTab.RaidTimerContainer.Bonus:SetScale(0.8)
  adjustTab.RaidTimerContainer.Bonus:SetPoint("LEFT", adjustTab.RaidTimerContainer.BonusHeader, "RIGHT", 5, 0);

  -- Start Raid Timer Button
  adjustTab.RaidTimerContainer.StartTimer = self:CreateButton("BOTTOMLEFT", adjustTab.RaidTimerContainer, "BOTTOMLEFT", 10, 135, L["INITRAID"]);
  adjustTab.RaidTimerContainer.StartTimer:SetSize(90, 25)
  adjustTab.RaidTimerContainer.StartTimer:SetScript("OnClick", function(self)
    if not IsInRaid() then
      StaticPopupDialogs["NO_RAID_TIMER"] = {
        text = L["NOTINRAID"],
        button1 = L["OK"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("NO_RAID_TIMER")
      return;
    end
    if not core.RaidInProgress then
      if MonDKP_DB.DKPBonus.GiveRaidStart and self:GetText() ~= L["CONTINUERAID"] then
        StaticPopupDialogs["START_RAID_BONUS"] = {
          text = L["RAIDTIMERBONUSCONFIRM"],
          button1 = L["YES"],
          button2 = L["NO"],
          OnAccept = function()
            local setInterval = adjustTab.RaidTimerContainer.interval:GetNumber();
            local setBonus = adjustTab.RaidTimerContainer.bonusvalue:GetNumber();
            local setOnTime = tostring(adjustTab.RaidTimerContainer.StartBonus:GetChecked());
            local setGiveEnd = tostring(adjustTab.RaidTimerContainer.EndRaidBonus:GetChecked());
            local setStandby = tostring(adjustTab.RaidTimerContainer.StandbyInclude:GetChecked());
            MonDKP.Sync:SendData("MonDKPRaidTime", "start,false " .. setInterval .. " " .. setBonus .. " " .. setOnTime .. " " .. setGiveEnd .. " " .. setStandby)
            if adjustTab.RaidTimerContainer.StartTimer:GetText() == L["CONTINUERAID"] then
              MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDRESUME"])
            else
              MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDSTART"])
              adjustTab.RaidTimerContainer.Output:SetText("|cff00ff0000|r")
            end
            MonDKP:StartRaidTimer(false)
          end,
          timeout = 0,
          whileDead = true,
          hideOnEscape = true,
          preferredIndex = 3,
        }
        StaticPopup_Show("START_RAID_BONUS")
      else
        local setInterval = adjustTab.RaidTimerContainer.interval:GetNumber();
        local setBonus = adjustTab.RaidTimerContainer.bonusvalue:GetNumber();
        local setOnTime = tostring(adjustTab.RaidTimerContainer.StartBonus:GetChecked());
        local setGiveEnd = tostring(adjustTab.RaidTimerContainer.EndRaidBonus:GetChecked());
        local setStandby = tostring(adjustTab.RaidTimerContainer.StandbyInclude:GetChecked());
        MonDKP.Sync:SendData("MonDKPRaidTime", "start,false " .. setInterval .. " " .. setBonus .. " " .. setOnTime .. " " .. setGiveEnd .. " " .. setStandby)
        if adjustTab.RaidTimerContainer.StartTimer:GetText() == L["CONTINUERAID"] then
          MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDRESUME"])
        else
          MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDSTART"])
          adjustTab.RaidTimerContainer.Output:SetText("|cff00ff0000|r")
        end
        MonDKP:StartRaidTimer(false)
      end
    else
      StaticPopupDialogs["END_RAID"] = {
        text = L["ENDCURRAIDCONFIRM"],
        button1 = L["YES"],
        button2 = L["NO"],
        OnAccept = function()
          MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDTIMERCONCLUDE"] .. " " .. adjustTab.RaidTimerContainer.Output:GetText() .. "!")
          MonDKP.Sync:SendData("MonDKPRaidTime", "stop")
          MonDKP:StopRaidTimer()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("END_RAID")
    end
  end)
  adjustTab.RaidTimerContainer.StartTimer:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["INITRAID"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["INITRAIDTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["INITRAIDTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.StartTimer:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Pause Raid Timer Button
  adjustTab.RaidTimerContainer.PauseTimer = self:CreateButton("BOTTOMRIGHT", adjustTab.RaidTimerContainer, "BOTTOMRIGHT", -10, 135, L["PAUSERAID"]);
  adjustTab.RaidTimerContainer.PauseTimer:SetSize(90, 25)
  adjustTab.RaidTimerContainer.PauseTimer:Hide();
  adjustTab.RaidTimerContainer.PauseTimer:SetScript("OnClick", function(self)
    if core.RaidInProgress then
      local setInterval = adjustTab.RaidTimerContainer.interval:GetNumber();
      local setBonus = adjustTab.RaidTimerContainer.bonusvalue:GetNumber();
      local setOnTime = tostring(adjustTab.RaidTimerContainer.StartBonus:GetChecked());
      local setGiveEnd = tostring(adjustTab.RaidTimerContainer.EndRaidBonus:GetChecked());
      local setStandby = tostring(adjustTab.RaidTimerContainer.StandbyInclude:GetChecked());

      MonDKP.Sync:SendData("MonDKPRaidTime", "start,true " .. setInterval .. " " .. setBonus .. " " .. setOnTime .. " " .. setGiveEnd .. " " .. setStandby)
      MonDKP.Sync:SendData("MonDKPBCastMsg", L["RAIDPAUSE"] .. " " .. adjustTab.RaidTimerContainer.Output:GetText() .. "!")
      MonDKP:StartRaidTimer(true)
    end
  end)
  adjustTab.RaidTimerContainer.PauseTimer:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["PAUSERAID"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["PAUSERAIDTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["PAUSERAIDTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.PauseTimer:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Award Interval Editbox
  if not MonDKP_DB.modes.increment then MonDKP_DB.modes.increment = 60 end
  adjustTab.RaidTimerContainer.interval = CreateFrame("EditBox", nil, adjustTab.RaidTimerContainer)
  adjustTab.RaidTimerContainer.interval:SetPoint("BOTTOMLEFT", adjustTab.RaidTimerContainer, "BOTTOMLEFT", 35, 225)
  adjustTab.RaidTimerContainer.interval:SetAutoFocus(false)
  adjustTab.RaidTimerContainer.interval:SetMultiLine(false)
  adjustTab.RaidTimerContainer.interval:SetSize(60, 24)
  adjustTab.RaidTimerContainer.interval:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  adjustTab.RaidTimerContainer.interval:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.RaidTimerContainer.interval:SetBackdropBorderColor(1, 1, 1, 0.6)
  adjustTab.RaidTimerContainer.interval:SetMaxLetters(5)
  adjustTab.RaidTimerContainer.interval:SetTextColor(1, 1, 1, 1)
  adjustTab.RaidTimerContainer.interval:SetFontObject("MonDKPSmallRight")
  adjustTab.RaidTimerContainer.interval:SetTextInsets(10, 15, 5, 5)
  adjustTab.RaidTimerContainer.interval:SetNumber(tonumber(MonDKP_DB.modes.increment))
  adjustTab.RaidTimerContainer.interval:SetScript("OnTextChanged", function(self) -- clears focus on esc
    if tonumber(self:GetNumber()) then
      MonDKP_DB.modes.increment = self:GetNumber();
    else
      StaticPopupDialogs["ALERT_NUMBER"] = {
        text = L["INCREMENTINVALIDWARN"],
        button1 = L["OK"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("ALERT_NUMBER")
    end
  end)
  adjustTab.RaidTimerContainer.interval:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    self:ClearFocus()
  end)
  adjustTab.RaidTimerContainer.interval:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    self:ClearFocus()
  end)
  adjustTab.RaidTimerContainer.interval:SetScript("OnTabPressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    adjustTab.RaidTimerContainer.bonusvalue:SetFocus()
    adjustTab.RaidTimerContainer.bonusvalue:HighlightText()
  end)

  adjustTab.RaidTimerContainer.interval:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["AWARDINTERVAL"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["AWARDINTERVALTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["AWARDINTERVALTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.interval:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.RaidTimerContainer.intervalHeader = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.intervalHeader:SetFontObject("MonDKPTinyRight");
  adjustTab.RaidTimerContainer.intervalHeader:SetPoint("BOTTOMLEFT", adjustTab.RaidTimerContainer.interval, "TOPLEFT", 0, 2);
  adjustTab.RaidTimerContainer.intervalHeader:SetText(L["INTERVAL"] .. ":")

  -- Award Value Editbox
  if not MonDKP_DB.DKPBonus.IntervalBonus then MonDKP_DB.DKPBonus.IntervalBonus = 15 end
  adjustTab.RaidTimerContainer.bonusvalue = CreateFrame("EditBox", nil, adjustTab.RaidTimerContainer)
  adjustTab.RaidTimerContainer.bonusvalue:SetPoint("LEFT", adjustTab.RaidTimerContainer.interval, "RIGHT", 10, 0)
  adjustTab.RaidTimerContainer.bonusvalue:SetAutoFocus(false)
  adjustTab.RaidTimerContainer.bonusvalue:SetMultiLine(false)
  adjustTab.RaidTimerContainer.bonusvalue:SetSize(60, 24)
  adjustTab.RaidTimerContainer.bonusvalue:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  adjustTab.RaidTimerContainer.bonusvalue:SetBackdropColor(0, 0, 0, 0.9)
  adjustTab.RaidTimerContainer.bonusvalue:SetBackdropBorderColor(1, 1, 1, 0.6)
  adjustTab.RaidTimerContainer.bonusvalue:SetMaxLetters(5)
  adjustTab.RaidTimerContainer.bonusvalue:SetTextColor(1, 1, 1, 1)
  adjustTab.RaidTimerContainer.bonusvalue:SetFontObject("MonDKPSmallRight")
  adjustTab.RaidTimerContainer.bonusvalue:SetTextInsets(10, 15, 5, 5)
  adjustTab.RaidTimerContainer.bonusvalue:SetNumber(tonumber(MonDKP_DB.DKPBonus.IntervalBonus))
  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnTextChanged", function(self) -- clears focus on esc
    if tonumber(self:GetNumber()) then
      MonDKP_DB.DKPBonus.IntervalBonus = self:GetNumber();
    else
      StaticPopupDialogs["ALERT_NUMBER"] = {
        text = L["INCREMENTINVALIDWARN"],
        button1 = L["OK"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("ALERT_NUMBER")
    end
  end)
  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    self:ClearFocus()
  end)
  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    self:ClearFocus()
  end)
  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnTabPressed", function(self) -- clears focus on esc
    self:HighlightText(0, 0)
    adjustTab.RaidTimerContainer.interval:SetFocus()
    adjustTab.RaidTimerContainer.interval:HighlightText()
  end)

  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["AWARDBONUS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["AWARDBONUSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.bonusvalue:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.RaidTimerContainer.bonusvalueHeader = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.bonusvalueHeader:SetFontObject("MonDKPTinyRight");
  adjustTab.RaidTimerContainer.bonusvalueHeader:SetPoint("BOTTOMLEFT", adjustTab.RaidTimerContainer.bonusvalue, "TOPLEFT", 0, 2);
  adjustTab.RaidTimerContainer.bonusvalueHeader:SetText(L["BONUS"] .. ":")

  -- Give On Time Bonus Checkbox
  adjustTab.RaidTimerContainer.StartBonus = CreateFrame("CheckButton", nil, adjustTab.RaidTimerContainer, "UICheckButtonTemplate");
  adjustTab.RaidTimerContainer.StartBonus:SetChecked(MonDKP_DB.DKPBonus.GiveRaidStart)
  adjustTab.RaidTimerContainer.StartBonus:SetScale(0.6);
  adjustTab.RaidTimerContainer.StartBonus.text:SetText("  |cff999999" .. L["GIVEONTIMEBONUS"] .. "|r");
  adjustTab.RaidTimerContainer.StartBonus.text:SetScale(1.5);
  adjustTab.RaidTimerContainer.StartBonus.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.RaidTimerContainer.StartBonus:SetPoint("TOPLEFT", adjustTab.RaidTimerContainer.interval, "BOTTOMLEFT", 0, -10);
  adjustTab.RaidTimerContainer.StartBonus:SetScript("OnClick", function(self)
    if self:GetChecked() then
      MonDKP_DB.DKPBonus.GiveRaidStart = true;
      PlaySound(808)
    else
      MonDKP_DB.DKPBonus.GiveRaidStart = false;
    end
  end)
  adjustTab.RaidTimerContainer.StartBonus:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["GIVEONTIMEBONUS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["GIVEONTIMETTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.StartBonus:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Give Raid End Bonus Checkbox
  adjustTab.RaidTimerContainer.EndRaidBonus = CreateFrame("CheckButton", nil, adjustTab.RaidTimerContainer, "UICheckButtonTemplate");
  adjustTab.RaidTimerContainer.EndRaidBonus:SetChecked(MonDKP_DB.DKPBonus.GiveRaidEnd)
  adjustTab.RaidTimerContainer.EndRaidBonus:SetScale(0.6);
  adjustTab.RaidTimerContainer.EndRaidBonus.text:SetText("  |cff999999" .. L["GIVEENDBONUS"] .. "|r");
  adjustTab.RaidTimerContainer.EndRaidBonus.text:SetScale(1.5);
  adjustTab.RaidTimerContainer.EndRaidBonus.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.RaidTimerContainer.EndRaidBonus:SetPoint("TOP", adjustTab.RaidTimerContainer.StartBonus, "BOTTOM", 0, 2);
  adjustTab.RaidTimerContainer.EndRaidBonus:SetScript("OnClick", function(self)
    if self:GetChecked() then
      MonDKP_DB.DKPBonus.GiveRaidEnd = true;
      PlaySound(808)
    else
      MonDKP_DB.DKPBonus.GiveRaidEnd = false;
    end
  end)
  adjustTab.RaidTimerContainer.EndRaidBonus:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["GIVEENDBONUS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["GIVEENDBONUSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.EndRaidBonus:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Include Standby Checkbox
  adjustTab.RaidTimerContainer.StandbyInclude = CreateFrame("CheckButton", nil, adjustTab.RaidTimerContainer, "UICheckButtonTemplate");
  adjustTab.RaidTimerContainer.StandbyInclude:SetChecked(MonDKP_DB.DKPBonus.IncStandby)
  adjustTab.RaidTimerContainer.StandbyInclude:SetScale(0.6);
  adjustTab.RaidTimerContainer.StandbyInclude.text:SetText("  |cff999999" .. L["INCLUDESTANDBY"] .. "|r");
  adjustTab.RaidTimerContainer.StandbyInclude.text:SetScale(1.5);
  adjustTab.RaidTimerContainer.StandbyInclude.text:SetFontObject("MonDKPSmallLeft")
  adjustTab.RaidTimerContainer.StandbyInclude:SetPoint("TOP", adjustTab.RaidTimerContainer.EndRaidBonus, "BOTTOM", 0, 2);
  adjustTab.RaidTimerContainer.StandbyInclude:SetScript("OnClick", function(self)
    if self:GetChecked() then
      MonDKP_DB.DKPBonus.IncStandby = true;
      PlaySound(808)
    else
      MonDKP_DB.DKPBonus.IncStandby = false;
    end
  end)
  adjustTab.RaidTimerContainer.StandbyInclude:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["INCLUDESTANDBY"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["INCLUDESTANDBYTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["INCLUDESTANDBYTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  adjustTab.RaidTimerContainer.StandbyInclude:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  adjustTab.RaidTimerContainer.TimerWarning = adjustTab.RaidTimerContainer:CreateFontString(nil, "OVERLAY")
  adjustTab.RaidTimerContainer.TimerWarning:SetFontObject("MonDKPTinyLeft");
  adjustTab.RaidTimerContainer.TimerWarning:SetWidth(180)
  adjustTab.RaidTimerContainer.TimerWarning:SetPoint("BOTTOMLEFT", adjustTab.RaidTimerContainer, "BOTTOMLEFT", 10, 10);
  adjustTab.RaidTimerContainer.TimerWarning:SetText("|CFFFF0000" .. L["TIMERWARNING"] .. "|r")
  RaidTimerPopout_Create()
end