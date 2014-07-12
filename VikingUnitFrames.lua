require "Window"
require "Unit"
require "GameLib"
require "Apollo"
require "ApolloColor"
require "Window"

local VikingLib
local VikingUnitFrames = {
  _VERSION = 'VikingUnitFrames.lua 0.1.0',
  _URL     = 'https://github.com/vikinghug/VikingUnitFrames',
  _DESCRIPTION = '',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2014 Kevin Altman

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- GameLib.CodeEnumClass.Warrior      = 1
-- GameLib.CodeEnumClass.Engineer     = 2
-- GameLib.CodeEnumClass.Esper        = 3
-- GameLib.CodeEnumClass.Medic        = 4
-- GameLib.CodeEnumClass.Stalker      = 5
-- GameLib.CodeEnumClass.Spellslinger = 7

local tClassName = {
  [GameLib.CodeEnumClass.Warrior]      = "Warrior",
  [GameLib.CodeEnumClass.Engineer]     = "Engineer",
  [GameLib.CodeEnumClass.Esper]        = "Esper",
  [GameLib.CodeEnumClass.Medic]        = "Medic",
  [GameLib.CodeEnumClass.Stalker]      = "Stalker",
  [GameLib.CodeEnumClass.Spellslinger] = "Spellslinger"
}


local tClassToSpriteMap =
{
  [GameLib.CodeEnumClass.Warrior]       = "VikingSprites:ClassWarrior",
  [GameLib.CodeEnumClass.Engineer]      = "VikingSprites:ClassEngineer",
  [GameLib.CodeEnumClass.Esper]         = "VikingSprites:ClassEsper",
  [GameLib.CodeEnumClass.Medic]         = "VikingSprites:ClassMedic",
  [GameLib.CodeEnumClass.Stalker]       = "VikingSprites:ClassStalker",
  [GameLib.CodeEnumClass.Spellslinger]  = "VikingSprites:ClassSpellslinger"
}


local tRankToSpriteMap = {
  [Unit.CodeEnumRank.Elite]    = "spr_TargetFrame_ClassIcon_Elite",
  [Unit.CodeEnumRank.Superior] = "spr_TargetFrame_ClassIcon_Superior",
  [Unit.CodeEnumRank.Champion] = "spr_TargetFrame_ClassIcon_Champion",
  [Unit.CodeEnumRank.Standard] = "spr_TargetFrame_ClassIcon_Standard",
  [Unit.CodeEnumRank.Minion]   = "spr_TargetFrame_ClassIcon_Minion",
  [Unit.CodeEnumRank.Fodder]   = "spr_TargetFrame_ClassIcon_Fodder"
}


local tTargetMarkSpriteMap =
{
  "Icon_Windows_UI_CRB_Marker_Bomb",
  "Icon_Windows_UI_CRB_Marker_Ghost",
  "Icon_Windows_UI_CRB_Marker_Mask",
  "Icon_Windows_UI_CRB_Marker_Octopus",
  "Icon_Windows_UI_CRB_Marker_Pig",
  "Icon_Windows_UI_CRB_Marker_Chicken",
  "Icon_Windows_UI_CRB_Marker_Toaster",
  "Icon_Windows_UI_CRB_Marker_UFO"
}

local eTextStyle =
{
  None = 1,
  Percent = 2,
  Value = 3
}

local tColors = {
  black       = "141122",
  white       = "ffffff",
  lightGrey   = "bcb7da",
  green       = "1fd865",
  yellow      = "ffd161",
  orange      = "e08457",
  lightPurple = "645f7e",
  purple      = "2b273d",
  red         = "e05757",
  blue        = "4ae8ee"
}

local tDefaultSettings = 
{
  style = 0,
  position = {
    playerFrame = {
      fPoints  = {0.5, 1, 0.5, 1},
      nOffsets = {-350, -200, -100, -120}
    },
    targetFrame = {
      fPoints  = {0.5, 1, 0.5, 1},
      nOffsets = {100, -200, 350, -120}
    },
    focusFrame = {
      fPoints  = {0, 1, 0, 1},
      nOffsets = {40, -500, 250, -440}
    }
  },
  textStyle = eTextStyle.Percent,
  colors = {
    Health = { high = "ff" .. tColors.green,  average = "ff" .. tColors.yellow, low = "ff" .. tColors.red },
    Shield = { high = "ff" .. tColors.blue,   average = "ff" .. tColors.blue, low = "ff" ..   tColors.blue },
    Absorb = { high = "ff" .. tColors.yellow, average = "ff" .. tColors.yellow, low = "ff" .. tColors.yellow },
  }
}

function VikingUnitFrames:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function VikingUnitFrames:Init()
  Apollo.RegisterAddon(self, nil, nil, {"VikingLibrary"})
end

function VikingUnitFrames:OnLoad()
  self.xmlDoc = XmlDoc.CreateFromFile("VikingUnitFrames.xml")
  self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

function VikingUnitFrames:OnDocumentReady()
  if self.xmlDoc == nil then
    return
  end

  Apollo.RegisterEventHandler("WindowManagementReady"      , "OnWindowManagementReady"      , self)
  Apollo.RegisterEventHandler("WindowManagementUpdate"     , "OnWindowManagementUpdate"     , self)
  Apollo.RegisterEventHandler("TargetUnitChanged"          , "OnTargetUnitChanged"          , self)
  Apollo.RegisterEventHandler("AlternateTargetUnitChanged" , "OnFocusUnitChanged"           , self)
  Apollo.RegisterEventHandler("PlayerLevelChange"          , "OnUnitLevelChange"            , self)
  Apollo.RegisterEventHandler("UnitLevelChanged"           , "OnUnitLevelChange"            , self)
  Apollo.RegisterEventHandler("VarChange_FrameCount"       , "OnFrame"                      , self)
  Apollo.RegisterEventHandler("ChangeWorld"                , "OnWorldChanged"               , self)

  self.bDocLoaded = true
  self:OnRequiredFlagsChanged()

end

function VikingUnitFrames:OnWindowManagementReady()
  Event_FireGenericEvent("WindowManagementAdd", { wnd = self.tPlayerFrame.wndUnitFrame, strName = Apollo.GetString("OptionsHUD_MyUnitFrameLabel") })
  Event_FireGenericEvent("WindowManagementAdd", { wnd = self.tTargetFrame.wndUnitFrame, strName = Apollo.GetString("OptionsHUD_TargetFrameLabel") })
  Event_FireGenericEvent("WindowManagementAdd", { wnd = self.tFocusFrame.wndUnitFrame,  strName = Apollo.GetString("OptionsHUD_FocusTargetLabel") })
end


function VikingUnitFrames:OnRequiredFlagsChanged()
  if GameLib.GetPlayerUnit() then
    self:OnCharacterLoaded()
  else
    Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterLoaded", self)
  end
end


function VikingUnitFrames:OnWindowManagementUpdate(tWindow)
  if tWindow and tWindow.wnd and (tWindow.wnd == self.tPlayerFrame.wndUnitFrame or tWindow.wnd == self.tTargetFrame.wndUnitFrame or tWindow.wnd == self.tFocusFrame.wndUnitFrame) then
    local bMoveable = tWindow.wnd:IsStyleOn("Moveable")

    tWindow.wnd:SetStyle("Sizable", bMoveable)
    tWindow.wnd:SetStyle("RequireMetaKeyToMove", bMoveable)
    tWindow.wnd:SetStyle("IgnoreMouse", not bMoveable)
  end
end


function VikingUnitFrames:OnUnitLevelChange()
  self:SetUnitLevel(self.tPlayerFrame)
  self:SetUnitLevel(self.tTargetFrame)
end


--
-- CreateUnitFrame
--
--   Builds a UnitFrame instance

function VikingUnitFrames:CreateUnitFrame(name)

  local sFrame = "t" .. name .. "Frame"

  local wndUnitFrame = Apollo.LoadForm(self.xmlDoc, "UnitFrame", "FixedHudStratumLow" , self)

  local tFrame = {
    name          = name,
    wndUnitFrame  = wndUnitFrame,
    wndHealthBar  = wndUnitFrame:FindChild("Bars:Health"),
    wndShieldBar  = wndUnitFrame:FindChild("Bars:Shield"),
    wndAbsorbBar  = wndUnitFrame:FindChild("Bars:Absorb"),
    wndCastBar    = wndUnitFrame:FindChild("Bars:Cast"),
    wndTargetMark = wndUnitFrame:FindChild("TargetExtra:Mark"),
    bCasting      = false
  }

  tFrame.wndUnitFrame:SetSizingMinimum(140, 60)

  tFrame.locDefaultPosition = WindowLocation.new(self.db.position[name:lower() .. "Frame"])
  tFrame.wndUnitFrame:MoveToLocation(tFrame.locDefaultPosition)
  self:InitColors(tFrame)

  return tFrame

end


--
-- OnCharacterLoaded
--
--
function VikingUnitFrames:OnCharacterLoaded()
  local playerUnit = GameLib.GetPlayerUnit()
  if not playerUnit then
    return
  end

  if VikingLib == nil then
    VikingLib = Apollo.GetAddon("VikingLibrary")
  end

  if VikingLib ~= nil then
    VikingLib.Settings.RegisterSettings(self, "VikingUnitFrames", tDefaultSettings)
    self.db = VikingLib.Settings.GetDatabase("VikingUnitFrames")
  end

  -- PlayerFrame
  self.tPlayerFrame = self:CreateUnitFrame("Player")

  self:SetUnit(self.tPlayerFrame, playerUnit)
  self:SetUnitName(self.tPlayerFrame, playerUnit:GetName())
  self:SetUnitLevel(self.tPlayerFrame)
  self.tPlayerFrame.wndUnitFrame:Show(true, false)
  self:SetClass(self.tPlayerFrame)

  -- Target Frame
  self.tTargetFrame = self:CreateUnitFrame("Target")
  if GameLib.GetTargetUnit() ~= nil then
    self:OnTargetUnitChanged(GameLib.GetTargetUnit())
  end

  -- Focus Frame
  self.tFocusFrame = self:CreateUnitFrame("Focus")


  self.eClassID =  playerUnit:GetClassId()

end


local LoadingTimer
function VikingUnitFrames:OnWorldChanged()
  self:OnRequiredFlagsChanged()

  LoadingTimer = ApolloTimer.Create(0.01, true, "OnLoading", self)
end


function VikingUnitFrames:OnLoading()
  local playerUnit = GameLib.GetPlayerUnit()
  if not playerUnit then return end
  self:SetUnit(self.tPlayerFrame, playerUnit)
  self:SetUnitLevel(self.tPlayerFrame)
  self.tPlayerFrame.unit = playerUnit
  LoadingTimer:Stop()
end


--
-- OnTargetUnitChanged
--

function VikingUnitFrames:OnTargetUnitChanged(unit)
  self:UnitChanged(self.tTargetFrame, unit)
  self.targetUnit = unit
end


--
-- OnFocusUnitChanged
--

function VikingUnitFrames:OnFocusUnitChanged(unit)
  self:UnitChanged(self.tFocusFrame, unit)
  self.focusUnit = unit
end

function VikingUnitFrames:UnitChanged(tFrame, unit)

  tFrame.wndUnitFrame:Show(unit ~= nil)

  if unit ~= nil then
    self:SetUnit(tFrame, unit)
    self:SetUnitName(tFrame, unit:GetName())
    self:SetClass(tFrame)
  end

end

--
-- OnFrame
--
-- Render loop

function VikingUnitFrames:OnFrame()
  if not self.tPlayerFrame.unit then return end

  if self.tPlayerFrame ~= nil and self.tTargetFrame ~= nil then

    -- UnitFrame
    self:UpdateBars(self.tPlayerFrame)

    -- TargetFrame
    self:UpdateBars(self.tTargetFrame)
    self:SetUnitLevel(self.tTargetFrame)

    -- FocusFrame
    self:UpdateBars(self.tFocusFrame)
    self:SetUnitLevel(self.tFocusFrame)


  end

end


--
-- UpdateBars
--
-- Update the bars for a unit on UnitFrame

function VikingUnitFrames:UpdateBars(tFrame)

  local tHealthMap = {
    bar     = "Health",
    current = "GetHealth",
    max     = "GetMaxHealth"
  }

  local tShieldMap = {
    bar     = "Shield",
    current = "GetShieldCapacity",
    max     = "GetShieldCapacityMax"

  }

  local tAbsorbMap = {
    bar     = "Absorb",
    current = "GetAbsorptionValue",
    max     = "GetAbsorptionMax"
  }

  self:ShowCastBar(tFrame)
  self:SetBar(tFrame, tHealthMap)
  self:SetBar(tFrame, tShieldMap)
  self:SetBar(tFrame, tAbsorbMap)
  self:SetTargetMark(tFrame)
end


-- SetBar
--
-- Set Bar Value on UnitFrame

function VikingUnitFrames:SetBar(tFrame, tMap)
  if tFrame.unit ~= nil and tMap ~= nil then
    local unit          = tFrame.unit
    local nCurrent      = unit[tMap.current](unit)
    local nMax          = unit[tMap.max](unit)
    local wndBar        = tFrame["wnd" .. tMap.bar .. "Bar"]
    local wndProgress   = wndBar:FindChild("ProgressBar")
    local wndText       = wndBar:FindChild("Text")

    --Temp fix until VikingSettings work for changing healthText display option
    local nVisibility = Apollo.GetConsoleVariable("hud.healthTextDisplay")


    local isValidBar = (nMax ~= nil and nMax ~= 0) and true or false
    wndBar:Show(isValidBar, false)

    if isValidBar then

      wndProgress:SetMax(nMax)
      wndProgress:SetProgress(nCurrent)
      
      if self.db.textStyle == eTextStyle.None then
        wndText:SetText("")
      elseif self.db.textStyle == eTextStyle.Value then
        wndText:SetText(nCurrent .. " / " .. nMax)
      elseif self.db.textStyle == eTextStyle.Percent then
        wndText:SetText(math.floor(nCurrent  / nMax * 100) .. "%")
      end

      local nLowBar     = 0.3
      local nAverageBar = 0.5

      -- Set our bar color based on the percent full
      local tColors = self.db.colors[tMap.bar]
      local color   = tColors.high

      if nCurrent / nMax <= nLowBar then
        color = tColors.low
      elseif nCurrent / nMax <= nAverageBar then
        color = tColors.average
      end

      wndProgress:SetBarColor(ApolloColor.new(color))
    end
  end
end



--
-- SetClass
--
-- Set Class on UnitFrame

function VikingUnitFrames:SetClass(tFrame)

    local strPlayerIconSprite, strRankIconSprite, locNameText
    local sUnitType = tFrame.unit:GetType()

    if sUnitType == "Player" then
      locNameText         = { 24, 0, -30, 26 }
      strRankIconSprite   = ""
      strPlayerIconSprite = tClassToSpriteMap[tFrame.unit:GetClassId()]
    else
      locNameText         = { 34, 0, -30, 26 }
      strPlayerIconSprite = ""
      strRankIconSprite   = tRankToSpriteMap[tFrame.unit:GetRank()]
    end

    tFrame.wndUnitFrame:FindChild("TargetInfo:UnitName"):SetAnchorOffsets(locNameText[1], locNameText[2], locNameText[3], locNameText[4])
    tFrame.wndUnitFrame:FindChild("TargetInfo:ClassIcon"):SetSprite(strPlayerIconSprite)
    tFrame.wndUnitFrame:FindChild("TargetInfo:RankIcon"):SetSprite(strRankIconSprite)

end


--
-- SetDisposition
--
-- Set Disposition on UnitFrame

function VikingUnitFrames:SetTargetMark(tFrame)
  if not tFrame.unit then return else end

  local nMarkerID = tFrame.unit:GetTargetMarker() or 0

  if nMarkerID ~= 0 then
    local sprite = tTargetMarkSpriteMap[nMarkerID]
    tFrame.wndTargetMark:Show(true, false)
    tFrame.wndTargetMark:SetSprite(sprite)
  else
    tFrame.wndTargetMark:Show(false, true)
  end
end


--
-- SetDisposition
--
-- Set Disposition on UnitFrame

function VikingUnitFrames:SetDisposition(tFrame, targetUnit)
  tFrame.disposition = targetUnit:GetDispositionTo(self.tPlayerFrame.unit)


  local dispositionColor = ApolloColor.new(self.db.General.dispositionColors[tFrame.disposition])
  tFrame.wndUnitFrame:FindChild("TargetInfo:UnitName"):SetTextColor(dispositionColor)
end


--
-- SetUnit
--
-- Set Unit on UnitFrame

function VikingUnitFrames:SetUnit(tFrame, unit)
  tFrame.unit = unit
  tFrame.wndUnitFrame:FindChild("Good"):SetUnit(unit)
  tFrame.wndUnitFrame:FindChild("Bad"):SetUnit(unit)
  self:SetDisposition(tFrame, unit)

  -- Set the Data to the unit, for mouse events
  tFrame.wndUnitFrame:SetData(tFrame.unit)
end


--
-- SetUnitName
--
-- Set Name on UnitFrame

function VikingUnitFrames:SetUnitName(tFrame, sName)
  tFrame.wndUnitFrame:FindChild("UnitName"):SetText(sName)
end


--
-- SetUnitLevel
--
-- Set Level on UnitFrame

function VikingUnitFrames:SetUnitLevel(tFrame)
  if tFrame.unit == nil then return end
  local sLevel = tFrame.unit:GetLevel()
  tFrame.wndUnitFrame:FindChild("UnitLevel"):SetText(sLevel)
end



--
-- InitColor
--
-- Let's initialize some colors from settings

function VikingUnitFrames:InitColors(tFrame)

  local colors = {
    background = {
      wnd   = tFrame.wndUnitFrame:FindChild("Background"),
      color = ApolloColor.new(self.db.General.colors.background)
    },
    gradient = {
      wnd   = tFrame.wndUnitFrame,
      color = ApolloColor.new(self.db.General.colors.gradient)
    }
  }

  for k,v in pairs(colors) do
    v.wnd:SetBGColor(v.color)
  end
end



-- ShowCastBar
--
-- Check to see if a unit is casting, if so, render the cast bar

function VikingUnitFrames:ShowCastBar(tFrame)

  -- If no unit then don't do anything
  if tFrame.unit == nil then return end

  local unit = tFrame.unit
  local bCasting = unit:ShouldShowCastBar()
  self:UpdateCastBar(tFrame, bCasting)
end


--
-- UpdateCastBar
--
-- Casts that have timers use this method to indicate their progress

function VikingUnitFrames:UpdateCastBar(tFrame, bCasting)

  -- If just started casting
  if bCasting and tFrame.bCasting == false then
    tFrame.bCasting = true

    local wndProgressBar = tFrame.wndCastBar:FindChild("ProgressBar")
    local wndText        = tFrame.wndCastBar:FindChild("Text")
    local sCastName      = tFrame.unit:GetCastName()

    tFrame.nTimePrevious = 0
    tFrame.nTimeMax      = tFrame.unit:GetCastDuration()
    tFrame.wndCastBar:Show(true, false)
    wndProgressBar:SetProgress(0)
    wndProgressBar:SetMax(tFrame.nTimeMax)
    wndText:SetText(sCastName)

    tFrame.CastTimerTick = ApolloTimer.Create(0.01, true, "OnCast" .. tFrame.name .. "FrameTimerTick", self)

  elseif bCasting and tFrame.bCasting == true then
    return
  elseif not bCasting and tFrame.bCasting == true then
    VikingUnitFrames:KillCastTimer(tFrame)
    tFrame.bCasting = false
  end

end


-----------------------------------------------------------------------------------------------
-- Cast Timer
-----------------------------------------------------------------------------------------------

function VikingUnitFrames:OnCastPlayerFrameTimerTick()
  self:UpdateCastTimer(self.tPlayerFrame)
end


function VikingUnitFrames:OnCastTargetFrameTimerTick()
  self:UpdateCastTimer(self.tTargetFrame)
end

function VikingUnitFrames:OnCastFocusFrameTimerTick()
  self:UpdateCastTimer(self.tFocusFrame)
end

function VikingUnitFrames:UpdateCastTimer(tFrame)
  local wndProgressBar = tFrame.wndCastBar:FindChild("ProgressBar")
  local nMin = tFrame.unit:GetCastElapsed() or 0
  local nTimeCurrent   = math.min(nMin, tFrame.nTimeMax)
  wndProgressBar:SetProgress(nTimeCurrent, nTimeCurrent - tFrame.nTimePrevious * 1000)

  tFrame.nTimePrevious = nTimeCurrent
end


function VikingUnitFrames:KillCastTimer(tFrame)
  tFrame.CastTimerTick:Stop()
  local wndProgressBar = tFrame.wndCastBar:FindChild("ProgressBar")
  wndProgressBar:SetProgress(tFrame.nTimeMax)
  tFrame.wndCastBar:Show(false, .002)
end



---------------------------------------------------------------------------------------------------
-- UnitFrame Functions
---------------------------------------------------------------------------------------------------

function VikingUnitFrames:OnMouseButtonDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if wndHandler ~= wndControl then return end
  local unit = wndHandler:GetData()

  if eMouseButton == GameLib.CodeEnumInputMouse.Left and unit ~= nil then
    GameLib.SetTargetUnit(unit)
    return
  end

  -- Player Menu
  if eMouseButton == GameLib.CodeEnumInputMouse.Right and unit ~= nil then
    Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, unit:GetName(), unit)
  end
