--[[
    ═══════════════════════════════════════════════════════════
        TEV HUB v1.1 — Murder Mystery 2
        github.com/hztvs01-netizen/TEV-Hub
        Analytics yok. Key yok. Obfuscate yok.
    ═══════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
--  YÜKLEME KONTROLÜ
-- ═══════════════════════════════════════════════════════════
if _G.TEV_Hub_Loaded then
    warn("[TEV] Zaten yüklü. Silmek için: _G.TEV_Hub_Loaded = nil ve ScreenGui'yi sil.")
    return
end
_G.TEV_Hub_Loaded = true

print("[TEV] loader başladı")

-- ═══════════════════════════════════════════════════════════
--  SERVİSLER
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")

local LP = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
--  TEMA
-- ═══════════════════════════════════════════════════════════
local T = {
    BgDark   = Color3.fromRGB(10, 10, 16),
    BgPanel  = Color3.fromRGB(20, 20, 32),
    BgHover  = Color3.fromRGB(30, 30, 48),
    Accent1  = Color3.fromRGB(139, 92, 246),
    Accent2  = Color3.fromRGB(217, 70, 239),
    Accent3  = Color3.fromRGB(99, 102, 241),
    Text     = Color3.fromRGB(245, 245, 250),
    TextSub  = Color3.fromRGB(150, 150, 185),
    Success  = Color3.fromRGB(52, 211, 153),
    Danger   = Color3.fromRGB(248, 113, 113),
    Murder   = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 140, 255),
    Innocent = Color3.fromRGB(80, 220, 120),
}

-- ═══════════════════════════════════════════════════════════
--  CONFIG
-- ═══════════════════════════════════════════════════════════
local Config = {
    Notifications    = true,

    ESP              = false,
    Tracers          = true,
    DistanceDisplay  = true,
    NameDisplay      = true,
    XRay             = false,
    Fullbright       = false,
    RemoveBarriers   = false,

    Aimbot           = false,
    AimbotKey        = Enum.KeyCode.E,
    AimbotFOV        = 200,
    AimbotSmooth     = 0.15,
    AimbotMurder     = false,
    AimbotSheriff    = true,

    CoinGrabber      = false,
    CoinRange        = 500,
    AutoPickupGun    = false,

    WalkSpeed        = 16,
    JumpPower        = 50,
    Gravity          = 196.2,
    Fly              = false,
    FlySpeed         = 50,
    Noclip           = false,
    InfiniteJump     = false,
    CtrlClickTP      = false,

    GodMode          = false,
}

local function notify(title, text, dur)
    if not Config.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "TEV HUB",
            Text = text or "",
            Duration = dur or 3,
        })
    end)
end

-- ═══════════════════════════════════════════════════════════
--  YARDIMCILAR
-- ═══════════════════════════════════════════════════════════
local function New(cls, props)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    return i
end

local function Corner(p, r)
    return New("UICorner", { CornerRadius = r or UDim.new(0, 8), Parent = p })
end

local function Stroke(p, c, t, tr)
    return New("UIStroke", {
        Color = c or T.Accent1,
        Thickness = t or 1.2,
        Transparency = tr or 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = p,
    })
end

local function Gradient(p, c1, c2, rot)
    return New("UIGradient", {
        Color = ColorSequence.new(c1 or T.Accent3, c2 or T.Accent2),
        Rotation = rot or 45,
        Parent = p,
    })
end

