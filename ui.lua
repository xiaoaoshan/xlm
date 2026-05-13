XLM = XLM or {}

local FRAME_WIDTH = 920
local FRAME_HEIGHT = 660
local MENU_WIDTH = 250
local CONTENT_WIDTH = FRAME_WIDTH - MENU_WIDTH - 70
local CONTENT_HEIGHT = FRAME_HEIGHT - 138
local CONTENT_PAD = 24
local WRONG_PAGE_SIZE = 8
local CONTENT_CENTER_OFFSET = 24 + MENU_WIDTH + 18 + (CONTENT_WIDTH / 2) - (FRAME_WIDTH / 2)

local COLORS = {
    gold = { 1.0, 0.78, 0.12, 1 },
    goldSoft = { 0.96, 0.70, 0.28, 1 },
    text = { 0.96, 0.88, 0.72, 1 },
    muted = { 0.72, 0.66, 0.56, 1 },
    pale = { 1.0, 0.95, 0.82, 1 },
    dark = { 0.035, 0.028, 0.022, 0.98 },
    panel = { 0.075, 0.055, 0.038, 0.96 },
    panelSoft = { 0.15, 0.09, 0.045, 0.90 },
    green = { 0.40, 1.0, 0.0, 1 },
    red = { 1.0, 0.12, 0.12, 1 },
    blue = { 0.22, 0.56, 1.0, 1 },
    orange = { 1.0, 0.56, 0.10, 1 },
}

local MENU_ITEMS = {
    { key = "practice", title = "开始练习", desc = "随机词汇，敲出答案", icon = "Interface\\Icons\\INV_Scroll_03" },
    { key = "dicts", title = "词库选择", desc = "选择你想练习的领域", icon = "Interface\\Icons\\INV_Box_01" },
    { key = "wrong", title = "错词本", desc = "复习输错过的词", icon = "Interface\\Icons\\INV_Misc_Book_11" },
    { key = "records", title = "学习记录", desc = "查看进度与统计", icon = "Interface\\Icons\\INV_Misc_Note_05" },
    { key = "about", title = "开源许可", desc = "qwerty-learner / GPL", icon = "Interface\\Icons\\INV_Misc_Book_09" },
}

local function ApplyColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function CreateBackdropFrame(frameType, name, parent, template)
    if BackdropTemplateMixin then
        if template and template ~= "" then
            template = template .. ",BackdropTemplate"
        else
            template = "BackdropTemplate"
        end
    end
    return CreateFrame(frameType, name, parent, template)
end

local function SetPanelBackdrop(frame, alpha)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        frame:SetBackdropColor(0.025, 0.020, 0.016, alpha or 0.95)
        frame:SetBackdropBorderColor(0.74, 0.54, 0.22, 1)
    end
end

local function SetContentBackdrop(frame)
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 16,
            insets = { left = 5, right = 5, top = 5, bottom = 5 },
        })
        frame:SetBackdropColor(0.055, 0.040, 0.030, 0.96)
        frame:SetBackdropBorderColor(0.62, 0.42, 0.16, 1)
    end
end

local function CreateText(parent, font, justify, color)
    local text = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    text:SetJustifyH(justify or "LEFT")
    text:SetJustifyV("TOP")
    ApplyColor(text, color or COLORS.text)
    return text
end

local function CreateInsetPanel(parent, width, height)
    local panel = CreateBackdropFrame("Frame", nil, parent)
    panel:SetSize(width, height)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0.09, 0.055, 0.032, 0.72)
    panel:SetBackdropBorderColor(0.46, 0.30, 0.12, 0.92)

    local top = panel:CreateTexture(nil, "BORDER")
    top:SetPoint("TOPLEFT", 5, -5)
    top:SetPoint("TOPRIGHT", -5, -5)
    top:SetHeight(18)
    top:SetTexture("Interface\\Buttons\\WHITE8x8")
    top:SetVertexColor(0.85, 0.48, 0.12, 0.12)
    panel.top = top
    return panel
end