end


function VikingUnitFrames:OnGenerateBuffTooltip(wndHandler, wndControl, tType, splBuff)
  if wndHandler == wndControl then
    return
  end
  Tooltip.GetBuffTooltipForm(self, wndControl, splBuff, {bFutureSpell = false})
end

---------------------------------------------------------------------------------------------------
-- VikingSettings Functions
---------------------------------------------------------------------------------------------------

function VikingUnitFrames:UpdateSettingsForm(wndContainer)
  -- Text Style
  local strTextStyle = VikingLib.GetKeyFromValue(eTextStyle, self.db.textStyle)
  for k, v in pairs(eTextStyle) do 
    local wndTextStyleButton = wndContainer:FindChild("TextStyle:Content:"..k)
    if wndTextStyleButton then wndTextStyleButton:SetCheck(k == strTextStyle) end
  end

  -- Bar colors
  for strBarName, tBarColorData in pairs(self.db.colors) do
    local wndColorContainer = wndContainer:FindChild("Colors:Content:" .. strBarName)

    if wndColorContainer then
      for strColorState, strColor in pairs(tBarColorData) do
        local wndColor = wndColorContainer:FindChild(strColorState)

        if wndColor then wndColor:SetBGColor(strColor) end
      end
    end
  end
end

function VikingUnitFrames:OnTextStyleBtnCheck( wndHandler, wndControl, eMouseButton )
  self.db.textStyle = eTextStyle[wndControl:GetName()]
end

function VikingUnitFrames:OnSettingsBarColor( wndHandler, wndControl, eMouseButton )
  VikingLib.Settings.ShowColorPickerForSetting(self.db.colors[wndControl:GetParent():GetName()], wndControl:GetName(), nil, wndControl)
end

local VikingUnitFramesInst = VikingUnitFrames:new()
VikingUnitFramesInst:Init()