local function Tween(o, t, props, style)
    if not o or not o.Parent then return end
    TweenService:Create(o, TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

-- ═══════════════════════════════════════════════════════════
--  ROL TESPİTİ
-- ═══════════════════════════════════════════════════════════
local Roles = {
    Murderer = nil,
    Sheriff = nil,
    Innocents = {},
    All = {},
}

local function getPlayerRole(plr)
    if not plr or not plr.Parent then return "Innocent" end
    local function has(t, n)
        return t and t:FindFirstChild(n) ~= nil
    end
    if has(plr.Character, "Knife") or has(plr.Backpack, "Knife") then
        return "Murderer"
    end
    if has(plr.Character, "Gun") or has(plr.Backpack, "Gun")
    or has(plr.Character, "Revolver") or has(plr.Backpack, "Revolver") then
        return "Sheriff"
    end
    return "Innocent"
end

local function getRoleColor(role)
    if role == "Murderer" then return T.Murder end
    if role == "Sheriff" then return T.Sheriff end
    return T.Innocent
end

task.spawn(function()
    while task.wait(0.5) do
        Roles.Murderer = nil
        Roles.Sheriff = nil
        Roles.Innocents = {}
        Roles.All = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                local role = getPlayerRole(plr)
                table.insert(Roles.All, { player = plr, role = role })
                if role == "Murderer" then
                    Roles.Murderer = plr
                elseif role == "Sheriff" then
                    Roles.Sheriff = plr
                else
                    table.insert(Roles.Innocents, plr)
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
--  UI — ANA PENCERE
-- ═══════════════════════════════════════════════════════════

-- Parent fallback: CoreGui → PlayerGui
local parent
if pcall(function() CoreGui.Name = CoreGui.Name end) then
    parent = CoreGui
else
    parent = LP:WaitForChild("PlayerGui")
end
print("[TEV] parent: " .. tostring(parent))

local old = parent:FindFirstChild("TEV_Hub")
if old then old:Destroy() end

local ScreenGui = New("ScreenGui", {
    Name = "TEV_Hub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = parent,
})

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 700, 0, 450),
    Position = UDim2.new(0.5, -350, 0.5, -225),
    BackgroundColor3 = T.BgDark,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true,
    ZIndex = 2,
    Parent = ScreenGui,
})
Corner(Main, UDim.new(0, 16))
Stroke(Main, T.Accent1, 1.5, 0.35)

local TopGlow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 110),
    BackgroundColor3 = T.Accent1,
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = Main,
})
Gradient(TopGlow, T.Accent1, T.Accent2, 90)

New("TextLabel", {
    Text = "TEV HUB",
    Font = Enum.Font.GothamBlack,
    TextSize = 30,
    TextColor3 = T.Text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 16),
    Size = UDim2.new(0, 300, 0, 34),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = Main,
})

New("TextLabel", {
    Text = "v1.1  ·  Murder Mystery 2",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = T.TextSub,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 24, 0, 48),
    Size = UDim2.new(0, 300, 0, 14),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = Main,
})

local CloseBtn = New("TextButton", {
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    TextColor3 = T.Text,
    BackgroundColor3 = T.BgPanel,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -48, 0, 16),
    Size = UDim2.new(0, 32, 0, 32),
    AutoButtonColor = false,
    ZIndex = 5,
    Parent = Main,
})
Corner(CloseBtn, UDim.new(1, 0))
Stroke(CloseBtn, T.Danger, 1, 0.5)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(Main, 0.25, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }, Enum.EasingStyle.Back)
    task.wait(0.28)
    ScreenGui:Destroy()
    _G.TEV_Hub_Loaded = nil
end)

-- ═══════════════════════════════════════════════════════════
--  SEKME ÇUBUĞU
-- ═══════════════════════════════════════════════════════════
local Tabs = {
    { Name = "Visual",   Icon = "◉" },
    { Name = "Combat",   Icon = "X" },
    { Name = "Farm",     Icon = "$" },
    { Name = "Movement", Icon = ">" },
    { Name = "Troll",    Icon = "!" },
    { Name = "Emotes",   Icon = ":" },
    { Name = "Settings", Icon = "*" },
}

local TabBar = New("Frame", {
    Size = UDim2.new(0, 150, 0, 340),
    Position = UDim2.new(0, 20, 0, 90),
    BackgroundColor3 = T.BgPanel,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = Main,
})
Corner(TabBar, UDim.new(0, 12))
Stroke(TabBar, T.Accent3, 1, 0.6)

New("UIListLayout", {
    Padding = UDim.new(0, 4),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = TabBar,
})

local ContentFrame = New("Frame", {
    Size = UDim2.new(1, -190, 1, -110),
    Position = UDim2.new(0, 180, 0, 90),
    BackgroundColor3 = T.BgPanel,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = Main,
})
Corner(ContentFrame, UDim.new(0, 12))
Stroke(ContentFrame, T.Accent3, 1, 0.6)

