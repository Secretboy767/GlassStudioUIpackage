# Glass Studio 5.0 — GlassUI Edition

A UI-only recreation of the original compact mobile dashboard, now built on the reusable `GlassUI.lua` library.

## Package files

- `GlassUI.lua` — reusable UI library.
- `GlassStudio.lua` — Glass Studio dashboard built using the library.
- `GlassUI_Example.lua` — small component/API example.
- `GlassUI_README.md` — library API documentation.
- `ASSETS.md` — asset and attribution notes.

## Included UI

- Graphite glass shell, subtle gradients, rounded cards, outlines and shadow.
- Header grip and native window controls.
- Animated open, close, minimize, restore and maximize behavior.
- Touch dragging with bounded movement.
- Responsive portrait bottom navigation and landscape side navigation.
- Animated page transitions and selected-tab states.
- Dashboard, Account Studio, Session Center, Activity and Preferences pages.
- Notification toasts and activity history.
- Reusable buttons, toggles, sliders, dropdowns, inputs, labels, paragraphs and dividers.
- No mandatory external asset download.

## Safety and scope

This package is a UI library and visual demo. The Account Studio page is a generic local form preview. It does not automate account registration, generate account credentials, handle authentication cookies/tokens, or modify a game. The Session Center page is informational only.

## Loading

For a Roblox experience you own, put `GlassUI.lua` in a ModuleScript and require it:

```lua
local GlassUI = require(path.To.GlassUI)
```

Then put `GlassStudio.lua` in a LocalScript and replace its loader line with the `require` call above.

If you distribute the library through a public repository, update the raw URL in `GlassStudio.lua` to the exact repository path. Review and test in Roblox Studio on both portrait and landscape touch layouts before publishing.

## Publishing

No GitHub repository was specified, so these files are packaged locally and have not been pushed to a repository. To publish, provide the target repository as `owner/repository` and the intended branch.
