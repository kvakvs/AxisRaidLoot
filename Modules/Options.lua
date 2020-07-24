local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

local moveTimerToggle = 0;
local validating = false

local function DrawPercFrame(box)
  --Draw % signs if set to percent
  local optionsTab = MonDKP.ConfigTab4
  optionsTab.DefaultMinBids.SlotBox[box].perc = optionsTab.DefaultMinBids.SlotBox[box]:CreateFontString(nil, "OVERLAY")
  optionsTab.DefaultMinBids.SlotBox[box].perc:SetFontObject("MonDKPNormalLeft");
  optionsTab.DefaultMinBids.SlotBox[box].perc:SetPoint("LEFT", optionsTab.DefaultMinBids.SlotBox[box], "RIGHT", -15, 0);
  optionsTab.DefaultMinBids.SlotBox[box].perc:SetText("%")

  optionsTab.DefaultMaxBids.SlotBox[box].perc = optionsTab.DefaultMaxBids.SlotBox[box]:CreateFontString(nil, "OVERLAY")
  optionsTab.DefaultMaxBids.SlotBox[box].perc:SetFontObject("MonDKPNormalLeft");
  optionsTab.DefaultMaxBids.SlotBox[box].perc:SetPoint("LEFT", optionsTab.DefaultMaxBids.SlotBox[box], "RIGHT", -15, 0);
  optionsTab.DefaultMaxBids.SlotBox[box].perc:SetText("%")
end

local function SaveSettings()
  local optionsTab = MonDKP.ConfigTab4
  if optionsTab.default[1] then
    MonDKP_DB.DKPBonus.OnTimeBonus = optionsTab.default[1]:GetNumber();
    MonDKP_DB.DKPBonus.BossKillBonus = optionsTab.default[2]:GetNumber();
    MonDKP_DB.DKPBonus.CompletionBonus = optionsTab.default[3]:GetNumber();
    MonDKP_DB.DKPBonus.NewBossKillBonus = optionsTab.default[4]:GetNumber();
    MonDKP_DB.DKPBonus.UnexcusedAbsence = optionsTab.default[5]:GetNumber();
    if optionsTab.default[6]:GetNumber() < 0 then
      MonDKP_DB.DKPBonus.DecayPercentage = 0 - optionsTab.default[6]:GetNumber();
    else
      MonDKP_DB.DKPBonus.DecayPercentage = optionsTab.default[6]:GetNumber();
    end
    MonDKP.ConfigTab2.decayDKP:SetNumber(MonDKP_DB.DKPBonus.DecayPercentage);
    optionsTab.default[6]:SetNumber(MonDKP_DB.DKPBonus.DecayPercentage)
    MonDKP_DB.DKPBonus.BidTimer = optionsTab.bidTimer:GetNumber();

    MonDKP_DB.MinBidBySlot.Head = optionsTab.DefaultMinBids.SlotBox[1]:GetNumber()
    MonDKP_DB.MinBidBySlot.Neck = optionsTab.DefaultMinBids.SlotBox[2]:GetNumber()
    MonDKP_DB.MinBidBySlot.Shoulders = optionsTab.DefaultMinBids.SlotBox[3]:GetNumber()
    MonDKP_DB.MinBidBySlot.Cloak = optionsTab.DefaultMinBids.SlotBox[4]:GetNumber()
    MonDKP_DB.MinBidBySlot.Chest = optionsTab.DefaultMinBids.SlotBox[5]:GetNumber()
    MonDKP_DB.MinBidBySlot.Bracers = optionsTab.DefaultMinBids.SlotBox[6]:GetNumber()
    MonDKP_DB.MinBidBySlot.Hands = optionsTab.DefaultMinBids.SlotBox[7]:GetNumber()
    MonDKP_DB.MinBidBySlot.Belt = optionsTab.DefaultMinBids.SlotBox[8]:GetNumber()
    MonDKP_DB.MinBidBySlot.Legs = optionsTab.DefaultMinBids.SlotBox[9]:GetNumber()
    MonDKP_DB.MinBidBySlot.Boots = optionsTab.DefaultMinBids.SlotBox[10]:GetNumber()
    MonDKP_DB.MinBidBySlot.Ring = optionsTab.DefaultMinBids.SlotBox[11]:GetNumber()
    MonDKP_DB.MinBidBySlot.Trinket = optionsTab.DefaultMinBids.SlotBox[12]:GetNumber()
    MonDKP_DB.MinBidBySlot.OneHanded = optionsTab.DefaultMinBids.SlotBox[13]:GetNumber()
    MonDKP_DB.MinBidBySlot.TwoHanded = optionsTab.DefaultMinBids.SlotBox[14]:GetNumber()
    MonDKP_DB.MinBidBySlot.OffHand = optionsTab.DefaultMinBids.SlotBox[15]:GetNumber()
    MonDKP_DB.MinBidBySlot.Range = optionsTab.DefaultMinBids.SlotBox[16]:GetNumber()
    MonDKP_DB.MinBidBySlot.Other = optionsTab.DefaultMinBids.SlotBox[17]:GetNumber()

    MonDKP_DB.MaxBidBySlot.Head = optionsTab.DefaultMaxBids.SlotBox[1]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Neck = optionsTab.DefaultMaxBids.SlotBox[2]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Shoulders = optionsTab.DefaultMaxBids.SlotBox[3]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Cloak = optionsTab.DefaultMaxBids.SlotBox[4]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Chest = optionsTab.DefaultMaxBids.SlotBox[5]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Bracers = optionsTab.DefaultMaxBids.SlotBox[6]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Hands = optionsTab.DefaultMaxBids.SlotBox[7]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Belt = optionsTab.DefaultMaxBids.SlotBox[8]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Legs = optionsTab.DefaultMaxBids.SlotBox[9]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Boots = optionsTab.DefaultMaxBids.SlotBox[10]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Ring = optionsTab.DefaultMaxBids.SlotBox[11]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Trinket = optionsTab.DefaultMaxBids.SlotBox[12]:GetNumber()
    MonDKP_DB.MaxBidBySlot.OneHanded = optionsTab.DefaultMaxBids.SlotBox[13]:GetNumber()
    MonDKP_DB.MaxBidBySlot.TwoHanded = optionsTab.DefaultMaxBids.SlotBox[14]:GetNumber()
    MonDKP_DB.MaxBidBySlot.OffHand = optionsTab.DefaultMaxBids.SlotBox[15]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Range = optionsTab.DefaultMaxBids.SlotBox[16]:GetNumber()
    MonDKP_DB.MaxBidBySlot.Other = optionsTab.DefaultMaxBids.SlotBox[17]:GetNumber()
  end

  core.MonDKPUI:SetScale(MonDKP_DB.defaults.MonDKPScaleSize);
  MonDKP_DB.defaults.HistoryLimit = optionsTab.history:GetNumber();
  MonDKP_DB.defaults.DKPHistoryLimit = optionsTab.DKPHistory:GetNumber();
  MonDKP_DB.defaults.TooltipHistoryCount = optionsTab.TooltipHistory:GetNumber();
  DKPTable_Update()
end