local ContentScroll = New("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = T.Accent1,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 5,
    Parent = ContentFrame,
})
New("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ContentScroll,
})
New("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    Parent = ContentScroll,
})

-- ═══════════════════════════════════════════════════════════
--  UI ELEMANLARI
-- ═══════════════════════════════════════════════════════════
local Modules = {}
local tabButtons = {}
local activeTab = nil

local function clearContent()
    for _, c in ipairs(ContentScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

local function makeButton(text, parent)
    local btn = New("TextButton", {
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        BackgroundColor3 = T.BgDark,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 34),
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = parent,
    })
    Corner(btn, UDim.new(0, 8))
    Stroke(btn, T.Accent3, 1, 0.7)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    New("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = btn })
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, { BackgroundColor3 = T.BgHover, BackgroundTransparency = 0.05 })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, { BackgroundColor3 = T.BgDark, BackgroundTransparency = 0.2 })
    end)
    return btn
end

local function makeToggle(name, default, callback, parent)
    local row = New("Frame", {
        Size = UDim2.new(1, -8, 0, 34),
        BackgroundColor3 = T.BgDark,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = parent,
    })
    Corner(row, UDim.new(0, 8))
    Stroke(row, T.Accent3, 1, 0.7)

    New("TextLabel", {
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
        Parent = row,
    })

    local state = default
    local indicator = New("TextButton", {
        Text = state and "ON" or "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = state and T.Success or T.TextSub,
        BackgroundColor3 = state and T.Success or T.BgPanel,
        BackgroundTransparency = state and 0.7 or 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -58, 0.5, -11),
        Size = UDim2.new(0, 46, 0, 22),
        AutoButtonColor = false,
        ZIndex = 7,
        Parent = row,
    })
    Corner(indicator, UDim.new(0, 6))

    indicator.MouseButton1Click:Connect(function()
        state = not state
        indicator.Text = state and "ON" or "OFF"
        indicator.TextColor3 = state and T.Success or T.TextSub
        Tween(indicator, 0.15, {
            BackgroundColor3 = state and T.Success or T.BgPanel,
            BackgroundTransparency = state and 0.7 or 0.3,
        })
        if callback then pcall(callback, state) end
    end)
    return row
end

