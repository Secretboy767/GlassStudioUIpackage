-- GLASS STUDIO 6.0 — GLASSUI 2.0 SHOWCASE
-- Roblox Studio: put GlassUI.lua in ReplicatedStorage as a ModuleScript,
-- then run this from a LocalScript.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlassUI = require(ReplicatedStorage:WaitForChild("GlassUI"))

local Window = GlassUI:CreateWindow({
    Title = "GLASS STUDIO",
    Subtitle = "LIQUID INTERFACE SYSTEM  •  2.0",
    Theme = "Graphite",
    DefaultTab = "Overview",
})

local function notify(title, content)
    Window:Notify({Title = title, Content = content, Duration = 3})
end

local Overview = Window:CreateTab("Overview", "⌂")
local Intro = Overview:CreateSection("WELCOME")
Intro:AddParagraph({
    Title = "GLASS STUDIO",
    Content = "A modular, mobile-first interface framework. Explore the controls, material presets, and live customization tools.",
})
Intro:AddBadge({Text = "GLASSUI 2.0  •  READY", Width = 142})
local Metrics = Overview:CreateSection("LIVE METRICS")
local fps = Metrics:AddStatCard({Name = "INTERFACE STATUS", Value = "ONLINE"})
local progress = Metrics:AddProgressBar({Name = "SHOWCASE PROGRESS", Default = 72})
local Actions = Overview:CreateSection("QUICK ACTIONS")
Actions:AddButton({Name = "Test notification", ButtonText = "TEST", Callback = function()
    notify("GLASS STUDIO", "Notification system is working.")
end})
Actions:AddButton({Name = "Open customization", ButtonText = "OPEN", Callback = function()
    Window:SelectTab("Appearance")
end})

local Components = Window:CreateTab("Components", "◇")
local Inputs = Components:CreateSection("CORE INPUTS")
Inputs:AddToggle({Name = "Example toggle", Default = true, Callback = function(v)
    notify("TOGGLE", v and "Enabled" or "Disabled")
end})
Inputs:AddSlider({Name = "Intensity", Min = 0, Max = 100, Default = 64, Step = 1,
    Callback = function(v) progress:SetValue(v) end})
Inputs:AddDropdown({Name = "Operating mode", Options = {"Balanced", "Performance", "Quiet"},
    Default = "Balanced", Callback = function(v) fps:SetValue(v:upper()) end})
Inputs:AddInput({Name = "Workspace label", Placeholder = "Type a label...", Default = "My Workspace",
    Callback = function(v) print("Workspace label:", v) end})
Inputs:AddSearch({Placeholder = "Search components...", Callback = function(v)
    print("Search query:", v)
end})
Inputs:AddKeybind({Name = "Showcase shortcut", Default = "RightShift", Callback = function(key)
    Window:Toggle()
end})
local Advanced = Components:CreateSection("ADVANCED INPUTS")
Advanced:AddRangeSlider({Name = "Range selector", Min = 0, Max = 100, DefaultMin = 20, DefaultMax = 78,
    Callback = function(a, b) print("Range:", a, b) end})
Advanced:AddColorPicker({Name = "Accent palette", Callback = function(color)
    Window:SetAccent(color)
end})
Advanced:AddAccordion({Title = "More information", Content = "GlassUI components are reusable. Returned controls expose GetValue, SetValue, and Destroy methods where applicable."})

local Appearance = Window:CreateTab("Appearance", "◈")
local Materials = Appearance:CreateSection("GLASS MATERIALS")
Materials:AddParagraph({Title = "Choose a surface", Content = "Material presets adjust the visual transparency and border treatment of supported surfaces."})
Materials:AddDropdown({Name = "Material preset", Options = {"Graphite", "Liquid", "FullGlass", "Solid"},
    Default = "Graphite", Callback = function(v)
        Window:SetMaterial(v)
        notify("MATERIAL", v .. " applied")
    end})
Materials:AddDropdown({Name = "Color theme", Options = {"Graphite", "Midnight", "Light"},
    Default = "Graphite", Callback = function(v)
        Window:SetTheme(v)
    end})
Materials:AddColorPicker({Name = "Custom accent", Callback = function(color)
    Window:SetAccent(color)
end})
Materials:AddButton({Name = "Restore default appearance", ButtonText = "RESET", Callback = function()
    Window:SetTheme("Graphite")
    Window:SetMaterial("Graphite")
    notify("APPEARANCE", "Default appearance restored.")
end})

local Developer = Window:CreateTab("Developer", "⌘")
local ConsoleSection = Developer:CreateSection("OUTPUT")
local console = ConsoleSection:AddConsole({Default = "GlassUI 2.0 initialized.", Height = 132})
ConsoleSection:AddButton({Name = "Write sample log", ButtonText = "WRITE", Callback = function()
    console:Write(os.date("%H:%M:%S") .. "  Showcase action completed")
end})
ConsoleSection:AddButton({Name = "Clear console", ButtonText = "CLEAR", Callback = function()
    console:Clear()
end})
local CodeSection = Developer:CreateSection("CODE PREVIEW")
CodeSection:AddCodeBlock({Title = "LUA EXAMPLE", Code = 'local Window = GlassUI:CreateWindow({\\n    Title = "My Interface",\\n    Theme = "Graphite",\\n})\\n\\nlocal Tab = Window:CreateTab("Main", "M")'})

local Settings = Window:CreateTab("Settings", "⚙")
local WindowSection = Settings:CreateSection("WINDOW")
WindowSection:AddButton({Name = "Minimize window", ButtonText = "MINIMIZE", Callback = function() Window:Minimize() end})
WindowSection:AddButton({Name = "Maximize / restore", ButtonText = "RESIZE", Callback = function() Window:Maximize() end})
WindowSection:AddButton({Name = "Close window", ButtonText = "CLOSE", Callback = function() Window:Destroy() end})
WindowSection:AddParagraph({Title = "About", Content = "Glass Studio 6.0 • GlassUI 2.0. Designed for Roblox experiences you own or are authorized to develop."})

notify("GLASS STUDIO", "Showcase loaded successfully.")
