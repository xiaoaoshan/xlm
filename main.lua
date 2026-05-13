XLM = XLM or {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "xlm" then
        XLM:InitDB()
    elseif event == "PLAYER_LOGIN" then
        XLM:InitDB()
        if XLM.CreateUI then
            XLM:CreateUI()
        end
    end
end)

SLASH_XLM1 = "/xlm"
SlashCmdList.XLM = function()
    XLM:InitDB()
    XLM:CreateUI()
    XLM:ShowHome()
end