local function CreateButton(parent, text, width, height, primary)
    local button = CreateBackdropFrame("Button", nil, parent)
    button:SetSize(width or 140, height or 36)
    button.primary = primary
    button.isActive = false
    button.isHovered = false
    button.isPressed = false

    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    button:SetBackdropColor(0.26, 0.035, 0.025, 0.95)
    button:SetBackdropBorderColor(0.82, 0.58, 0.18, 1)

    local shine = button:CreateTexture(nil, "ARTWORK")
    shine:SetPoint("TOPLEFT", 4, -4)
    shine:SetPoint("TOPRIGHT", -4, -4)
    shine:SetHeight(10)
    shine:SetTexture("Interface\\Buttons\\WHITE8x8")
    shine:SetVertexColor(1.0, 0.65, 0.22, 0.18)
    button.shine = shine

    local label = CreateText(button, "GameFontNormalLarge", "CENTER", COLORS.gold)
    label:SetPoint("CENTER")
    label:SetSize((width or 140) - 14, (height or 36) - 6)
    label:SetJustifyV("MIDDLE")
    button.label = label

    button.SetText = function(self, value)
        self.label:SetText(value or "")
    end
    button.GetText = function(self)
        return self.label:GetText()
    end
    button.RefreshVisual = function(self)
        if self.isActive then
            self:SetBackdropColor(0.42, 0.12, 0.035, 1)
            self:SetBackdropBorderColor(0.34, 1.0, 0.44, 1)
            self.shine:SetVertexColor(0.34, 1.0, 0.44, 0.22)
            ApplyColor(self.label, { 1.0, 0.96, 0.48, 1 })
        elseif self.isHovered then
            self:SetBackdropColor(0.36, 0.055, 0.035, 1)
            self:SetBackdropBorderColor(1.0, 0.78, 0.22, 1)
            self.shine:SetVertexColor(1.0, 0.65, 0.22, 0.18)
            ApplyColor(self.label, { 1.0, 0.92, 0.32, 1 })
        else
            self:SetBackdropColor(0.18, 0.035, 0.025, 0.95)
            self:SetBackdropBorderColor(0.70, 0.48, 0.16, 1)
            self.shine:SetVertexColor(1.0, 0.65, 0.22, 0.12)
            ApplyColor(self.label, COLORS.gold)
        end
    end
    button.SetActive = function(self, active)
        self.isActive = active and true or false
        self:RefreshVisual()
    end
    button.SetPressed = function(self, pressed)
        self.isPressed = pressed and true or false
        self.label:ClearAllPoints()
        self.label:SetPoint("CENTER", pressed and 1 or 0, pressed and -2 or 0)
        if pressed then
            self:SetBackdropColor(0.10, 0.018, 0.014, 1)
            self:SetBackdropBorderColor(0.46, 0.30, 0.10, 1)
        else
            self:RefreshVisual()
        end
    end
    button:SetText(text)
    button:RefreshVisual()

    button:SetScript("OnEnter", function(self)
        self.isHovered = true
        if not self.isPressed then
            self:RefreshVisual()
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.isHovered = false
        self:SetPressed(false)
    end)
    button:SetScript("OnMouseDown", function(self)
        self:SetPressed(true)
    end)
    button:SetScript("OnMouseUp", function(self)
        self:SetPressed(false)
    end)
    return button
end

local function CreateMenuButton(parent, item)
    local button = CreateBackdropFrame("Button", nil, parent)
    button:SetSize(220, 74)
    SetPanelBackdrop(button, 0.88)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(42, 42)
    icon:SetPoint("LEFT", 16, 0)
    icon:SetTexture(item.icon)
    button.icon = icon

    local title = CreateText(button, "GameFontHighlightLarge", "LEFT", COLORS.gold)
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 14, -2)
    title:SetText(item.title)
    button.title = title

    local desc = CreateText(button, "GameFontNormal", "LEFT", { 0.82, 0.74, 0.62, 1 })
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
    desc:SetText(item.desc)
    button.desc = desc

    button.SetActive = function(self, active)
        self.isActive = active and true or false
        if self.SetBackdropBorderColor then
            if active then
                self:SetBackdropColor(0.18, 0.10, 0.04, 0.96)
                self:SetBackdropBorderColor(1, 0.85, 0.20, 1)
                ApplyColor(self.title, { 1, 0.92, 0.30, 1 })
            else
                self:SetBackdropColor(0.025, 0.020, 0.016, 0.88)
                self:SetBackdropBorderColor(0.42, 0.33, 0.22, 1)
                ApplyColor(self.title, COLORS.gold)
            end
        end
    end

    button.SetPressed = function(self, pressed)
        self.isPressed = pressed and true or false
        if pressed then
            self:SetBackdropColor(0.01, 0.008, 0.006, 0.96)
            self:SetBackdropBorderColor(0.30, 0.22, 0.12, 1)
        else
            self:SetActive(self.isActive)
        end
    end
    button:SetScript("OnMouseDown", function(self)
        self:SetPressed(true)
    end)
    button:SetScript("OnMouseUp", function(self)
        self:SetPressed(false)
    end)

    return button
end

