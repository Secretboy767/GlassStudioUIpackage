# GlassUI 1.0.0

A reusable, mobile-first Luau UI library inspired by the Glass Studio 5.0 design.

## Files

- `GlassUI.lua` — the library. Publish this file as a GitHub repository file or place it in a Roblox `ModuleScript`.
- `GlassUI_Example.lua` — a small working example showing the public API.

## Loading

### Roblox Studio

1. Add `GlassUI.lua` as a `ModuleScript` (for example, `ReplicatedStorage.GlassUI`).
2. Require it from a `LocalScript`:

```lua
local GlassUI = require(game:GetService("ReplicatedStorage"):WaitForChild("GlassUI"))
```

### Remote source in a compatible client

Publish `GlassUI.lua` and replace the URL below with its raw file URL:

```lua
local GlassUI = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
```

The remote-loader line depends on the environment supporting those functions. The library itself does not call `loadstring`, `HttpGet`, clipboard functions, file functions, or custom-asset functions.

## Quick start

```lua
local Window = GlassUI:CreateWindow({
    Title = "MY PANEL",
    Subtitle = "POWERED BY GLASSUI",
    Theme = "Graphite",
})

local Main = Window:CreateTab("Main", "M")
local Section = Main:CreateSection("GENERAL")

Section:AddButton({
    Name = "Run action",
    ButtonText = "Run",
    Callback = function()
        print("Button pressed")
    end,
})

Section:AddToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

Section:AddSlider({
    Name = "Amount",
    Min = 0,
    Max = 100,
    Default = 25,
    Step = 1,
    Callback = function(value)
        print("Amount:", value)
    end,
})

Window:Notify({
    Title = "Ready",
    Content = "The panel has loaded.",
    Duration = 3,
})
```

## Window options

| Option | Default | Description |
|---|---|---|
| `Title` | `GLASS STUDIO` | Header title |
| `Subtitle` | `MOBILE UI LIBRARY` | Smaller header caption |
| `Theme` | `Graphite` | `Graphite`, `Midnight`, `Light`, or a custom color table |
| `HeaderHeight` | `42` | Header height in pixels |
| `DisplayOrder` | `100` | ScreenGui display order |
| `Parent` | automatic | Optional ScreenGui parent |
| `StartMinimized` | `false` | Start with the restore pill visible |
| `DefaultTab` | `nil` | Tab name to select when it is created |
| `Size` | automatic | Optional `Vector2` window size |

Custom themes can override any of these colors: `Shell`, `Header`, `Content`, `Sidebar`, `Card`, `CardHover`, `Field`, `Text`, `Secondary`, `Muted`, `Accent`, `AccentSurface`, `Green`, `Red`, and `Border`.

## Public API

### Window

- `Window:CreateTab(name, iconText)` — creates a page and navigation item.
- `Window:AddTab(name, iconText)` — alias for `CreateTab`.
- `Window:SelectTab(name)` — switches pages.
- `Window:GetTabNames()` — returns the created tab names.
- `Window:SetTitle(title, subtitle)` — changes the header text.
- `Window:Notify({Title, Content, Duration})` — shows a temporary notification.
- `Window:Minimize()` / `Window:Restore()` / `Window:Toggle()` — window visibility controls.
- `Window:Maximize(trueOrFalse)` — maximize or restore the adaptive size.
- `Window:Destroy()` — disconnects library-level input connections and destroys the GUI.

### Tab and section

```lua
local Tab = Window:CreateTab("Visuals", "V")
local Section = Tab:CreateSection("DISPLAY")
-- Tab:AddSection("DISPLAY") is also supported.
```

### Components

| Method | Important options | Callback value |
|---|---|---|
| `Section:AddButton(options)` | `Name`, `Description`, `ButtonText`, `Callback`, `Height` | No arguments |
| `Section:AddToggle(options)` | `Name`, `Default`, `Callback`, `FireOnInit`, `Height` | `boolean` |
| `Section:AddSlider(options)` | `Name`, `Min`, `Max`, `Default`, `Step`, `Callback`, `Height` | `number` |
| `Section:AddDropdown(options)` | `Name`, `Options`, `Default`, `Callback` | Selected option |
| `Section:AddInput(options)` | `Name`, `Placeholder`, `Default`, `Numeric`, `Callback`, `Height` | `string`, or number for numeric inputs |
| `Section:AddLabel(text)` | Text value | — |
| `Section:AddParagraph(options)` | `Title`, `Content` (or `Text`) | — |
| `Section:AddDivider()` | — | — |

### Returned component methods

- Toggle: `SetValue(value, fireCallback)`, `GetValue()`
- Slider: `SetValue(value, fireCallback)`, `GetValue()`, `Destroy()`
- Dropdown: `SetValue(value, fireCallback)`, `GetValue()`, `SetOptions(array)`
- Input: `SetValue(value, fireCallback)`, `GetValue()`
- Button: `SetText(text)`
- Label: `SetText(text)`
- Paragraph: `SetTitle(text)`, `SetText(text)`

Pass `false` as `fireCallback` when setting a control programmatically without running its callback.

## Mobile behavior

- Portrait: horizontal bottom navigation with horizontally scrollable tabs.
- Landscape: compact vertical icon rail.
- Touch and mouse dragging from the small header grip.
- Responsive window sizing when the viewport changes.
- Scrolling page content and touch-friendly component heights.
- Uses the Roblox interactive safe area when the current client exposes `ScreenGui.ScreenInsets`.

## Notes

- The library is client-side UI code. Create it from a `LocalScript` or another client execution context.
- The library provides controls and callbacks; each script author supplies the behavior inside those callbacks.
- The UI library does not create accounts, automate registration, collect session cookies, or transmit user data.