function MonDKP:Options()
  local default = {}
  local optionsTab = MonDKP.ConfigTab4
  optionsTab.default = default;

  optionsTab.header = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.header:SetFontObject("MonDKPLargeCenter");
  optionsTab.header:SetPoint("TOPLEFT", optionsTab, "TOPLEFT", 15, -10);
  optionsTab.header:SetText(L["DEFAULTSETTINGS"]);
  optionsTab.header:SetScale(1.2)

  if core.IsOfficer == true then
    optionsTab.description = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.description:SetFontObject("MonDKPNormalLeft");
    optionsTab.description:SetPoint("TOPLEFT", optionsTab.header, "BOTTOMLEFT", 7, -15);
    optionsTab.description:SetText("|CFFcca600" .. L["DEFAULTDKPAWARDVALUES"] .. "|r");

    for i = 1, 6 do
      optionsTab.default[i] = CreateFrame("EditBox", nil, optionsTab)
      optionsTab.default[i]:SetAutoFocus(false)
      optionsTab.default[i]:SetMultiLine(false)
      optionsTab.default[i]:SetSize(80, 24)
      optionsTab.default[i]:SetBackdrop({
        bgFile = "Textures\\white.blp",
        tile = true,
        edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
        tile = true,
        tileSize = 32,
        edgeSize = 2,
      });
      optionsTab.default[i]:SetBackdropColor(0, 0, 0, 0.9)
      optionsTab.default[i]:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
      optionsTab.default[i]:SetMaxLetters(6)
      optionsTab.default[i]:SetTextColor(1, 1, 1, 1)
      optionsTab.default[i]:SetFontObject("MonDKPSmallRight")
      optionsTab.default[i]:SetTextInsets(10, 10, 5, 5)
      optionsTab.default[i]:SetScript("OnEscapePressed", function(self) -- clears focus on esc
        self:HighlightText(0, 0)
        SaveSettings()
        self:ClearFocus()
      end)
      optionsTab.default[i]:SetScript("OnEnterPressed", function(self) -- clears focus on esc
        self:HighlightText(0, 0)
        SaveSettings()
        self:ClearFocus()
      end)
      optionsTab.default[i]:SetScript("OnTabPressed", function(self) -- clears focus on esc
        SaveSettings()
        if i == 6 then
          self:HighlightText(0, 0)
          optionsTab.DefaultMinBids.SlotBox[1]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[1]:HighlightText()
        else
          self:HighlightText(0, 0)
          optionsTab.default[i + 1]:SetFocus()
          optionsTab.default[i + 1]:HighlightText()
        end
      end)
      optionsTab.default[i]:SetScript("OnEnter", function(self)
        if (self.tooltipText) then
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
          GameTooltip:SetText(self.tooltipText, 0.25, 0.75, 0.90, 1, true);
        end
        if (self.tooltipDescription) then
          GameTooltip:AddLine(self.tooltipDescription, 1.0, 1.0, 1.0, true);
          GameTooltip:Show();
        end
        if (self.tooltipWarning) then
          GameTooltip:AddLine(self.tooltipWarning, 1.0, 0, 0, true);
          GameTooltip:Show();
        end
      end)
      optionsTab.default[i]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
      end)

      if i == 1 then
        optionsTab.default[i]:SetPoint("TOPLEFT", optionsTab, "TOPLEFT", 144, -84)
      elseif i == 4 then
        optionsTab.default[i]:SetPoint("TOPLEFT", optionsTab.default[1], "TOPLEFT", 212, 0)
      else
        optionsTab.default[i]:SetPoint("TOP", optionsTab.default[i - 1], "BOTTOM", 0, -22)
      end
    end

    -- Modes Button
    optionsTab.ModesButton = self:CreateButton("TOPRIGHT", optionsTab, "TOPRIGHT", -40, -20, L["DKPMODES"]);
    optionsTab.ModesButton:SetSize(110, 25)
    optionsTab.ModesButton:SetScript("OnClick", function()
      MonDKP:ToggleDKPModesWindow()
    end);
    optionsTab.ModesButton:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["DKPMODES"], 0.25, 0.75, 0.90, 1, true)
      GameTooltip:AddLine(L["DKPMODESTTDESC2"], 1.0, 1.0, 1.0, true);
      GameTooltip:AddLine(L["DKPMODESTTWARN"], 1.0, 0, 0, true);
      GameTooltip:Show()
    end)
    optionsTab.ModesButton:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    if not core.IsOfficer then
      optionsTab.ModesButton:Hide()
    end

    optionsTab.default[1]:SetText(MonDKP_DB.DKPBonus.OnTimeBonus)
    optionsTab.default[1].tooltipText = L["ONTIMEBONUS"]
    optionsTab.default[1].tooltipDescription = L["ONTIMEBONUSTTDESC"]

    optionsTab.default[2]:SetText(MonDKP_DB.DKPBonus.BossKillBonus)
    optionsTab.default[2].tooltipText = L["BOSSKILLBONUS"]
    optionsTab.default[2].tooltipDescription = L["BOSSKILLBONUSTTDESC"]

    optionsTab.default[3]:SetText(MonDKP_DB.DKPBonus.CompletionBonus)
    optionsTab.default[3].tooltipText = L["RAIDCOMPLETIONBONUS"]
    optionsTab.default[3].tooltipDescription = L["RAIDCOMPLETEBONUSTT"]

    optionsTab.default[4]:SetText(MonDKP_DB.DKPBonus.NewBossKillBonus)
    optionsTab.default[4].tooltipText = L["NEWBOSSKILLBONUS"]
    optionsTab.default[4].tooltipDescription = L["NEWBOSSKILLTTDESC"]

    optionsTab.default[5]:SetText(MonDKP_DB.DKPBonus.UnexcusedAbsence)
    optionsTab.default[5]:SetNumeric(false)
    optionsTab.default[5].tooltipText = L["UNEXCUSEDABSENCE"]
    optionsTab.default[5].tooltipDescription = L["UNEXCUSEDTTDESC"]
    optionsTab.default[5].tooltipWarning = L["UNEXCUSEDTTWARN"]

    optionsTab.default[6]:SetText(MonDKP_DB.DKPBonus.DecayPercentage)
    optionsTab.default[6]:SetTextInsets(0, 15, 0, 0)
    optionsTab.default[6].tooltipText = L["DECAYPERCENTAGE"]
    optionsTab.default[6].tooltipDescription = L["DECAYPERCENTAGETTDESC"]
    optionsTab.default[6].tooltipWarning = L["DECAYPERCENTAGETTWARN"]

    --OnTimeBonus Header
    optionsTab.OnTimeHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.OnTimeHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.OnTimeHeader:SetPoint("RIGHT", optionsTab.default[1], "LEFT", 0, 0);
    optionsTab.OnTimeHeader:SetText(L["ONTIMEBONUS"] .. ": ")

    --BossKillBonus Header
    optionsTab.BossKillHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.BossKillHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.BossKillHeader:SetPoint("RIGHT", optionsTab.default[2], "LEFT", 0, 0);
    optionsTab.BossKillHeader:SetText(L["BOSSKILLBONUS"] .. ": ")

    --CompletionBonus Header
    optionsTab.CompleteHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.CompleteHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.CompleteHeader:SetPoint("RIGHT", optionsTab.default[3], "LEFT", 0, 0);
    optionsTab.CompleteHeader:SetText(L["RAIDCOMPLETIONBONUS"] .. ": ")

    --NewBossKillBonus Header
    optionsTab.NewBossHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.NewBossHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.NewBossHeader:SetPoint("RIGHT", optionsTab.default[4], "LEFT", 0, 0);
    optionsTab.NewBossHeader:SetText(L["NEWBOSSKILLBONUS"] .. ": ")

    --UnexcusedAbsence Header
    optionsTab.UnexcusedHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.UnexcusedHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.UnexcusedHeader:SetPoint("RIGHT", optionsTab.default[5], "LEFT", 0, 0);
    optionsTab.UnexcusedHeader:SetText(L["UNEXCUSEDABSENCE"] .. ": ")

    --DKP Decay Header
    optionsTab.DecayHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.DecayHeader:SetFontObject("MonDKPSmallRight");
    optionsTab.DecayHeader:SetPoint("RIGHT", optionsTab.default[6], "LEFT", 0, 0);
    optionsTab.DecayHeader:SetText(L["DECAYAMOUNT"] .. ": ")

    optionsTab.DecayFooter = optionsTab.default[6]:CreateFontString(nil, "OVERLAY")
    optionsTab.DecayFooter:SetFontObject("MonDKPSmallRight");
    optionsTab.DecayFooter:SetPoint("LEFT", optionsTab.default[6], "RIGHT", -15, -1);
    optionsTab.DecayFooter:SetText("%")

    -- Default Minimum Bids Container Frame
    optionsTab.DefaultMinBids = CreateFrame("Frame", nil, optionsTab);
    optionsTab.DefaultMinBids:SetPoint("TOPLEFT", optionsTab.default[3], "BOTTOMLEFT", -130, -52)
    optionsTab.DefaultMinBids:SetSize(420, 410);

    optionsTab.DefaultMinBids.description = optionsTab.DefaultMinBids:CreateFontString(nil, "OVERLAY")
    optionsTab.DefaultMinBids.description:SetFontObject("MonDKPSmallRight");
    optionsTab.DefaultMinBids.description:SetPoint("TOPLEFT", optionsTab.DefaultMinBids, "TOPLEFT", 15, 15);

    -- DEFAULT min bids Create EditBoxes
    local SlotBox = {}
    optionsTab.DefaultMinBids.SlotBox = SlotBox;

    for i = 1, 17 do
      optionsTab.DefaultMinBids.SlotBox[i] = CreateFrame("EditBox", nil, optionsTab)
      optionsTab.DefaultMinBids.SlotBox[i]:SetAutoFocus(false)
      optionsTab.DefaultMinBids.SlotBox[i]:SetMultiLine(false)
      optionsTab.DefaultMinBids.SlotBox[i]:SetSize(60, 24)
      optionsTab.DefaultMinBids.SlotBox[i]:SetBackdrop({
        bgFile = "Textures\\white.blp",
        tile = true,
        edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
        tile = true,
        tileSize = 32,
        edgeSize = 2,
      });
      optionsTab.DefaultMinBids.SlotBox[i]:SetBackdropColor(0, 0, 0, 0.9)
      optionsTab.DefaultMinBids.SlotBox[i]:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
      optionsTab.DefaultMinBids.SlotBox[i]:SetMaxLetters(6)
      optionsTab.DefaultMinBids.SlotBox[i]:SetTextColor(1, 1, 1, 1)
      optionsTab.DefaultMinBids.SlotBox[i]:SetFontObject("MonDKPSmallRight")
      optionsTab.DefaultMinBids.SlotBox[i]:SetTextInsets(10, 10, 5, 5)
      optionsTab.DefaultMinBids.SlotBox[i]:SetScript("OnEscapePressed", function(self) -- clears focus on esc
        self:HighlightText(0, 0)
        SaveSettings()
        self:ClearFocus()
      end)
      optionsTab.DefaultMinBids.SlotBox[i]:SetScript("OnEnterPressed", function(self) -- clears focus on esc
        self:HighlightText(0, 0)
        SaveSettings()
        self:ClearFocus()
      end)
      optionsTab.DefaultMinBids.SlotBox[i]:SetScript("OnTabPressed", function(self) -- clears focus on esc
        if i == 8 then
          self:HighlightText(0, 0)
          optionsTab.DefaultMinBids.SlotBox[17]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[17]:HighlightText()
          SaveSettings()
        elseif i == 5 then
          self:HighlightText(0, 0)
          MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(200)
          optionsTab.DefaultMinBids.SlotBox[i + 1]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[i + 1]:HighlightText()
          SaveSettings()
        elseif i == 13 then
          self:HighlightText(0, 0)
          MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(200)
          optionsTab.DefaultMinBids.SlotBox[14]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[14]:HighlightText()
          SaveSettings()
        elseif i == 17 then
          self:HighlightText(0, 0)
          optionsTab.DefaultMinBids.SlotBox[9]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[9]:HighlightText()
          SaveSettings()
        elseif i == 16 then
          self:HighlightText(0, 0)
          MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(1)
          optionsTab.default[1]:SetFocus()
          optionsTab.default[1]:HighlightText()
          SaveSettings()
        else
          self:HighlightText(0, 0)
          optionsTab.DefaultMinBids.SlotBox[i + 1]:SetFocus()
          optionsTab.DefaultMinBids.SlotBox[i + 1]:HighlightText()
          SaveSettings()
        end
      end)
      optionsTab.DefaultMinBids.SlotBox[i]:SetScript("OnEnter", function(self)
        if (self.tooltipText) then
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
          GameTooltip:SetText(self.tooltipText, 0.25, 0.75, 0.90, 1, true);
        end
        if (self.tooltipDescription) then
          GameTooltip:AddLine(self.tooltipDescription, 1.0, 1.0, 1.0, true);
          GameTooltip:Show();
        end
        if (self.tooltipWarning) then
          GameTooltip:AddLine(self.tooltipWarning, 1.0, 0, 0, true);
          GameTooltip:Show();
        end
      end)
      optionsTab.DefaultMinBids.SlotBox[i]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
      end)

      -- Slot Headers
      optionsTab.DefaultMinBids.SlotBox[i].Header = optionsTab.DefaultMinBids:CreateFontString(nil, "OVERLAY")
      optionsTab.DefaultMinBids.SlotBox[i].Header:SetFontObject("MonDKPNormalLeft");
      optionsTab.DefaultMinBids.SlotBox[i].Header:SetPoint("RIGHT", optionsTab.DefaultMinBids.SlotBox[i], "LEFT", 0, 0);

      if i == 1 then
        optionsTab.DefaultMinBids.SlotBox[i]:SetPoint("TOPLEFT", optionsTab.DefaultMinBids, "TOPLEFT", 100, -10)
      elseif i == 9 then
        optionsTab.DefaultMinBids.SlotBox[i]:SetPoint("TOPLEFT", optionsTab.DefaultMinBids.SlotBox[1], "TOPLEFT", 150, 0)
      elseif i == 17 then
        optionsTab.DefaultMinBids.SlotBox[i]:SetPoint("TOP", optionsTab.DefaultMinBids.SlotBox[8], "BOTTOM", 0, -22)
      else
        optionsTab.DefaultMinBids.SlotBox[i]:SetPoint("TOP", optionsTab.DefaultMinBids.SlotBox[i - 1], "BOTTOM", 0, -22)
      end
    end

    local prefix;

    if MonDKP_DB.modes.mode == "Minimum Bid Values" then
      prefix = L["MINIMUMBID"];
      optionsTab.DefaultMinBids.description:SetText("|CFFcca600" .. L["DEFAULTMINBIDVALUES"] .. "|r");
    elseif MonDKP_DB.modes.mode == "Static Item Values" then
      optionsTab.DefaultMinBids.description:SetText("|CFFcca600" .. L["DEFAULTITEMCOSTS"] .. "|r");
      if MonDKP_DB.modes.costvalue == "Integer" then
        prefix = L["DKPPRICE"]
      elseif MonDKP_DB.modes.costvalue == "Percent" then
        prefix = L["PERCENTCOST"]
      end
    elseif MonDKP_DB.modes.mode == "Roll Based Bidding" then
      optionsTab.DefaultMinBids.description:SetText("|CFFcca600" .. L["DEFAULTITEMCOSTS"] .. "|r");
      if MonDKP_DB.modes.costvalue == "Integer" then
        prefix = L["DKPPRICE"]
      elseif MonDKP_DB.modes.costvalue == "Percent" then
        prefix = L["PERCENTCOST"]
      end
    elseif MonDKP_DB.modes.mode == "Zero Sum" then
      optionsTab.DefaultMinBids.description:SetText("|CFFcca600" .. L["DEFAULTITEMCOSTS"] .. "|r");
      if MonDKP_DB.modes.costvalue == "Integer" then
        prefix = L["DKPPRICE"]
      elseif MonDKP_DB.modes.costvalue == "Percent" then
        prefix = L["PERCENTCOST"]
      end
    end

    optionsTab.DefaultMinBids.SlotBox[1].Header:SetText(L["HEAD"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[1]:SetText(MonDKP_DB.MinBidBySlot.Head)
    optionsTab.DefaultMinBids.SlotBox[1].tooltipText = L["HEAD"]
    optionsTab.DefaultMinBids.SlotBox[1].tooltipDescription = prefix .. " " .. L["FORHEADSLOT"]

    optionsTab.DefaultMinBids.SlotBox[2].Header:SetText(L["NECK"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[2]:SetText(MonDKP_DB.MinBidBySlot.Neck)
    optionsTab.DefaultMinBids.SlotBox[2].tooltipText = L["NECK"]
    optionsTab.DefaultMinBids.SlotBox[2].tooltipDescription = prefix .. " " .. L["FORNECKSLOT"]

    optionsTab.DefaultMinBids.SlotBox[3].Header:SetText(L["SHOULDERS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[3]:SetText(MonDKP_DB.MinBidBySlot.Shoulders)
    optionsTab.DefaultMinBids.SlotBox[3].tooltipText = L["SHOULDERS"]
    optionsTab.DefaultMinBids.SlotBox[3].tooltipDescription = prefix .. " " .. L["FORSHOULDERSLOT"]

    optionsTab.DefaultMinBids.SlotBox[4].Header:SetText(L["CLOAK"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[4]:SetText(MonDKP_DB.MinBidBySlot.Cloak)
    optionsTab.DefaultMinBids.SlotBox[4].tooltipText = L["CLOAK"]
    optionsTab.DefaultMinBids.SlotBox[4].tooltipDescription = prefix .. " " .. L["FORBACKSLOT"]

    optionsTab.DefaultMinBids.SlotBox[5].Header:SetText(L["CHEST"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[5]:SetText(MonDKP_DB.MinBidBySlot.Chest)
    optionsTab.DefaultMinBids.SlotBox[5].tooltipText = L["CHEST"]
    optionsTab.DefaultMinBids.SlotBox[5].tooltipDescription = prefix .. " " .. L["FORCHESTSLOT"]

    optionsTab.DefaultMinBids.SlotBox[6].Header:SetText(L["BRACERS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[6]:SetText(MonDKP_DB.MinBidBySlot.Bracers)
    optionsTab.DefaultMinBids.SlotBox[6].tooltipText = L["BRACERS"]
    optionsTab.DefaultMinBids.SlotBox[6].tooltipDescription = prefix .. " " .. L["FORWRISTSLOT"]

    optionsTab.DefaultMinBids.SlotBox[7].Header:SetText(L["HANDS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[7]:SetText(MonDKP_DB.MinBidBySlot.Hands)
    optionsTab.DefaultMinBids.SlotBox[7].tooltipText = L["HANDS"]
    optionsTab.DefaultMinBids.SlotBox[7].tooltipDescription = prefix .. " " .. L["FORHANDSLOT"]

    optionsTab.DefaultMinBids.SlotBox[8].Header:SetText(L["BELT"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[8]:SetText(MonDKP_DB.MinBidBySlot.Belt)
    optionsTab.DefaultMinBids.SlotBox[8].tooltipText = L["BELT"]
    optionsTab.DefaultMinBids.SlotBox[8].tooltipDescription = prefix .. " " .. L["FORWAISTSLOT"]

    optionsTab.DefaultMinBids.SlotBox[9].Header:SetText(L["LEGS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[9]:SetText(MonDKP_DB.MinBidBySlot.Legs)
    optionsTab.DefaultMinBids.SlotBox[9].tooltipText = L["LEGS"]
    optionsTab.DefaultMinBids.SlotBox[9].tooltipDescription = prefix .. " " .. L["FORLEGSLOT"]

    optionsTab.DefaultMinBids.SlotBox[10].Header:SetText(L["BOOTS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[10]:SetText(MonDKP_DB.MinBidBySlot.Boots)
    optionsTab.DefaultMinBids.SlotBox[10].tooltipText = L["BOOTS"]
    optionsTab.DefaultMinBids.SlotBox[10].tooltipDescription = prefix .. " " .. L["FORFEETSLOT"]

    optionsTab.DefaultMinBids.SlotBox[11].Header:SetText(L["RINGS"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[11]:SetText(MonDKP_DB.MinBidBySlot.Ring)
    optionsTab.DefaultMinBids.SlotBox[11].tooltipText = L["RINGS"]
    optionsTab.DefaultMinBids.SlotBox[11].tooltipDescription = prefix .. " " .. L["FORFINGERSLOT"]

    optionsTab.DefaultMinBids.SlotBox[12].Header:SetText(L["TRINKET"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[12]:SetText(MonDKP_DB.MinBidBySlot.Trinket)
    optionsTab.DefaultMinBids.SlotBox[12].tooltipText = L["TRINKET"]
    optionsTab.DefaultMinBids.SlotBox[12].tooltipDescription = prefix .. " " .. L["FORTRINKETSLOT"]

    optionsTab.DefaultMinBids.SlotBox[13].Header:SetText(L["ONEHANDED"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[13]:SetText(MonDKP_DB.MinBidBySlot.OneHanded)
    optionsTab.DefaultMinBids.SlotBox[13].tooltipText = L["ONEHANDEDWEAPONS"]
    optionsTab.DefaultMinBids.SlotBox[13].tooltipDescription = prefix .. " " .. L["FORONEHANDSLOT"]

    optionsTab.DefaultMinBids.SlotBox[14].Header:SetText(L["TWOHANDED"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[14]:SetText(MonDKP_DB.MinBidBySlot.TwoHanded)
    optionsTab.DefaultMinBids.SlotBox[14].tooltipText = L["TWOHANDEDWEAPONS"]
    optionsTab.DefaultMinBids.SlotBox[14].tooltipDescription = prefix .. " " .. L["FORTWOHANDSLOT"]

    optionsTab.DefaultMinBids.SlotBox[15].Header:SetText(L["OFFHAND"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[15]:SetText(MonDKP_DB.MinBidBySlot.OffHand)
    optionsTab.DefaultMinBids.SlotBox[15].tooltipText = L["OFFHANDITEMS"]
    optionsTab.DefaultMinBids.SlotBox[15].tooltipDescription = prefix .. " " .. L["FOROFFHANDSLOT"]

    optionsTab.DefaultMinBids.SlotBox[16].Header:SetText(L["RANGE"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[16]:SetText(MonDKP_DB.MinBidBySlot.Range)
    optionsTab.DefaultMinBids.SlotBox[16].tooltipText = L["RANGE"]
    optionsTab.DefaultMinBids.SlotBox[16].tooltipDescription = prefix .. " " .. L["FORRANGESLOT"]

    optionsTab.DefaultMinBids.SlotBox[17].Header:SetText(L["OTHER"] .. ": ")
    optionsTab.DefaultMinBids.SlotBox[17]:SetText(MonDKP_DB.MinBidBySlot.Other)
    optionsTab.DefaultMinBids.SlotBox[17].tooltipText = L["OTHER"]
    optionsTab.DefaultMinBids.SlotBox[17].tooltipDescription = prefix .. " " .. L["FOROTHERSLOT"]

    if MonDKP_DB.modes.costvalue == "Percent" then
      for i = 1, #optionsTab.DefaultMinBids.SlotBox do
        DrawPercFrame(i)
        optionsTab.DefaultMinBids.SlotBox[i]:SetTextInsets(0, 15, 0, 0)
      end
    end

    -- Broadcast Minimum Bids Button
    optionsTab.BroadcastMinBids = self:CreateButton("TOP", optionsTab, "BOTTOM", 30, 30, L["BCASTVALUES"]);
    optionsTab.BroadcastMinBids:ClearAllPoints();
    optionsTab.BroadcastMinBids:SetPoint("LEFT", optionsTab.DefaultMinBids.SlotBox[17], "RIGHT", 41, 0)
    optionsTab.BroadcastMinBids:SetSize(110, 25)
    optionsTab.BroadcastMinBids:SetScript("OnClick", function()
      StaticPopupDialogs["SEND_MINBIDS"] = {
        text = L["BCASTMINBIDCONFIRM"],
        button1 = L["YES"],
        button2 = L["NO"],
        OnAccept = function()
          local temptable = {}
          table.insert(temptable, MonDKP_DB.MinBidBySlot)
          table.insert(temptable, MonDKP_MinBids)
          MonDKP.Sync:SendData("MonDKPMinBid", temptable)
          MonDKP.Print(L["MINBIDVALUESSENT"])
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("SEND_MINBIDS")
    end);
    optionsTab.BroadcastMinBids:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["BCASTVALUES"], 0.25, 0.75, 0.90, 1, true)
      GameTooltip:AddLine(L["BCASTVALUESTTDESC"], 1.0, 1.0, 1.0, true);
      GameTooltip:AddLine(L["BCASTVALUESTTWARN"], 1.0, 0, 0, true);
      GameTooltip:Show()
    end)
    optionsTab.BroadcastMinBids:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    -- Default Maximum Bids Container Frame
    if MonDKP_DB.modes.mode == "Minimum Bid Values" or (MonDKP_DB.modes.mode == "Zero Sum" and MonDKP_DB.modes.ZeroSumBidType == "Minimum Bid") then
      optionsTab.DefaultMaxBids = CreateFrame("Frame", nil, optionsTab);
      optionsTab.DefaultMaxBids:SetPoint("TOPLEFT", optionsTab.DefaultMinBids, "BOTTOMLEFT", 0, -52)
      optionsTab.DefaultMaxBids:SetSize(420, 410);

      optionsTab.DefaultMaxBids.description = optionsTab.DefaultMaxBids:CreateFontString(nil, "OVERLAY")
      optionsTab.DefaultMaxBids.description:SetFontObject("MonDKPSmallRight");
      optionsTab.DefaultMaxBids.description:SetPoint("TOPLEFT", optionsTab.DefaultMaxBids, "TOPLEFT", 15, 15);

      -- DEFAULT Max bids Create EditBoxes
      local SlotBox = {}
      optionsTab.DefaultMaxBids.SlotBox = SlotBox;

      for i = 1, 17 do
        optionsTab.DefaultMaxBids.SlotBox[i] = CreateFrame("EditBox", nil, optionsTab)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetAutoFocus(false)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetMultiLine(false)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetSize(60, 24)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetBackdrop({
          bgFile = "Textures\\white.blp",
          tile = true,
          edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
          tile = true,
          tileSize = 32,
          edgeSize = 2,
        });
        optionsTab.DefaultMaxBids.SlotBox[i]:SetBackdropColor(0, 0, 0, 0.9)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetMaxLetters(6)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetTextColor(1, 1, 1, 1)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetFontObject("MonDKPSmallRight")
        optionsTab.DefaultMaxBids.SlotBox[i]:SetTextInsets(10, 10, 5, 5)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetScript("OnEscapePressed", function(self) -- clears focus on esc
          self:HighlightText(0, 0)
          SaveSettings()
          self:ClearFocus()
        end)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetScript("OnEnterPressed", function(self) -- clears focus on esc
          self:HighlightText(0, 0)
          SaveSettings()
          self:ClearFocus()
        end)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetScript("OnTabPressed", function(self) -- clears focus on esc
          if i == 8 then
            self:HighlightText(0, 0)
            optionsTab.DefaultMaxBids.SlotBox[17]:SetFocus()
            optionsTab.DefaultMaxBids.SlotBox[17]:HighlightText()
            SaveSettings()
          elseif i == 5 then
            self:HighlightText(0, 0)
            MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(200)
            optionsTab.DefaultMaxBids.SlotBox[i + 1]:SetFocus()
            optionsTab.DefaultMaxBids.SlotBox[i + 1]:HighlightText()
            SaveSettings()
          elseif i == 13 then
            self:HighlightText(0, 0)
            MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(200)
            optionsTab.DefaultMaxBids.SlotBox[14]:SetFocus()
            optionsTab.DefaultMaxBids.SlotBox[14]:HighlightText()
            SaveSettings()
          elseif i == 17 then
            self:HighlightText(0, 0)
            optionsTab.DefaultMaxBids.SlotBox[9]:SetFocus()
            optionsTab.DefaultMaxBids.SlotBox[9]:HighlightText()
            SaveSettings()
          elseif i == 16 then
            self:HighlightText(0, 0)
            MonDKP.UIConfig.TabMenu.ScrollFrame:SetVerticalScroll(1)
            optionsTab.default[1]:SetFocus()
            optionsTab.default[1]:HighlightText()
            SaveSettings()
          else
            self:HighlightText(0, 0)
            optionsTab.DefaultMaxBids.SlotBox[i + 1]:SetFocus()
            optionsTab.DefaultMaxBids.SlotBox[i + 1]:HighlightText()
            SaveSettings()
          end
        end)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetScript("OnEnter", function(self)
          if (self.tooltipText) then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetText(self.tooltipText, 0.25, 0.75, 0.90, 1, true);
          end
          if (self.tooltipDescription) then
            GameTooltip:AddLine(self.tooltipDescription, 1.0, 1.0, 1.0, true);
            GameTooltip:Show();
          end
          if (self.tooltipWarning) then
            GameTooltip:AddLine(self.tooltipWarning, 1.0, 0, 0, true);
            GameTooltip:Show();
          end
        end)
        optionsTab.DefaultMaxBids.SlotBox[i]:SetScript("OnLeave", function(self)
          GameTooltip:Hide()
        end)

        -- Slot Headers
        optionsTab.DefaultMaxBids.SlotBox[i].Header = optionsTab.DefaultMaxBids:CreateFontString(nil, "OVERLAY")
        optionsTab.DefaultMaxBids.SlotBox[i].Header:SetFontObject("MonDKPNormalLeft");
        optionsTab.DefaultMaxBids.SlotBox[i].Header:SetPoint("RIGHT", optionsTab.DefaultMaxBids.SlotBox[i], "LEFT", 0, 0);

        if i == 1 then
          optionsTab.DefaultMaxBids.SlotBox[i]:SetPoint("TOPLEFT", optionsTab.DefaultMaxBids, "TOPLEFT", 100, -10)
        elseif i == 9 then
          optionsTab.DefaultMaxBids.SlotBox[i]:SetPoint("TOPLEFT", optionsTab.DefaultMaxBids.SlotBox[1], "TOPLEFT", 150, 0)
        elseif i == 17 then
          optionsTab.DefaultMaxBids.SlotBox[i]:SetPoint("TOP", optionsTab.DefaultMaxBids.SlotBox[8], "BOTTOM", 0, -22)
        else
          optionsTab.DefaultMaxBids.SlotBox[i]:SetPoint("TOP", optionsTab.DefaultMaxBids.SlotBox[i - 1], "BOTTOM", 0, -22)
        end
      end

      local prefix;

      prefix = L["MAXIMUMBID"];
      optionsTab.DefaultMaxBids.description:SetText("|CFFcca600" .. L["DEFAULTMAXBIDVALUES"] .. "|r");

      optionsTab.DefaultMaxBids.SlotBox[1].Header:SetText(L["HEAD"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[1]:SetText(MonDKP_DB.MaxBidBySlot.Head)
      optionsTab.DefaultMaxBids.SlotBox[1].tooltipText = L["HEAD"]
      optionsTab.DefaultMaxBids.SlotBox[1].tooltipDescription = prefix .. " " .. L["FORHEADSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[2].Header:SetText(L["NECK"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[2]:SetText(MonDKP_DB.MaxBidBySlot.Neck)
      optionsTab.DefaultMaxBids.SlotBox[2].tooltipText = L["NECK"]
      optionsTab.DefaultMaxBids.SlotBox[2].tooltipDescription = prefix .. " " .. L["FORNECKSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[3].Header:SetText(L["SHOULDERS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[3]:SetText(MonDKP_DB.MaxBidBySlot.Shoulders)
      optionsTab.DefaultMaxBids.SlotBox[3].tooltipText = L["SHOULDERS"]
      optionsTab.DefaultMaxBids.SlotBox[3].tooltipDescription = prefix .. " " .. L["FORSHOULDERSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[4].Header:SetText(L["CLOAK"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[4]:SetText(MonDKP_DB.MaxBidBySlot.Cloak)
      optionsTab.DefaultMaxBids.SlotBox[4].tooltipText = L["CLOAK"]
      optionsTab.DefaultMaxBids.SlotBox[4].tooltipDescription = prefix .. " " .. L["FORBACKSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[5].Header:SetText(L["CHEST"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[5]:SetText(MonDKP_DB.MaxBidBySlot.Chest)
      optionsTab.DefaultMaxBids.SlotBox[5].tooltipText = L["CHEST"]
      optionsTab.DefaultMaxBids.SlotBox[5].tooltipDescription = prefix .. " " .. L["FORCHESTSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[6].Header:SetText(L["BRACERS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[6]:SetText(MonDKP_DB.MaxBidBySlot.Bracers)
      optionsTab.DefaultMaxBids.SlotBox[6].tooltipText = L["BRACERS"]
      optionsTab.DefaultMaxBids.SlotBox[6].tooltipDescription = prefix .. " " .. L["FORWRISTSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[7].Header:SetText(L["HANDS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[7]:SetText(MonDKP_DB.MaxBidBySlot.Hands)
      optionsTab.DefaultMaxBids.SlotBox[7].tooltipText = L["HANDS"]
      optionsTab.DefaultMaxBids.SlotBox[7].tooltipDescription = prefix .. " " .. L["FORHANDSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[8].Header:SetText(L["BELT"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[8]:SetText(MonDKP_DB.MaxBidBySlot.Belt)
      optionsTab.DefaultMaxBids.SlotBox[8].tooltipText = L["BELT"]
      optionsTab.DefaultMaxBids.SlotBox[8].tooltipDescription = prefix .. " " .. L["FORWAISTSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[9].Header:SetText(L["LEGS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[9]:SetText(MonDKP_DB.MaxBidBySlot.Legs)
      optionsTab.DefaultMaxBids.SlotBox[9].tooltipText = L["LEGS"]
      optionsTab.DefaultMaxBids.SlotBox[9].tooltipDescription = prefix .. " " .. L["FORLEGSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[10].Header:SetText(L["BOOTS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[10]:SetText(MonDKP_DB.MaxBidBySlot.Boots)
      optionsTab.DefaultMaxBids.SlotBox[10].tooltipText = L["BOOTS"]
      optionsTab.DefaultMaxBids.SlotBox[10].tooltipDescription = prefix .. " " .. L["FORFEETSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[11].Header:SetText(L["RINGS"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[11]:SetText(MonDKP_DB.MaxBidBySlot.Ring)
      optionsTab.DefaultMaxBids.SlotBox[11].tooltipText = L["RINGS"]
      optionsTab.DefaultMaxBids.SlotBox[11].tooltipDescription = prefix .. " " .. L["FORFINGERSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[12].Header:SetText(L["TRINKET"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[12]:SetText(MonDKP_DB.MaxBidBySlot.Trinket)
      optionsTab.DefaultMaxBids.SlotBox[12].tooltipText = L["TRINKET"]
      optionsTab.DefaultMaxBids.SlotBox[12].tooltipDescription = prefix .. " " .. L["FORTRINKETSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[13].Header:SetText(L["ONEHANDED"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[13]:SetText(MonDKP_DB.MaxBidBySlot.OneHanded)
      optionsTab.DefaultMaxBids.SlotBox[13].tooltipText = L["ONEHANDEDWEAPONS"]
      optionsTab.DefaultMaxBids.SlotBox[13].tooltipDescription = prefix .. " " .. L["FORONEHANDSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[14].Header:SetText(L["TWOHANDED"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[14]:SetText(MonDKP_DB.MaxBidBySlot.TwoHanded)
      optionsTab.DefaultMaxBids.SlotBox[14].tooltipText = L["TWOHANDEDWEAPONS"]
      optionsTab.DefaultMaxBids.SlotBox[14].tooltipDescription = prefix .. " " .. L["FORTWOHANDSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[15].Header:SetText(L["OFFHAND"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[15]:SetText(MonDKP_DB.MaxBidBySlot.OffHand)
      optionsTab.DefaultMaxBids.SlotBox[15].tooltipText = L["OFFHANDITEMS"]
      optionsTab.DefaultMaxBids.SlotBox[15].tooltipDescription = prefix .. " " .. L["FOROFFHANDSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[16].Header:SetText(L["RANGE"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[16]:SetText(MonDKP_DB.MaxBidBySlot.Range)
      optionsTab.DefaultMaxBids.SlotBox[16].tooltipText = L["RANGE"]
      optionsTab.DefaultMaxBids.SlotBox[16].tooltipDescription = prefix .. " " .. L["FORRANGESLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      optionsTab.DefaultMaxBids.SlotBox[17].Header:SetText(L["OTHER"] .. ": ")
      optionsTab.DefaultMaxBids.SlotBox[17]:SetText(MonDKP_DB.MaxBidBySlot.Other)
      optionsTab.DefaultMaxBids.SlotBox[17].tooltipText = L["OTHER"]
      optionsTab.DefaultMaxBids.SlotBox[17].tooltipDescription = prefix .. " " .. L["FOROTHERSLOT"] .. " " .. L["MAXIMUMBIDTTDESC"]

      if MonDKP_DB.modes.costvalue == "Percent" then
        for i = 1, #optionsTab.DefaultMaxBids.SlotBox do
          DrawPercFrame(i)
          optionsTab.DefaultMaxBids.SlotBox[i]:SetTextInsets(0, 15, 0, 0)
        end
      end

      -- Broadcast Maximum Bids Button
      optionsTab.BroadcastMaxBids = self:CreateButton("TOP", optionsTab, "BOTTOM", 30, 30, L["BCASTVALUES"]);
      optionsTab.BroadcastMaxBids:ClearAllPoints();
      optionsTab.BroadcastMaxBids:SetPoint("LEFT", optionsTab.DefaultMaxBids.SlotBox[17], "RIGHT", 41, 0)
      optionsTab.BroadcastMaxBids:SetSize(110, 25)
      optionsTab.BroadcastMaxBids:SetScript("OnClick", function()
        StaticPopupDialogs["SEND_MAXBIDS"] = {
          text = L["BCASTMAXBIDCONFIRM"],
          button1 = L["YES"],
          button2 = L["NO"],
          OnAccept = function()
            local temptable = {}
            table.insert(temptable, MonDKP_DB.MaxBidBySlot)
            table.insert(temptable, MonDKP_MaxBids)
            MonDKP.Sync:SendData("MonDKPMaxBid", temptable)
            MonDKP.Print(L["MAXBIDVALUESSENT"])
          end,
          timeout = 0,
          whileDead = true,
          hideOnEscape = true,
          preferredIndex = 3,
        }
        StaticPopup_Show("SEND_MAXBIDS")
      end);
      optionsTab.BroadcastMaxBids:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["BCASTVALUES"], 0.25, 0.75, 0.90, 1, true)
        GameTooltip:AddLine(L["BCASTVALUESTTDESC"], 1.0, 1.0, 1.0, true);
        GameTooltip:AddLine(L["BCASTVALUESTTWARN"], 1.0, 0, 0, true);
        GameTooltip:Show()
      end)
      optionsTab.BroadcastMaxBids:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    end
    -- Bid Timer Slider
    optionsTab.bidTimerSlider = CreateFrame("SLIDER", "$parentBidTimerSlider", optionsTab, "MonDKPOptionsSliderTemplate");
    if MonDKP_DB.modes.mode == "Minimum Bid Values" or (MonDKP_DB.modes.mode == "Zero Sum" and MonDKP_DB.modes.ZeroSumBidType == "Minimum Bid") then
      optionsTab.bidTimerSlider:SetPoint("TOPLEFT", optionsTab.DefaultMaxBids, "BOTTOMLEFT", 54, -40);
    else
      optionsTab.bidTimerSlider:SetPoint("TOPLEFT", optionsTab.DefaultMinBids, "BOTTOMLEFT", 54, -40);
    end
    optionsTab.bidTimerSlider:SetMinMaxValues(10, 90);
    optionsTab.bidTimerSlider:SetValue(MonDKP_DB.DKPBonus.BidTimer);
    optionsTab.bidTimerSlider:SetValueStep(1);
    optionsTab.bidTimerSlider.tooltipText = L["BIDTIMER"]
    optionsTab.bidTimerSlider.tooltipRequirement = L["BIDTIMERDEFAULTTTDESC"]
    optionsTab.bidTimerSlider:SetObeyStepOnDrag(true);
    getglobal(optionsTab.bidTimerSlider:GetName() .. "Low"):SetText("10")
    getglobal(optionsTab.bidTimerSlider:GetName() .. "High"):SetText("90")
    optionsTab.bidTimerSlider:SetScript("OnValueChanged", function(self) -- clears focus on esc
      optionsTab.bidTimer:SetText(optionsTab.bidTimerSlider:GetValue())
    end)

    optionsTab.bidTimerHeader = optionsTab:CreateFontString(nil, "OVERLAY")
    optionsTab.bidTimerHeader:SetFontObject("MonDKPTinyCenter");
    optionsTab.bidTimerHeader:SetPoint("BOTTOM", optionsTab.bidTimerSlider, "TOP", 0, 3);
    optionsTab.bidTimerHeader:SetText(L["BIDTIMER"])

    optionsTab.bidTimer = CreateFrame("EditBox", nil, optionsTab)
    optionsTab.bidTimer:SetAutoFocus(false)
    optionsTab.bidTimer:SetMultiLine(false)
    optionsTab.bidTimer:SetSize(50, 18)
    optionsTab.bidTimer:SetBackdrop({
      bgFile = "Textures\\white.blp",
      tile = true,
      edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
      tile = true,
      tileSize = 32,
      edgeSize = 2,
    });
    optionsTab.bidTimer:SetBackdropColor(0, 0, 0, 0.9)
    optionsTab.bidTimer:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
    optionsTab.bidTimer:SetMaxLetters(4)
    optionsTab.bidTimer:SetTextColor(1, 1, 1, 1)
    optionsTab.bidTimer:SetFontObject("MonDKPTinyCenter")
    optionsTab.bidTimer:SetTextInsets(10, 10, 5, 5)
    optionsTab.bidTimer:SetScript("OnEscapePressed", function(self) -- clears focus on esc
      self:ClearFocus()
    end)
    optionsTab.bidTimer:SetScript("OnEnterPressed", function(self) -- clears focus on esc
      self:ClearFocus()
    end)
    optionsTab.bidTimer:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
      optionsTab.bidTimerSlider:SetValue(optionsTab.bidTimer:GetNumber());
    end)
    optionsTab.bidTimer:SetPoint("TOP", optionsTab.bidTimerSlider, "BOTTOM", 0, -3)
    optionsTab.bidTimer:SetText(optionsTab.bidTimerSlider:GetValue())
  end

  -- Tooltip History Slider
  optionsTab.TooltipHistorySlider = CreateFrame("SLIDER", "$parentTooltipHistorySlider", optionsTab, "MonDKPOptionsSliderTemplate");
  if optionsTab.bidTimer then
    optionsTab.TooltipHistorySlider:SetPoint("LEFT", optionsTab.bidTimerSlider, "RIGHT", 30, 0);
  else
    optionsTab.TooltipHistorySlider:SetPoint("TOP", optionsTab, "TOP", 1, -107);
  end
  optionsTab.TooltipHistorySlider:SetMinMaxValues(5, 35);
  optionsTab.TooltipHistorySlider:SetValue(MonDKP_DB.defaults.TooltipHistoryCount);
  optionsTab.TooltipHistorySlider:SetValueStep(1);
  optionsTab.TooltipHistorySlider.tooltipText = L["TTHISTORYCOUNT"]
  optionsTab.TooltipHistorySlider.tooltipRequirement = L["TTHISTORYCOUNTTTDESC"]
  optionsTab.TooltipHistorySlider:SetObeyStepOnDrag(true);
  getglobal(optionsTab.TooltipHistorySlider:GetName() .. "Low"):SetText("5")
  getglobal(optionsTab.TooltipHistorySlider:GetName() .. "High"):SetText("35")
  optionsTab.TooltipHistorySlider:SetScript("OnValueChanged", function(self) -- clears focus on esc
    optionsTab.TooltipHistory:SetText(optionsTab.TooltipHistorySlider:GetValue())
  end)

  optionsTab.TooltipHistoryHeader = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.TooltipHistoryHeader:SetFontObject("MonDKPTinyCenter");
  optionsTab.TooltipHistoryHeader:SetPoint("BOTTOM", optionsTab.TooltipHistorySlider, "TOP", 0, 3);
  optionsTab.TooltipHistoryHeader:SetText(L["TTHISTORYCOUNT"])

  optionsTab.TooltipHistory = CreateFrame("EditBox", nil, optionsTab)
  optionsTab.TooltipHistory:SetAutoFocus(false)
  optionsTab.TooltipHistory:SetMultiLine(false)
  optionsTab.TooltipHistory:SetSize(50, 18)
  optionsTab.TooltipHistory:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  optionsTab.TooltipHistory:SetBackdropColor(0, 0, 0, 0.9)
  optionsTab.TooltipHistory:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  optionsTab.TooltipHistory:SetMaxLetters(4)
  optionsTab.TooltipHistory:SetTextColor(1, 1, 1, 1)
  optionsTab.TooltipHistory:SetFontObject("MonDKPTinyCenter")
  optionsTab.TooltipHistory:SetTextInsets(10, 10, 5, 5)
  optionsTab.TooltipHistory:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.TooltipHistory:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.TooltipHistory:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
    optionsTab.TooltipHistorySlider:SetValue(optionsTab.TooltipHistory:GetNumber());
  end)
  optionsTab.TooltipHistory:SetPoint("TOP", optionsTab.TooltipHistorySlider, "BOTTOM", 0, -3)
  optionsTab.TooltipHistory:SetText(optionsTab.TooltipHistorySlider:GetValue())


  -- Loot History Limit Slider
  optionsTab.historySlider = CreateFrame("SLIDER", "$parentHistorySlider", optionsTab, "MonDKPOptionsSliderTemplate");
  if optionsTab.bidTimer then
    optionsTab.historySlider:SetPoint("TOPLEFT", optionsTab.bidTimerSlider, "BOTTOMLEFT", 0, -50);
  else
    optionsTab.historySlider:SetPoint("TOPRIGHT", optionsTab.TooltipHistorySlider, "BOTTOMLEFT", 56, -49);
  end
  optionsTab.historySlider:SetMinMaxValues(500, 2500);
  optionsTab.historySlider:SetValue(MonDKP_DB.defaults.HistoryLimit);
  optionsTab.historySlider:SetValueStep(25);
  optionsTab.historySlider.tooltipText = L["LOOTHISTORYLIMIT"]
  optionsTab.historySlider.tooltipRequirement = L["LOOTHISTLIMITTTDESC"]
  optionsTab.historySlider.tooltipWarning = L["LOOTHISTLIMITTTWARN"]
  optionsTab.historySlider:SetObeyStepOnDrag(true);
  getglobal(optionsTab.historySlider:GetName() .. "Low"):SetText("500")
  getglobal(optionsTab.historySlider:GetName() .. "High"):SetText("2500")
  optionsTab.historySlider:SetScript("OnValueChanged", function(self) -- clears focus on esc
    optionsTab.history:SetText(optionsTab.historySlider:GetValue())
  end)

  optionsTab.HistoryHeader = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.HistoryHeader:SetFontObject("MonDKPTinyCenter");
  optionsTab.HistoryHeader:SetPoint("BOTTOM", optionsTab.historySlider, "TOP", 0, 3);
  optionsTab.HistoryHeader:SetText(L["LOOTHISTORYLIMIT"])

  optionsTab.history = CreateFrame("EditBox", nil, optionsTab)
  optionsTab.history:SetAutoFocus(false)
  optionsTab.history:SetMultiLine(false)
  optionsTab.history:SetSize(50, 18)
  optionsTab.history:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  optionsTab.history:SetBackdropColor(0, 0, 0, 0.9)
  optionsTab.history:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  optionsTab.history:SetMaxLetters(4)
  optionsTab.history:SetTextColor(1, 1, 1, 1)
  optionsTab.history:SetFontObject("MonDKPTinyCenter")
  optionsTab.history:SetTextInsets(10, 10, 5, 5)
  optionsTab.history:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.history:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.history:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
    optionsTab.historySlider:SetValue(optionsTab.history:GetNumber());
  end)
  optionsTab.history:SetPoint("TOP", optionsTab.historySlider, "BOTTOM", 0, -3)
  optionsTab.history:SetText(optionsTab.historySlider:GetValue())

  -- DKP History Limit Slider
  optionsTab.DKPHistorySlider = CreateFrame("SLIDER", "$parentDKPHistorySlider", optionsTab, "MonDKPOptionsSliderTemplate");
  optionsTab.DKPHistorySlider:SetPoint("LEFT", optionsTab.historySlider, "RIGHT", 30, 0);
  optionsTab.DKPHistorySlider:SetMinMaxValues(500, 2500);
  optionsTab.DKPHistorySlider:SetValue(MonDKP_DB.defaults.DKPHistoryLimit);
  optionsTab.DKPHistorySlider:SetValueStep(25);
  optionsTab.DKPHistorySlider.tooltipText = L["DKPHISTORYLIMIT"]
  optionsTab.DKPHistorySlider.tooltipRequirement = L["DKPHISTLIMITTTDESC"]
  optionsTab.DKPHistorySlider.tooltipWarning = L["DKPHISTLIMITTTWARN"]
  optionsTab.DKPHistorySlider:SetObeyStepOnDrag(true);
  getglobal(optionsTab.DKPHistorySlider:GetName() .. "Low"):SetText("500")
  getglobal(optionsTab.DKPHistorySlider:GetName() .. "High"):SetText("2500")
  optionsTab.DKPHistorySlider:SetScript("OnValueChanged", function(self) -- clears focus on esc
    optionsTab.DKPHistory:SetText(optionsTab.DKPHistorySlider:GetValue())
  end)

  optionsTab.DKPHistoryHeader = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.DKPHistoryHeader:SetFontObject("MonDKPTinyCenter");
  optionsTab.DKPHistoryHeader:SetPoint("BOTTOM", optionsTab.DKPHistorySlider, "TOP", 0, 3);
  optionsTab.DKPHistoryHeader:SetText(L["DKPHISTORYLIMIT"])

  optionsTab.DKPHistory = CreateFrame("EditBox", nil, optionsTab)
  optionsTab.DKPHistory:SetAutoFocus(false)
  optionsTab.DKPHistory:SetMultiLine(false)
  optionsTab.DKPHistory:SetSize(50, 18)
  optionsTab.DKPHistory:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  optionsTab.DKPHistory:SetBackdropColor(0, 0, 0, 0.9)
  optionsTab.DKPHistory:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  optionsTab.DKPHistory:SetMaxLetters(4)
  optionsTab.DKPHistory:SetTextColor(1, 1, 1, 1)
  optionsTab.DKPHistory:SetFontObject("MonDKPTinyCenter")
  optionsTab.DKPHistory:SetTextInsets(10, 10, 5, 5)
  optionsTab.DKPHistory:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.DKPHistory:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.DKPHistory:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
    optionsTab.DKPHistorySlider:SetValue(optionsTab.history:GetNumber());
  end)
  optionsTab.DKPHistory:SetPoint("TOP", optionsTab.DKPHistorySlider, "BOTTOM", 0, -3)
  optionsTab.DKPHistory:SetText(optionsTab.DKPHistorySlider:GetValue())

  -- Bid Timer Size Slider
  optionsTab.TimerSizeSlider = CreateFrame("SLIDER", "$parentBidTimerSizeSlider", optionsTab, "MonDKPOptionsSliderTemplate");
  optionsTab.TimerSizeSlider:SetPoint("TOPLEFT", optionsTab.historySlider, "BOTTOMLEFT", 0, -50);
  optionsTab.TimerSizeSlider:SetMinMaxValues(0.5, 2.0);
  optionsTab.TimerSizeSlider:SetValue(MonDKP_DB.defaults.BidTimerSize);
  optionsTab.TimerSizeSlider:SetValueStep(0.05);
  optionsTab.TimerSizeSlider.tooltipText = L["TIMERSIZE"]
  optionsTab.TimerSizeSlider.tooltipRequirement = L["TIMERSIZETTDESC"]
  optionsTab.TimerSizeSlider.tooltipWarning = L["TIMERSIZETTWARN"]
  optionsTab.TimerSizeSlider:SetObeyStepOnDrag(true);
  getglobal(optionsTab.TimerSizeSlider:GetName() .. "Low"):SetText("50%")
  getglobal(optionsTab.TimerSizeSlider:GetName() .. "High"):SetText("200%")
  optionsTab.TimerSizeSlider:SetScript("OnValueChanged", function(self)
    optionsTab.TimerSize:SetText(optionsTab.TimerSizeSlider:GetValue())
    MonDKP_DB.defaults.BidTimerSize = optionsTab.TimerSizeSlider:GetValue();
    MonDKP.BidTimer:SetScale(MonDKP_DB.defaults.BidTimerSize);
  end)

  optionsTab.DKPHistoryHeader = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.DKPHistoryHeader:SetFontObject("MonDKPTinyCenter");
  optionsTab.DKPHistoryHeader:SetPoint("BOTTOM", optionsTab.TimerSizeSlider, "TOP", 0, 3);
  optionsTab.DKPHistoryHeader:SetText(L["TIMERSIZE"])

  optionsTab.TimerSize = CreateFrame("EditBox", nil, optionsTab)
  optionsTab.TimerSize:SetAutoFocus(false)
  optionsTab.TimerSize:SetMultiLine(false)
  optionsTab.TimerSize:SetSize(50, 18)
  optionsTab.TimerSize:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  optionsTab.TimerSize:SetBackdropColor(0, 0, 0, 0.9)
  optionsTab.TimerSize:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  optionsTab.TimerSize:SetMaxLetters(4)
  optionsTab.TimerSize:SetTextColor(1, 1, 1, 1)
  optionsTab.TimerSize:SetFontObject("MonDKPTinyCenter")
  optionsTab.TimerSize:SetTextInsets(10, 10, 5, 5)
  optionsTab.TimerSize:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.TimerSize:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.TimerSize:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
    optionsTab.TimerSizeSlider:SetValue(optionsTab.TimerSize:GetNumber());
  end)
  optionsTab.TimerSize:SetPoint("TOP", optionsTab.TimerSizeSlider, "BOTTOM", 0, -3)
  optionsTab.TimerSize:SetText(optionsTab.TimerSizeSlider:GetValue())

  -- UI Scale Size Slider
  optionsTab.MonDKPScaleSize = CreateFrame("SLIDER", "$parentMonDKPScaleSizeSlider", optionsTab, "MonDKPOptionsSliderTemplate");
  optionsTab.MonDKPScaleSize:SetPoint("TOPLEFT", optionsTab.DKPHistorySlider, "BOTTOMLEFT", 0, -50);
  optionsTab.MonDKPScaleSize:SetMinMaxValues(0.5, 2.0);
  optionsTab.MonDKPScaleSize:SetValue(MonDKP_DB.defaults.MonDKPScaleSize);
  optionsTab.MonDKPScaleSize:SetValueStep(0.05);
  optionsTab.MonDKPScaleSize.tooltipText = L["MONDKPSCALESIZE"]
  optionsTab.MonDKPScaleSize.tooltipRequirement = L["MONDKPSCALESIZETTDESC"]
  optionsTab.MonDKPScaleSize.tooltipWarning = L["MONDKPSCALESIZETTWARN"]
  optionsTab.MonDKPScaleSize:SetObeyStepOnDrag(true);
  getglobal(optionsTab.MonDKPScaleSize:GetName() .. "Low"):SetText("50%")
  getglobal(optionsTab.MonDKPScaleSize:GetName() .. "High"):SetText("200%")
  optionsTab.MonDKPScaleSize:SetScript("OnValueChanged", function(self)
    optionsTab.UIScaleSize:SetText(optionsTab.MonDKPScaleSize:GetValue())
    MonDKP_DB.defaults.MonDKPScaleSize = optionsTab.MonDKPScaleSize:GetValue();
  end)

  optionsTab.DKPHistoryHeader = optionsTab:CreateFontString(nil, "OVERLAY")
  optionsTab.DKPHistoryHeader:SetFontObject("MonDKPTinyCenter");
  optionsTab.DKPHistoryHeader:SetPoint("BOTTOM", optionsTab.MonDKPScaleSize, "TOP", 0, 3);
  optionsTab.DKPHistoryHeader:SetText(L["MAINGUISIZE"])

  optionsTab.UIScaleSize = CreateFrame("EditBox", nil, optionsTab)
  optionsTab.UIScaleSize:SetAutoFocus(false)
  optionsTab.UIScaleSize:SetMultiLine(false)
  optionsTab.UIScaleSize:SetSize(50, 18)
  optionsTab.UIScaleSize:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\AddOns\\AxisRaidLoot\\Media\\Textures\\edgefile",
    tile = true,
    tileSize = 32,
    edgeSize = 2,
  });
  optionsTab.UIScaleSize:SetBackdropColor(0, 0, 0, 0.9)
  optionsTab.UIScaleSize:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  optionsTab.UIScaleSize:SetMaxLetters(4)
  optionsTab.UIScaleSize:SetTextColor(1, 1, 1, 1)
  optionsTab.UIScaleSize:SetFontObject("MonDKPTinyCenter")
  optionsTab.UIScaleSize:SetTextInsets(10, 10, 5, 5)
  optionsTab.UIScaleSize:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.UIScaleSize:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    self:ClearFocus()
  end)
  optionsTab.UIScaleSize:SetScript("OnEditFocusLost", function(self) -- clears focus on esc
    optionsTab.MonDKPScaleSize:SetValue(optionsTab.UIScaleSize:GetNumber());
  end)
  optionsTab.UIScaleSize:SetPoint("TOP", optionsTab.MonDKPScaleSize, "BOTTOM", 0, -3)
  optionsTab.UIScaleSize:SetText(optionsTab.MonDKPScaleSize:GetValue())

  -- Supress Broadcast Notifications checkbox
  optionsTab.supressNotifications = CreateFrame("CheckButton", nil, optionsTab, "UICheckButtonTemplate");
  optionsTab.supressNotifications:SetPoint("TOP", optionsTab.TimerSizeSlider, "BOTTOMLEFT", 0, -35)
  optionsTab.supressNotifications:SetChecked(MonDKP_DB.defaults.supressNotifications)
  optionsTab.supressNotifications:SetScale(0.8)
  optionsTab.supressNotifications.text:SetText("|cff999999" .. L["SUPPRESSNOTIFICATIONS"] .. "|r");
  optionsTab.supressNotifications.text:SetFontObject("MonDKPSmall")
  optionsTab.supressNotifications:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["SUPPRESSNOTIFICATIONS"], 0.25, 0.75, 0.90, 1, true)
    GameTooltip:AddLine(L["SUPPRESSNOTIFYTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["SUPPRESSNOTIFYTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show()
  end)
  optionsTab.supressNotifications:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  optionsTab.supressNotifications:SetScript("OnClick", function()
    if optionsTab.supressNotifications:GetChecked() then
      MonDKP.Print(L["NOTIFICATIONSLIKETHIS"] .. " |cffff0000" .. L["HIDDEN"] .. "|r.")
      MonDKP_DB["defaults"]["supressNotifications"] = true;
    else
      MonDKP_DB["defaults"]["supressNotifications"] = false;
      MonDKP.Print(L["NOTIFICATIONSLIKETHIS"] .. " |cff00ff00" .. L["VISIBLE"] .. "|r.")
    end
    PlaySound(808)
  end)

  -- Combat Logging checkbox
  optionsTab.CombatLogging = CreateFrame("CheckButton", nil, optionsTab, "UICheckButtonTemplate");
  optionsTab.CombatLogging:SetPoint("TOP", optionsTab.supressNotifications, "BOTTOM", 0, 0)
  optionsTab.CombatLogging:SetChecked(MonDKP_DB.defaults.AutoLog)
  optionsTab.CombatLogging:SetScale(0.8)
  optionsTab.CombatLogging.text:SetText("|cff999999" .. L["AUTOCOMBATLOG"] .. "|r");
  optionsTab.CombatLogging.text:SetFontObject("MonDKPSmall")
  optionsTab.CombatLogging:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["AUTOCOMBATLOG"], 0.25, 0.75, 0.90, 1, true)
    GameTooltip:AddLine(L["AUTOCOMBATLOGTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["AUTOCOMBATLOGTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show()
  end)
  optionsTab.CombatLogging:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  optionsTab.CombatLogging:SetScript("OnClick", function(self)
    MonDKP_DB.defaults.AutoLog = self:GetChecked()
    PlaySound(808)
  end)

  if MonDKP_DB.defaults.AutoOpenBid == nil then
    MonDKP_DB.defaults.AutoOpenBid = true
  end

  optionsTab.AutoOpenCheckbox = CreateFrame("CheckButton", nil, optionsTab, "UICheckButtonTemplate");
  optionsTab.AutoOpenCheckbox:SetChecked(MonDKP_DB.defaults.AutoOpenBid)
  optionsTab.AutoOpenCheckbox:SetScale(0.8);
  optionsTab.AutoOpenCheckbox.text:SetText("|cff999999" .. L["AUTOOPEN"] .. "|r");
  optionsTab.AutoOpenCheckbox.text:SetScale(1);
  optionsTab.AutoOpenCheckbox.text:SetFontObject("MonDKPSmallLeft")
  optionsTab.AutoOpenCheckbox:SetPoint("TOP", optionsTab.CombatLogging, "BOTTOM", 0, 0);
  optionsTab.AutoOpenCheckbox:SetScript("OnClick", function(self)
    MonDKP_DB.defaults.AutoOpenBid = self:GetChecked()
  end)
  optionsTab.AutoOpenCheckbox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:SetText(L["AUTOOPEN"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["AUTOOPENTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  optionsTab.AutoOpenCheckbox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  if core.IsOfficer == true then
    -- Supress Broadcast Notifications checkbox
    optionsTab.supressTells = CreateFrame("CheckButton", nil, optionsTab, "UICheckButtonTemplate");
    optionsTab.supressTells:SetPoint("LEFT", optionsTab.supressNotifications, "RIGHT", 200, 0)
    optionsTab.supressTells:SetChecked(MonDKP_DB.defaults.SupressTells)
    optionsTab.supressTells:SetScale(0.8)
    optionsTab.supressTells.text:SetText("|cff999999" .. L["SUPPRESSBIDWHISP"] .. "|r");
    optionsTab.supressTells.text:SetFontObject("MonDKPSmall")
    optionsTab.supressTells:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["SUPPRESSBIDWHISP"], 0.25, 0.75, 0.90, 1, true)
      GameTooltip:AddLine(L["SUPRESSBIDWHISPTTDESC"], 1.0, 1.0, 1.0, true);
      GameTooltip:AddLine(L["SUPRESSBIDWHISPTTWARN"], 1.0, 0, 0, true);
      GameTooltip:Show()
    end)
    optionsTab.supressTells:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    optionsTab.supressTells:SetScript("OnClick", function()
      if optionsTab.supressTells:GetChecked() then
        MonDKP.Print(L["BIDWHISPARENOW"] .. " |cffff0000" .. L["HIDDEN"] .. "|r.")
        MonDKP_DB["defaults"]["SupressTells"] = true;
      else
        MonDKP_DB["defaults"]["SupressTells"] = false;
        MonDKP.Print(L["BIDWHISPARENOW"] .. " |cff00ff00" .. L["VISIBLE"] .. "|r.")
      end
      PlaySound(808)
    end)
  end

  -- Save Settings Button
  optionsTab.submitSettings = self:CreateButton("BOTTOMLEFT", optionsTab, "BOTTOMLEFT", 30, 30, L["SAVESETTINGS"]);
  optionsTab.submitSettings:ClearAllPoints();
  optionsTab.submitSettings:SetPoint("TOP", optionsTab.AutoOpenCheckbox, "BOTTOMLEFT", 20, -40)
  optionsTab.submitSettings:SetSize(90, 25)
  optionsTab.submitSettings:SetScript("OnClick", function()
    if core.IsOfficer == true then
      for i = 1, 6 do
        if not tonumber(optionsTab.default[i]:GetText()) then
          StaticPopupDialogs["OPTIONS_VALIDATION"] = {
            text = L["INVALIDOPTIONENTRY"] .. " " .. optionsTab.default[i].tooltipText .. ". " .. L["PLEASEUSENUMS"],
            button1 = L["OK"],
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
          }
          StaticPopup_Show("OPTIONS_VALIDATION")

          return;
        end
      end
      for i = 1, 17 do
        if not tonumber(optionsTab.DefaultMinBids.SlotBox[i]:GetText()) then
          StaticPopupDialogs["OPTIONS_VALIDATION"] = {
            text = L["INVALIDMINBIDENTRY"] .. " " .. optionsTab.DefaultMinBids.SlotBox[i].tooltipText .. ". " .. L["PLEASEUSENUMS"],
            button1 = L["OK"],
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
          }
          StaticPopup_Show("OPTIONS_VALIDATION")

          return;
        end
      end
    end

    SaveSettings()
    MonDKP.Print(L["DEFAULTSETSAVED"])
  end)

  -- Chatframe Selection 
  optionsTab.ChatFrame = CreateFrame("FRAME", "MonDKPChatFrameSelectDropDown", optionsTab, "MonolithDKPUIDropDownMenuTemplate")
  if not MonDKP_DB.defaults.ChatFrames then MonDKP_DB.defaults.ChatFrames = {} end

  UIDropDownMenu_Initialize(optionsTab.ChatFrame, function(self, level, menuList)
    local SelectedFrame = UIDropDownMenu_CreateInfo()
    SelectedFrame.func = self.SetValue
    SelectedFrame.fontObject = "MonDKPSmallCenter"
    SelectedFrame.keepShownOnClick = true;
    SelectedFrame.isNotRadio = true;

    for i = 1, NUM_CHAT_WINDOWS do
      local name = GetChatWindowInfo(i)
      if name ~= "" then
        SelectedFrame.text, SelectedFrame.arg1, SelectedFrame.checked = name, name, MonDKP_DB.defaults.ChatFrames[name]
        UIDropDownMenu_AddButton(SelectedFrame)
      end
    end
  end)

  optionsTab.ChatFrame:SetPoint("LEFT", optionsTab.CombatLogging, "RIGHT", 130, 0)
  UIDropDownMenu_SetWidth(optionsTab.ChatFrame, 150)
  UIDropDownMenu_SetText(optionsTab.ChatFrame, "Addon Notifications")

  function optionsTab.ChatFrame:SetValue(arg1)
    MonDKP_DB.defaults.ChatFrames[arg1] = not MonDKP_DB.defaults.ChatFrames[arg1]
    CloseDropDownMenus()
  end



  -- Position Bid Timer Button
  optionsTab.moveTimer = self:CreateButton("BOTTOMRIGHT", optionsTab, "BOTTOMRIGHT", -50, 30, L["MOVEBIDTIMER"]);
  optionsTab.moveTimer:ClearAllPoints();
  optionsTab.moveTimer:SetPoint("LEFT", optionsTab.submitSettings, "RIGHT", 200, 0)
  optionsTab.moveTimer:SetSize(110, 25)
  optionsTab.moveTimer:SetScript("OnClick", function()
    if moveTimerToggle == 0 then
      MonDKP:StartTimer(120, L["MOVEME"])
      optionsTab.moveTimer:SetText(L["HIDEBIDTIMER"])
      moveTimerToggle = 1;
    else
      MonDKP.BidTimer:SetScript("OnUpdate", nil)
      MonDKP.BidTimer:Hide()
      optionsTab.moveTimer:SetText(L["MOVEBIDTIMER"])
      moveTimerToggle = 0;
    end
  end)

  -- wipe tables button
  optionsTab.WipeTables = self:CreateButton("BOTTOMRIGHT", optionsTab, "BOTTOMRIGHT", -50, 30, L["WIPETABLES"]);
  optionsTab.WipeTables:ClearAllPoints();
  optionsTab.WipeTables:SetPoint("RIGHT", optionsTab.moveTimer, "LEFT", -40, 0)
  optionsTab.WipeTables:SetSize(110, 25)
  optionsTab.WipeTables:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["WIPETABLES"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["WIPETABLESTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  optionsTab.WipeTables:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  optionsTab.WipeTables:SetScript("OnClick", function()

    StaticPopupDialogs["WIPE_TABLES"] = {
      text = L["WIPETABLESCONF"],
      button1 = L["YES"],
      button2 = L["NO"],
      OnAccept = function()
        MonDKP_Whitelist = nil
        MonDKP_DKPTable = nil
        MonDKP_Loot = nil
        MonDKP_DKPHistory = nil
        MonDKP_Archive = nil
        MonDKP_Standby = nil
        MonDKP_MinBids = nil
        MonDKP_MaxBids = nil

        MonDKP_DKPTable = {}
        MonDKP_Loot = {}
        MonDKP_DKPHistory = {}
        MonDKP_Archive = {}
        MonDKP_Whitelist = {}
        MonDKP_Standby = {}
        MonDKP_MinBids = {}
        MonDKP_MaxBids = {}
        MonDKP:LootHistory_Reset()
        MonDKP:FilterDKPTable(core.currentSort, "reset")
        MonDKP:StatusVerify_Update()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("WIPE_TABLES")
  end)

  -- Options Footer (empty frame to push bottom of scrollframe down)
  optionsTab.OptionsFooterFrame = CreateFrame("Frame", nil, optionsTab);
  optionsTab.OptionsFooterFrame:SetPoint("TOPLEFT", optionsTab.moveTimer, "BOTTOMLEFT")
  optionsTab.OptionsFooterFrame:SetSize(420, 50);
end