local function CreateStatusBar(parent, width, label, color)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetSize(width, 18)
    bar:SetMinMaxValues(0, 1)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(color[1], color[2], color[3], 1)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetVertexColor(0.05, 0.035, 0.025, 0.95)
    bar.bg = bg

    local text = CreateText(bar, "GameFontNormalSmall", "CENTER", COLORS.pale)
    text:SetPoint("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetText(label)
    bar.text = text

    bar.SetPercent = function(self, value)
        value = math.max(0, math.min(1, value or 0))
        self:SetValue(value)
        if self.label and self.label ~= "" then
            self.text:SetText(self.label .. "  " .. math.floor(value * 100 + 0.5) .. "%")
        end
    end
    bar.label = label

    return bar
end

local function CreateExperienceBar(parent, width, label, color)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetSize(width, 18)
    bar:SetMinMaxValues(0, 1)
    bar:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    bar.label = label

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
    bg:SetVertexColor(0.12, 0.09, 0.06, 0.92)
    bar.bg = bg

    local border = CreateBackdropFrame("Frame", nil, bar)
    border:SetPoint("TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", 3, -3)
    border:SetFrameLevel(bar:GetFrameLevel() + 1)
    if border.SetBackdrop then
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        border:SetBackdropBorderColor(0.78, 0.58, 0.22, 1)
    end
    bar.border = border

    local text = CreateText(bar, "GameFontNormalSmall", "CENTER", COLORS.pale)
    text:SetPoint("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetText(label .. "  0%")
    bar.text = text

    bar.SetPercent = function(self, value)
        value = math.max(0, math.min(1, value or 0))
        self:SetValue(value)
        self.text:SetText(self.label .. "  " .. math.floor(value * 100 + 0.5) .. "%")
    end

    return bar
end

local function Normalize(value)
    value = value or ""
    value = string.lower(value)
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function ColorizeTarget(target, typed)
    target = target or ""
    typed = typed or ""

    local result = ""
    local typedLower = string.lower(typed)
    local targetLower = string.lower(target)
    local typedLength = string.len(typed)

    for i = 1, string.len(target) do
        local char = string.sub(target, i, i)
        local targetChar = string.sub(targetLower, i, i)
        local typedChar = string.sub(typedLower, i, i)

        if i <= typedLength then
            if typedChar == targetChar then
                result = result .. "|cff66ff00" .. char .. "|r"
            else
                result = result .. "|cffff2020" .. string.sub(typed, i, i) .. "|r"
            end
        elseif i == typedLength + 1 then
            result = result .. "|cffffffff" .. char .. "|r"
        else
            result = result .. "|cffffffff" .. char .. "|r"
        end
    end

    return result
end

local function FitTextToWidth(fontString, text, maxWidth, baseSize)
    if not fontString.SetFont or not STANDARD_TEXT_FONT then
        return
    end
    local size = baseSize or 44
    fontString:SetFont(STANDARD_TEXT_FONT, size, "")
    fontString:SetText(text)
    while fontString:GetStringWidth() > maxWidth and size > 20 do
        size = size - 2
        fontString:SetFont(STANDARD_TEXT_FONT, size, "")
    end
end

local function MaskTarget(target, typed)
    target = target or ""
    typed = typed or ""

    local result = ""
    local typedLower = string.lower(typed)
    local targetLower = string.lower(target)

    for i = 1, string.len(target) do
        local typedChar = string.sub(typed, i, i)
        local typedCharLower = string.sub(typedLower, i, i)
        local targetCharLower = string.sub(targetLower, i, i)

        if typedChar ~= "" then
            if typedCharLower == targetCharLower then
                result = result .. "|cff66ff00" .. typedChar .. "|r"
            else
                result = result .. "|cffff2020" .. typedChar .. "|r"
            end
        else
            result = result .. "|cffffffff_|r"
        end

        if i < string.len(target) then
            result = result .. " "
        end
    end

    return result
end

local function HasTypingMistake(target, typed)
    target = string.lower(target or "")
    typed = string.lower(typed or "")

    for i = 1, string.len(typed) do
        if string.sub(typed, i, i) ~= string.sub(target, i, i) then
            return true
        end
    end

    return false
end

function XLM:CreateUI()
    if self.frame and self.uiReady then
        return
    end

    if self.frame and not self.uiReady then
        self.frame:Hide()
        self.frame:SetParent(nil)
        self.frame = nil
    end

    self.uiReady = false
    local frame = CreateBackdropFrame("Frame", "XLM_MainFrame", UIParent)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    SetPanelBackdrop(frame, 0.98)
    self.frame = frame

    local glow = frame:CreateTexture(nil, "BORDER")
    glow:SetPoint("TOPLEFT", 18, -18)
    glow:SetPoint("TOPRIGHT", -18, -18)
    glow:SetHeight(76)
    glow:SetTexture("Interface\\Buttons\\WHITE8x8")
    glow:SetVertexColor(0.42, 0.23, 0.06, 0.22)
    frame.glow = glow

    local title = CreateText(frame, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", frame, "TOP", CONTENT_CENTER_OFFSET, -28)
    title:SetText("学了么")
    frame.title = title

    local sub = CreateText(frame, "GameFontNormalLarge", "CENTER", COLORS.goldSoft)
    sub:SetPoint("TOP", title, "BOTTOM", 0, -2)
    sub:SetText("XLM")

    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetSize(420, 2)
    divider:SetPoint("TOP", sub, "BOTTOM", 0, -12)
    divider:SetTexture("Interface\\Buttons\\WHITE8x8")
    divider:SetVertexColor(0.9, 0.62, 0.16, 0.45)
    frame.divider = divider

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -18, -18)

    self:CreateSidebar()
    self:CreateContent()
    self:CreateHomeView()
    self:CreatePracticeView()
    self:CreateDictView()
    self:CreateWrongView()
    self:CreateRecordView()
    self:CreateAboutView()

    table.insert(UISpecialFrames, "XLM_MainFrame")
    self.uiReady = true
end

function XLM:CreateSidebar()
    local sidebar = CreateBackdropFrame("Frame", nil, self.frame)
    sidebar:SetSize(MENU_WIDTH, FRAME_HEIGHT - 110)
    sidebar:SetPoint("TOPLEFT", 24, -88)
    SetPanelBackdrop(sidebar, 0.92)
    self.sidebar = sidebar

    self.menuButtons = {}
    for i, item in ipairs(MENU_ITEMS) do
        local button = CreateMenuButton(sidebar, item)
        button:SetPoint("TOP", 0, -18 - ((i - 1) * 84))
        button:SetScript("OnClick", function()
            self:ShowView(item.key)
        end)
        self.menuButtons[item.key] = button
    end

    local portrait = sidebar:CreateTexture(nil, "ARTWORK")
    portrait:SetSize(58, 58)
    portrait:SetPoint("BOTTOMLEFT", 20, 22)
    portrait:SetTexture("Interface\\Icons\\Achievement_Character_Orc_Male")

    local info = CreateText(sidebar, "GameFontNormal", "LEFT", COLORS.text)
    info:SetPoint("LEFT", portrait, "RIGHT", 12, 0)
    info:SetSize(130, 60)
    sidebar.info = info
end

function XLM:CreateContent()
    local content = CreateBackdropFrame("Frame", nil, self.frame)
    content:SetSize(CONTENT_WIDTH, CONTENT_HEIGHT)
    content:SetPoint("TOPLEFT", self.sidebar, "TOPRIGHT", 18, 0)
    SetContentBackdrop(content)
    self.content = content

    local wash = content:CreateTexture(nil, "BORDER")
    wash:SetPoint("TOPLEFT", 10, -10)
    wash:SetPoint("BOTTOMRIGHT", -10, 10)
    wash:SetTexture("Interface\\Buttons\\WHITE8x8")
    wash:SetVertexColor(0.18, 0.10, 0.04, 0.22)
    content.wash = wash

    local close = CreateButton(self.frame, "关闭窗口", 170, 36)
    close:SetPoint("TOP", self.content, "BOTTOM", 0, 0)
    close:SetScript("OnClick", function()
        self.frame:Hide()
    end)
    self.closeButton = close
end

function XLM:HideViews()
    if self.homeView then self.homeView:Hide() end
    if self.practiceView then self.practiceView:Hide() end
    if self.dictView then self.dictView:Hide() end
    if self.wrongView then self.wrongView:Hide() end
    if self.recordView then self.recordView:Hide() end
    if self.aboutView then self.aboutView:Hide() end
end

function XLM:SetActiveMenu(key)
    for itemKey, button in pairs(self.menuButtons) do
        button:SetActive(itemKey == key)
    end
end

function XLM:CreateHomeView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    self.homeView = view

    local panelWidth = CONTENT_WIDTH - (CONTENT_PAD * 2)
    local statsPanel = CreateInsetPanel(view, panelWidth, 156)
    statsPanel:SetPoint("TOPLEFT", CONTENT_PAD, -62)

    local recentPanel = CreateInsetPanel(view, panelWidth, 168)
    recentPanel:SetPoint("TOPLEFT", CONTENT_PAD, -344)

    local title = CreateText(view, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", 0, -26)
    title:SetText("词汇练习")

    local dict = CreateText(view, "GameFontNormalLarge", "LEFT", COLORS.pale)
    dict:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 22, -20)
    dict:SetSize(520, 26)
    view.dict = dict

    view.accuracy = CreateStatusBar(view, 242, "正确率", COLORS.green)
    view.accuracy:SetPoint("TOPLEFT", dict, "BOTTOMLEFT", 0, -36)

    view.exp = CreateStatusBar(view, 242, "等级经验", COLORS.orange)
    view.exp:SetPoint("LEFT", view.accuracy, "RIGHT", 42, 0)

    view.explore = CreateStatusBar(view, panelWidth - 36, "词库探索进度", COLORS.blue)
    view.explore:SetPoint("TOPLEFT", view.accuracy, "BOTTOMLEFT", 0, -44)

    local start = CreateButton(view, "开始练习", 150, 46)
    start:SetPoint("TOPLEFT", statsPanel, "BOTTOMLEFT", 0, -34)
    start:SetScript("OnClick", function()
        self:StartPractice()
    end)

    local daily = CreateButton(view, "默写模式", 150, 46)
    daily:SetPoint("LEFT", start, "RIGHT", 54, 0)
    daily:SetScript("OnClick", function()
        self:StartPractice(nil, "dictation")
    end)

    local wrong = CreateButton(view, "错词复习", 150, 46)
    wrong:SetPoint("LEFT", daily, "RIGHT", 54, 0)
    wrong:SetScript("OnClick", function()
        self:ShowView("wrong")
    end)

    local recentTitle = CreateText(view, "GameFontNormalLarge", "LEFT", COLORS.pale)
    recentTitle:SetPoint("TOPLEFT", recentPanel, "TOPLEFT", 22, -18)
    recentTitle:SetText("最近学习记录")

    view.recentLines = {}
    for i = 1, 5 do
        local row = CreateFrame("Frame", nil, view)
        row:SetSize(panelWidth - 54, 22)
        row:SetPoint("TOPLEFT", recentTitle, "BOTTOMLEFT", 0, -8 - ((i - 1) * 24))

        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        bg:SetVertexColor(0.18, 0.10, 0.04, i % 2 == 0 and 0.10 or 0.18)
        row.bg = bg

        local status = CreateText(row, "GameFontNormalSmall", "CENTER", COLORS.green)
        status:SetPoint("LEFT", 10, 0)
        status:SetSize(46, 18)
        status:SetJustifyV("MIDDLE")
        row.status = status

        local word = CreateText(row, "GameFontNormal", "LEFT", COLORS.pale)
        word:SetPoint("LEFT", status, "RIGHT", 12, 0)
        word:SetSize(190, 18)
        word:SetJustifyV("MIDDLE")
        row.word = word

        local dictName = CreateText(row, "GameFontNormalSmall", "RIGHT", COLORS.muted)
        dictName:SetPoint("RIGHT", -10, 0)
        dictName:SetSize(200, 18)
        dictName:SetJustifyV("MIDDLE")
        row.dict = dictName

        view.recentLines[i] = row
    end

    local empty = CreateText(view, "GameFontNormal", "CENTER", COLORS.muted)
    empty:SetPoint("CENTER", recentPanel, "CENTER", 0, -18)
    empty:SetText("还没有学习记录")
    empty:Hide()
    view.recentEmpty = empty
end

function XLM:CreatePracticeView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    view:EnableMouse(true)
    view:SetScript("OnMouseDown", function()
        if self.practiceView and self.practiceView.input then
            self.practiceView.input:SetFocus()
        end
    end)
    view:Hide()
    self.practiceView = view

    local panelWidth = CONTENT_WIDTH - (CONTENT_PAD * 2)
    local focusPanel = CreateInsetPanel(view, panelWidth, 410)
    focusPanel:SetPoint("TOPLEFT", CONTENT_PAD, -76)
    view.focusPanel = focusPanel

    local dict = CreateText(view, "GameFontNormalLarge", "LEFT", COLORS.pale)
    dict:SetPoint("TOPLEFT", CONTENT_PAD + 18, -30)
    view.dict = dict

    local counter = CreateText(view, "GameFontNormal", "LEFT", COLORS.muted)
    counter:SetPoint("LEFT", dict, "RIGHT", 12, 0)
    view.counter = counter

    local streak = CreateText(view, "GameFontNormal", "RIGHT", COLORS.orange)
    streak:SetPoint("TOPRIGHT", -CONTENT_PAD - 18, -56)
    view.streak = streak

    local normalMode = CreateButton(view, "看词练习", 112, 30)
    normalMode:SetPoint("TOPRIGHT", -CONTENT_PAD - 134, -26)
    normalMode:SetScript("OnClick", function()
        self:SetPracticeMode("normal")
    end)
    view.normalMode = normalMode

    local dictationMode = CreateButton(view, "默写模式", 112, 30)
    dictationMode:SetPoint("LEFT", normalMode, "RIGHT", 10, 0)
    dictationMode:SetScript("OnClick", function()
        self:SetPracticeMode("dictation")
    end)
    view.dictationMode = dictationMode

    self:SetPracticeMode("normal", true)

    local topRule = view:CreateTexture(nil, "ARTWORK")
    topRule:SetPoint("TOPLEFT", focusPanel, "TOPLEFT", 34, -42)
    topRule:SetPoint("TOPRIGHT", focusPanel, "TOPRIGHT", -34, -42)
    topRule:SetHeight(2)
    topRule:SetTexture("Interface\\Buttons\\WHITE8x8")
    topRule:SetVertexColor(0.85, 0.58, 0.16, 0.42)
    view.topRule = topRule

    local target = CreateText(view, "GameFontHighlightLarge", "CENTER", { 1.0, 1.0, 1.0, 1 })
    if target.SetFont and STANDARD_TEXT_FONT then
        target:SetFont(STANDARD_TEXT_FONT, 48, "OUTLINE")
    end
    target:SetShadowColor(0, 0, 0, 1)
    target:SetShadowOffset(2, -2)
    target:SetPoint("TOP", focusPanel, "TOP", 0, -112)
    target:SetSize(panelWidth - 60, 72)
    view.target = target

    local sound = CreateText(view, "GameFontNormalLarge", "CENTER", COLORS.muted)
    sound:SetPoint("TOP", target, "BOTTOM", 0, -4)
    sound:SetText("")
    sound:Hide()
    view.sound = sound

    local trans = CreateText(view, "GameFontHighlightLarge", "CENTER", { 1.0, 0.98, 0.86, 1 })
    if trans.SetFont and STANDARD_TEXT_FONT then
        trans:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
    end
    trans:SetShadowColor(0, 0, 0, 1)
    trans:SetShadowOffset(1, -1)
    trans:SetPoint("TOP", target, "BOTTOM", 0, -30)
    trans:SetSize(panelWidth - 60, 78)
    view.trans = trans

    local progress = CreateStatusBar(view, 280, "", COLORS.gold)
    progress:SetPoint("BOTTOM", focusPanel, "BOTTOM", 0, 14)
    progress.text:SetText("")
    progress:SetHeight(10)
    progress:Hide()
    view.progress = progress

    local hintLine = view:CreateTexture(nil, "ARTWORK")
    hintLine:SetSize(330, 3)
    hintLine:SetPoint("BOTTOM", progress, "TOP", 0, 8)
    hintLine:SetTexture("Interface\\Buttons\\WHITE8x8")
    hintLine:SetVertexColor(0.65, 0.60, 0.95, 0.42)
    hintLine:Hide()
    view.hintLine = hintLine

    local input = CreateFrame("EditBox", nil, view)
    input:SetSize(1, 1)
    input:SetPoint("BOTTOM", focusPanel, "BOTTOM", 0, 10)
    input:SetAutoFocus(false)
    input:SetFontObject("GameFontNormal")
    input:SetAlpha(0.01)
    input:EnableKeyboard(true)
    input:SetScript("OnTextChanged", function()
        self:UpdateTyping()
    end)
    view.input = input

    local result = CreateText(view, "GameFontNormalLarge", "CENTER", COLORS.pale)
    result:SetPoint("TOP", trans, "BOTTOM", 0, -10)
    result:SetSize(panelWidth - 40, 30)
    view.result = result

    local typed = CreateText(view, "GameFontNormal", "CENTER", COLORS.muted)
    typed:SetPoint("TOP", result, "BOTTOM", 0, -10)
    typed:SetSize(panelWidth - 40, 50)
    typed:Hide()
    view.typed = typed

    local reveal = CreateButton(view, "提示", 90, 36)
    reveal:SetPoint("BOTTOM", focusPanel, "BOTTOM", 0, 24)
    reveal:SetScript("OnClick", function()
        self:RevealAnswer()
    end)
    view.reveal = reveal

    local next = CreateButton(view, "下一个", 120, 36)
    next:SetPoint("BOTTOMLEFT", reveal, "BOTTOMRIGHT", 16, 0)
    next:SetScript("OnClick", function()
        self:LoadWord()
    end)
    view.next = next

    local back = CreateButton(view, "返回", 120, 36)
    back:SetPoint("BOTTOMRIGHT", reveal, "BOTTOMLEFT", -16, 0)
    back:SetScript("OnClick", function()
        self:ShowView("home")
    end)

    input:SetScript("OnEnterPressed", function()
        if self.currentCompleted then
            self:LoadWord()
        end
    end)
    input:SetScript("OnEscapePressed", function()
        self:ShowView("home")
    end)
    input:SetScript("OnTabPressed", function()
        self:RevealAnswer()
    end)
end

function XLM:CreateDictView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    view:Hide()
    self.dictView = view

    local title = CreateText(view, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", 0, -30)
    title:SetText("词库选择")

    view.buttons = {}
    for i, dict in ipairs(XLM_DICTIONARIES) do
        local button = CreateButton(view, dict.name, 470, 42)
        button:SetPoint("TOP", title, "BOTTOM", 0, -24 - ((i - 1) * 54))
        button:SetScript("OnClick", function()
            self:SetSelectedDictionary(dict.id)
            self:StartPractice(nil, self.practiceMode or "normal")
        end)
        view.buttons[i] = button
    end

    local source = CreateText(view, "GameFontNormal", "LEFT", COLORS.pale)
    source:SetPoint("BOTTOMLEFT", 44, 48)
    source:SetSize(540, 52)
    view.source = source
end

function XLM:CreateWrongView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    view:Hide()
    self.wrongView = view
    self.wrongPage = 1

    local title = CreateText(view, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", 0, -30)
    title:SetText("错词本")

    view.lines = {}
    for i = 1, WRONG_PAGE_SIZE do
        local button = CreateButton(view, "", 520, 32)
        button:SetPoint("TOPLEFT", 44, -82 - ((i - 1) * 38))
        view.lines[i] = button
    end

    local detail = CreateText(view, "GameFontNormal", "LEFT", COLORS.pale)
    detail:SetPoint("TOPLEFT", view.lines[WRONG_PAGE_SIZE], "BOTTOMLEFT", 0, -20)
    detail:SetSize(520, 60)
    view.detail = detail

    local retry = CreateButton(view, "复习选中", 120, 34)
    retry:SetPoint("BOTTOMLEFT", 44, 36)
    retry:SetScript("OnClick", function()
        if self.selectedWrongWord then
            self:StartPractice(self.selectedWrongWord)
        end
    end)
    view.retry = retry

    local clear = CreateButton(view, "清空", 100, 34)
    clear:SetPoint("LEFT", retry, "RIGHT", 12, 0)
    clear:SetScript("OnClick", function()
        self:ClearWrongWords()
        self.selectedWrongWord = nil
        self:RefreshWrongView()
    end)

    local back = CreateButton(view, "返回", 100, 34)
    back:SetPoint("BOTTOMRIGHT", -44, 36)
    back:SetScript("OnClick", function()
        self:ShowView("home")
    end)
end

function XLM:CreateRecordView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    view:Hide()
    self.recordView = view

    local title = CreateText(view, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", 0, -30)
    title:SetText("学习记录")

    view.bars = {}
    local labels = { "正确率", "等级经验", "连击状态", "错词压力" }
    local colors = { COLORS.green, COLORS.orange, COLORS.gold, COLORS.red }
    for i, label in ipairs(labels) do
        local labelText = CreateText(view, "GameFontNormalLarge", "LEFT", COLORS.pale)
        labelText:SetPoint("TOPLEFT", 58, -92 - ((i - 1) * 70))
        labelText:SetText(label)
        local bar = CreateExperienceBar(view, 420, label, colors[i])
        bar:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -12)
        view.bars[i] = bar
    end
end

function XLM:CreateAboutView()
    local view = CreateFrame("Frame", nil, self.content)
    view:SetAllPoints()
    view:Hide()
    self.aboutView = view

    local title = CreateText(view, "GameFontHighlightLarge", "CENTER", COLORS.gold)
    title:SetPoint("TOP", 0, -32)
    title:SetText("开源许可")

    local body = CreateText(view, "GameFontNormalLarge", "LEFT", COLORS.pale)
    body:SetPoint("TOPLEFT", 54, -90)
    body:SetSize(CONTENT_WIDTH - 108, 320)
    body:SetWordWrap(true)
    body:SetText(
        "本插件按 qwerty-learner 的核心体验移植：看释义，输入英文。\n\n" ..
        "词库来源：RealKai42/qwerty-learner\n" ..
        "许可证：GNU GPL-3.0\n\n" ..
        "当前已搬入：CET-4 四级词汇、CET-6 六级词汇。"
    )
end

function XLM:RefreshSidebar()
    local db = self:GetDB()
    self.sidebar.info:SetText("等级：" .. db.level .. "\n经验：" .. db.exp .. " / " .. self:GetLevelExp() .. "\n连击：" .. db.streak)
end

function XLM:RefreshHome()
    local db = self:GetDB()
    local dict = self:GetSelectedDictionary()
    local mastered = 0
    for _, word in ipairs(dict.words) do
        if db.mastered[dict.id .. ":" .. word.name] then
            mastered = mastered + 1
        end
    end

    self.homeView.dict:SetText("当前词库：" .. dict.name)
    self.homeView.accuracy:SetPercent(self:GetAccuracy() / 100)
    self.homeView.exp:SetPercent(db.exp / self:GetLevelExp())
    self.homeView.explore:SetPercent(mastered / math.max(1, #dict.words))

    for i = 1, 5 do
        local record = db.recent[i]
        local row = self.homeView.recentLines[i]
        if record then
            row:Show()
            if record.correct then
                row.status:SetText("正确")
                ApplyColor(row.status, COLORS.green)
            else
                row.status:SetText("错词")
                ApplyColor(row.status, COLORS.red)
            end
            row.word:SetText(record.word or "")
            row.dict:SetText(record.dict or "")
        else
            row:Hide()
        end
    end
    if self.homeView.recentEmpty then
        if #db.recent == 0 then
            self.homeView.recentEmpty:Show()
        else
            self.homeView.recentEmpty:Hide()
        end
    end

    self:RefreshSidebar()
end

function XLM:RefreshDictView()
    local dict = self:GetSelectedDictionary()
    self.dictView.source:SetText("当前：" .. dict.name .. "\n来源：" .. dict.source .. "\n许可：GPL-3.0")
end

function XLM:RefreshWrongView()
    local list = self:GetWrongList()
    for i = 1, WRONG_PAGE_SIZE do
        local record = list[i]
        local button = self.wrongView.lines[i]
        if record then
            button:SetText(record.name .. "    错误次数：" .. record.wrongCount)
            button:Show()
            button:SetScript("OnClick", function()
                local word = self:GetWordByKey(record.key)
                self.selectedWrongWord = word
                self.wrongView.detail:SetText(record.trans .. "\n上次输入：" .. (record.lastTyped or ""))
            end)
        else
            button:SetText("")
            button:Hide()
        end
    end
    if #list == 0 then
        self.wrongView.detail:SetText("没有错词。")
    end
end

function XLM:RefreshRecordView()
    local db = self:GetDB()
    self.recordView.bars[1]:SetPercent(self:GetAccuracy() / 100)
    self.recordView.bars[2]:SetPercent(db.exp / self:GetLevelExp())
    self.recordView.bars[3]:SetPercent(math.min(1, db.streak / 10))
    self.recordView.bars[4]:SetPercent(math.min(1, self:GetWrongCount() / 20))
end

function XLM:ShowView(key)
    self:CreateUI()
    self:HideViews()
    self:SetActiveMenu(key)
    self.frame:Show()

    if key == "practice" then
        self:StartPractice()
    elseif key == "dicts" then
        self.dictView:Show()
        self:RefreshDictView()
    elseif key == "wrong" then
        self.wrongView:Show()
        self:RefreshWrongView()
    elseif key == "records" then
        self.recordView:Show()
        self:RefreshRecordView()
    elseif key == "about" then
        self.aboutView:Show()
    else
        self.homeView:Show()
        self:RefreshHome()
    end

    self:RefreshSidebar()
end

function XLM:ShowHome()
    self:ShowView("home")
end

function XLM:SetPracticeMode(mode, noReload)
    self.practiceMode = mode or "normal"

    if self.practiceView then
        self.practiceView.normalMode:SetText("看词练习")
        self.practiceView.dictationMode:SetText("默写模式")
        self.practiceView.normalMode:SetActive(self.practiceMode == "normal")
        self.practiceView.dictationMode:SetActive(self.practiceMode == "dictation")
    end

    if not noReload and self.currentWord and self.practiceView and self.practiceView:IsVisible() then
        self:LoadWord(self.currentWord)
    end
end

function XLM:StartPractice(word, mode)
    self:HideViews()
    self:SetActiveMenu("practice")
    self.practiceView:Show()
    self.frame:Show()
    self.practiceCount = 0
    self:SetPracticeMode(mode, true)
    self:LoadWord(word)
end

function XLM:LoadWord(word)
    self.currentWord = word or self:GetRandomWord()
    if not self.currentWord then
        return
    end

    self.loadingWord = true
    self.currentHadMistake = false
    self.currentWrongRecorded = false
    self.currentCompleted = false
    self.practiceCount = (self.practiceCount or 0) + 1

    local dict = self:GetSelectedDictionary()
    local totalWords = dict and #dict.words or 0
    self.practiceView.counter:SetText("第 " .. self.practiceCount .. " 词  (共 " .. totalWords .. " 词)")

    self.practiceView.dict:SetText(self.currentWord.dictName)
    if self.practiceView.progress then
        self.practiceView.progress:SetValue(0)
    end

    self.practiceView.underline = self.practiceView.underline or CreateText(self.practiceView, "GameFontNormal", "CENTER", { 1, 1, 1, 0.3 })
    self.practiceView.underline:ClearAllPoints()
    self.practiceView.underline:SetPoint("TOP", self.practiceView.target, "BOTTOM", 0, -4)
    self.practiceView.underline:SetText(string.rep("_", string.len(self.currentWord.name)))
    self.practiceView.underline:Hide()

    local targetWidth = self.practiceView.target:GetWidth() or (CONTENT_WIDTH - (CONTENT_PAD * 2) - 60)
    if self.practiceMode == "dictation" then
        FitTextToWidth(self.practiceView.target, MaskTarget(self.currentWord.name, ""), targetWidth - 20, 44)
        self.practiceView.target:SetAlpha(1)
        self.practiceView.sound:Hide()
    else
        FitTextToWidth(self.practiceView.target, ColorizeTarget(self.currentWord.name, ""), targetWidth - 20, 44)
        self.practiceView.target:SetAlpha(1)
        self.practiceView.sound:Hide()
    end

    self.practiceView.trans:SetText(self.currentWord.trans)
    self.practiceView.input:SetText("")
    self.practiceView.input:SetFocus()
    self.practiceView.result:SetText("")
    self.practiceView.typed:SetText("")
    self.practiceView.streak:SetText("")

    self.loadingWord = false
end

function XLM:UpdateTyping()
    if self.loadingWord or self.currentCompleted or not self.currentWord then
        return
    end

    local typed = self.practiceView.input:GetText()
    local target = self.currentWord.name
    local typedLength = string.len(typed or "")
    local targetLength = math.max(1, string.len(target or ""))
    local hasMistake = HasTypingMistake(target, typed)
    local complete = Normalize(typed) == Normalize(target)

    if self.practiceView.input.SetCursorPosition then
        self.practiceView.input:SetCursorPosition(typedLength)
    end

    if self.practiceMode == "dictation" then
        self.practiceView.target:SetText(MaskTarget(target, typed))
        self.practiceView.typed:SetText("")
    else
        self.practiceView.target:SetText(ColorizeTarget(target, typed))
        self.practiceView.typed:SetText(typed)
    end

    if self.practiceView.underline then
        self.practiceView.underline:SetText(string.rep("_", string.len(target)))
        self.practiceView.underline:Hide()
    end

    if hasMistake then
        self.currentHadMistake = true
        ApplyColor(self.practiceView.result, COLORS.red)
        self.practiceView.result:SetText("输入有误，退格修正")
    else
        self.practiceView.result:SetText("")
    end

    if complete then
        self.currentCompleted = true
        self:AddCorrect(self.currentWord)
        local db = self:GetDB()
        local streakText = db.streak > 1 and ("连击 x" .. db.streak .. "!") or ""
        ApplyColor(self.practiceView.result, COLORS.green)
        self.practiceView.result:SetText("正确，经验 +10")
        self.practiceView.streak:SetText(streakText)
        self.practiceView.target:SetText("|cffb6ff3f" .. target .. "|r")
        self.practiceView.target:SetAlpha(1)
        self.practiceView.sound:Hide()
        if self.practiceView.underline then
            self.practiceView.underline:SetText(string.rep("_", string.len(target)))
            self.practiceView.underline:Hide()
        end
        PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or "igMainMenuOptionCheckBoxOn")

        if C_Timer and C_Timer.After then
            C_Timer.After(0.8, function()
                self:LoadWord()
            end)
        else
            self:LoadWord()
        end
    elseif hasMistake and typedLength >= targetLength and not self.currentWrongRecorded then
        self.currentWrongRecorded = true
        self:AddWrong(self.currentWord, typed)
        PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or "igMainMenuOptionCheckBoxOff")
    end

    self:RefreshSidebar()
end

function XLM:SubmitWord()
    self:UpdateTyping()
end

function XLM:RevealAnswer()
    if not self.currentWord or self.currentCompleted then
        return
    end

    local target = self.currentWord.name
    self.practiceView.target:SetText("|cffffcc00" .. target .. "|r")
    self.practiceView.target:SetAlpha(1)
    ApplyColor(self.practiceView.result, COLORS.orange)
    self.practiceView.result:SetText("已揭示答案，不计入正确")

    if not self.currentWrongRecorded then
        self.currentWrongRecorded = true
        self.currentHadMistake = true
        self:AddWrong(self.currentWord, self.practiceView.input:GetText() or "")
    end
end
