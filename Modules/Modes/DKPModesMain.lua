local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

function MonDKP:DKPModes_Main()
  local fMain = core.ModesWindow.DKPModesMain

  fMain.ModeDescriptionHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ModeDescriptionHeader:SetFontObject("MonDKPLargeLeft");
  fMain.ModeDescriptionHeader:SetWidth(400);
  fMain.ModeDescriptionHeader:SetPoint("TOPLEFT", fMain, "TOPLEFT", 30, -20);

  fMain.ModeDescription = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ModeDescription:SetPoint("TOPLEFT", fMain, "TOPLEFT", 20, -45);
  fMain.ModeDescription:SetWidth(400);
  fMain.ModeDescription:SetFontObject("MonDKPSmallLeft")

  local MinBidDescription = L["MINBIDDESCRIPTION"]
  local StaticDescription = L["STATICDESCRIPTION"]
  local RollDescription = L["ROLLDESCRIPTION"]
  local ZeroSumDescription = L["ZEROSUMDESCRIPTION"];

  if MonDKP_DB.modes.mode == "Minimum Bid Values" then
    fMain.ModeDescriptionHeader:SetText(L["MINBIDVALUESHEAD"])
    fMain.ModeDescription:SetText(MinBidDescription)
  elseif MonDKP_DB.modes.mode == "Static Item Values" then
    fMain.ModeDescriptionHeader:SetText(L["STATICITEMVALUESHEAD"])
    fMain.ModeDescription:SetText(StaticDescription)
  elseif MonDKP_DB.modes.mode == "Roll Based Bidding" then
    fMain.ModeDescriptionHeader:SetText(L["ROLLBIDDINGHEAD"])
    fMain.ModeDescription:SetText(RollDescription)
  elseif MonDKP_DB.modes.mode == "Zero Sum" then
    fMain.ModeDescriptionHeader:SetText(L["ZEROSUMHEAD"])
    fMain.ModeDescription:SetText(ZeroSumDescription)
  end

  -- Mode DROPDOWN box 
  local CurMode = MonDKP_DB.modes.mode;
  local LocalMode;

  if CurMode == "Minimum Bid Values" then
    LocalMode = L["MINBIDVALUESHEAD"];
  elseif CurMode == "Static Item Values" then
    LocalMode = L["STATICITEMVALUESHEAD"]
  elseif CurMode == "Roll Based Bidding" then
    LocalMode = L["ROLLBIDDINGHEAD"]
  elseif CurMode == "Zero Sum" then
    LocalMode = L["ZEROSUMHEAD"]
  end


  fMain.ModesDropDown = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.ModesDropDown, function(self, level, menuList)
    local DKPMode = UIDropDownMenu_CreateInfo()
    DKPMode.func = self.SetValue
    DKPMode.fontObject = "MonDKPSmallCenter"
    DKPMode.text, DKPMode.arg1, DKPMode.checked, DKPMode.isNotRadio =
      L["MINBIDVALUESHEAD"], "Minimum Bid Values", "Minimum Bid Values" == CurMode, false
    UIDropDownMenu_AddButton(DKPMode)
    DKPMode.text, DKPMode.arg1, DKPMode.checked, DKPMode.isNotRadio =
      L["STATICITEMVALUESHEAD"], "Static Item Values", "Static Item Values" == CurMode, false
    UIDropDownMenu_AddButton(DKPMode)
    DKPMode.text, DKPMode.arg1, DKPMode.checked, DKPMode.isNotRadio =
      L["ROLLBIDDINGHEAD"], "Roll Based Bidding", "Roll Based Bidding" == CurMode, false
    UIDropDownMenu_AddButton(DKPMode)
    DKPMode.text, DKPMode.arg1, DKPMode.checked, DKPMode.isNotRadio =
      L["ZEROSUMHEAD"], "Zero Sum", "Zero Sum" == CurMode, false
    UIDropDownMenu_AddButton(DKPMode)
  end)

  fMain.ModesDropDown:SetPoint("TOPLEFT", fMain, "TOPLEFT", 10, -200)
  UIDropDownMenu_SetWidth(fMain.ModesDropDown, 150)
  UIDropDownMenu_SetText(fMain.ModesDropDown, LocalMode)

  -- Dropdown Menu Function
  function fMain.ModesDropDown:SetValue(newValue)
    if curMode ~= newValue then CurMode = newValue end

    fMain.ModeDescriptionHeader:SetText(newValue)

    if newValue == "Minimum Bid Values" then
      MonDKP_DB.modes.mode = "Minimum Bid Values";
      fMain.ModeDescription:SetText(MinBidDescription)
      fMain.ItemCostDropDown:Hide();
      fMain.ItemCostHeader:Hide();
      fMain.MaxBidBehaviorDropDown:Show();
      fMain.MaxBidBehaviorHeader:Show();
      MonDKP_DB.modes.costvalue = "Integer";
      UIDropDownMenu_SetText(fMain.ItemCostDropDown, "Integer")
      fMain.SubZeroBidding:Show();
      fMain.SubZeroBidding:SetChecked(MonDKP_DB.modes.SubZeroBidding)
      if MonDKP_DB.modes.SubZeroBidding == true then
        fMain.AllowNegativeBidders:Show()
        fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
      end
      fMain.RollContainer:Hide();
      fMain.ZeroSumType:Hide();
      fMain.ZeroSumTypeHeader:Hide();
      fMain.CostSelection:Show();
      fMain.CostSelectionHeader:Show();
      fMain.Inflation:Hide()
      fMain.Inflation.Header:Hide()
    elseif newValue == "Static Item Values" then
      MonDKP_DB.modes.mode = "Static Item Values"
      fMain.ModeDescription:SetText(StaticDescription)
      fMain.ItemCostHeader:Show();
      fMain.ItemCostDropDown:Show();
      fMain.MaxBidBehaviorDropDown:Hide();
      fMain.MaxBidBehaviorHeader:Hide();
      MonDKP_DB.modes.MaxBehavior = "Max DKP";
      UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, "Max DKP")
      fMain.RollContainer:Hide()
      fMain.ZeroSumType:Hide()
      fMain.ZeroSumTypeHeader:Hide();
      fMain.CostSelection:Hide();
      fMain.CostSelectionHeader:Hide();
      fMain.Inflation:Hide()
      fMain.Inflation.Header:Hide()

      if MonDKP_DB.modes.costvalue == "Integer" then
        fMain.SubZeroBidding:Show()
        fMain.SubZeroBidding:SetChecked(MonDKP_DB.modes.SubZeroBidding)
        if MonDKP_DB.modes.SubZeroBidding == true then
          fMain.AllowNegativeBidders:Show()
          fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
        end
        UIDropDownMenu_SetText(fMain.ItemCostDropDown, "Integer")
      end
    elseif newValue == "Roll Based Bidding" then
      MonDKP_DB.modes.mode = "Roll Based Bidding"
      fMain.ItemCostHeader:Show();
      fMain.ItemCostDropDown:Show();
      fMain.MaxBidBehaviorDropDown:Hide();
      fMain.MaxBidBehaviorHeader:Hide();
      MonDKP_DB.modes.MaxBehavior = "Max DKP";
      UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, "Max DKP")
      fMain.ModeDescription:SetText(RollDescription)
      fMain.RollContainer:Show()
      fMain.ZeroSumType:Hide()
      fMain.ZeroSumTypeHeader:Hide();
      fMain.CostSelection:Hide()
      fMain.CostSelectionHeader:Hide()
      fMain.Inflation:Hide()
      fMain.Inflation.Header:Hide()

      if MonDKP_DB.modes.costvalue == "Integer" then
        fMain.SubZeroBidding:Show()
        fMain.SubZeroBidding:SetChecked(MonDKP_DB.modes.SubZeroBidding)
        if MonDKP_DB.modes.SubZeroBidding == true then
          fMain.AllowNegativeBidders:Show()
          fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
        end
        UIDropDownMenu_SetText(fMain.ItemCostDropDown, "Integer")
      end
    elseif newValue == "Zero Sum" then
      MonDKP_DB.modes.mode = "Zero Sum"
      MonDKP_DB.modes.costvalue = "Integer"
      fMain.ModeDescription:SetText(ZeroSumDescription)
      fMain.SubZeroBidding:Hide()
      fMain.AllowNegativeBidders:Hide()
      fMain.RollContainer:Hide()
      fMain.ItemCostHeader:Hide();
      UIDropDownMenu_SetText(fMain.ItemCostDropDown, "Integer")
      fMain.ItemCostDropDown:Hide();
      fMain.ZeroSumType:Show()
      fMain.ZeroSumTypeHeader:Show();
      MonDKP_DB.modes.SubZeroBidding = true
      fMain.Inflation:Show()
      fMain.Inflation.Header:Show()

      if MonDKP_DB.modes.ZeroSumBidType == "Static" then
        fMain.MaxBidBehaviorDropDown:Hide();
        fMain.MaxBidBehaviorHeader:Hide();
        MonDKP_DB.modes.MaxBehavior = "Max DKP";
        UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, "Max DKP")
        fMain.CostSelection:Hide()
        fMain.CostSelectionHeader:Hide()
      else
        fMain.MaxBidBehaviorDropDown:Show();
        fMain.MaxBidBehaviorHeader:Show();
        fMain.CostSelection:Show()
        fMain.CostSelectionHeader:Show()
        fMain.SubZeroBidding:Show()
        fMain.AllowNegativeBidders:Show()
      end
    end

    if CurMode == "Minimum Bid Values" then
      LocalMode = L["MINBIDVALUESHEAD"];
    elseif CurMode == "Static Item Values" then
      LocalMode = L["STATICITEMVALUESHEAD"]
    elseif CurMode == "Roll Based Bidding" then
      LocalMode = L["ROLLBIDDINGHEAD"]
    elseif CurMode == "Zero Sum" then
      LocalMode = L["ZEROSUMHEAD"]
    end

    UIDropDownMenu_SetText(fMain.ModesDropDown, LocalMode)
    CloseDropDownMenus()
  end

  fMain.ModesDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["DKPMODES"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["DKPMODESTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.ModesDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.ModeHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ModeHeader:SetPoint("BOTTOMLEFT", fMain.ModesDropDown, "TOPLEFT", 25, 0);
  fMain.ModeHeader:SetFontObject("MonDKPSmallLeft")
  fMain.ModeHeader:SetText(L["DKPMODES"])

  -- Rounding DROPDOWN box 
  fMain.RoundDropDown = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.RoundDropDown, function(self, level, menuList)
    local places = UIDropDownMenu_CreateInfo()
    places.func = self.SetValue
    places.fontObject = "MonDKPSmallCenter"
    places.text, places.arg1, places.checked, places.isNotRadio = 0, 0, 0 == MonDKP_DB.modes.rounding, false
    UIDropDownMenu_AddButton(places)
    places.text, places.arg1, places.checked, places.isNotRadio = 1, 1, 1 == MonDKP_DB.modes.rounding, false
    UIDropDownMenu_AddButton(places)
    places.text, places.arg1, places.checked, places.isNotRadio = 2, 2, 2 == MonDKP_DB.modes.rounding, false
    UIDropDownMenu_AddButton(places)
    places.text, places.arg1, places.checked, places.isNotRadio = 3, 3, 3 == MonDKP_DB.modes.rounding, false
    UIDropDownMenu_AddButton(places)
    places.text, places.arg1, places.checked, places.isNotRadio = 4, 4, 4 == MonDKP_DB.modes.rounding, false
    UIDropDownMenu_AddButton(places)
  end)

  fMain.RoundDropDown:SetPoint("TOPLEFT", fMain.ModesDropDown, "BOTTOMLEFT", 0, -95)
  UIDropDownMenu_SetWidth(fMain.RoundDropDown, 80)
  UIDropDownMenu_SetText(fMain.RoundDropDown, MonDKP_DB.modes.rounding)

  -- Dropdown Menu Function
  function fMain.RoundDropDown:SetValue(newValue)
    MonDKP_DB.modes.rounding = newValue;
    UIDropDownMenu_SetText(fMain.RoundDropDown, newValue)
    CloseDropDownMenus()
  end

  fMain.RoundDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  fMain.RoundDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["DKPROUNDING"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["DKPROUNDINGTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.RoundDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.RoundHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.RoundHeader:SetPoint("BOTTOMLEFT", fMain.RoundDropDown, "TOPLEFT", 25, 0);
  fMain.RoundHeader:SetFontObject("MonDKPSmallLeft")
  fMain.RoundHeader:SetText(L["DKPROUNDING"])

  -- MAX Bid button behavior
  fMain.MaxBidBehaviorDropDown = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.MaxBidBehaviorDropDown, function(self, level, menuList)
    local MaxBehavior = UIDropDownMenu_CreateInfo()
    MaxBehavior.func = self.SetValue
    MaxBehavior.fontObject = "MonDKPSmallCenter"
    MaxBehavior.text, MaxBehavior.arg1, MaxBehavior.checked, MaxBehavior.isNotRadio = L["MAXBIDBEHAVIORMAXDKP"], "Max DKP", "Max DKP" == MonDKP_DB.modes.MaxBehavior, false
    UIDropDownMenu_AddButton(MaxBehavior)
    MaxBehavior.text, MaxBehavior.arg1, MaxBehavior.checked, MaxBehavior.isNotRadio = L["MAXBIDBEHAVIORMAXITEMVALUE"], "Max Item Value", "Max Item Value" == MonDKP_DB.modes.MaxBehavior, false
    UIDropDownMenu_AddButton(MaxBehavior)
    MaxBehavior.text, MaxBehavior.arg1, MaxBehavior.checked, MaxBehavior.isNotRadio = L["MAXBIDBEHAVIORMIN"], "Min(Max DKP, Max Item Value)", "Min(Max DKP, Max Item Value)" == MonDKP_DB.modes.MaxBehavior, false
    UIDropDownMenu_AddButton(MaxBehavior)
  end)

  fMain.MaxBidBehaviorDropDown:SetPoint("TOPLEFT", fMain.ModesDropDown, "BOTTOMLEFT", 0, -50)
  UIDropDownMenu_SetWidth(fMain.MaxBidBehaviorDropDown, 200)
  UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, MonDKP_DB.modes.MaxBehavior)

  -- Dropdown Menu Function
  function fMain.MaxBidBehaviorDropDown:SetValue(newValue)
    MonDKP_DB.modes.MaxBehavior = newValue;
    if newValue == "Max DKP" then
      UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, L["MAXBIDBEHAVIORMAXDKP"])
    elseif newValue == "Max Item Value" then
      UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, L["MAXBIDBEHAVIORMAXITEMVALUE"])
    else
      UIDropDownMenu_SetText(fMain.MaxBidBehaviorDropDown, L["MAXBIDBEHAVIORMIN"])
    end
    CloseDropDownMenus()
  end

  fMain.MaxBidBehaviorDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.MaxBidBehaviorDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["MAXBIDBEHAVIOR"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["MAXBIDBEHAVIORTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.MaxBidBehaviorDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.MaxBidBehaviorHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.MaxBidBehaviorHeader:SetPoint("BOTTOMLEFT", fMain.MaxBidBehaviorDropDown, "TOPLEFT", 25, 0);
  fMain.MaxBidBehaviorHeader:SetFontObject("MonDKPSmallLeft")
  fMain.MaxBidBehaviorHeader:SetText(L["MAXBIDBEHAVIOR"])

  -- AntiSnipe Option
  fMain.AntiSnipe = CreateFrame("EditBox", nil, fMain)
  fMain.AntiSnipe:SetAutoFocus(false)
  fMain.AntiSnipe:SetMultiLine(false)
  fMain.AntiSnipe:SetPoint("TOPLEFT", fMain.RoundDropDown, "BOTTOMLEFT", 18, -15)
  fMain.AntiSnipe:SetSize(100, 24)
  fMain.AntiSnipe:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.AntiSnipe:SetBackdropColor(0, 0, 0, 0.9)
  fMain.AntiSnipe:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.AntiSnipe:SetMaxLetters(8)
  fMain.AntiSnipe:SetTextColor(1, 1, 1, 1)
  fMain.AntiSnipe:SetFontObject("MonDKPSmallRight")
  fMain.AntiSnipe:SetTextInsets(10, 15, 5, 5)
  fMain.AntiSnipe:SetText(MonDKP_DB.modes.AntiSnipe)
  fMain.AntiSnipe:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.AntiSnipe = fMain.AntiSnipe:GetNumber()
    self:ClearFocus()
  end)
  fMain.AntiSnipe:SetScript("OnTabPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.AntiSnipe = fMain.AntiSnipe:GetNumber()
    self:ClearFocus()
  end)
  fMain.AntiSnipe:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.AntiSnipe = fMain.AntiSnipe:GetNumber()
    self:ClearFocus()
  end)
  fMain.AntiSnipe:SetScript("OnKeyUp", function(self) -- clears focus on esc
    if fMain.AntiSnipe:GetText():match("%a+") then
      fMain.AntiSnipe:SetNumber(fMain.AntiSnipe:GetNumber() or 0)
      if fMain.AntiSnipe:GetText() == "0" then
        fMain.AntiSnipe:HighlightText()
      end
    else
      MonDKP_DB.modes.AntiSnipe = fMain.AntiSnipe:GetNumber()
    end
  end)
  fMain.AntiSnipe:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ANTISNIPE"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ANTISNIPETTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["ANTISNIPETTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  fMain.AntiSnipe:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.AntiSnipe.Header = fMain.AntiSnipe:CreateFontString(nil, "OVERLAY")
  fMain.AntiSnipe.Header:SetFontObject("MonDKPNormalLeft");
  fMain.AntiSnipe.Header:SetPoint("BOTTOMLEFT", fMain.AntiSnipe, "TOPLEFT", 0, 2);
  fMain.AntiSnipe.Header:SetText(L["ANTISNIPE"])

  -- Channels DROPDOWN box 
  fMain.ChannelsDropDown = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.ChannelsDropDown, function(self, level, menuList)
    local OpenChannel = UIDropDownMenu_CreateInfo()
    OpenChannel.func = self.SetValue
    OpenChannel.fontObject = "MonDKPSmallCenter"
    OpenChannel.keepShownOnClick = true;
    OpenChannel.isNotRadio = true;
    OpenChannel.text, OpenChannel.arg1, OpenChannel.checked = L["WHISPER"], "Whisper", true == MonDKP_DB.modes.channels.whisper
    UIDropDownMenu_AddButton(OpenChannel)
    OpenChannel.text, OpenChannel.arg1, OpenChannel.checked = L["RAID"], "Raid", true == MonDKP_DB.modes.channels.raid
    UIDropDownMenu_AddButton(OpenChannel)
    OpenChannel.text, OpenChannel.arg1, OpenChannel.checked = L["GUILD"], "Guild", true == MonDKP_DB.modes.channels.guild
    UIDropDownMenu_AddButton(OpenChannel)
  end)

  fMain.ChannelsDropDown:SetPoint("LEFT", fMain.ModesDropDown, "RIGHT", 30, 0)
  UIDropDownMenu_SetWidth(fMain.ChannelsDropDown, 150)
  UIDropDownMenu_SetText(fMain.ChannelsDropDown, L["OPENCHANNELS"])

  -- Dropdown Menu Function
  function fMain.ChannelsDropDown:SetValue(arg1)
    if arg1 == "Whisper" then
      MonDKP_DB.modes.channels.whisper = not MonDKP_DB.modes.channels.whisper
    elseif arg1 == "Raid" then
      MonDKP_DB.modes.channels.raid = not MonDKP_DB.modes.channels.raid
    elseif arg1 == "Guild" then
      MonDKP_DB.modes.channels.guild = not MonDKP_DB.modes.channels.guild
    end

    UIDropDownMenu_SetText(fMain.ChannelsDropDown, "Open Channels")
    CloseDropDownMenus()
  end

  fMain.ChannelsDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["COMMANDCHANNELS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["COMMANDCHANNELSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.ChannelsDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.ChannelsHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ChannelsHeader:SetPoint("BOTTOMLEFT", fMain.ChannelsDropDown, "TOPLEFT", 25, 0);
  fMain.ChannelsHeader:SetFontObject("MonDKPSmallLeft")
  fMain.ChannelsHeader:SetText(L["COMMANDCHANNELS"])

  -- Cost Auto Update Value DROPDOWN box 
  if not MonDKP_DB.modes.CostSelection then MonDKP_DB.modes.CostSelection = "Second Bidder" end
  fMain.CostSelection = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")
  fMain.CostSelection:SetPoint("TOPLEFT", fMain.ChannelsDropDown, "BOTTOMLEFT", 0, -10)

  local LocalCostSel;

  if MonDKP_DB.modes.CostSelection == "First Bidder" then
    LocalCostSel = L["FIRSTBIDDER"]
  elseif MonDKP_DB.modes.CostSelection == "Second Bidder" then
    LocalCostSel = L["SECONDBIDDER"]
  end

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.CostSelection, function(self, level, menuList)
    local CostSelect = UIDropDownMenu_CreateInfo()
    CostSelect.func = self.SetValue
    CostSelect.fontObject = "MonDKPSmallCenter"
    CostSelect.text, CostSelect.arg1, CostSelect.checked, CostSelect.isNotRadio = L["FIRSTBIDDER"], "First Bidder", "First Bidder" == MonDKP_DB.modes.CostSelection, false
    UIDropDownMenu_AddButton(CostSelect)
    CostSelect.text, CostSelect.arg1, CostSelect.checked, CostSelect.isNotRadio = L["SECONDBIDDER"], "Second Bidder", "Second Bidder" == MonDKP_DB.modes.CostSelection, false
    UIDropDownMenu_AddButton(CostSelect)
  end)

  UIDropDownMenu_SetWidth(fMain.CostSelection, 150)
  UIDropDownMenu_SetText(fMain.CostSelection, LocalCostSel)

  -- Dropdown Menu Function
  function fMain.CostSelection:SetValue(arg1)
    MonDKP_DB.modes.CostSelection = arg1

    if arg1 == "First Bidder" then
      LocalCostSel = L["FIRSTBIDDER"]
    else
      LocalCostSel = L["SECONDBIDDER"]
    end

    UIDropDownMenu_SetText(fMain.CostSelection, LocalCostSel)
    CloseDropDownMenus()
  end

  fMain.CostSelection:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["COSTAUTOUPDATE"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["COSTAUTOUPDATETTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.CostSelection:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.CostSelectionHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.CostSelectionHeader:SetPoint("BOTTOMLEFT", fMain.CostSelection, "TOPLEFT", 25, 0);
  fMain.CostSelectionHeader:SetFontObject("MonDKPSmallLeft")
  fMain.CostSelectionHeader:SetText(L["COSTAUTOUPDATEVALUE"])

  if not (MonDKP_DB.modes.mode == "Minimum Bid Values" or (MonDKP_DB.modes.mode == "Zero Sum" and MonDKP_DB.modes.ZeroSumBidType == "Minimum Bid")) then
    fMain.CostSelection:Hide()
    fMain.CostSelectionHeader:Hide();
  end

  -- Artificial Inflation Editbox
  if not MonDKP_DB.modes.Inflation then MonDKP_DB.modes.Inflation = 0 end
  fMain.Inflation = CreateFrame("EditBox", nil, fMain)
  fMain.Inflation:SetAutoFocus(false)
  fMain.Inflation:SetMultiLine(false)
  fMain.Inflation:SetPoint("TOPLEFT", fMain.CostSelection, "BOTTOMLEFT", 20, -15)
  fMain.Inflation:SetSize(100, 24)
  fMain.Inflation:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.Inflation:SetBackdropColor(0, 0, 0, 0.9)
  fMain.Inflation:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.Inflation:SetMaxLetters(8)
  fMain.Inflation:SetTextColor(1, 1, 1, 1)
  fMain.Inflation:SetFontObject("MonDKPSmallRight")
  fMain.Inflation:SetTextInsets(10, 15, 5, 5)
  fMain.Inflation:SetText(MonDKP_DB.modes.Inflation)
  fMain.Inflation:Hide();
  fMain.Inflation:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.Inflation = fMain.Inflation:GetNumber()
    self:ClearFocus()
  end)
  fMain.Inflation:SetScript("OnTabPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.Inflation = fMain.Inflation:GetNumber()
    self:ClearFocus()
  end)
  fMain.Inflation:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.Inflation = fMain.Inflation:GetNumber()
    self:ClearFocus()
  end)
  fMain.Inflation:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ARTIFICIALINFLATION"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ARTINFLATTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.Inflation:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Min Roll Header
  fMain.Inflation.Header = fMain.Inflation:CreateFontString(nil, "OVERLAY")
  fMain.Inflation.Header:SetFontObject("MonDKPNormalLeft");
  fMain.Inflation.Header:SetPoint("BOTTOM", fMain.Inflation, "TOP", -20, 2);
  fMain.Inflation.Header:SetText(L["INFLATION"])

  if MonDKP_DB.modes.mode == "Zero Sum" then
    fMain.Inflation:Show()
    fMain.Inflation.Header:Show()
  end

  -- ZeroSum Type DROPDOWN box
  fMain.ZeroSumType = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.ZeroSumType, function(self, level, menuList)
    local BidType = UIDropDownMenu_CreateInfo()
    BidType.func = self.SetValue
    BidType.fontObject = "MonDKPSmallCenter"
    BidType.text, BidType.arg1, BidType.checked, BidType.isNotRadio = L["STATIC"], "Static", "Static" == MonDKP_DB.modes.ZeroSumBidType, false
    UIDropDownMenu_AddButton(BidType)
    BidType.text, BidType.arg1, BidType.checked, BidType.isNotRadio = L["MINIMUMBID"], "Minimum Bid", "Minimum Bid" == MonDKP_DB.modes.ZeroSumBidType, false
    UIDropDownMenu_AddButton(BidType)
  end)

  fMain.ZeroSumType:SetPoint("TOPLEFT", fMain.Inflation, "BOTTOMLEFT", -20, -20)
  UIDropDownMenu_SetWidth(fMain.ZeroSumType, 150)
  UIDropDownMenu_SetText(fMain.ZeroSumType, MonDKP_DB.modes.ZeroSumBidType)

  -- Dropdown Menu Function
  function fMain.ZeroSumType:SetValue(newValue)
    MonDKP_DB.modes.ZeroSumBidType = newValue;
    if newValue == "Static" then
      fMain.CostSelection:Hide();
      fMain.CostSelectionHeader:Hide();
      newValue = L["STATIC"]
      fMain.SubZeroBidding:Hide()
      fMain.AllowNegativeBidders:Hide()
      fMain.MaxBidBehaviorDropDown:Hide();
      fMain.MaxBidBehaviorHeader:Hide();
      MonDKP_DB.modes.MaxBehavior = "Max DKP";
    else
      fMain.CostSelection:Show();
      fMain.CostSelectionHeader:Show();
      newValue = L["MINIMUMBID"]
      fMain.SubZeroBidding:Show()
      fMain.AllowNegativeBidders:Show()
      fMain.MaxBidBehaviorDropDown:Show();
      fMain.MaxBidBehaviorHeader:Show();
    end

    UIDropDownMenu_SetText(fMain.ZeroSumType, newValue)
    CloseDropDownMenus()
  end

  fMain.ZeroSumType:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ZEROSUMITEMCOST"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ZEROSUMITEMCOSTTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.ZeroSumType:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.ZeroSumTypeHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ZeroSumTypeHeader:SetPoint("BOTTOMLEFT", fMain.ZeroSumType, "TOPLEFT", 25, 0);
  fMain.ZeroSumTypeHeader:SetFontObject("MonDKPSmallLeft")
  fMain.ZeroSumTypeHeader:SetText(L["BIDMETHOD"])

  if MonDKP_DB.modes.mode ~= "Zero Sum" then
    fMain.ZeroSumType:Hide()
    fMain.ZeroSumTypeHeader:Hide();
  end

  -- Item Cost Value DROPDOWN box 
  fMain.ItemCostDropDown = CreateFrame("FRAME", "MonDKPModeSelectDropDown", fMain, "MonolithDKPUIDropDownMenuTemplate")

  -- Create and bind the initialization function to the dropdown menu
  UIDropDownMenu_Initialize(fMain.ItemCostDropDown, function(self, level, menuList)
    local CostValue = UIDropDownMenu_CreateInfo()
    CostValue.func = self.SetValue
    CostValue.fontObject = "MonDKPSmallCenter"
    CostValue.text, CostValue.arg1, CostValue.checked, CostValue.isNotRadio = L["INTEGER"], "Integer", "Integer" == MonDKP_DB.modes.costvalue, false
    UIDropDownMenu_AddButton(CostValue)
    CostValue.text, CostValue.arg1, CostValue.checked, CostValue.isNotRadio = L["PERCENT"], "Percent", "Percent" == MonDKP_DB.modes.costvalue, false
    UIDropDownMenu_AddButton(CostValue)
  end)

  fMain.ItemCostDropDown:SetPoint("TOPLEFT", fMain.ModesDropDown, "BOTTOMLEFT", 0, -50)
  UIDropDownMenu_SetWidth(fMain.ItemCostDropDown, 150)
  UIDropDownMenu_SetText(fMain.ItemCostDropDown, L[MonDKP_DB.modes.costvalue])

  -- Dropdown Menu Function
  function fMain.ItemCostDropDown:SetValue(arg1)
    if arg1 == "Integer" then
      MonDKP_DB.modes.costvalue = "Integer"
      fMain.SubZeroBidding:Show()
      fMain.SubZeroBidding:SetChecked(MonDKP_DB.modes.SubZeroBidding)
      if MonDKP_DB.modes.SubZeroBidding == true then
        fMain.AllowNegativeBidders:Show()
        fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
      end
    elseif arg1 == "Percent" then
      MonDKP_DB.modes.costvalue = "Percent"
      fMain.SubZeroBidding:Hide()
      fMain.AllowNegativeBidders:Hide()
      MonDKP_DB.modes.SubZeroBidding = false;
      fMain.SubZeroBidding:SetChecked(false)
    end

    UIDropDownMenu_SetText(fMain.ItemCostDropDown, L[arg1])
    CloseDropDownMenus()
  end

  fMain.ItemCostDropDown:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ITEMCOSTTYPES"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ITEMCOSTTYPESTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.ItemCostDropDown:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  fMain.ItemCostHeader = fMain:CreateFontString(nil, "OVERLAY")
  fMain.ItemCostHeader:SetPoint("BOTTOMLEFT", fMain.ItemCostDropDown, "TOPLEFT", 25, 0);
  fMain.ItemCostHeader:SetFontObject("MonDKPSmallLeft")
  fMain.ItemCostHeader:SetText(L["ITEMCOSTTYPES"])

  if MonDKP_DB.modes.mode == "Minimum Bid Values" then
    fMain.ItemCostDropDown:Hide();
    fMain.ItemCostHeader:Hide();
    MonDKP_DB.modes.costvalue = "Integer";
    fMain.MaxBidBehaviorDropDown:Show();
    fMain.MaxBidBehaviorHeader:Show();
  elseif MonDKP_DB.modes.mode == "Roll Based Bidding" then
    fMain.MaxBidBehaviorDropDown:Hide();
    fMain.MaxBidBehaviorHeader:Hide();
    MonDKP_DB.modes.MaxBehavior = "Max DKP";
  elseif MonDKP_DB.modes.mode == "Static Item Values" then
    fMain.MaxBidBehaviorDropDown:Hide();
    fMain.MaxBidBehaviorHeader:Hide();
    MonDKP_DB.modes.MaxBehavior = "Max DKP";
  elseif MonDKP_DB.modes.mode == "Zero Sum" then
    fMain.ItemCostDropDown:Hide();
    fMain.ItemCostHeader:Hide();
    MonDKP_DB.modes.costvalue = "Integer";
    if MonDKP_DB.modes.ZeroSumBidType == "Static" then
      fMain.MaxBidBehaviorDropDown:Hide();
      fMain.MaxBidBehaviorHeader:Hide();
      MonDKP_DB.modes.MaxBehavior = "Max DKP";
    else
      fMain.MaxBidBehaviorDropDown:Show();
      fMain.MaxBidBehaviorHeader:Show();
    end
  end

  -- Sub Zero Bidding Checkbox
  fMain.SubZeroBidding = CreateFrame("CheckButton", nil, fMain, "UICheckButtonTemplate");
  fMain.SubZeroBidding:SetChecked(MonDKP_DB.modes.SubZeroBidding)
  fMain.SubZeroBidding:SetScale(0.6);
  fMain.SubZeroBidding.text:SetText("  |cff999999" .. L["SUBZEROBIDDING"] .. "|r");
  fMain.SubZeroBidding.text:SetScale(1.5);
  fMain.SubZeroBidding.text:SetFontObject("MonDKPSmallLeft")
  fMain.SubZeroBidding:SetPoint("TOP", fMain.ModesDropDown, "BOTTOMLEFT", 60, 0);
  fMain.SubZeroBidding:SetScript("OnClick", function(self)
    if self:GetChecked() == true then
      MonDKP_DB.modes.SubZeroBidding = true;
      MonDKP.Print("Sub Zero Bidding |cff00ff00" .. L["ENABLED"] .. "|r")
      fMain.AllowNegativeBidders:Show()
      fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
    else
      MonDKP_DB.modes.SubZeroBidding = false;
      MonDKP.Print("Sub Zero Bidding |cffff0000" .. L["DISABLED"] .. "|r")
      MonDKP_DB.modes.AllowNegativeBidders = false
      fMain.AllowNegativeBidders:Hide()
    end
    PlaySound(808);
  end)
  fMain.SubZeroBidding:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["SUBZEROBIDDING"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["SUBZEROBIDDINGTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.SubZeroBidding:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  if MonDKP_DB.modes.costvalue == "Percent" or (MonDKP_DB.modes.mode == "Zero Sum" and MonDKP_DB.modes.ZeroSumBidType == "Static") then
    fMain.SubZeroBidding:Hide()
  end

  -- Allow Bids below zero Checkbox
  fMain.AllowNegativeBidders = CreateFrame("CheckButton", nil, fMain, "UICheckButtonTemplate");
  fMain.AllowNegativeBidders:SetChecked(MonDKP_DB.modes.AllowNegativeBidders)
  fMain.AllowNegativeBidders:SetScale(0.6);
  fMain.AllowNegativeBidders.text:SetText("  |cff999999" .. L["ALLOWNEGATIVEBIDDERS"] .. "|r");
  fMain.AllowNegativeBidders.text:SetScale(1.5);
  fMain.AllowNegativeBidders.text:SetFontObject("MonDKPSmallLeft")
  fMain.AllowNegativeBidders:SetPoint("TOPLEFT", fMain.SubZeroBidding, "BOTTOMLEFT", 0, 0);
  fMain.AllowNegativeBidders:SetScript("OnClick", function(self)
    if self:GetChecked() == true then
      MonDKP_DB.modes.AllowNegativeBidders = true;
      MonDKP.Print("Allow Negative Bidders |cff00ff00" .. L["ENABLED"] .. "|r")
    else
      MonDKP_DB.modes.AllowNegativeBidders = false;
      MonDKP.Print("Allow Negative Bidders |cffff0000" .. L["DISABLED"] .. "|r")
    end
    PlaySound(808);
  end)
  fMain.AllowNegativeBidders:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ALLOWNEGATIVEBIDDERS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ALLOWNEGATIVEBIDTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show();
  end)
  fMain.AllowNegativeBidders:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  if (MonDKP_DB.modes.costvalue == "Percent" or (MonDKP_DB.modes.mode == "Zero Sum" and MonDKP_DB.modes.ZeroSumBidType == "Static")) or MonDKP_DB.modes.SubZeroBidding == false then
    fMain.AllowNegativeBidders:Hide()
  end


  -- Roll Container
  fMain.RollContainer = CreateFrame("Frame", nil, fMain);
  fMain.RollContainer:SetSize(210, 150);
  fMain.RollContainer:SetPoint("TOPLEFT", fMain.ChannelsDropDown, "BOTTOMLEFT", -10, -20)
  fMain.RollContainer:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.RollContainer:SetBackdropColor(0, 0, 0, 0.9)
  fMain.RollContainer:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.RollContainer:Hide();
  if MonDKP_DB.modes.mode == "Roll Based Bidding" then
    fMain.RollContainer:Show()
  end

  -- Roll Container Header
  fMain.RollContainer.Header = fMain.RollContainer:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.Header:SetFontObject("MonDKPLargeLeft");
  fMain.RollContainer.Header:SetScale(0.6)
  fMain.RollContainer.Header:SetPoint("TOPLEFT", fMain.RollContainer, "TOPLEFT", 15, -15);
  fMain.RollContainer.Header:SetText(L["ROLLSETTINGS"])


  -- Min Roll Editbox
  fMain.RollContainer.rollMin = CreateFrame("EditBox", nil, fMain.RollContainer)
  fMain.RollContainer.rollMin:SetAutoFocus(false)
  fMain.RollContainer.rollMin:SetMultiLine(false)
  fMain.RollContainer.rollMin:SetPoint("TOPLEFT", fMain.RollContainer, "TOPLEFT", 20, -50)
  fMain.RollContainer.rollMin:SetSize(70, 24)
  fMain.RollContainer.rollMin:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.RollContainer.rollMin:SetBackdropColor(0, 0, 0, 0.9)
  fMain.RollContainer.rollMin:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.RollContainer.rollMin:SetMaxLetters(6)
  fMain.RollContainer.rollMin:SetTextColor(1, 1, 1, 1)
  fMain.RollContainer.rollMin:SetFontObject("MonDKPSmallRight")
  fMain.RollContainer.rollMin:SetTextInsets(10, 15, 5, 5)
  fMain.RollContainer.rollMin:SetText(MonDKP_DB.modes.rolls.min)
  fMain.RollContainer.rollMin:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.rollMin:SetScript("OnTabPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    fMain.RollContainer.rollMax:SetFocus()
  end)
  fMain.RollContainer.rollMin:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.rollMin:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["MINIMUMROLL"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["MINIMUMROLLTTDESC"], 1.0, 1.0, 1.0, true);
    --GameTooltip:AddLine("The state of this option will persist indefinitely until manually disabled/enabled.", 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  fMain.RollContainer.rollMin:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Min Roll Header
  fMain.RollContainer.rollMin.Header = fMain.RollContainer.rollMin:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.rollMin.Header:SetFontObject("MonDKPNormalLeft");
  fMain.RollContainer.rollMin.Header:SetPoint("BOTTOM", fMain.RollContainer.rollMin, "TOP", -20, 2);
  fMain.RollContainer.rollMin.Header:SetText(L["MIN"])

  -- Dash Between Rolls
  fMain.RollContainer.dash = fMain.RollContainer:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.dash:SetFontObject("MonDKPLargeLeft");
  fMain.RollContainer.dash:SetPoint("LEFT", fMain.RollContainer.rollMin, "RIGHT", 9, 0);
  fMain.RollContainer.dash:SetText("-")

  -- Max Roll Editbox
  fMain.RollContainer.rollMax = CreateFrame("EditBox", nil, fMain.RollContainer)
  fMain.RollContainer.rollMax:SetAutoFocus(false)
  fMain.RollContainer.rollMax:SetMultiLine(false)
  fMain.RollContainer.rollMax:SetPoint("LEFT", fMain.RollContainer.rollMin, "RIGHT", 24, 0)
  fMain.RollContainer.rollMax:SetSize(70, 24)
  fMain.RollContainer.rollMax:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.RollContainer.rollMax:SetBackdropColor(0, 0, 0, 0.9)
  fMain.RollContainer.rollMax:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.RollContainer.rollMax:SetMaxLetters(6)
  fMain.RollContainer.rollMax:SetTextColor(1, 1, 1, 1)
  fMain.RollContainer.rollMax:SetFontObject("MonDKPSmallRight")
  fMain.RollContainer.rollMax:SetTextInsets(10, 15, 5, 5)
  fMain.RollContainer.rollMax:SetText(MonDKP_DB.modes.rolls.max)
  fMain.RollContainer.rollMax:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.rollMax:SetScript("OnTabPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    fMain.RollContainer.AddMax:SetFocus()
  end)
  fMain.RollContainer.rollMax:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.rollMax:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["MAXIMUMROLL"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["MAXIMUMROLLTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["MAXIMUMROLLTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  fMain.RollContainer.rollMax:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Max Roll Header
  fMain.RollContainer.rollMax.Header = fMain.RollContainer.rollMax:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.rollMax.Header:SetFontObject("MonDKPNormalLeft");
  fMain.RollContainer.rollMax.Header:SetPoint("BOTTOM", fMain.RollContainer.rollMax, "TOP", -20, 2);
  fMain.RollContainer.rollMax.Header:SetText(L["MAX"])

  fMain.RollContainer.rollMin.perc = fMain.RollContainer.rollMin:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.rollMin.perc:SetFontObject("MonDKPSmallLeft");
  fMain.RollContainer.rollMin.perc:SetPoint("LEFT", fMain.RollContainer.rollMin, "RIGHT", -15, 0);
  fMain.RollContainer.rollMin.perc:SetText("%")
  fMain.RollContainer.rollMin.perc:SetShown(MonDKP_DB.modes.rolls.UsePerc);

  fMain.RollContainer.rollMax.perc = fMain.RollContainer.rollMax:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.rollMax.perc:SetFontObject("MonDKPSmallLeft");
  fMain.RollContainer.rollMax.perc:SetPoint("LEFT", fMain.RollContainer.rollMax, "RIGHT", -15, 0);
  fMain.RollContainer.rollMax.perc:SetText("%")
  fMain.RollContainer.rollMax.perc:SetShown(MonDKP_DB.modes.rolls.UsePerc);

  -- Percent Rolls Checkbox
  fMain.RollContainer.UsePerc = CreateFrame("CheckButton", nil, fMain.RollContainer, "UICheckButtonTemplate");
  fMain.RollContainer.UsePerc:SetChecked(MonDKP_DB.modes.rolls.UsePerc)
  fMain.RollContainer.UsePerc:SetScale(0.6);
  fMain.RollContainer.UsePerc.text:SetText("  |cff999999" .. L["USEPERCENTAGE"] .. "|r");
  fMain.RollContainer.UsePerc.text:SetScale(1.5);
  fMain.RollContainer.UsePerc.text:SetFontObject("MonDKPSmallLeft")
  fMain.RollContainer.UsePerc:SetPoint("TOP", fMain.RollContainer.rollMin, "BOTTOMLEFT", 0, -10);
  fMain.RollContainer.UsePerc:SetScript("OnClick", function(self)
    MonDKP_DB.modes.rolls.UsePerc = self:GetChecked();
    fMain.RollContainer.rollMin.perc:SetShown(self:GetChecked())
    fMain.RollContainer.rollMax.perc:SetShown(self:GetChecked())
    if fMain.RollContainer.rollMax:GetNumber() == 0 then
      fMain.RollContainer.rollMax:SetNumber(100)
    end
    PlaySound(808);
  end)
  fMain.RollContainer.UsePerc:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:SetText(L["USEPERCFORROLLS"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["USEPERCROLLSTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["USEPERCROLLSTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  fMain.RollContainer.UsePerc:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Add to Max Editbox
  fMain.RollContainer.AddMax = CreateFrame("EditBox", nil, fMain.RollContainer)
  fMain.RollContainer.AddMax:SetAutoFocus(false)
  fMain.RollContainer.AddMax:SetMultiLine(false)
  fMain.RollContainer.AddMax:SetPoint("TOP", fMain.RollContainer.rollMax, "BOTTOM", 0, -30)
  fMain.RollContainer.AddMax:SetSize(70, 24)
  fMain.RollContainer.AddMax:SetBackdrop({
    bgFile = "Textures\\white.blp",
    tile = true,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = true,
    tileSize = 1,
    edgeSize = 2,
  });
  fMain.RollContainer.AddMax:SetBackdropColor(0, 0, 0, 0.9)
  fMain.RollContainer.AddMax:SetBackdropBorderColor(0.12, 0.12, 0.34, 1)
  fMain.RollContainer.AddMax:SetMaxLetters(6)
  fMain.RollContainer.AddMax:SetTextColor(1, 1, 1, 1)
  fMain.RollContainer.AddMax:SetFontObject("MonDKPSmallRight")
  fMain.RollContainer.AddMax:SetTextInsets(10, 15, 5, 5)
  fMain.RollContainer.AddMax:SetText(MonDKP_DB.modes.rolls.AddToMax)
  fMain.RollContainer.AddMax:SetScript("OnEscapePressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.AddMax:SetScript("OnTabPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    fMain.RollContainer.rollMin:SetFocus()
  end)
  fMain.RollContainer.AddMax:SetScript("OnEnterPressed", function(self) -- clears focus on esc
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()
    self:ClearFocus()
  end)
  fMain.RollContainer.AddMax:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(L["ADDTOMAXROLL"], 0.25, 0.75, 0.90, 1, true);
    GameTooltip:AddLine(L["ADDTOMAXROLLTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:AddLine(L["ADDTOMAXROLLTTWARN"], 1.0, 0, 0, true);
    GameTooltip:Show();
  end)
  fMain.RollContainer.AddMax:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Add to Max Header
  fMain.RollContainer.AddMax.Header = fMain.RollContainer.rollMax:CreateFontString(nil, "OVERLAY")
  fMain.RollContainer.AddMax.Header:SetFontObject("MonDKPSmallRight");
  fMain.RollContainer.AddMax.Header:SetPoint("RIGHT", fMain.RollContainer.AddMax, "LEFT", -5, 0);
  fMain.RollContainer.AddMax.Header:SetText(L["ADDTOMAXROLL"] .. ": ")

  -- Broadcast DKP Modes Button
  fMain.BroadcastSettings = self:CreateButton("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -30, 30, L["BROADCASTSETTINGS"]);
  fMain.BroadcastSettings:SetSize(110, 25)
  fMain.BroadcastSettings:SetScript("OnClick", function()
    MonDKP_DB.modes.rolls.min = fMain.RollContainer.rollMin:GetNumber()
    MonDKP_DB.modes.rolls.max = fMain.RollContainer.rollMax:GetNumber()
    MonDKP_DB.modes.rolls.AddToMax = fMain.RollContainer.AddMax:GetNumber()

    if (MonDKP_DB.modes.rolls.min > MonDKP_DB.modes.rolls.max and MonDKP_DB.modes.rolls.max ~= 0 and MonDKP_DB.modes.rolls.UserPerc == false) or (MonDKP_DB.modes.rolls.UsePerc and (MonDKP_DB.modes.rolls.min < 0 or MonDKP_DB.modes.rolls.max > 100 or MonDKP_DB.modes.rolls.min > MonDKP_DB.modes.rolls.max)) then
      StaticPopupDialogs["NOTIFY_ROLLS"] = {
        text = "|CFFFF0000" .. L["WARNING"] .. "|r: " .. L["INVALIDROLLRANGE"],
        button1 = L["OK"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }
      StaticPopup_Show("NOTIFY_ROLLS")
      return;
    end

    StaticPopupDialogs["SEND_MODES"] = {
      text = L["AREYOUSUREBROADCAST"],
      button1 = L["YES"],
      button2 = L["NO"],
      OnAccept = function()
        local temptable1 = {}
        table.insert(temptable1, MonDKP_DB.modes)
        table.insert(temptable1, MonDKP_DB.DKPBonus)
        table.insert(temptable1, MonDKP_DB.raiders)
        MonDKP.Sync:SendData("MonDKPDKPModes", temptable1)
        MonDKP.Print(L["DKPMODESENTCONF"])
        local temptable2 = {}
        table.insert(temptable2, MonDKP_DB.MinBidBySlot)
        table.insert(temptable2, MonDKP_MinBids)
        MonDKP.Sync:SendData("MonDKPMinBid", temptable2)
        local temptable3 = {}
        table.insert(temptable3, MonDKP_DB.MaxBidBySlot)
        table.insert(temptable3, MonDKP_MaxBids)
        MonDKP.Sync:SendData("MonDKPMaxBid", temptable3)
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("SEND_MODES")
  end);
  fMain.BroadcastSettings:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["BROADCASTSETTINGS"], 0.25, 0.75, 0.90, 1, true)
    GameTooltip:AddLine(L["BROADCASTSETTTDESC"], 1.0, 1.0, 1.0, true);
    GameTooltip:Show()
  end)
  fMain.BroadcastSettings:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end