local function makeSlider(name, min, max, default, callback, parent)
    local row = New("Frame", {
        Size = UDim2.new(1, -8, 0, 56),
        BackgroundColor3 = T.BgDark,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = parent,
    })
    Corner(row, UDim.new(0, 8))
    Stroke(row, T.Accent3, 1, 0.7)

    local valueLabel = New("TextLabel", {
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = T.Accent2,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 6),
        Size = UDim2.new(0, 60, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 7,
        Parent = row,
    })
    New("TextLabel", {
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -90, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
        Parent = row,
    })
    local barBg = New("Frame", {
        BackgroundColor3 = T.BgPanel,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -24, 0, 8),
        ZIndex = 7,
        Parent = row,
    })
    Corner(barBg, UDim.new(1, 0))
    local fill = New("Frame", {
        BackgroundColor3 = T.Accent1,
        BorderSizePixel = 0,
        Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0),
        ZIndex = 8,
        Parent = barBg,
    })
    Corner(fill, UDim.new(1, 0))
    Gradient(fill, T.Accent1, T.Accent2, 0)

    local dragging = false
    local function updateFromMouse(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(val)
        if callback then pcall(callback, val) end
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromMouse(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromMouse(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return row
end

local function makeLabel(text, parent)
    return New("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = T.TextSub,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 6,
        Parent = parent,
    })
end

local function makeSection(text, parent)
    return New("TextLabel", {
        Text = "— " .. text .. " —",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = T.Accent2,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
        Parent = parent,
    })
end

-- ═══════════════════════════════════════════════════════════
--  ESP (Drawing API)
-- ═══════════════════════════════════════════════════════════
local ESP = {
    objects = {},       -- [player] = { box lines, tracer, name text, dist text }
    camera = workspace.CurrentCamera,
}

local function createESPObejcts()
    return {
        top    = Drawing.new("Line"),
        bottom = Drawing.new("Line"),
        left   = Drawing.new("Line"),
        right  = Drawing.new("Line"),
        tracer = Drawing.new("Line"),
        name   = Drawing.new("Text"),
        dist   = Drawing.new("Text"),
    }
end

local function destroyESP(o)
    for _, v in pairs(o) do
        if v and v.Remove then v:Remove() end
    end
end

local function worldToScreen(pos)
    local sp, onScreen = ESP.camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
end

local function updateESP()
    local camera = workspace.CurrentCamera
    ESP.camera = camera
    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    -- oyuncular
    for _, entry in ipairs(Roles.All) do
        local plr = entry.player
        local role = entry.role
        if plr and plr.Character and plr.Character:FindFirstChild("Head") then
            if not ESP.objects[plr] then
                ESP.objects[plr] = createESPObejcts()
            end
            local o = ESP.objects[plr]
            local head = plr.Character.Head
            local headPos = head.Position
            local headScreen, onScreen = worldToScreen(headPos + Vector3.new(0, 0.5, 0))
            local bottomScreen = worldToScreen(headPos - Vector3.new(0, 3, 0))
            local color = getRoleColor(role)
            local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position or Vector3.new()
            local dist = (headPos - myPos).Magnitude

            if Config.ESP and onScreen then
                local h = math.abs(headScreen.Y - bottomScreen.Y)
                local w = h * 0.6
                local top    = Vector2.new(headScreen.X - w/2, headScreen.Y)
                local bottom = Vector2.new(headScreen.X - w/2, bottomScreen.Y)
                local right  = Vector2.new(headScreen.X + w/2, headScreen.Y)
                local left   = Vector2.new(headScreen.X + w/2, bottomScreen.Y)
                local bottomRight = Vector2.new(headScreen.X + w/2, bottomScreen.Y)

                o.top.From, o.top.To = top, Vector2.new(headScreen.X + w/2, headScreen.Y)
                o.bottom.From, o.bottom.To = bottom, bottomRight
                o.left.From, o.left.To = top, bottom
                o.right.From, o.right.To = Vector2.new(headScreen.X + w/2, headScreen.Y), bottomRight

                for _, line in ipairs({o.top, o.bottom, o.left, o.right}) do
                    line.Color = color
                    line.Thickness = 1.5
                    line.Visible = true
                    line.Transparency = 1
                end

                if Config.Tracers then
                    o.tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
                    o.tracer.To = Vector2.new(headScreen.X, headScreen.Y)
                    o.tracer.Color = color
                    o.tracer.Thickness = 1.5
                    o.tracer.Transparency = 0.7
                    o.tracer.Visible = true
                else
                    o.tracer.Visible = false
                end

                if Config.NameDisplay then
                    o.name.Text = plr.Name .. " [" .. role .. "]"
                    o.name.Position = Vector2.new(headScreen.X, headScreen.Y - 18)
                    o.name.Color = color
                    o.name.Size = 14
                    o.name.Center = true
                    o.name.Outline = true
                    o.name.OutlineColor = Color3.new(0, 0, 0)
                    o.name.Visible = true
                else
                    o.name.Visible = false
                end

                if Config.DistanceDisplay then
                    o.dist.Text = tostring(math.floor(dist)) .. " studs"
                    o.dist.Position = Vector2.new(headScreen.X, bottomScreen.Y + 4)
                    o.dist.Color = color
                    o.dist.Size = 12
                    o.dist.Center = true
                    o.dist.Outline = true
                    o.dist.OutlineColor = Color3.new(0, 0, 0)
                    o.dist.Visible = true
                else
                    o.dist.Visible = false
                end
            else
                for _, v in pairs(o) do v.Visible = false end
            end
        elseif ESP.objects[plr] then
            destroyESP(ESP.objects[plr])
            ESP.objects[plr] = nil
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

-- ═══════════════════════════════════════════════════════════
--  MODÜLLER
-- ═══════════════════════════════════════════════════════════

-- ── VISUAL ─────────────────────────────────────────────
function Modules.Visual(parent)
    makeSection("ESP", parent)
    makeToggle("ESP (rol renkli)", Config.ESP, function(v) Config.ESP = v end, parent)
    makeToggle("Tracers", Config.Tracers, function(v) Config.Tracers = v end, parent)
    makeToggle("Mesafe Göster", Config.DistanceDisplay, function(v) Config.DistanceDisplay = v end, parent)
    makeToggle("İsim Göster", Config.NameDisplay, function(v) Config.NameDisplay = v end, parent)

    makeSection("Dünya", parent)
    makeToggle("X-Ray", Config.XRay, function(v)
        Config.XRay = v
        if TEV_XRay then TEV_XRay(v) end
    end, parent)
    makeToggle("Fullbright", Config.Fullbright, function(v)
        Config.Fullbright = v
        if v then
            Lighting.Ambient = Color3.fromRGB(200,200,200)
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
        else
            Lighting.Ambient = Color3.fromRGB(70,70,70)
            Lighting.Brightness = 1
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        end
    end, parent)
    makeToggle("Bariyerleri Kaldır", Config.RemoveBarriers, function(v)
        Config.RemoveBarriers = v
        if v and TEV_RemoveBarriers then TEV_RemoveBarriers() end
    end, parent)

    makeSection("Bilgi", parent)
    makeLabel("Murderer = Kırmızı\nSheriff = Mavi\nInnocent = Yeşil", parent)
end

-- ── COMBAT ─────────────────────────────────────────────
function Modules.Combat(parent)
    makeSection("Aimbot", parent)
    makeToggle("Aimbot", Config.Aimbot, function(v) Config.Aimbot = v end, parent)
    makeToggle("Murderer'a Aim", Config.AimbotMurder, function(v) Config.AimbotMurder = v end, parent)
    makeToggle("Sheriff'e Aim", Config.AimbotSheriff, function(v) Config.AimbotSheriff = v end, parent)
    makeSlider("FOV", 50, 500, Config.AimbotFOV, function(v) Config.AimbotFOV = v end, parent)
    makeSlider("Smooth (%)", 0, 100, Config.AimbotSmooth * 100, function(v) Config.AimbotSmooth = v / 100 end, parent)
    makeLabel("Aimbot tuşu: E (basılı tut)", parent)
end

-- ── FARM ───────────────────────────────────────────────
function Modules.Farm(parent)
    makeSection("Coin", parent)
    makeToggle("Coin Grabber", Config.CoinGrabber, function(v) Config.CoinGrabber = v end, parent)
    makeSlider("Coin Range", 50, 2000, Config.CoinRange, function(v) Config.CoinRange = v end, parent)
    makeSection("Silah", parent)
    makeToggle("Auto Pickup Gun", Config.AutoPickupGun, function(v) Config.AutoPickupGun = v end, parent)
    makeLabel("Silah düşünce otomatik yanına gelir.", parent)
end

-- ── MOVEMENT ───────────────────────────────────────────
function Modules.Movement(parent)
    makeSection("Hız", parent)
    makeSlider("WalkSpeed", 0, 500, Config.WalkSpeed, function(v)
        Config.WalkSpeed = v
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = v
        end
    end, parent)
    makeSlider("JumpPower", 0, 500, Config.JumpPower, function(v)
        Config.JumpPower = v
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.JumpPower = v
        end
    end, parent)
    makeSlider("Gravity", 0, 500, Config.Gravity, function(v)
        Config.Gravity = v
        workspace.Gravity = v
    end, parent)

    makeSection("Uçuş / Klipler", parent)
    makeToggle("Fly (F)", Config.Fly, function(v) Config.Fly = v; TEV_Fly(v) end, parent)
    makeSlider("Fly Hız", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end, parent)
    makeToggle("Noclip (R)", Config.Noclip, function(v) Config.Noclip = v end, parent)
    makeToggle("Sonsuz Zıplama", Config.InfiniteJump, function(v) Config.InfiniteJump = v end, parent)

    makeSection("Teleport", parent)
    makeToggle("Ctrl+Click TP", Config.CtrlClickTP, function(v) Config.CtrlClickTP = v end, parent)
    makeLabel("Ctrl basılı tut + sol tık → hedef part'a ışınlan.", parent)
end

-- ── TROLL ──────────────────────────────────────────────
function Modules.Troll(parent)
    makeSection("Troll", parent)
    makeButton("Fling Players (Yakın)", parent).MouseButton1Click:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Velocity = Vector3.new(500, 500, 500)
                        end
                    end
                end
            end
        end
    end)
    makeButton("Tüm Oyuncuları Uçur", parent).MouseButton1Click:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
            end
        end
    end)
