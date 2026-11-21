-- GLASSUI EXAMPLE
-- For an executor distribution, replace RAW_GITHUB_URL with your published raw file URL.
-- In Roblox Studio, place GlassUI.lua in a ModuleScript and use: local GlassUI = require(path.To.GlassUI)

local GlassUI = loadstring(game:HttpGet("RAW_GITHUB_URL"))()

local Window = GlassUI:CreateWindow({
    Title = "MY PANEL",
    Subtitle = "POWERED BY GLASSUI",
    Theme = "Graphite", -- Graphite, Midnight, Light, or a custom color table
    StartMinimized = false,
})

local Main = Window:CreateTab("Main", "M")
local Settings = Window:CreateTab("Settings", "S")

local General = Main:CreateSection("GENERAL")

General:AddParagraph({
    Title = "Welcome",
    Content = "This is a reusable GlassUI panel. Add your own controls and connect them to your own script functions.",
})

General:AddButton({
    Name = "Run example",
    Description = "Calls a normal Luau callback.",
    ButtonText = "Run",
    Callback = function()
        Window:Notify({
            Title = "Example",
            Content = "The button callback ran successfully.",
            Duration = 3,
        })
    end,
})

local enabled = General:AddToggle({
    Name = "Enable feature",
    Default = false,
    Callback = function(value)
        print("Feature enabled:", value)
    end,
})

local volume = General:AddSlider({
    Name = "Example value",
    Min = 0,
    Max = 100,
    Default = 45,
    Step = 1,
    Callback = function(value)
        print("Slider value:", value)
    end,
})

local choices = General:AddDropdown({
    Name = "Select mode",
    Options = {"Balanced", "Fast", "Quiet"},
    Default = "Balanced",
    Callback = function(value)
        print("Selected:", value)
    end,
})

local SettingsSection = Settings:CreateSection("PREFERENCES")

local usernameInput = SettingsSection:AddInput({
    Name = "Display name",
    Placeholder = "Type something...",
    Default = "Player",
    Callback = function(value)
        print("Input:", value)
    end,
})

SettingsSection:AddLabel("Changes are local to this UI example.")
SettingsSection:AddDivider()
SettingsSection:AddParagraph({
    Content = "Use Window:Destroy() to close the interface from your own code.",
})

-- Useful methods:
-- Window:Notify({Title = "Saved", Content = "Your setting was saved."})
-- Window:SelectTab("Settings")
-- Window:Minimize()
-- Window:Restore()
-- Window:Maximize(true) / Window:Maximize(false)
-- Window:Destroy()
-- enabled:SetValue(true, false) -- second argument false = do not fire callback
-- print(volume:GetValue())
-- choices:SetValue("Fast")
-- usernameInput:SetValue("New value")
