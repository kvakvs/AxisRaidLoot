local _, core = ...;
local _G = _G;
local MonDKP = core.MonDKP;
local L = core.L;

--- Stacks control 10pt under 'stackUnder' or as first topleft position in the parent
local function StackUnder(control, parent, stackUnder)
  -- stack under something or topleft position
  if stackUnder ~= nil then
    control:SetPoint("TOP", stackUnder, "BOTTOM", 0, 0);
  else
    control:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10);
  end
end

--- Create a checkbox and stack it under another
-- args = {
--    name = "" | nil,
--    parent = <frame>,
--    stackUnder = nil | <reference frame>,
--    checked = true|false,
--    text = "",
--    clickFun = function(), -- what to do on click
--    tooltipFun = function(), -- what to do on mouse enter in the tooltip
-- }
local function CreateCheckbox(args)
  local control = CreateFrame("CheckButton", args.name, args.parent, "UICheckButtonTemplate");
  control:SetChecked(args.checked)
  control:SetScale(0.6);
  control.text:SetText("  |cff999999" .. args.text .. "|r");
  control.text:SetScale(1.5);
  control.text:SetFontObject("MonDKPSmallLeft")

  StackUnder(control, args.parent, args.stackUnder)

  control:SetScript("OnClick", function(self)
    args.clickFun(self);
    PlaySound(808);
  end)

  control:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    args.tooltipFun();
    GameTooltip:Show();
  end)

  control:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  return control
end

