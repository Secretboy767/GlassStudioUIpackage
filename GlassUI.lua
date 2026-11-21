--[[
    GLASSUI 1.0.0
    Mobile-first Luau UI library inspired by Glass Studio 5.0.

    Design goals:
      * Graphite glass appearance with subtle gradients and outlines.
      * Responsive portrait bottom navigation / landscape side navigation.
      * Touch-friendly controls, touch dragging, scrolling and safe-area support.
      * Reusable Window -> Tab -> Section -> Component API.
      * No external icon atlas or executor-only APIs required to draw the UI.

    Supported components:
      Button, Toggle, Slider, Dropdown, Input, Label, Paragraph, Divider.

    Optional executor integration:
      gethui() is used only when available; otherwise PlayerGui is used.

    Example:
      local GlassUI = loadstring(game:HttpGet("RAW_GITHUB_URL"))()
      local Window = GlassUI:CreateWindow({ Title = "My Panel" })
      local Main = Window:CreateTab("Main", "M")
      local Section = Main:CreateSection("General")
      Section:AddButton({ Name = "Test", Callback = function() print("Clicked") end })
]]

local GlassUI = {}
GlassUI.__index = GlassUI

GlassUI.Version = "1.0.0"

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--========================================================
-- THEMES
--========================================================

GlassUI.Themes = {
    Graphite = {
        Shell = Color3.fromRGB(25, 27, 29),
        Header = Color3.fromRGB(31, 33, 35),
        Content = Color3.fromRGB(28, 30, 32),
        Sidebar = Color3.fromRGB(31, 33, 35),
        Card = Color3.fromRGB(47, 49, 52),
        CardHover = Color3.fromRGB(57, 59, 62),
        Field = Color3.fromRGB(34, 36, 38),
        Text = Color3.fromRGB(241, 242, 244),
        Secondary = Color3.fromRGB(160, 164, 169),
        Muted = Color3.fromRGB(112, 117, 123),
        Accent = Color3.fromRGB(185, 200, 220),
        AccentSurface = Color3.fromRGB(62, 73, 88),
        Green = Color3.fromRGB(137, 202, 165),
        Red = Color3.fromRGB(211, 130, 135),
        Border = Color3.fromRGB(115, 120, 126),
    },

    Midnight = {
        Shell = Color3.fromRGB(17, 20, 29),
        Header = Color3.fromRGB(23, 27, 39),
        Content = Color3.fromRGB(20, 23, 34),
        Sidebar = Color3.fromRGB(24, 28, 40),
        Card = Color3.fromRGB(39, 45, 62),
        CardHover = Color3.fromRGB(50, 58, 78),
        Field = Color3.fromRGB(27, 32, 46),
        Text = Color3.fromRGB(238, 242, 255),
        Secondary = Color3.fromRGB(157, 169, 195),
        Muted = Color3.fromRGB(105, 118, 146),
        Accent = Color3.fromRGB(157, 182, 255),
        AccentSurface = Color3.fromRGB(61, 79, 125),
        Green = Color3.fromRGB(135, 211, 177),
        Red = Color3.fromRGB(231, 135, 151),
        Border = Color3.fromRGB(121, 139, 178),
    },

    Light = {
        Shell = Color3.fromRGB(224, 228, 234),
        Header = Color3.fromRGB(238, 240, 244),
        Content = Color3.fromRGB(231, 234, 239),
        Sidebar = Color3.fromRGB(237, 239, 243),
        Card = Color3.fromRGB(250, 251, 253),
        CardHover = Color3.fromRGB(232, 236, 243),
        Field = Color3.fromRGB(242, 244, 247),
        Text = Color3.fromRGB(35, 39, 47),
        Secondary = Color3.fromRGB(93, 101, 114),
        Muted = Color3.fromRGB(137, 144, 155),
        Accent = Color3.fromRGB(81, 103, 135),
        AccentSurface = Color3.fromRGB(93, 116, 150),
        Green = Color3.fromRGB(54, 139, 99),
        Red = Color3.fromRGB(183, 75, 85),
        Border = Color3.fromRGB(113, 122, 137),
    },
}

local DEFAULTS = {
    Title = "GLASS STUDIO",
    Subtitle = "MOBILE UI LIBRARY",
    Theme = "Graphite",
    HeaderHeight = 42,
    DisplayOrder = 100,
    Parent = nil,
    StartMinimized = false,
    DefaultTab = nil,
    Size = nil,
    MinSize = Vector2.new(280, 235),
    MaxPortrait = Vector2.new(440, 620),
    MaxLandscape = Vector2.new(560, 420),
    PortraitWidth = 0.90,
    PortraitHeight = 0.76,
    LandscapeWidth = 0.58,
    LandscapeHeight = 0.72,
}

--========================================================
-- GENERAL HELPERS
--========================================================

local function copyTable(source)
    local output = {}
    for key, value in pairs(source or {}) do
        output[key] = value
    end
    return output
end

local function mergeTable(base, override)
    local output = copyTable(base)
    for key, value in pairs(override or {}) do
        output[key] = value
    end
    return output
end

local function create(className, properties, parent)
    local object = Instance.new(className)

    for key, value in pairs(properties or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function addCorner(object, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
    }, object)
end

local function addStroke(object, theme, transparency)
    return create("UIStroke", {
        Color = theme.Border,
        Thickness = 1,
        Transparency = transparency or 0.84,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, object)
end

local function addGradient(object, topColor, bottomColor, transparency)
    return create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, topColor),
            ColorSequenceKeypoint.new(1, bottomColor),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, transparency or 0.50),
            NumberSequenceKeypoint.new(1, math.min((transparency or 0.50) + 0.25, 1)),
        }),
    }, object)
end

local function tween(object, properties, duration, style)
    if not object or not object.Parent then
        return nil
    end

    local info = TweenInfo.new(
        duration or 0.20,
        style or Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    local animation = TweenService:Create(object, info, properties)
    animation:Play()
    return animation
end

local function getViewport()
    local camera = Workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(900, 600)
end

local function makeLabel(parent, text, size, color, bold)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextColor3 = color,
        TextSize = size or 11,
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        BorderSizePixel = 0,
    }, parent)
end