end

-- ── EMOTES ─────────────────────────────────────────────
local EMOTES = {
    "sit", "zombie", "SprayPaint", "dab", "ninja", "floss", "zen",
    "point", "wave", "dance", "laugh", "cry", "facepalm",
    "shrug", "salute", "cheer", "clap", "bow", "kneel",
}

function Modules.Emotes(parent)
    makeSection("Emotes", parent)
    local PlayEmote = ReplicatedStorage:FindFirstChild("PlayEmote")
    if not PlayEmote then
        makeLabel("PlayEmote remote bulunamadı.", parent)
        return
    end
    for _, e in ipairs(EMOTES) do
        local b = makeButton(e, parent)
        b.MouseButton1Click:Connect(function()
            pcall(function() PlayEmote:FireServer(e) end)
        end)
    end
end

-- ── SETTINGS ───────────────────────────────────────────
function Modules.Settings(parent)
    makeSection("UI", parent)
    makeToggle("Bildirimler", Config.Notifications, function(v) Config.Notifications = v end, parent)
    makeSection("Keybind", parent)
    makeLabel("UI Toggle: RightControl\nFly: F\nNoclip: R\nAimbot: E (basılı tut)\nCtrl+Click TP: Ctrl + Sol tık", parent)
    makeSection("Config", parent)
    makeButton("Config Kaydet", parent).MouseButton1Click:Connect(function()
        pcall(function()
            writefile("tev_config.json", HttpService:JSONEncode(Config))
            notify("TEV", "Config kaydedildi")
        end)
    end)
    makeButton("Config Yükle", parent).MouseButton1Click:Connect(function()
        pcall(function()
            local data = readfile("tev_config.json")
            local cfg = HttpService:JSONDecode(data)
            for k, v in pairs(cfg) do Config[k] = v end
            notify("TEV", "Config yüklendi (UI yenile)")
        end)
    end)
    makeSection("Hakkında", parent)
    makeLabel("TEV HUB v1.1\nAnalytics yok. Key yok. Obfuscate yok.", parent)