function MonDKP:DKPModes_Misc()
  local f = core.ModesWindow.DKPModesMisc;

  f.AutoAwardContainer = MonDKP:CreateContainer(f, "AutoAwardContainer", L["AUTOAWARD"])
  f.AutoAwardContainer:SetPoint("TOPLEFT", f, "TOPLEFT", 40, -40)
  f.AutoAwardContainer:SetSize(175, 50)

  -- AutoAward DKP Checkbox
  f.AutoAwardContainer.AutoAward = CreateCheckbox({
    parent = f.AutoAwardContainer,
    checked = MonDKP_DB.modes.AutoAward,
    text = L["AUTOAWARD"],
    clickFun = function(self)
      MonDKP_DB.modes.AutoAward = self:GetChecked();
      if self:GetChecked() == false then
        f.AutoAwardContainer.IncStandby:SetChecked(false)
        MonDKP_DB.DKPBonus.AutoIncStandby = false;
      end
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["AUTOAWARD"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["AUTOAWARDTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Include Standby Checkbox
  f.AutoAwardContainer.IncStandby = CreateCheckbox({
    parent = f.AutoAwardContainer,
    stackUnder = f.AutoAwardContainer.AutoAward,
    checked = MonDKP_DB.DKPBonus.AutoIncStandby,
    text = L["INCLUDESTANDBY"],
    clickFun = function(self)
      MonDKP_DB.DKPBonus.AutoIncStandby = self:GetChecked();
      if self:GetChecked() == true then
        f.AutoAwardContainer.AutoAward:SetChecked(true)
        MonDKP_DB.modes.AutoAward = true;
      end
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["INCLUDESTANDBY"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["INCLUDESBYTTDESC"], 1.0, 1.0, 1.0, true);
      GameTooltip:AddLine(L["INCLUDESBYTTWARN"], 1.0, 0, 0, true);
    end
  })

  -- Announce Highest Bidder Container
  f.AnnounceBidContainer = MonDKP:CreateContainer(f, "AnnounceBidContainer", L["HIGHESTBID"])
  f.AnnounceBidContainer:SetPoint("TOPRIGHT", f, "TOPRIGHT", -50, -40)
  f.AnnounceBidContainer:SetSize(175, 70)

  -- Announce Highest Bid
  f.AnnounceBidContainer.AnnounceBid = CreateCheckbox({
    parent = f.AnnounceBidContainer,
    checked = MonDKP_DB.modes.AnnounceBid,
    text = L["ANNOUNCEBID"],
    clickFun = function(self)
      MonDKP_DB.modes.AnnounceBid = self:GetChecked();
      if self:GetChecked() == false then
        f.AnnounceBidContainer.AnnounceBidName:SetChecked(false)
        MonDKP_DB.modes.AnnounceBidName = false;
      end
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["ANNOUNCEBID"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["ANNOUNCEBIDTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Include Name Announce Highest Bid
  f.AnnounceBidContainer.AnnounceBidName = CreateCheckbox({
    parent = f.AnnounceBidContainer,
    stackUnder = f.AnnounceBidContainer.AnnounceBid,
    checked = MonDKP_DB.modes.AnnounceBidName,
    text = L["INCLUDENAME"],
    clickFun = function(self)
      MonDKP_DB.modes.AnnounceBidName = self:GetChecked();
      if self:GetChecked() == true then
        f.AnnounceBidContainer.AnnounceBid:SetChecked(true)
        MonDKP_DB.modes.AnnounceBid = true;
      end
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["INCLUDENAME"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["INCLUDENAMETTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Decline lower bids
  f.AnnounceBidContainer.DeclineLowerBids = CreateCheckbox({
    parent = f.AnnounceBidContainer,
    stackUnder = f.AnnounceBidContainer.AnnounceBidName,
    checked = MonDKP_DB.modes.DeclineLowerBids,
    text = L["DECLINELOWBIDS"],
    clickFun = function(self)
      MonDKP_DB.modes.DeclineLowerBids = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["DECLINELOWBIDS"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["DECLINELOWBIDSTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  --Misc Options Container
  f.MiscContainer = MonDKP:CreateContainer(f, "MiscContainer", L["MISCSETTINGS"])
  f.MiscContainer:SetPoint("TOPLEFT", f.AutoAwardContainer, "BOTTOMLEFT", 0, -20)
  f.MiscContainer:SetSize(175, 90)

  -- Standby On Boss Kill Checkbox
  f.MiscContainer.Standby = CreateCheckbox({
    parent = f.MiscContainer,
    checked = MonDKP_DB.modes.StandbyOptIn,
    text = L["STANDBYOPTIN"],
    clickFun = function(self)
      MonDKP_DB.modes.StandbyOptIn = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["STANDBYOPTIN"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["STANDBYOPTINTTDESC"], 1.0, 1.0, 1.0, true);
      GameTooltip:AddLine(L["STANDBYOPTINTTWARN"], 1.0, 0, 0, true);
    end
  })

  -- Announce Award to Guild
  f.MiscContainer.AnnounceAward = CreateCheckbox({
    parent = f.MiscContainer,
    stackUnder = f.MiscContainer.Standby,
    checked = MonDKP_DB.modes.AnnounceAward,
    text = L["ANNOUNCEAWARD"],
    clickFun = function(self)
      MonDKP_DB.modes.AnnounceAward = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["ANNOUNCEAWARD"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["ANNOUNCEAWARDTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Broadcast Bid Table to Raid
  f.MiscContainer.BroadcastBids = CreateCheckbox({
    parent = f.MiscContainer,
    stackUnder = f.MiscContainer.AnnounceAward,
    checked = MonDKP_DB.modes.BroadcastBids,
    text = L["BROADCASTBIDS"],
    clickFun = function(self)
      MonDKP_DB.modes.BroadcastBids = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["BROADCASTBIDS"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["BROADCASTBIDSTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Log Bids/Rolls
  f.MiscContainer.StoreBids = CreateCheckbox({
    parent = f.MiscContainer,
    stackUnder = f.MiscContainer.BroadcastBids,
    checked = MonDKP_DB.modes.StoreBids,
    text = L["LOGBIDS"],
    clickFun = function(self)
      MonDKP_DB.modes.StoreBids = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["LOGBIDS"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["LOGBIDSTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  --DKP Award Options Container
  f.DKPAwardContainer = MonDKP:CreateContainer(f, "DKPAwardContainer", L["DKPSETTINGS"])
  f.DKPAwardContainer:SetPoint("TOPLEFT", f.AnnounceBidContainer, "BOTTOMLEFT", 0, -20)
  f.DKPAwardContainer:SetSize(175, 50)

  -- Online Only Checkbox
  MonDKP_DB.modes.OnlineOnly = MonDKP_DB.modes.OnlineOnly or false -- default false

  f.DKPAwardContainer.OnlineOnly = CreateCheckbox({
    parent = f.DKPAwardContainer,
    checked = MonDKP_DB.modes.OnlineOnly,
    text = L["ONLINEONLY"],
    clickFun = function(self)
      MonDKP_DB.modes.OnlineOnly = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["ONLINEONLY"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["ONLINEONLYTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

  -- Same Zone Only Checkbox
  MonDKP_DB.modes.SameZoneOnly = MonDKP_DB.modes.SameZoneOnly or false

  f.DKPAwardContainer.SameZoneOnly = CreateCheckbox({
    parent = f.DKPAwardContainer,
    stackUnder = f.DKPAwardContainer.OnlineOnly,
    checked = MonDKP_DB.modes.SameZoneOnly,
    text = L["INZONEONLY"],
    clickFun = function(self)
      MonDKP_DB.modes.SameZoneOnly = self:GetChecked();
    end,
    tooltipFun = function(self)
      GameTooltip:SetText(L["INZONEONLY"], 0.25, 0.75, 0.90, 1, true);
      GameTooltip:AddLine(L["INZONEONLYTTDESC"], 1.0, 1.0, 1.0, true);
    end
  })

end