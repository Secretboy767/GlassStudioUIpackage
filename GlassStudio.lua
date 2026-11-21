--[[
    GLASS STUDIO 5.0 - GLASSUI EDITION
    A UI-only showcase built on the reusable GlassUI library.

    This recreates the compact graphite dashboard, five-page navigation,
    responsive mobile layout, glass cards, activity feed, notifications,
    minimize/restore/maximize/close controls, and animated transitions.

    This sample intentionally contains no account automation, credential
    generation, cookie/session importing, or game-modification logic.

    Put GlassUI.lua in the same folder / ModuleScript location and load it
    using the method appropriate for your environment.
]]

-- For Roblox Studio, put GlassUI.lua in a ModuleScript named GlassUI:
-- local GlassUI = require(path.To.GlassUI)
-- For an authorized loader, replace the URL with your own published raw URL:
local GlassUI = loadstring(game:HttpGet("RAW_GITHUB_URL/GlassUI.lua"))()

local Window = GlassUI:CreateWindow({
    Title = "GLASS STUDIO",
    Subtitle = "ACCOUNT WORKSPACE",
    Theme = "Graphite",
    StartMinimized = false,
    DefaultTab = "Dashboard",
})

--========================================================
-- ACTIVITY FEED
--========================================================

local activityEntries = {}
local activityOutput
local activityCount = 0

local function log(message)
    activityCount += 1
    table.insert(activityEntries, 1, os.date("%H:%M:%S") .. "   " .. tostring(message))
    while #activityEntries > 18 do
        table.remove(activityEntries)
    end
    if activityOutput then
        activityOutput:SetValue(table.concat(activityEntries, "\n\n"))
    end
end

local function notify(title, content, duration)
    Window:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
    })
end

--========================================================
-- DASHBOARD
--========================================================

local Dashboard = Window:CreateTab("Dashboard", "H")
local Overview = Dashboard:CreateSection("OVERVIEW")

Overview:AddParagraph({
    Title = "GLASS STUDIO",
    Content = "Your compact workspace is ready. This is the GlassUI-powered edition of the original mobile dashboard.",
})

local Status = Dashboard:CreateSection("WORKSPACE STATUS")
Status:AddLabel("WORKSPACE     Local interface")
Status:AddLabel("LIBRARY           GlassUI 1.0.0")
Status:AddLabel("LAYOUT              Responsive / Mobile first")

local Quick = Dashboard:CreateSection("QUICK ACCESS")
Quick:AddButton({
    Name = "Open Account Studio",
    Description = "Open the workspace tools page.",
    ButtonText = "Open",
    Callback = function()
        Window:SelectTab("Account Studio")
        log("Opened Account Studio")
    end,
})
Quick:AddButton({
    Name = "Show notification",
    Description = "Preview the built-in animated toast.",
    ButtonText = "Preview",
    Callback = function()
        notify("GLASS STUDIO", "The notification system is working.")
        log("Displayed notification")
    end,
})

--========================================================
-- ACCOUNT STUDIO (UI DEMO ONLY)
--========================================================

local Account = Window:CreateTab("Account Studio", "A")
local Profile = Account:CreateSection("PROFILE WORKSPACE")

Profile:AddParagraph({
    Title = "Workspace details",
    Content = "A neutral example page for text fields and actions. Values stay in this local interface; this demo does not create accounts or handle login credentials.",
})

local displayName = ""
local profileNote = ""

Profile:AddInput({
    Name = "Display label",
    Placeholder = "Enter a label...",
    Default = "",
    Callback = function(value)
        displayName = value
    end,
})

Profile:AddInput({
    Name = "Workspace note",
    Placeholder = "Add a short note...",
    Default = "",
    Callback = function(value)
        profileNote = value
    end,
})

Profile:AddButton({
    Name = "Preview workspace details",
    Description = "Shows the values entered above in a notification.",
    ButtonText = "Preview",
    Callback = function()
        local label = displayName ~= "" and displayName or "Untitled workspace"
        local note = profileNote ~= "" and profileNote or "No note provided"
        notify(label, note, 4)
        log("Previewed workspace details")
    end,
})