end

-- ═══════════════════════════════════════════════════════════
--  SEKME OLUŞTURMA
-- ═══════════════════════════════════════════════════════════
local function selectTab(name)
    if activeTab == name then return end
    activeTab = name
    for n, btn in pairs(tabButtons) do
        local on = (n == name)
        Tween(btn, 0.18, {
            BackgroundColor3 = on and T.Accent1 or T.BgDark,
            BackgroundTransparency = on and 0.1 or 0.5,
        })
        if btn:FindFirstChild("UIStroke") then
            Tween(btn.UIStroke, 0.18, { Transparency = on and 0.2 or 0.7 })
        end
    end
    clearContent()
    if Modules[name] then
        task.spawn(Modules[name], ContentScroll)
    end
end

for i, tab in ipairs(Tabs) do
    local btn = New("TextButton", {
        Name = tab.Name,
        Text = "  " .. tab.Icon .. "   " .. tab.Name,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        BackgroundColor3 = T.BgDark,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 0, 38),
        AutoButtonColor = false,
        LayoutOrder = i,
        ZIndex = 5,
        Parent = TabBar,
    })
    Corner(btn, UDim.new(0, 8))
    Stroke(btn, T.Accent3, 1, 0.7)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseEnter:Connect(function()
        if activeTab ~= tab.Name then
            Tween(btn, 0.15, { BackgroundColor3 = T.BgHover, BackgroundTransparency = 0.3 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= tab.Name then
            Tween(btn, 0.15, { BackgroundColor3 = T.BgDark, BackgroundTransparency = 0.5 })
        end
    end)
    btn.MouseButton1Click:Connect(function() selectTab(tab.Name) end)
    tabButtons[tab.Name] = btn
end

-- ═══════════════════════════════════════════════════════════
--  SÜRÜKLEME
-- ═══════════════════════════════════════════════════════════
do
    local dragging, dragStart, startPos
    local titleBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        ZIndex = 10,
        Parent = Main,
    })
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  YARDIMCI FONKSİYONLAR
-- ═══════════════════════════════════════════════════════════