local function safeCallback(callback, ...)
    if type(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[GlassUI] Callback error: " .. tostring(err))
    end
end

local function resolveParent(customParent)
    if customParent and typeof(customParent) == "Instance" then
        return customParent
    end

    -- Optional executor parent. The library still works without this function.
    local getHiddenUI
    pcall(function()
        if type(gethui) == "function" then
            getHiddenUI = gethui
        end
    end)

    if getHiddenUI then
        local ok, hiddenParent = pcall(getHiddenUI)
        if ok and hiddenParent then
            return hiddenParent
        end
    end

    assert(LocalPlayer, "GlassUI must be created from a client context")
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function addConnection(bucket, connection)
    table.insert(bucket, connection)
    return connection
end

local function disconnectAll(bucket)
    for _, connection in ipairs(bucket) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(bucket)
end

local function roundToStep(value, step, minimum)
    step = tonumber(step) or 1
    if step <= 0 then
        step = 1
    end
    minimum = tonumber(minimum) or 0
    return minimum + math.floor(((value - minimum) / step) + 0.5) * step
end

local function numberText(value)
    if math.abs(value - math.floor(value)) < 0.000001 then
        return tostring(math.floor(value))
    end
    return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end

--========================================================
-- WINDOW CREATION
--========================================================

function GlassUI:CreateWindow(userOptions)
    local options = mergeTable(DEFAULTS, userOptions)
    local theme

    if type(options.Theme) == "table" then
        theme = mergeTable(GlassUI.Themes.Graphite, options.Theme)
    else
        theme = copyTable(GlassUI.Themes[options.Theme] or GlassUI.Themes.Graphite)
    end

    local parent = resolveParent(options.Parent)
    local connections = {}
    local window = {
        _theme = theme,
        _options = options,
        _connections = connections,
        _tabs = {},
        _navButtons = {},
        _currentTab = nil,
        _transitionId = 0,
        _destroyed = false,
        _minimized = false,
        _maximized = false,
        _closing = false,
    }

    local initialViewport = getViewport()
    local portrait = initialViewport.Y > initialViewport.X

    local function calculateSize(maximized)
        local viewport = getViewport()
        local isPortrait = viewport.Y > viewport.X

        if options.Size and not maximized then
            local requested = options.Size
            if typeof(requested) == "Vector2" then
                return Vector2.new(
                    math.min(requested.X, viewport.X - 18),
                    math.min(requested.Y, viewport.Y - 18)
                )
            end
        end

        local widthRatio = isPortrait and options.PortraitWidth or options.LandscapeWidth
        local heightRatio = isPortrait and options.PortraitHeight or options.LandscapeHeight
        local maximum

        if isPortrait then
            maximum = maximized and Vector2.new(460, 700) or options.MaxPortrait
        else
            maximum = maximized and Vector2.new(760, 560) or options.MaxLandscape
        end

        local width = math.min(viewport.X * widthRatio, maximum.X, viewport.X - 18)
        local height = math.min(viewport.Y * heightRatio, maximum.Y, viewport.Y - 18)

        local minWidth = math.min(options.MinSize.X, viewport.X - 18)
        local minHeight = math.min(options.MinSize.Y, viewport.Y - 18)

        width = math.max(width, minWidth)
        height = math.max(height, minHeight)

        return Vector2.new(math.floor(width), math.floor(height))
    end

    local initialSize = calculateSize(false)

    --====================================================
    -- SCREEN GUI / WINDOW SHELL
    --====================================================

    local gui = create("ScreenGui", {
        Name = "GlassUI_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        DisplayOrder = options.DisplayOrder,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, parent)

    -- Respect Roblox's interactive safe area when supported by the client.
    pcall(function()
        gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    end)

    window._gui = gui

    local shadow = create("Frame", {
        Name = "WindowShadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(initialSize.X + 12, initialSize.Y + 12),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.66,
        BorderSizePixel = 0,
    }, gui)
    addCorner(shadow, 23)

    local root = create("CanvasGroup", {
        Name = "WindowGroup",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(initialSize.X, initialSize.Y),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        BorderSizePixel = 0,
    }, gui)

    local rootScale = create("UIScale", {
        Scale = 0.94,
    }, root)

    local shell = create("Frame", {
        Name = "Shell",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Shell,
        BackgroundTransparency = 0.12,
        ClipsDescendants = true,
        BorderSizePixel = 0,
    }, root)
    addCorner(shell, 17)
    addStroke(shell, theme, 0.60)
    addGradient(shell, Color3.fromRGB(59, 62, 67), Color3.fromRGB(24, 26, 28), 0.28)

    local reflection = create("Frame", {
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 0, 92),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 1,
    }, shell)
    addCorner(reflection, 16)
    addGradient(reflection, Color3.fromRGB(255, 255, 255), Color3.fromRGB(130, 140, 155), 0.48)

    --====================================================
    -- HEADER
    --====================================================

    local header = create("Frame", {
        Name = "Header",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 0, options.HeaderHeight),
        BackgroundColor3 = theme.Header,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, shell)
    addCorner(header, 15)

    create("Frame", {
        Position = UDim2.fromOffset(0, 13),
        Size = UDim2.new(1, 0, 1, -13),
        BackgroundColor3 = theme.Header,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, header)

    local titleLabel = makeLabel(header, options.Title, 12, theme.Text, true)
    titleLabel.Position = UDim2.fromOffset(13, 3)
    titleLabel.Size = UDim2.new(0.55, -15, 0, 17)
    titleLabel.ZIndex = 4

    local subtitleLabel = makeLabel(header, options.Subtitle, 7, theme.Secondary, true)
    subtitleLabel.Position = UDim2.fromOffset(14, 21)
    subtitleLabel.Size = UDim2.new(0.58, -15, 0, 11)
    subtitleLabel.ZIndex = 4

    local dragGrip = create("TextButton", {
        Name = "DragGrip",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.59, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 26),
        BackgroundColor3 = theme.Card,
        BackgroundTransparency = 0.78,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)
    addCorner(dragGrip, 8)

    for index = 1, 2 do
        local line = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, (index - 1) * 4 - 2),
            Size = UDim2.fromOffset(11, 2),
            BackgroundColor3 = theme.Secondary,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, dragGrip)
        addCorner(line, 2)
    end

    local function makeWindowControl(kind, rightOffset)
        local button = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, rightOffset, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = theme.Card,
            BackgroundTransparency = 0.45,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, header)
        addCorner(button, 7)

        if kind == "minimize" then
            local line = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(9, 1.5),
                BackgroundColor3 = theme.Text,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, button)
            addCorner(line, 2)
        elseif kind == "maximize" then
            local square = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(9, 9),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, button)
            addStroke(square, theme, 0.20)
        elseif kind == "close" then
            for _, angle in ipairs({45, -45}) do
                local line = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(10, 1.5),
                    Rotation = angle,
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 6,
                }, button)
                addCorner(line, 2)
            end
        end

        addConnection(connections, button.MouseEnter:Connect(function()
            tween(button, {BackgroundTransparency = 0.10}, 0.12)
        end))
        addConnection(connections, button.MouseLeave:Connect(function()
            tween(button, {BackgroundTransparency = 0.45}, 0.12)
        end))

        return button
    end

    local minimizeButton = makeWindowControl("minimize", -88)
    local maximizeButton = makeWindowControl("maximize", -58)
    local closeButton = makeWindowControl("close", -28)

    --====================================================
    -- BODY / NAVIGATION / PAGE AREA
    --====================================================

    local body = create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 1, 0, options.HeaderHeight - 1),
        Size = UDim2.new(1, -2, 1, -options.HeaderHeight),
        BackgroundColor3 = theme.Content,
        BackgroundTransparency = 0.13,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, shell)
    addCorner(body, 15)

    create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = theme.Content,
        BackgroundTransparency = 0.13,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, body)

    local navArea = create("Frame", {
        Name = "Navigation",
        BackgroundColor3 = theme.Sidebar,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, body)
    addCorner(navArea, 11)
    addStroke(navArea, theme, 0.94)

    local navScroll = create("ScrollingFrame", {
        Name = "NavigationScroll",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.XY,
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Active = true,
        ZIndex = 5,
    }, navArea)

    local navLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, navScroll)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3),
    }, navScroll)

    local pageArea = create("Frame", {
        Name = "PageArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, body)

    local function updateNavCanvas()
        if navScroll.Parent then
            navScroll.CanvasSize = UDim2.fromOffset(
                navLayout.AbsoluteContentSize.X + 8,
                navLayout.AbsoluteContentSize.Y + 8
            )
        end
    end

    addConnection(connections, navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateNavCanvas))

    --====================================================
    -- PAGE TRANSITIONS
    --====================================================

    local function selectTab(tabName)
        if window._destroyed or window._currentTab == tabName then
            return
        end

        local destination = window._tabs[tabName]
        if not destination then
            return
        end

        window._transitionId += 1
        local transition = window._transitionId
        local previousName = window._currentTab
        local targetGroup = destination.Group

        window._currentTab = tabName
        targetGroup.Visible = true
        targetGroup.Position = UDim2.fromOffset(7, 0)
        targetGroup.GroupTransparency = 1

        tween(targetGroup, {
            Position = UDim2.fromOffset(0, 0),
            GroupTransparency = 0,
        }, 0.22)

        if previousName and window._tabs[previousName] then
            local previousGroup = window._tabs[previousName].Group
            tween(previousGroup, {
                Position = UDim2.fromOffset(-5, 0),
                GroupTransparency = 1,
            }, 0.16)

            task.delay(0.18, function()
                if window._destroyed then
                    return
                end
                if transition == window._transitionId and window._currentTab ~= previousName then
                    previousGroup.Visible = false
                    previousGroup.Position = UDim2.fromOffset(0, 0)
                end
            end)
        end

        for name, button in pairs(window._navButtons) do
            local selected = name == tabName
            tween(button, {
                BackgroundColor3 = selected and theme.CardHover or theme.Sidebar,
            }, 0.15)

            local marker = button:FindFirstChild("Marker")
            if marker then
                marker.Visible = selected
            end

            local iconLabel = button:FindFirstChild("TabIcon")
            if iconLabel then
                iconLabel.TextColor3 = selected and theme.Text or theme.Secondary
            end

            local nameLabel = button:FindFirstChild("TabName")
            if nameLabel then
                nameLabel.TextColor3 = selected and theme.Text or theme.Secondary
            end
        end
    end

    --====================================================
    -- RESPONSIVE LAYOUT
    --====================================================

    local portraitMode = portrait

    local function updateLayout()
        local viewport = getViewport()
        portraitMode = viewport.Y > viewport.X

        if portraitMode then
            navArea.Position = UDim2.new(0, 7, 1, -48)
            navArea.Size = UDim2.new(1, -14, 0, 41)
            pageArea.Position = UDim2.fromOffset(0, 0)
            pageArea.Size = UDim2.new(1, 0, 1, -54)

            navLayout.FillDirection = Enum.FillDirection.Horizontal
            navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            navLayout.Padding = UDim.new(0, 5)
            navScroll.ScrollingDirection = Enum.ScrollingDirection.X
            navScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
            navScroll.CanvasSize = UDim2.fromOffset(navLayout.AbsoluteContentSize.X + 12, 0)

            for _, button in pairs(window._navButtons) do
                button.Size = UDim2.fromOffset(76, 32)
                local marker = button:FindFirstChild("Marker")
                if marker then
                    marker.Position = UDim2.new(0.5, -7, 1, -1)
                    marker.Size = UDim2.fromOffset(14, 2)
                end
                local iconLabel = button:FindFirstChild("TabIcon")
                if iconLabel then
                    iconLabel.Position = UDim2.fromOffset(7, 0)
                    iconLabel.Size = UDim2.fromOffset(18, 32)
                end
                local nameLabel = button:FindFirstChild("TabName")
                if nameLabel then
                    nameLabel.Position = UDim2.fromOffset(26, 0)
                    nameLabel.Size = UDim2.new(1, -29, 1, 0)
                end
            end
        else
            navArea.Position = UDim2.fromOffset(5, 5)
            navArea.Size = UDim2.new(0, 42, 1, -10)
            pageArea.Position = UDim2.fromOffset(53, 0)
            pageArea.Size = UDim2.new(1, -53, 1, 0)

            navLayout.FillDirection = Enum.FillDirection.Vertical
            navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            navLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            navLayout.Padding = UDim.new(0, 7)
            navScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            navScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
            navScroll.CanvasSize = UDim2.fromOffset(0, navLayout.AbsoluteContentSize.Y + 12)

            for _, button in pairs(window._navButtons) do
                button.Size = UDim2.fromOffset(34, 36)
                local marker = button:FindFirstChild("Marker")
                if marker then
                    marker.Position = UDim2.fromOffset(0, 8)
                    marker.Size = UDim2.fromOffset(2, 20)
                end
                local iconLabel = button:FindFirstChild("TabIcon")
                if iconLabel then
                    iconLabel.Position = UDim2.fromScale(0, 0)
                    iconLabel.Size = UDim2.fromScale(1, 1)
                end
                local nameLabel = button:FindFirstChild("TabName")
                if nameLabel then
                    nameLabel.Visible = false
                end
            end
        end

        updateNavCanvas()
    end

    --====================================================
    -- WINDOW METHODS
    --====================================================

    local restorePill, restorePillScale

    function window:SetTitle(title, subtitle)
        options.Title = tostring(title or options.Title)
        titleLabel.Text = options.Title
        if subtitle ~= nil then
            options.Subtitle = tostring(subtitle)
            subtitleLabel.Text = options.Subtitle
        end
    end

    function window:SelectTab(tabName)
        selectTab(tabName)
    end

    function window:GetTabNames()
        local names = {}
        for _, tab in ipairs(self._tabOrder or {}) do
            table.insert(names, tab.Name)
        end
        return names
    end

    function window:Minimize()
        if self._destroyed or self._minimized then
            return
        end
        self._minimized = true
        restorePill.Visible = true
        restorePillScale.Scale = 0.82
        tween(restorePillScale, {Scale = 1}, 0.20)
        tween(root, {GroupTransparency = 1}, 0.16)
        tween(rootScale, {Scale = 0.92}, 0.18)
        tween(shadow, {BackgroundTransparency = 1}, 0.16)
        task.delay(0.19, function()
            if self._minimized and not self._destroyed then
                root.Visible = false
                shadow.Visible = false
            end
        end)
    end

    function window:Restore()
        if self._destroyed or not self._minimized then
            return
        end
        self._minimized = false
        root.Visible = true
        shadow.Visible = true
        restorePill.Visible = false
        local size = calculateSize(self._maximized)
        root.Size = UDim2.fromOffset(size.X, size.Y)
        shadow.Size = UDim2.fromOffset(size.X + 12, size.Y + 12)
        root.GroupTransparency = 1
        rootScale.Scale = 0.94
        tween(root, {GroupTransparency = 0}, 0.20)
        tween(rootScale, {Scale = 1}, 0.24)
        tween(shadow, {BackgroundTransparency = 0.66}, 0.20)
        updateLayout()
    end

    function window:Toggle()
        if self._minimized then
            self:Restore()
        else
            self:Minimize()
        end
    end

    function window:Maximize(value)
        if self._destroyed then
            return
        end
        if value == nil then
            self._maximized = not self._maximized
        else
            self._maximized = value == true
        end
        if self._minimized then
            self:Restore()
        end
        local size = calculateSize(self._maximized)
        tween(root, {
            Size = UDim2.fromOffset(size.X, size.Y),
            Position = UDim2.fromScale(0.5, 0.5),
        }, 0.24)
        tween(shadow, {
            Size = UDim2.fromOffset(size.X + 12, size.Y + 12),
            Position = UDim2.fromScale(0.5, 0.5),
        }, 0.24)
        updateLayout()
    end

    function window:Notify(notice)
        notice = notice or {}
        if self._destroyed then
            return
        end

        local title = tostring(notice.Title or "GlassUI")
        local content = tostring(notice.Content or notice.Description or "")
        local duration = math.clamp(tonumber(notice.Duration) or 3, 1, 10)

        local toast = create("CanvasGroup", {
            Name = "Notification",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 12),
            Size = UDim2.fromOffset(230, 66),
            BackgroundColor3 = theme.Card,
            BackgroundTransparency = 0.08,
            GroupTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 30,
        }, gui)
        addCorner(toast, 11)
        addStroke(toast, theme, 0.80)
        addGradient(toast, Color3.fromRGB(66, 69, 75), theme.Card, 0.60)

        local toastTitle = makeLabel(toast, title, 10, theme.Text, true)
        toastTitle.Position = UDim2.fromOffset(11, 8)
        toastTitle.Size = UDim2.new(1, -22, 0, 17)
        toastTitle.ZIndex = 31

        local toastText = makeLabel(toast, content, 8, theme.Secondary, false)
        toastText.Position = UDim2.fromOffset(11, 27)
        toastText.Size = UDim2.new(1, -22, 0, 30)
        toastText.TextWrapped = true
        toastText.TextYAlignment = Enum.TextYAlignment.Top
        toastText.ZIndex = 31

        tween(toast, {
            GroupTransparency = 0,
            Position = UDim2.new(1, -12, 0, 18),
        }, 0.20)

        task.delay(duration, function()
            if toast and toast.Parent then
                tween(toast, {
                    GroupTransparency = 1,
                    Position = UDim2.new(1, 4, 0, 12),
                }, 0.18)
                task.delay(0.20, function()
                    if toast then
                        toast:Destroy()
                    end
                end)
            end
        end)
    end

    function window:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        self._closing = true

        tween(root, {GroupTransparency = 1}, 0.18)
        tween(rootScale, {Scale = 0.94}, 0.18)
        tween(shadow, {BackgroundTransparency = 1}, 0.16)

        task.delay(0.20, function()
            disconnectAll(self._connections)
            if gui then
                gui:Destroy()
            end
        end)
    end

    --====================================================
    -- RESTORE PILL
    --====================================================

    restorePill = create("TextButton", {
        Name = "GlassUI_Restore",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.14, 0),
        Size = UDim2.fromOffset(52, 32),
        BackgroundColor3 = theme.Header,
        BackgroundTransparency = 0.08,
        Text = "GS",
        TextColor3 = theme.Text,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Visible = false,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 40,
    }, gui)
    addCorner(restorePill, 12)
    addStroke(restorePill, theme, 0.55)

    restorePillScale = create("UIScale", {Scale = 0.82}, restorePill)
    addConnection(connections, restorePill.Activated:Connect(function()
        window:Restore()
    end))

    --====================================================
    -- WINDOW INTERACTIONS
    --====================================================

    local dragObject = nil
    local dragInput = nil
    local dragStart = nil
    local dragStartPosition = nil

    addConnection(connections, dragGrip.InputBegan:Connect(function(input)
        if window._minimized or window._maximized then
            return
        end

        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragObject = root
            dragStart = input.Position
            dragStartPosition = root.Position
            if input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end
    end))

    addConnection(connections, UserInputService.InputChanged:Connect(function(input)
        if not dragObject or not dragStart then
            return
        end

        local mouseMoved = input.UserInputType == Enum.UserInputType.MouseMovement
        local touchMoved = input.UserInputType == Enum.UserInputType.Touch and input == dragInput
        if not mouseMoved and not touchMoved then
            return
        end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(dragStart.X, dragStart.Y)
        local viewport = getViewport()
        local size = dragObject.AbsoluteSize

        local x = viewport.X / 2 + dragStartPosition.X.Offset + delta.X
        local y = viewport.Y / 2 + dragStartPosition.Y.Offset + delta.Y

        x = math.clamp(x, size.X / 2 + 8, viewport.X - size.X / 2 - 8)
        y = math.clamp(y, size.Y / 2 + 8, viewport.Y - size.Y / 2 - 8)

        dragObject.Position = UDim2.new(0.5, x - viewport.X / 2, 0.5, y - viewport.Y / 2)
        shadow.Position = root.Position
    end))

    addConnection(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput) then
            dragObject = nil
            dragInput = nil
            dragStart = nil
            dragStartPosition = nil
        end
    end))

    addConnection(connections, minimizeButton.Activated:Connect(function()
        if window._minimized then
            window:Restore()
        else
            window:Minimize()
        end
    end))

    addConnection(connections, maximizeButton.Activated:Connect(function()
        window:Maximize()
    end))

    addConnection(connections, closeButton.Activated:Connect(function()
        window:Destroy()
    end))

    local cameraConnection
    local function resizeWindow()
        if window._destroyed or window._minimized then
            return
        end
        local size = calculateSize(window._maximized)
        root.Size = UDim2.fromOffset(size.X, size.Y)
        shadow.Size = UDim2.fromOffset(size.X + 12, size.Y + 12)
        updateLayout()
    end

    local function bindCamera()
        if cameraConnection then
            cameraConnection:Disconnect()
        end
        local camera = Workspace.CurrentCamera
        if camera then
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeWindow)
            addConnection(connections, cameraConnection)
        end
    end

    bindCamera()
    addConnection(connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        bindCamera()
        resizeWindow()
    end))

    --====================================================
    -- TAB / SECTION / COMPONENT API
    --====================================================

    window._tabOrder = {}

    function window:CreateTab(tabName, iconText)
        assert(type(tabName) == "string" and tabName ~= "", "CreateTab requires a tab name")
        if self._destroyed then
            error("Cannot create a tab on a destroyed GlassUI window")
        end
        if self._tabs[tabName] then
            return self._tabs[tabName]
        end

        local tabIndex = #self._tabOrder + 1
        local group = create("CanvasGroup", {
            Name = "TabGroup_" .. tostring(tabIndex),
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 3,
        }, pageArea)

        local scroll = create("ScrollingFrame", {
            Name = "TabContent_" .. tostring(tabIndex),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.Secondary,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Active = true,
            ZIndex = 4,
        }, group)

        create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        }, scroll)

        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, scroll)

        local pageHeading = create("Frame", {
            Size = UDim2.new(1, 0, 0, 31),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 0,
        }, scroll)

        local pageTitle = makeLabel(pageHeading, tabName, 14, theme.Text, true)
        pageTitle.Size = UDim2.new(1, 0, 0, 18)
        pageTitle.Position = UDim2.fromOffset(0, 0)

        local pageSubtitle = makeLabel(pageHeading, "Customize your controls", 8, theme.Secondary, false)
        pageSubtitle.Size = UDim2.new(1, 0, 0, 12)
        pageSubtitle.Position = UDim2.fromOffset(0, 18)

        local navButton = create("TextButton", {
            Name = "Tab_" .. tostring(tabIndex),
            Size = UDim2.fromOffset(34, 36),
            BackgroundColor3 = theme.Sidebar,
            BackgroundTransparency = 0.08,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = tabIndex,
            ZIndex = 6,
        }, navScroll)
        addCorner(navButton, 9)

        local marker = create("Frame", {
            Name = "Marker",
            Position = UDim2.fromOffset(0, 8),
            Size = UDim2.fromOffset(2, 20),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 8,
        }, navButton)
        addCorner(marker, 2)

        local iconLabel = makeLabel(navButton, tostring(iconText or string.sub(tabName, 1, 1)):sub(1, 2), 11, theme.Secondary, true)
        iconLabel.Name = "TabIcon"
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.Position = UDim2.fromScale(0, 0)
        iconLabel.Size = UDim2.fromScale(1, 1)
        iconLabel.ZIndex = 7

        local nameLabel = makeLabel(navButton, tabName, 8, theme.Secondary, true)
        nameLabel.Name = "TabName"
        nameLabel.Visible = false
        nameLabel.Position = UDim2.fromOffset(26, 0)
        nameLabel.Size = UDim2.new(1, -29, 1, 0)
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex = 7

        local tab = {
            Name = tabName,
            Icon = iconText,
            Group = group,
            Page = scroll,
            _window = self,
            _sectionCount = 0,
        }

        self._tabs[tabName] = tab
        table.insert(self._tabOrder, tab)
        self._navButtons[tabName] = navButton

        addConnection(self._connections, navButton.Activated:Connect(function()
            selectTab(tabName)
        end))
        addConnection(self._connections, navButton.MouseEnter:Connect(function()
            if self._currentTab ~= tabName then
                tween(navButton, {BackgroundColor3 = theme.Card}, 0.12)
            end
        end))
        addConnection(self._connections, navButton.MouseLeave:Connect(function()
            if self._currentTab ~= tabName then
                tween(navButton, {BackgroundColor3 = theme.Sidebar}, 0.12)
            end
        end))

        updateLayout()
        if not self._currentTab or options.DefaultTab == tabName then
            selectTab(tabName)
        end

        function tab:CreateSection(sectionName)
            self._sectionCount += 1

            local sectionFrame = create("Frame", {
                Name = "Section_" .. tostring(self._sectionCount),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Card,
                BackgroundTransparency = 0.13,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                LayoutOrder = self._sectionCount,
                ZIndex = 5,
            }, self.Page)
            addCorner(sectionFrame, 10)
            addStroke(sectionFrame, theme, 0.91)
            addGradient(sectionFrame, Color3.fromRGB(59, 62, 67), Color3.fromRGB(39, 41, 44), 0.66)

            create("UIPadding", {
                PaddingTop = UDim.new(0, 9),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }, sectionFrame)

            create("UIListLayout", {
                Padding = UDim.new(0, 7),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, sectionFrame)

            local sectionTitle = makeLabel(sectionFrame, tostring(sectionName or "Section"), 9, theme.Secondary, true)
            sectionTitle.Size = UDim2.new(1, 0, 0, 16)
            sectionTitle.LayoutOrder = 0

            local componentHolder = create("Frame", {
                Name = "Components",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = 1,
                ZIndex = 6,
            }, sectionFrame)

            create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, componentHolder)

            local section = {
                Name = tostring(sectionName or "Section"),
                Frame = sectionFrame,
                _holder = componentHolder,
                _order = 0,
            }

            local function nextOrder()
                section._order += 1
                return section._order
            end

            local function addRow(name, height)
                return create("Frame", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    ZIndex = 7,
                }, componentHolder)
            end

            -- BUTTON
            function section:AddButton(componentOptions)
                componentOptions = componentOptions or {}
                local row = addRow("ButtonRow", componentOptions.Height or 43)
                local title = makeLabel(row, componentOptions.Name or componentOptions.Text or "Button", 10, theme.Text, true)
                title.Position = UDim2.fromOffset(2, 1)
                title.Size = UDim2.new(1, -112, 1, -2)

                if componentOptions.Description then
                    title.Position = UDim2.fromOffset(2, 0)
                    title.Size = UDim2.new(1, -112, 0, 18)
                    local description = makeLabel(row, componentOptions.Description, 8, theme.Secondary, false)
                    description.Position = UDim2.fromOffset(2, 19)
                    description.Size = UDim2.new(1, -112, 0, 17)
                end

                local button = create("TextButton", {
                    Name = "Action",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(94, 34),
                    BackgroundColor3 = theme.AccentSurface,
                    BackgroundTransparency = 0.14,
                    Text = componentOptions.ButtonText or "Run",
                    TextColor3 = theme.Text,
                    TextSize = 9,
                    Font = Enum.Font.GothamSemibold,
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)
                addCorner(button, 7)

                button.Activated:Connect(function()
                    tween(button, {BackgroundTransparency = 0.04}, 0.08)
                    task.delay(0.10, function()
                        if button.Parent then
                            tween(button, {BackgroundTransparency = 0.14}, 0.12)
                        end
                    end)
                    safeCallback(componentOptions.Callback)
                end)

                return {
                    Frame = row,
                    Button = button,
                    SetText = function(_, text)
                        button.Text = tostring(text)
                    end,
                }
            end

            -- TOGGLE
            function section:AddToggle(componentOptions)
                componentOptions = componentOptions or {}
                local row = addRow("ToggleRow", componentOptions.Height or 44)
                local value = componentOptions.Default == true
                local title = makeLabel(row, componentOptions.Name or "Toggle", 10, theme.Text, true)
                title.Position = UDim2.fromOffset(2, 0)
                title.Size = UDim2.new(1, -66, 1, 0)

                local switch = create("TextButton", {
                    Name = "Switch",
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -1, 0.5, 0),
                    Size = UDim2.fromOffset(43, 24),
                    BackgroundColor3 = value and theme.AccentSurface or theme.Field,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)
                addCorner(switch, 12)

                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(value and 1 or 0, value and -20 or 3, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundColor3 = value and theme.Text or theme.Secondary,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, switch)
                addCorner(knob, 9)

                local control = {}
                function control:SetValue(newValue, fireCallback)
                    value = newValue == true
                    tween(switch, {BackgroundColor3 = value and theme.AccentSurface or theme.Field}, 0.14)
                    tween(knob, {
                        Position = UDim2.new(value and 1 or 0, value and -20 or 3, 0.5, 0),
                        BackgroundColor3 = value and theme.Text or theme.Secondary,
                    }, 0.14)
                    if fireCallback ~= false then
                        safeCallback(componentOptions.Callback, value)
                    end
                end
                function control:GetValue()
                    return value
                end

                switch.Activated:Connect(function()
                    control:SetValue(not value, true)
                end)

                if componentOptions.Callback and componentOptions.FireOnInit then
                    safeCallback(componentOptions.Callback, value)
                end

                control.Frame = row
                control.Button = switch
                return control
            end

            -- SLIDER
            function section:AddSlider(componentOptions)
                componentOptions = componentOptions or {}
                local minimum = tonumber(componentOptions.Min) or 0
                local maximum = tonumber(componentOptions.Max) or 100
                if maximum < minimum then
                    minimum, maximum = maximum, minimum
                end
                local step = tonumber(componentOptions.Step) or 1
                local value = math.clamp(tonumber(componentOptions.Default) or minimum, minimum, maximum)
                value = math.clamp(roundToStep(value, step, minimum), minimum, maximum)

                local row = addRow("SliderRow", componentOptions.Height or 62)
                local title = makeLabel(row, componentOptions.Name or "Slider", 9, theme.Text, true)
                title.Position = UDim2.fromOffset(2, 0)
                title.Size = UDim2.new(1, -70, 0, 17)

                local valueLabel = makeLabel(row, numberText(value), 9, theme.Secondary, true)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Position = UDim2.new(1, -58, 0, 0)
                valueLabel.Size = UDim2.fromOffset(56, 17)

                local track = create("TextButton", {
                    Name = "Track",
                    Position = UDim2.fromOffset(2, 30),
                    Size = UDim2.new(1, -4, 0, 8),
                    BackgroundColor3 = theme.Field,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)
                addCorner(track, 5)

                local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                local fill = create("Frame", {
                    Size = UDim2.new(alpha, 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, track)
                addCorner(fill, 5)

                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(alpha, 0, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, track)
                addCorner(knob, 8)
                addStroke(knob, theme, 0.68)

                local sliding = false
                local activeTouch = nil
                local sliderConnections = {}

                local function updateFromX(x, fireCallback)
                    local width = math.max(track.AbsoluteSize.X, 1)
                    local left = track.AbsolutePosition.X
                    local percentage = math.clamp((x - left) / width, 0, 1)
                    local raw = minimum + (maximum - minimum) * percentage
                    value = math.clamp(roundToStep(raw, step, minimum), minimum, maximum)
                    local newAlpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                    fill.Size = UDim2.new(newAlpha, 0, 1, 0)
                    knob.Position = UDim2.new(newAlpha, 0, 0.5, 0)
                    valueLabel.Text = numberText(value)
                    if fireCallback then
                        safeCallback(componentOptions.Callback, value)
                    end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        activeTouch = input
                        updateFromX(input.Position.X, true)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        updateFromX(input.Position.X, true)
                    end
                end)

                table.insert(sliderConnections, UserInputService.InputChanged:Connect(function(input)
                    if not sliding then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.MouseMovement
                        or (input.UserInputType == Enum.UserInputType.Touch and input == activeTouch) then
                        updateFromX(input.Position.X, true)
                    end
                end))

                table.insert(sliderConnections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or (input.UserInputType == Enum.UserInputType.Touch and input == activeTouch) then
                        sliding = false
                        activeTouch = nil
                    end
                end))

                for _, connection in ipairs(sliderConnections) do
                    addConnection(connections, connection)
                end

                local control = {}
                function control:SetValue(newValue, fireCallback)
                    local numeric = tonumber(newValue)
                    if not numeric then
                        return
                    end
                    value = math.clamp(roundToStep(numeric, step, minimum), minimum, maximum)
                    local newAlpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                    fill.Size = UDim2.new(newAlpha, 0, 1, 0)
                    knob.Position = UDim2.new(newAlpha, 0, 0.5, 0)
                    valueLabel.Text = numberText(value)
                    if fireCallback ~= false then
                        safeCallback(componentOptions.Callback, value)
                    end
                end
                function control:GetValue()
                    return value
                end
                function control:Destroy()
                    disconnectAll(sliderConnections)
                    row:Destroy()
                end
                control.Frame = row
                return control
            end

            -- DROPDOWN
            function section:AddDropdown(componentOptions)
                componentOptions = componentOptions or {}
                local choices = componentOptions.Options or {}
                local selected = componentOptions.Default
                if selected == nil then
                    selected = choices[1]
                end
                local expanded = false
                local rowHeight = 41
                local row = create("Frame", {
                    Name = "DropdownRow",
                    Size = UDim2.new(1, 0, 0, rowHeight),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    ZIndex = 7,
                }, componentHolder)

                local choiceButton = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundColor3 = theme.Field,
                    BackgroundTransparency = 0.05,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)
                addCorner(choiceButton, 7)

                local label = makeLabel(choiceButton, componentOptions.Name or "Dropdown", 9, theme.Secondary, true)
                label.Position = UDim2.fromOffset(9, 2)
                label.Size = UDim2.new(0.48, -9, 1, -4)

                local current = makeLabel(choiceButton, tostring(selected or "Select"), 9, theme.Text, true)
                current.TextXAlignment = Enum.TextXAlignment.Right
                current.Position = UDim2.new(0.48, 0, 0, 2)
                current.Size = UDim2.new(0.52, -25, 1, -4)
                current.TextTruncate = Enum.TextTruncate.AtEnd

                local arrow = makeLabel(choiceButton, ">", 12, theme.Secondary, true)
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Position = UDim2.new(1, -23, 0, 1)
                arrow.Size = UDim2.fromOffset(18, 36)
                arrow.Rotation = 90

                local list = create("ScrollingFrame", {
                    Name = "Options",
                    Position = UDim2.fromOffset(0, 42),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = theme.Field,
                    BackgroundTransparency = 0.02,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = theme.Secondary,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Visible = false,
                    ZIndex = 10,
                }, row)
                addCorner(list, 7)

                local listLayout = create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, list)

                create("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                }, list)

                local optionButtons = {}
                local function choose(value)
                    selected = value
                    current.Text = tostring(value)
                    expanded = false
                    list.Visible = false
                    list.Size = UDim2.new(1, 0, 0, 0)
                    arrow.Rotation = 90
                    safeCallback(componentOptions.Callback, selected)
                end

                for index, optionValue in ipairs(choices) do
                    local optionButton = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = theme.Card,
                        BackgroundTransparency = 0.35,
                        Text = tostring(optionValue),
                        TextColor3 = theme.Text,
                        TextSize = 9,
                        Font = Enum.Font.Gotham,
                        AutoButtonColor = false,
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        ZIndex = 11,
                    }, list)
                    addCorner(optionButton, 5)
                    optionButton.Activated:Connect(function()
                        choose(optionValue)
                    end)
                    table.insert(optionButtons, optionButton)
                end

                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 8)
                end)
                list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 8)

                choiceButton.Activated:Connect(function()
                    expanded = not expanded
                    list.Visible = expanded
                    if expanded then
                        list.Size = UDim2.new(1, 0, 0, math.min(#choices, 4) * 32 + 8)
                        arrow.Rotation = -90
                    else
                        list.Size = UDim2.new(1, 0, 0, 0)
                        arrow.Rotation = 90
                    end
                end)

                local control = {}
                function control:SetValue(newValue, fireCallback)
                    local found = false
                    for _, choice in ipairs(choices) do
                        if choice == newValue then
                            found = true
                            break
                        end
                    end
                    if not found then
                        return
                    end
                    selected = newValue
                    current.Text = tostring(newValue)
                    if fireCallback ~= false then
                        safeCallback(componentOptions.Callback, selected)
                    end
                end
                function control:GetValue()
                    return selected
                end
                function control:SetOptions(newOptions)
                    choices = newOptions or {}
                    for _, button in ipairs(optionButtons) do
                        button:Destroy()
                    end
                    table.clear(optionButtons)
                    for index, optionValue in ipairs(choices) do
                        local optionButton = create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = theme.Card,
                            BackgroundTransparency = 0.35,
                            Text = tostring(optionValue),
                            TextColor3 = theme.Text,
                            TextSize = 9,
                            Font = Enum.Font.Gotham,
                            AutoButtonColor = false,
                            BorderSizePixel = 0,
                            LayoutOrder = index,
                            ZIndex = 11,
                        }, list)
                        addCorner(optionButton, 5)
                        optionButton.Activated:Connect(function()
                            choose(optionValue)
                        end)
                        table.insert(optionButtons, optionButton)
                    end
                    list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 8)
                    if selected ~= nil then
                        local stillExists = false
                        for _, choice in ipairs(choices) do
                            if choice == selected then stillExists = true end
                        end
                        if not stillExists then
                            selected = choices[1]
                            current.Text = tostring(selected or "Select")
                        end
                    else
                        selected = choices[1]
                        current.Text = tostring(selected or "Select")
                    end
                end
                control.Frame = row
                return control
            end

            -- INPUT
            function section:AddInput(componentOptions)
                componentOptions = componentOptions or {}
                local row = addRow("InputRow", componentOptions.Height or 54)
                local title = makeLabel(row, componentOptions.Name or "Input", 9, theme.Secondary, true)
                title.Position = UDim2.fromOffset(2, 0)
                title.Size = UDim2.new(1, 0, 0, 15)

                local box = create("TextBox", {
                    Name = "Input",
                    Position = UDim2.fromOffset(0, 19),
                    Size = UDim2.new(1, 0, 0, 33),
                    BackgroundColor3 = theme.Field,
                    BackgroundTransparency = 0.04,
                    Text = tostring(componentOptions.Default or ""),
                    PlaceholderText = componentOptions.Placeholder or "Enter a value...",
                    PlaceholderColor3 = theme.Muted,
                    TextColor3 = theme.Text,
                    TextSize = 9,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)
                addCorner(box, 7)
                create("UIPadding", {
                    PaddingLeft = UDim.new(0, 9),
                    PaddingRight = UDim.new(0, 9),
                }, box)

                local function sendValue()
                    local value = box.Text
                    if componentOptions.Numeric then
                        local numberValue = tonumber(value)
                        if value ~= "" and not numberValue then
                            box.TextColor3 = theme.Red
                            return
                        end
                        box.TextColor3 = theme.Text
                        safeCallback(componentOptions.Callback, numberValue)
                    else
                        box.TextColor3 = theme.Text
                        safeCallback(componentOptions.Callback, value)
                    end
                end

                box.FocusLost:Connect(function(enterPressed)
                    sendValue()
                end)

                local control = {}
                function control:SetValue(value, fireCallback)
                    box.Text = tostring(value or "")
                    if fireCallback ~= false then
                        sendValue()
                    end
                end
                function control:GetValue()
                    if componentOptions.Numeric then
                        return tonumber(box.Text)
                    end
                    return box.Text
                end
                control.Frame = row
                control.TextBox = box
                return control
            end

            -- LABEL
            function section:AddLabel(textValue)
                local row = addRow("LabelRow", 22)
                local label = makeLabel(row, textValue or "Label", 9, theme.Text, false)
                label.Position = UDim2.fromOffset(2, 0)
                label.Size = UDim2.new(1, -4, 1, 0)
                return {
                    Frame = row,
                    Label = label,
                    SetText = function(_, text)
                        label.Text = tostring(text)
                    end,
                }
            end

            -- PARAGRAPH
            function section:AddParagraph(componentOptions)
                componentOptions = componentOptions or {}
                local row = create("Frame", {
                    Name = "ParagraphRow",
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = nextOrder(),
                    ZIndex = 7,
                }, componentHolder)

                local paragraphTitle = makeLabel(row, componentOptions.Title or "", 9, theme.Text, true)
                paragraphTitle.Size = UDim2.new(1, 0, 0, componentOptions.Title and 16 or 0)
                paragraphTitle.Position = UDim2.fromOffset(2, 0)
                paragraphTitle.Visible = componentOptions.Title ~= nil

                local paragraphText = makeLabel(row, componentOptions.Content or componentOptions.Text or "", 8, theme.Secondary, false)
                paragraphText.Position = UDim2.fromOffset(2, componentOptions.Title and 18 or 0)
                paragraphText.Size = UDim2.new(1, -4, 0, 0)
                paragraphText.AutomaticSize = Enum.AutomaticSize.Y
                paragraphText.TextWrapped = true
                paragraphText.TextYAlignment = Enum.TextYAlignment.Top

                local control = {}
                function control:SetTitle(value)
                    paragraphTitle.Text = tostring(value)
                    paragraphTitle.Visible = true
                    paragraphTitle.Size = UDim2.new(1, 0, 0, 16)
                    paragraphText.Position = UDim2.fromOffset(2, 18)
                end
                function control:SetText(value)
                    paragraphText.Text = tostring(value)
                end
                control.Frame = row
                return control
            end

            -- DIVIDER
            function section:AddDivider()
                local row = addRow("DividerRow", 9)
                local line = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.new(1, -2, 0, 1),
                    BackgroundColor3 = theme.Border,
                    BackgroundTransparency = 0.65,
                    BorderSizePixel = 0,
                }, row)
                return {Frame = row, Divider = line}
            end

            function section:Destroy()
                if sectionFrame then
                    sectionFrame:Destroy()
                end
            end

            return section
        end

        function tab:AddSection(sectionName)
            return self:CreateSection(sectionName)
        end

        return tab
    end

    function window:AddTab(tabName, iconText)
        return self:CreateTab(tabName, iconText)
    end

    --====================================================
    -- INITIALIZATION
    --====================================================

    updateLayout()

    tween(root, {GroupTransparency = 0}, 0.26)
    tween(rootScale, {Scale = 1}, 0.28)
    tween(shadow, {BackgroundTransparency = 0.66}, 0.24)

    if options.StartMinimized then
        task.defer(function()
            if not window._destroyed then
                window:Minimize()
            end
        end)
    end

    return window
end

return GlassUI