local Components = Account:CreateSection("COMPONENT PREVIEW")
Components:AddToggle({
    Name = "Example toggle",
    Default = false,
    Callback = function(value)
        log("Example toggle: " .. (value and "ON" or "OFF"))
    end,
})

Components:AddSlider({
    Name = "Example value",
    Min = 0,
    Max = 100,
    Default = 45,
    Step = 1,
    Callback = function(value)
        log("Example value changed to " .. tostring(value))
    end,
})

Components:AddDropdown({
    Name = "Workspace mode",
    Options = {"Balanced", "Compact", "Spacious"},
    Default = "Balanced",
    Callback = function(value)
        log("Workspace mode: " .. tostring(value))
    end,
})

--========================================================
-- SESSION CENTER (LOCAL UI STATUS ONLY)
--========================================================

local Session = Window:CreateTab("Session Center", "E")
local SessionInfo = Session:CreateSection("CURRENT SESSION")

SessionInfo:AddParagraph({
    Title = "Local interface session",
    Content = "No external session is connected. This page is informational only and does not read, import, store, or transmit authentication tokens or cookies.",
})
SessionInfo:AddLabel("STATUS       Not connected")
SessionInfo:AddLabel("STORAGE     No session data stored")

SessionInfo:AddButton({
    Name = "Refresh local status",
    Description = "Refreshes this demo page's informational status.",
    ButtonText = "Refresh",
    Callback = function()
        notify("SESSION CENTER", "Local status: Not connected")
        log("Refreshed local session status")
    end,
})

--========================================================
-- ACTIVITY
--========================================================

local Activity = Window:CreateTab("Activity", "L")
local History = Activity:CreateSection("EVENT HISTORY")

History:AddParagraph({
    Title = "Recent interface events",
    Content = "Actions performed in this demo appear below. The list is temporary and clears when the script is restarted.",
})

activityOutput = History:AddInput({
    Name = "Activity log",
    Placeholder = "No activity recorded yet.",
    Default = "No activity recorded.",
    Callback = function() end,
})

History:AddButton({
    Name = "Clear history",
    Description = "Clear the local activity list.",
    ButtonText = "Clear",
    Callback = function()
        table.clear(activityEntries)
        if activityOutput then
            activityOutput:SetValue("No activity recorded.")
        end
        notify("ACTIVITY", "History cleared.")
    end,
})

--========================================================
-- PREFERENCES
--========================================================

local Preferences = Window:CreateTab("Preferences", "P")
local WindowOptions = Preferences:CreateSection("WINDOW")

WindowOptions:AddButton({
    Name = "Minimize window",
    Description = "Collapse the panel into the restore pill.",
    ButtonText = "Minimize",
    Callback = function()
        Window:Minimize()
        log("Window minimized")
    end,
})

WindowOptions:AddButton({
    Name = "Restore window",
    Description = "Restore the panel after minimizing.",
    ButtonText = "Restore",
    Callback = function()
        Window:Restore()
        log("Window restored")
    end,
})

WindowOptions:AddButton({
    Name = "Maximize / restore size",
    Description = "Toggle the responsive expanded size.",
    ButtonText = "Resize",
    Callback = function()
        Window:Maximize()
        log("Toggled window size")
    end,
})

WindowOptions:AddButton({
    Name = "Center window",
    Description = "Restore the default centered position and size.",
    ButtonText = "Center",
    Callback = function()
        Window:Maximize(false)
        Window:Restore()
        notify("PREFERENCES", "Window size restored.")
        log("Restored default window size")
    end,
})

local About = Preferences:CreateSection("ABOUT")
About:AddLabel("GLASS STUDIO 5.0")
About:AddLabel("Powered by GlassUI 1.0.0")
About:AddLabel("Graphite glass · Compact · Mobile first")
About:AddDivider()
About:AddParagraph({
    Title = "Controls",
    Content = "Drag the center grip to move the window. Use the header controls to minimize, maximize, or close. Portrait mode uses bottom navigation; landscape mode uses the side rail.",
})

log("Glass Studio 5.0 initialized")
notify("GLASS STUDIO", "Workspace initialized successfully.", 3)

print("[Glass Studio 5.0] Loaded with GlassUI")