function TEV_XRay(state)
    local function scan(root)
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("BasePart") and (not v.Parent or not v.Parent:FindFirstChild("Humanoid")) then
                v.LocalTransparencyModifier = state and 0.75 or 0
            end
            scan(v)
        end
    end
    pcall(scan, workspace)
end

function TEV_RemoveBarriers()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            local nm = v.Name:lower()
            if nm:find("barrier") or nm:find("invisible") or v.Transparency == 1 then
                v.CanCollide = false
            end
        end
    end
end

local flyActive = false
local flyBV, flyBG

function TEV_Fly(state)
    flyActive = state
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hrp then return end

    if state then
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBG.P = 9e4
        flyBG.CFrame = hrp.CFrame
        char.Humanoid.PlatformStand = true

        task.spawn(function()
            while flyActive and char.Parent do
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

                if move.Magnitude > 0 then
                    flyBV.Velocity = move.Unit * Config.FlySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0, 0)
                end
                flyBG.CFrame = cam.CFrame
                RunService.Heartbeat:Wait()
            end
            if flyBV then flyBV:Destroy() end
            if flyBG then flyBG:Destroy() end
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end)
    else
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  ANA DÖNGÜLER
-- ═══════════════════════════════════════════════════════════

RunService.Stepped:Connect(function()
    if Config.Noclip and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Config.CoinGrabber and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LP.Character.HumanoidRootPart
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "Coin" then
                    local dist = (v.Position - hrp.Position).Magnitude
                    if dist < Config.CoinRange then
                        v.CFrame = hrp.CFrame
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoPickupGun and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local gunDrop = workspace:FindFirstChild("GunDrop")
            if gunDrop then
                gunDrop.CFrame = LP.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.CtrlClickTP
       and input.UserInputType == Enum.UserInputType.MouseButton1
       and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LP:GetMouse()
        local target = mouse.Target
        if target and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local TT = ReplicatedStorage:FindFirstChild("Remotes")
                and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
                and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("TeleportToPart")
            if TT then
                pcall(function() TT:FireServer(target) end)
            else
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not Config.Aimbot then return end
    if not UserInputService:IsKeyDown(Config.AimbotKey) then return end

    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local best, bestDist = nil, Config.AimbotFOV

    for _, entry in ipairs(Roles.All) do
        local plr = entry.player
        local role = entry.role
        if (role == "Murderer" and Config.AimbotMurder) or (role == "Sheriff" and Config.AimbotSheriff) or (role == "Innocent") then
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local v2 = Vector2.new(sp.X, sp.Y)
                    local dist = (v2 - center).Magnitude
                    if dist < bestDist then
                        best, bestDist = head, dist
                    end
                end
            end
        end
    end
    if best then
        local targetCF = CFrame.new(cam.CFrame.Position, best.Position)
        cam.CFrame = cam.CFrame:Lerp(targetCF, 1 - Config.AimbotSmooth)
    end
end)

-- Godmode
task.spawn(function()
    while task.wait(0.5) do
        if Config.GodMode and LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Name == "Humanoid" and hum.Health > 0 then
                hum.Name = "1"
                local clone = hum:Clone()
                clone.Name = "Humanoid"
                clone.Parent = LP.Character
                hum:Destroy()
                workspace.CurrentCamera.CameraSubject = LP.Character:FindFirstChild("Humanoid")
            end
        end
    end
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F then
        Config.Fly = not Config.Fly
        TEV_Fly(Config.Fly)
        notify("TEV", "Fly: " .. (Config.Fly and "AÇIK" or "KAPALI"), 1.5)
    elseif input.KeyCode == Enum.KeyCode.R then
        Config.Noclip = not Config.Noclip
        notify("TEV", "Noclip: " .. (Config.Noclip and "AÇIK" or "KAPALI"), 1.5)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  AÇILIŞ
-- ═══════════════════════════════════════════════════════════
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Tween(Main, 0.45, {
    Size = UDim2.new(0, 700, 0, 450),
    Position = UDim2.new(0.5, -350, 0.5, -225),
}, Enum.EasingStyle.Back)

selectTab("Visual")
notify("TEV HUB", "v1.1 yüklendi", 3)
print("[TEV] v1.1 aktif. Parent: " .. tostring(parent))
