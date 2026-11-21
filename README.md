# GlassUI 2.0 — Complete Product

A modular, mobile-first Luau interface framework with a Glass Studio showcase. Built for Roblox experiences and development tools.

## Package

- `GlassUI.lua` — complete library (base framework plus GlassUI 2.0 extensions).
- `GlassStudio_Showcase.lua` — interactive showcase of the included components and appearance presets.
- `README.md` — installation, API and usage guide.
- `CHANGELOG.md` — version notes.
- `LICENSE.txt` — MIT license.

## Install in Roblox Studio

1. Create a `ModuleScript` named `GlassUI` inside `ReplicatedStorage`.
2. Paste the contents of `GlassUI.lua` into that ModuleScript.
3. Create a `LocalScript` in `StarterPlayerScripts`.
4. Copy `GlassStudio_Showcase.lua` into the LocalScript.
5. Play-test in portrait and landscape orientations.

The framework is client-side. Use a LocalScript and a ModuleScript in an experience you own or are authorized to develop.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlassUI = require(ReplicatedStorage:WaitForChild("GlassUI"))

local Window = GlassUI:CreateWindow({
    Title = "MY PANEL",
    Subtitle = "POWERED BY GLASSUI",
    Theme = "Graphite", -- Graphite, Midnight, Light, or a custom color table
})

local Main = Window:CreateTab("Main", "M")
local General = Main:CreateSection("GENERAL")

General:AddButton({
    Name = "Run action",
    ButtonText = "RUN",
    Callback = function()
        Window:Notify({Title = "Done", Content = "Action completed."})
    end,
})

local enabled = General:AddToggle({
    Name = "Enable feature",
    Default = false,
    Callback = function(value) print("Enabled:", value) end,
})

local amount = General:AddSlider({
    Name = "Intensity",
    Min = 0, Max = 100, Default = 50, Step = 1,
    Callback = function(value) print(value) end,
})

General:AddRangeSlider({
    Name = "Range",
    Min = 0, Max = 100, DefaultMin = 20, DefaultMax = 80,
    Callback = function(minimum, maximum) print(minimum, maximum) end,
})

General:AddSearch({Placeholder = "Search...", Callback = function(query) print(query) end})
General:AddKeybind({Name = "Toggle panel", Default = "RightShift", Callback = function() Window:Toggle() end})
General:AddColorPicker({Name = "Accent", Callback = function(color) Window:SetAccent(color) end})
General:AddProgressBar({Name = "Progress", Default = 45})
General:AddBadge({Text = "READY"})
General:AddStatCard({Name = "STATUS", Value = "ONLINE"})
General:AddAccordion({Title = "Details", Content = "Expandable information."})
General:AddCodeBlock({Title = "Example", Code = "print('Hello GlassUI')"})
local console = General:AddConsole({Default = "Console ready."})
console:Write("New log entry")

Window:SetMaterial("FullGlass") -- Graphite, Liquid, FullGlass, Solid
Window:SetTheme("Midnight") -- Graphite, Midnight, Light, or custom palette
Window:SetAccent(Color3.fromRGB(120, 170, 230))
```

## Public API

### Window

| Method | Description |
|---|---|
| `CreateTab(name, iconText)` | Creates a page and navigation item |
| `SelectTab(name)` | Selects a page |
| `GetTabNames()` | Returns tab names |
| `SetTitle(title, subtitle)` | Changes header text |
| `Notify({Title, Content, Duration})` | Shows a toast |
| `SetTheme(themeNameOrTable)` | Changes palette colors |
| `SetAccent(Color3)` | Changes accent color |
| `SetMaterial(name, strength?)` | Applies Graphite, Liquid, FullGlass, or Solid treatment |
| `Minimize()` / `Restore()` / `Toggle()` | Window visibility |
| `Maximize(boolean?)` | Expands or restores adaptive size |
| `Destroy()` | Disconnects window-level connections and destroys UI |

### Existing components

`AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddInput`, `AddLabel`, `AddParagraph`, `AddDivider`.

### GlassUI 2.0 components

| Method | Key options / methods |
|---|---|
| `AddBadge` | `Text`, `Color`, `TextColor`, `Width`; `SetText`, `SetColor` |
| `AddProgressBar` | `Name`, `Default`; `SetValue`, `GetValue` |
| `AddSearch` | `Placeholder`, `Default`, `Callback`; `SetValue`, `GetValue` |
| `AddKeybind` | `Name`, `Default`, `Callback`; `SetValue`, `GetValue` |
| `AddRangeSlider` | `Min`, `Max`, `DefaultMin`, `DefaultMax`, `Step`, `Callback`; `SetValue`, `GetValue` |
| `AddColorPicker` | `Name`, `Default`, `Palette`, `Callback`; `SetColor`, `GetColor` |
| `AddAccordion` | `Title`, `Content`; `SetOpen` |
| `AddCodeBlock` | `Title`, `Code`; `SetCode`, `GetCode` |
| `AddConsole` | `Default`, `Height`, `MaxLines`; `Write`, `Clear`, `GetText` |
| `AddStatCard` | `Name`, `Value`; `SetValue`, `GetValue` |

All returned controls expose `Frame` and `Destroy()` where applicable. The existing controls retain their original `SetValue`, `GetValue`, and related methods.

## Materials

- `Graphite` — default dark graphite material.
- `Liquid` — slightly more transparent surface treatment.
- `FullGlass` — maximum transparency treatment supported by Roblox GUI primitives.
- `Solid` — higher-opacity surfaces for readability.

**Rendering note:** Roblox does not expose Apple's native per-element backdrop blur material. GlassUI uses layered transparency, gradients, strokes, and animation to create a Liquid Glass-inspired look. `BlurEffect` affects the 3D camera view globally, so the library does not enable it automatically.

## Important engineering notes

- The library does not require an external icon atlas, custom asset registration, or executor-only functions.
- The original tab icon argument accepts text/symbols. Use your own approved Roblox image assets for branded icon artwork.
- `SetMaterial` is a visual treatment, not true localized backdrop blur.
- Search, keybind, and range-slider controls create input connections; destroy their returned controls or destroy the window when finished.
- Configuration persistence is not bundled. Roblox experiences should save settings through server-validated DataStore logic appropriate to their own game.
- The library is a UI framework. It does not automate account creation, collect authentication tokens/cookies, bypass anti-cheat systems, or provide game-cheating behavior.

## Testing checklist

- [ ] Run from a LocalScript in Roblox Studio.
- [ ] Test portrait phone layout.
- [ ] Test landscape phone/tablet layout.
- [ ] Test mouse and touch interaction.
- [ ] Test keyboard shortcuts and text entry.
- [ ] Test window minimize, restore, maximize, and destroy.
- [ ] Test custom themes and all material presets.
- [ ] Test with long tab names and long text content.
- [ ] Check the Output window for callback errors.

This package is a complete source release, but it has not been executed inside Roblox Studio in this environment. Run the checklist before publishing it to production.
