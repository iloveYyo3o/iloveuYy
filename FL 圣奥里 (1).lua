--脚本圈大神3899403161开源
--删掉以上这句话死爹妈



local cloneref = (cloneref or clonereference or function(i) return i end)
local UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer = cloneref(game:GetService("Players")).LocalPlayer
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WINDUI_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"

local function tryLoadWindUI(url)
	local ok, result = pcall(function()
		local src = game:HttpGet(url)
		if not src or #src < 1000 then
			error("响应内容过短，可能不是有效源码")
		end
		return loadstring(src)()
	end)
	if ok and type(result) == "table" then
		return result
	end
	return nil, ok and "返回值不是 table" or tostring(result)
end

local v, loadErr = tryLoadWindUI(WINDUI_URL)

if not v then
	error("[FL] WindUI 加载失败: " .. tostring(loadErr))
end

local playerFunc = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("PlayerFunc")

BuyItem = function(arg, arg2, arg3, arg4)
	local stuff = ReplicatedStorage:FindFirstChild("Stuff")
	if not stuff then
		return false, "未找到 Stuff"
	end

	for _, part in ipairs(string.split(arg, "/")) do
		stuff = stuff:FindFirstChild(part)
		if not stuff then
			return false, "路径缺失: " .. part
		end
	end

	local v2 = stuff:FindFirstChild(arg2)
	if not v2 then
		return false, "物品不存在"
	end
	local response = playerFunc:InvokeServer("purchase", { isRestaurant = arg4, item = v2, quantity = arg3, color = nil })
	return response == true, tostring(response)
end

local ESP = (function()
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
    PurpleLight = Color3.fromRGB(210, 180, 255),
    PurpleMid   = Color3.fromRGB(170, 120, 255),
    PurpleDeep  = Color3.fromRGB(120,  70, 220),
    PurpleSoft  = Color3.fromRGB(235, 220, 255),
    PurpleGlow  = Color3.fromRGB(180, 140, 255),
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0, 0, 0),
    DarkBg      = Color3.fromRGB(22, 22, 28),
}

local ESP_CustomFonts = nil
do
    local ok = pcall(function()
        local Fonts = {}
        local function FontsRegister(Name, Weight, Style, Asset)
            if not isfile(Asset.Id) then
                writefile(Asset.Id, Asset.Font)
            end
            if isfile(Name .. ".font") then
                delfile(Name .. ".font")
            end
            local Info = {
                name = Name,
                faces = {
                    {
                        name = "Normal",
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Asset.Id),
                    },
                },
            }
            writefile(Name .. ".font", HttpService:JSONEncode(Info))
            return getcustomasset(Name .. ".font")
        end

        Fonts.Tahoma = FontsRegister("Tahoma", 400, "Normal", {
            Id = "Tahoma.ttf",
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"),
        })
        Fonts.XPTahoma = FontsRegister("XPTahoma", 400, "Normal", {
            Id = "Tahoma8PTBOLD.ttf",
            Font = game:HttpGet("https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/TAHOMA-8PT-BOLD-WINDOWS-XP.TTF"),
        })
        Fonts.SmallestPixel = FontsRegister("SmallestPixel", 400, "Normal", {
            Id = "smallest_pixel-7.ttf",
            Font = game:HttpGet("https://raw.githubusercontent.com/sametexe001/luas/main/smallest_pixel-7.ttf")
        })
        Fonts.ProggyTiny = FontsRegister("ProggyTiny", 400, "Normal", {
            Id = "ProggyTinyyyy.ttf",
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyTiny.ttf")
        })
        Fonts.ProggyClean = FontsRegister("ProggyClean", 400, "Normal", {
            Id = "ProggyClean.ttf",
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/main/fonts/ProggyClean.ttf"),
        })

        ESP_CustomFonts = {
            TahomaBold    = Font.new(Fonts.XPTahoma,     Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Tahoma        = Font.new(Fonts.Tahoma,       Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            SmallestPixel = Font.new(Fonts.SmallestPixel,Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ProggyTiny    = Font.new(Fonts.ProggyTiny,   Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ProggyClean   = Font.new(Fonts.ProggyClean,  Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        }
    end)
    if not ok or not ESP_CustomFonts then
        ESP_CustomFonts = {
            TahomaBold    = { Font = Enum.Font.GothamBold },
            Tahoma        = { Font = Enum.Font.Gotham },
            SmallestPixel = { Font = Enum.Font.Code },
            ProggyTiny    = { Font = Enum.Font.Code },
            ProggyClean   = { Font = Enum.Font.Code },
        }
    end
end

local Flags = setmetatable({}, {
    __index = function(t, k)
        local v = { Value=false, Color=Theme.PurpleLight, Transparency=0 }
        rawset(t, k, v)
        return v
    end
})

local function setFlag(name, data) Flags[name] = data end

setFlag("Esp Box",               {Value=true})
setFlag("Esp Box Style",         {Value="Full"})
setFlag("Esp Box Thickness",     {Value=2})
setFlag("Esp Box Color",         {Color=Theme.PurpleLight})
setFlag("Esp Box Fill",          {Value=true})
setFlag("Esp Box Fill Color",    {Color=Theme.PurpleMid})
setFlag("Esp Box Fill Transparency", {Value=0.55})
setFlag("Esp Box Fill Spin",     {Value=false})
setFlag("Esp Box Glow",          {Value=false})

setFlag("Esp Health Bar",        {Value=true})
setFlag("Esp Health Color 1",    {Color=Color3.fromRGB(255, 255, 255)})
setFlag("Esp Health Color 2",    {Color=Theme.PurpleLight})
setFlag("Esp Health Color 3",    {Color=Color3.fromRGB(255, 255, 255), Transparency=0})
setFlag("Esp Health Bar Type",   {Value="Gradient"})

setFlag("Esp Name",              {Value=true})
setFlag("Esp Name Font",         {Value="Bold"})
setFlag("Esp Name Color",        {Color=Theme.PurpleSoft, Transparency=0})

setFlag("Esp Weapon",            {Value=true})
setFlag("Esp Weapon Color",      {Color=Theme.PurpleSoft, Transparency=0})
setFlag("Esp Weapon Icon",       {Value=true})
setFlag("Esp Weapon Icon Color", {Color=Theme.White, Transparency=0})

setFlag("Esp Distance",          {Value=true})
setFlag("Esp Distance Color",    {Color=Theme.PurpleSoft, Transparency=0})

setFlag("Esp Skeleton",          {Value=false})
setFlag("Esp Skeleton Color",    {Color=Theme.PurpleMid, Transparency=0})

setFlag("Esp Flags",             {Value=true})
setFlag("Esp Flags Color",       {Color=Theme.PurpleSoft, Transparency=0})

setFlag("Esp Refresh Rate",      {Value=144})
setFlag("Esp Bounding Type",     {Value="Dynamic"})
setFlag("Esp Max Distance",      {Value=1500})
setFlag("Esp Priority Only",     {Value=false})

setFlag("Esp Oov",               {Value=false})
setFlag("Esp Oov Color",         {Color=Theme.PurpleLight, Transparency=0})
setFlag("Esp Oov Elements",      {Value={"Name","Health Bar","Distance","Weapon"}})
setFlag("Esp Oov Style",         {Value="Concave"})
setFlag("Esp Oov Distance",      {Value=40})
setFlag("Esp Oov Size",          {Value=13})
setFlag("Esp Oov Dynamic Distance", {Value=false})
setFlag("Esp Oov Dynamic Size",  {Value=false})
setFlag("Esp Oov Blink",         {Value=false})
setFlag("Esp Oov Blink Speed",   {Value=1})

setFlag("Chams Enabled",         {Value=false})
setFlag("Chams Color",           {Color=Theme.PurpleDeep, Transparency=0.61})
setFlag("Outline Color",         {Color=Theme.PurpleLight, Transparency=0.21})
setFlag("Glows Enabled",         {Value=false})
setFlag("Glows Size",            {Value=1.75})
setFlag("Chams Shading",         {Value=false})
setFlag("Inline Shade",          {Value="Default"})
setFlag("Outline Shade",         {Value="Default"})

setFlag("Priority Color Enabled",{Value=true})
setFlag("Priority Color",        {Color=Theme.PurpleLight})
setFlag("Whitelist Color Enabled",{Value=true})
setFlag("Whitelist Color",       {Color=Theme.PurpleSoft})

local ItemIcons = {}

local BodyPartNames = {
    "Head","UpperTorso","LowerTorso",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperLeg","RightLowerLeg","RightFoot",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "Torso","Left Arm","Right Arm","Left Leg","Right Leg",
    "LeftArm","RightArm","LeftLeg","RightLeg",
}
local BodyPartSizes = {
    ["Head"]          = Vector3.new(2,1.3,1),
    ["UpperTorso"]    = Vector3.new(2,1.6,1),
    ["LowerTorso"]    = Vector3.new(2,0.4,1),
    ["RightUpperArm"] = Vector3.new(1,1.169,1),
    ["RightLowerArm"] = Vector3.new(1,1.052,1),
    ["LeftUpperArm"]  = Vector3.new(1,1.169,1),
    ["LeftLowerArm"]  = Vector3.new(1,1.052,1),
    ["RightHand"]     = Vector3.new(1,0.3,1),
    ["LeftHand"]      = Vector3.new(1,0.3,1),
    ["RightUpperLeg"] = Vector3.new(1,1.127,1),
    ["RightLowerLeg"] = Vector3.new(1,1.193,1),
    ["RightFoot"]     = Vector3.new(1,0.3,1),
    ["LeftUpperLeg"]  = Vector3.new(1,1.127,1),
    ["LeftLowerLeg"]  = Vector3.new(1,1.193,1),
    ["LeftFoot"]      = Vector3.new(1,0.3,1),
}
local SkeletonJoints = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local ESP = {}
ESP.Theme        = Theme
ESP.Enabled      = true
ESP.ShowDead     = false
ESP.TrackSelf    = false
ESP.TeamCheck    = false
ESP.TeamResolver = nil
ESP.ColorResolver = nil
ESP.NameResolver = nil
ESP.WeaponResolver = nil
ESP.ItemIcons    = ItemIcons
ESP.CharResolver = nil
ESP.Camera      = Camera
ESP.ScreenSize  = Camera.ViewportSize
ESP.LocalPlayer = LocalPlayer
ESP.Flags       = {}
ESP.Overlay     = nil

ESP.Fonts = {
    ["Tiny5"]         = { FontObject = ESP_CustomFonts.SmallestPixel, Size = 8  },
    ["Sevasto"]       = { FontObject = ESP_CustomFonts.Tahoma,        Size = 14 },
    ["Tahoma"]        = { FontObject = ESP_CustomFonts.Tahoma,        Size = 12 },
    ["Tahoma Bold"]   = { FontObject = ESP_CustomFonts.TahomaBold,    Size = 9  },
    ["Consolas Bold"] = { FontObject = ESP_CustomFonts.ProggyTiny,    Size = 11 },
}

function ESP.DeepCopy(t)
    local c = {}
    for k,v in next, t do c[k] = type(v)=="table" and ESP.DeepCopy(v) or v end
    return c
end

local function ApplyFont(Obj, FontSpec)
    if not FontSpec then
        Obj.Font = Enum.Font.Code
        return
    end
    local FO = FontSpec.FontObject
    if FO == nil then
        if typeof(FontSpec) == "Font" then
            Obj.FontFace = FontSpec
        elseif FontSpec.Font then
            Obj.Font = FontSpec.Font
        else
            Obj.Font = Enum.Font.Code
        end
        return
    end
    if typeof(FO) == "Font" then
        Obj.FontFace = FO
    elseif typeof(FO) == "table" and FO.Font then
        Obj.Font = FO.Font
    else
        Obj.Font = Enum.Font.Code
    end
end

function ESP.Render(Type, Properties, Drawing)
    local IsText = Type=="TextLabel" or Type=="TextButton" or Type=="TextBox"
    local R = Instance.new(Type)

    if Type=="UIStroke" then
        R.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        R.LineJoinMode = Enum.LineJoinMode.Miter
        R.Color = Theme.Black; R.Thickness = 1
    elseif Type=="CylinderHandleAdornment" then
        R.CFrame = CFrame.new(Vector3.zero, Vector3.new(0,90,0))
    elseif IsText then
        R.TextStrokeTransparency = 1
    end

    if Type ~= "UIStroke" and Properties["TextStrokeTransparency"] ~= nil then
        local S = ESP.Render("UIStroke",{
            Parent=R, Color=Properties.TextStrokeColor3,
            LineJoinMode=Properties.LineJoinMode,
            ApplyStrokeMode=Properties.ApplyStrokeMode,
            Thickness=Properties.Thickness,
            Transparency=Properties.TextStrokeTransparency,
        })
        if IsText then
            R:GetPropertyChangedSignal("TextTransparency"):Connect(function()
                S.Transparency = R.TextTransparency
            end)
        end
    end

    if IsText then
        local F = Properties.FontObject or ESP.Fonts["Tiny5"]
        pcall(function() ApplyFont(R, F) end)
        R.TextSize = (F and F.Size) or 9
        R.TextColor3 = Theme.White
    end

    for i,v in next, Properties do
        if i=="FontObject" or i=="TextStrokeTransparency" or i=="FontFace" then continue end
        R[i] = v
    end

    if IsText and Drawing=="Shadow" then
        local Sh = ESP.Render("TextLabel", Properties)
        Sh.Position = R.Position + UDim2.new(0,1,0,1)
        Sh.TextColor3 = Theme.Black
        Sh.ZIndex = R.ZIndex - 1; Sh.RichText = false
        Sh.Text = R.ContentText
        R:GetPropertyChangedSignal("Parent"):Connect(function() Sh.Parent=R.Parent end)
        R:GetPropertyChangedSignal("Position"):Connect(function() Sh.Position=R.Position+UDim2.new(0,1,0,1) end)
        R:GetPropertyChangedSignal("Visible"):Connect(function() Sh.Visible=R.Visible end)
        R:GetPropertyChangedSignal("Text"):Connect(function() Sh.Text=R.ContentText end)
        R:GetPropertyChangedSignal("TextTransparency"):Connect(function() Sh.TextTransparency=R.TextTransparency end)
    end
    return R
end

function ESP.Rotate(Vector, Radians)
    local U = Vector.Unit
    local sx, cx = math.sin(Radians), math.cos(Radians)
    return Vector2.new((cx*U.X)-(sx*U.Y),(sx*U.X)+(cx*U.Y)).Unit * Vector.Magnitude
end
function ESP.MultiplyColor(C,R) return Color3.new(C.R*R,C.G*R,C.B*R) end
function ESP.LerpColor(C1,C2,R) return Color3.new(C1.R+(C2.R-C1.R)*R,C1.G+(C2.G-C1.G)*R,C1.B+(C2.B-C1.B)*R) end
function ESP.Lerp(Cur,Goal,G) return (1-G)*Cur + G*Goal end

function ESP.Parent(Renders)
    for Index, Render in next, Renders do
        if Index=="Arrow" or Index=="ArrowOutline" or Index=="Skeleton" or Index=="Chams"
            or Index=="CornerH" or Index=="CornerV" then
            continue
        elseif Index=="Flags" then
            for _, V in next, Render do if V.Render then V.Render.Parent=nil end end
        elseif typeof(Render)=="Instance" then
            Render.Parent = nil
        end
    end
end

function ESP.WorldToViewportPoint(Position)
    local Cam = Workspace.CurrentCamera or ESP.Camera
    if not Cam then return Vector3.new(0,0,0), false end
    ESP.Camera = Cam
    local V, On = Cam:WorldToViewportPoint(Position)
    return Vector3.new(V.X, V.Y, V.Z), On
end

function ESP.GetBoundingBox(This, RootPosition, Type)
    local SY = ESP.ScreenSize.Y
    if Type == "Static" then
        local P, On = ESP.WorldToViewportPoint(RootPosition)
        if not On then return end
        local Scale = (SY * 1.5) / (P.Z * 2 * math.tan((ESP.Camera.FieldOfView*math.pi/180)/2))
        local W = 2.0833 * Scale
        local H = 3.6364 * Scale
        return UDim2.new(0, math.floor(P.X - W/2), 0, math.floor(P.Y - H/2.5)),
               UDim2.new(0, math.ceil(W), 0, math.ceil(H))
    else
        local MinX,MinY = math.huge,math.huge
        local MaxX,MaxY = -math.huge,-math.huge
        local Any = false
        for _, Part in next, This.BodyParts do
            local CF, Sz = Part.CFrame, Part.Size
            local hx,hy,hz = Sz.X/2, Sz.Y/2, Sz.Z/2
            local C = {
                Vector3.new(hx,hy,hz),Vector3.new(-hx,hy,hz),
                Vector3.new(hx,-hy,hz),Vector3.new(-hx,-hy,hz),
                Vector3.new(hx,hy,-hz),Vector3.new(-hx,hy,-hz),
                Vector3.new(hx,-hy,-hz),Vector3.new(-hx,-hy,-hz),
            }
            for i=1,8 do
                local P, On = ESP.WorldToViewportPoint(CF*C[i])
                MinX=math.min(MinX,P.X); MinY=math.min(MinY,P.Y)
                MaxX=math.max(MaxX,P.X); MaxY=math.max(MaxY,P.Y)
                if On then Any = true end
            end
        end
        if not Any then return end
        MinX,MinY=math.floor(MinX),math.floor(MinY)
        MaxX,MaxY=math.floor(MaxX),math.floor(MaxY)
        return UDim2.new(0,MinX,0,MinY), UDim2.new(0,MaxX-MinX,0,MaxY-MinY)
    end
end

local function CreateLine(Parent, ZIndex)
    return ESP.Render("Frame", {
        Parent = Parent,
        BackgroundColor3 = Theme.PurpleLight,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = ZIndex or 3,
        AnchorPoint = Vector2.new(0, 0.5),
    })
end

local function UpdateLine(Line, From, To, Color, Transparency)
    local D = To - From
    local Len = D.Magnitude
    if Len <= 0.01 then
        Line.Visible = false
        return
    end
    Line.Position = UDim2.new(0, From.X, 0, From.Y)
    Line.Size = UDim2.new(0, Len, 0, 1)
    Line.Rotation = math.deg(math.atan2(D.Y, D.X))
    Line.BackgroundColor3 = Color
    Line.BackgroundTransparency = Transparency
    Line.Visible = true
end

function ESP.GetPlayerRenders(Player)
    local R = { Chams=ESP.GetChams(), Skeleton=ESP.GetSkeleton(), Flags={} }
    R.RenderFrame = ESP.Render("Frame",{Visible=false,BackgroundTransparency=1})
    R.ShadowName  = ESP.Render("TextLabel",{ZIndex=3,Visible=false,Position=UDim2.new(0.5,0,0,-9),Text=Player.Name,TextTransparency=0,BackgroundTransparency=1,FontObject=ESP.Fonts["Tahoma Bold"],RichText=true},"Shadow")
    R.OutlineName = ESP.Render("TextLabel",{ZIndex=3,Visible=false,Position=UDim2.new(0.5,0,0,-9),Text=Player.Name,TextTransparency=0,TextStrokeTransparency=0,BackgroundTransparency=1,FontObject=ESP.Fonts["Tiny5"],RichText=true})
    R.Distance    = ESP.Render("TextLabel",{ZIndex=3,Visible=false,Position=UDim2.new(0.5,0,1,7),TextTransparency=0,TextStrokeTransparency=0,BackgroundTransparency=1})
    R.Weapon      = ESP.Render("TextLabel",{ZIndex=3,Visible=false,Position=UDim2.new(0.5,0,1,15),TextTransparency=0,TextStrokeTransparency=0,BackgroundTransparency=1})
    R.WeaponIcon  = ESP.Render("ImageLabel",{ZIndex=2,Visible=false,Position=UDim2.new(0.5,-13,1,22),Size=UDim2.new(0,25,0,25),BackgroundTransparency=1,Image=""})
    R.Box         = ESP.Render("Frame",{ZIndex=1,Visible=false,Position=UDim2.new(0,-1,0,-1),Size=UDim2.new(1,2,1,2),BackgroundTransparency=1})
    R.CornerH = {}; R.CornerV = {}
    for _i = 1, 4 do
        R.CornerH[_i] = ESP.Render("Frame",{ZIndex=1,Visible=false,BorderSizePixel=0,BackgroundColor3=Theme.PurpleLight})
        R.CornerV[_i] = ESP.Render("Frame",{ZIndex=1,Visible=false,BorderSizePixel=0,BackgroundColor3=Theme.PurpleLight})
    end
    R.BoxFill     = ESP.Render("Frame",{ZIndex=2,Visible=false,Position=UDim2.new(0,1,0,1),Size=UDim2.new(1,-2,1,-2),BackgroundTransparency=0,BorderSizePixel=0,BackgroundColor3=Theme.PurpleMid})
    R.BoxFillGradient = ESP.Render("UIGradient",{Enabled=true,Rotation=90})
    R.BoxOutline  = ESP.Render("UIStroke",{Thickness=3})
    R.BoxInline   = ESP.Render("UIStroke",{LineJoinMode=Enum.LineJoinMode.Miter,Thickness=1,Color=Theme.PurpleLight})
    R.Health         = ESP.Render("Frame",{ZIndex=4,Visible=false,Position=UDim2.new(0,-6,0,-2),Size=UDim2.new(0,1.5,1,4),BorderColor3=Theme.Black,BackgroundColor3=Theme.PurpleLight,BackgroundTransparency=0,BorderSizePixel=0})
    R.HealthBack     = ESP.Render("Frame",{ZIndex=3,Visible=false,Position=UDim2.new(0,-6,0,-2),Size=UDim2.new(0,1.5,1,4),BorderColor3=Theme.Black,BackgroundColor3=Theme.DarkBg,BorderSizePixel=1})
    R.HealthGradient = ESP.Render("UIGradient",{Enabled=true,Rotation=90})
    R.HealthText     = ESP.Render("TextLabel",{ZIndex=5,Visible=false,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,-8,1,0),Text="115",TextTransparency=0,TextStrokeTransparency=0,BackgroundTransparency=1})
    R.OOVHolder = ESP.Render("Frame",{BackgroundTransparency=1,Visible=false,ZIndex=3})
    R.OOVLeft   = CreateLine(R.OOVHolder, 3)
    R.OOVRight  = CreateLine(R.OOVHolder, 3)
    R.OOVMiddle = CreateLine(R.OOVHolder, 3)
    return R
end

function ESP.GetChams()
    local This = {}
    local OO = Vector3.new(0.1,0.1,0.1)
    local IO = Vector3.new(-0.1,-0.1,-0.1)
    for Name, Value in next, BodyPartSizes do
        local IsHead = (Name == "Head")
        for i = 1, 2 do
            local IsOutline = (i == 1)
            local Offset = (IsOutline and 0.3 or 0.4)
            local R = ESP.Render(IsHead and "CylinderHandleAdornment" or "BoxHandleAdornment",{
                Parent=ESP.Overlay,
                AlwaysOnTop = IsOutline and false or true,
                ZIndex = IsOutline and -1 or 1,
                Transparency = IsOutline and 0.21 or 0.61,
                AdornCullingMode = Enum.AdornCullingMode.Never,
            })
            if IsHead then
                R.Height = (Value.Y + 0.4) - Offset
                R.Radius = (Value.X / 2) - Offset
            else
                R.Size = Value + (IsOutline and OO or IO)
            end
            This[#This+1] = {R, Name, IsOutline}
        end
    end
    return This
end

function ESP.GetSkeleton()
    local This = {}
    for i = 1, #SkeletonJoints do
        This[i] = CreateLine(nil, 3)
    end
    return This
end

local function GetPriorityColor(This)
    if This.OverrideColor then return This.OverrideColor end
    if This.Priority and Flags["Priority Color Enabled"].Value then
        return Flags["Priority Color"].Color
    elseif This.Whitelist and Flags["Whitelist Color Enabled"].Value then
        return Flags["Whitelist Color"].Color
    end
    return nil
end

local function ComputeNameScale(This)
    local target = 1 + math.clamp((This.Distance or 0) / 500, 0, 2.5)
    if not This._SmoothNameScale then
        This._SmoothNameScale = target
    else
        This._SmoothNameScale = ESP.Lerp(This._SmoothNameScale, target, 0.25)
    end
    return This._SmoothNameScale
end

function ESP.RenderPlayerOnScreen(This, R, BoxPos, BoxSize)
    local RF = R.RenderFrame
    local Box,BoxInline,BoxOutline,BoxFill,BoxFillGradient = R.Box,R.BoxInline,R.BoxOutline,R.BoxFill,R.BoxFillGradient
    local HI,HO,HT,HG = R.Health,R.HealthBack,R.HealthText,R.HealthGradient
    local SN,ON = R.ShadowName,R.OutlineName
    local W,WI,D = R.Weapon,R.WeaponIcon,R.Distance
    local SK = R.Skeleton
    local P = GetPriorityColor(This)

    R.OOVHolder.Visible=false
    if RF.Parent ~= ESP.Overlay then RF.Parent = ESP.Overlay end

    local targetX = BoxPos.X.Offset
    local targetY = BoxPos.Y.Offset
    local targetW = BoxSize.X.Offset
    local targetH = BoxSize.Y.Offset

    if not This._SmoothX then
        This._SmoothX = targetX
        This._SmoothY = targetY
        This._SmoothW = targetW
        This._SmoothH = targetH
    else
        local a = 0.45
        This._SmoothX = ESP.Lerp(This._SmoothX, targetX, a)
        This._SmoothY = ESP.Lerp(This._SmoothY, targetY, a)
        This._SmoothW = ESP.Lerp(This._SmoothW, targetW, a)
        This._SmoothH = ESP.Lerp(This._SmoothH, targetH, a)
    end

    BoxPos = UDim2.new(0, math.floor(This._SmoothX), 0, math.floor(This._SmoothY))
    BoxSize = UDim2.new(0, math.floor(This._SmoothW), 0, math.floor(This._SmoothH))

    RF.Position = BoxPos; RF.Size = BoxSize
    RF.Visible = true

    local _Corners = (Flags["Esp Box Style"].Value == "Corners")
    for _i = 1, 4 do
        if R.CornerH[_i] then
            R.CornerH[_i].Visible = false; R.CornerV[_i].Visible = false
        end
    end
    if Flags["Esp Box"].Value and _Corners then
        local C = P or Flags["Esp Box Color"].Color
        local _W, _H = BoxSize.X.Offset, BoxSize.Y.Offset
        local _L = math.min(_W * 0.25, _H * 0.25, 12)
        local _T = Flags["Esp Box Thickness"].Value
        local _ox, _oy = BoxPos.X.Offset, BoxPos.Y.Offset
        local _pts = {
            {_ox,      _oy,      1,  1},
            {_ox + _W, _oy,     -1,  1},
            {_ox,      _oy + _H, 1, -1},
            {_ox + _W, _oy + _H,-1, -1},
        }
        for _i = 1, 4 do
            local _p = _pts[_i]
            local _h, _v = R.CornerH[_i], R.CornerV[_i]
            _h.Parent = RF; _v.Parent = RF
            _h.BackgroundColor3 = C; _v.BackgroundColor3 = C
            _h.Size = UDim2.new(0, _L, 0, _T)
            _h.Position = UDim2.new(0, (_p[3] > 0) and _p[1] or (_p[1] - _L), 0, (_p[4] > 0) and _p[2] or (_p[2] - _T))
            _v.Size = UDim2.new(0, _T, 0, _L)
            _v.Position = UDim2.new(0, (_p[3] > 0) and _p[1] or (_p[1] - _T), 0, (_p[4] > 0) and _p[2] or (_p[2] - _L))
            _h.Visible = true; _v.Visible = true
        end
        Box.Visible=false; Box.Parent=nil; BoxInline.Parent=nil; BoxOutline.Parent=nil
        BoxFill.Visible=false; BoxFill.Parent=nil; BoxFillGradient.Parent=nil
    elseif Flags["Esp Box"].Value then
        local C = P or Flags["Esp Box Color"].Color
        Box.Parent = RF; BoxInline.Color = C
        if Flags["Esp Box Fill"].Value then
            BoxFill.Parent = Box
            BoxFillGradient.Parent = BoxFill
            local FC = Flags["Esp Box Fill Color"].Color
            local FT = Flags["Esp Box Fill Transparency"].Value
            BoxFillGradient.Color = ColorSequence.new(FC, FC)
            BoxFillGradient.Rotation = 90
            BoxFillGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1, 0),
                NumberSequenceKeypoint.new(0.45, 1, 0),
                NumberSequenceKeypoint.new(1, FT, 0),
            })
            BoxFillGradient.Enabled = true
            BoxFill.Visible = true
        else
            BoxFill.Visible=false; BoxFill.Parent=nil; BoxFillGradient.Parent=nil
        end
        BoxOutline.Thickness = Flags["Esp Box Thickness"].Value
        Box.Visible=true; BoxInline.Parent=Box; BoxOutline.Parent=RF
    else
        Box.Visible=false; Box.Parent=nil; BoxInline.Parent=nil; BoxOutline.Parent=nil
        BoxFillGradient.Parent=nil
    end

    if Flags["Esp Health Bar"].Value then
        local Hp=math.ceil(This.Health); local Percent=Hp/This.MaxHealth
        local SizeY=ESP.Lerp(HI.Size.Y.Scale,Percent,0.1)
        HO.Parent=RF; HI.Parent=HO
        HI.Size=UDim2.new(0,1.5,SizeY,0); HI.Position=UDim2.new(0,0,1-SizeY,0)
        HO.Size=UDim2.new(0,1.5,1,4); HO.Position=UDim2.new(0,-6,0,-2)
        HI.BackgroundTransparency=0; HO.BackgroundTransparency=0
        if P then
            HG.Enabled=false; HG.Parent=nil; HI.BackgroundColor3=P
        else
            local C1=Flags["Esp Health Color 1"].Color
            local C2=Flags["Esp Health Color 2"].Color
            local T=Flags["Esp Health Bar Type"].Value
            if T=="Static" then
                HG.Enabled=false; HG.Parent=nil; HI.BackgroundColor3=C1
            elseif T=="Dynamic" then
                HG.Enabled=false; HG.Parent=nil
                HI.BackgroundColor3=(C1==C2) and C1 or ESP.LerpColor(C2,C1,Percent)
            else
                HG.Parent=HI; HG.Enabled=true; HI.BackgroundColor3=Theme.White
                HG.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, C1),
                    ColorSequenceKeypoint.new(1, C2),
                })
            end
        end
        if Percent<1 then
            HT.Parent=HI; HT.Text=Hp
            HT.TextColor3=Color3.fromRGB(255,255,255)
            HT.TextTransparency=0
            HT.Visible=true
        else HT.Visible=false; HT.Parent=nil end
        HI.Visible=true; HO.Visible=true
    else
        HI.Visible=false; HO.Visible=false; HI.Parent=nil; HO.Parent=nil; HT.Parent=nil; HG.Parent=nil
    end

    if Flags["Esp Name"].Value then
        local F=Flags["Esp Name Font"].Value
        local T=(F=="Small") and string.upper(This.Name) or This.Name
        local NC=Flags["Esp Name Color"]
        local nameScale = ComputeNameScale(This)

        if F=="Bold" then
            ON.Visible=false; ON.Parent=nil
            SN.Parent=RF; SN.Position=UDim2.new(0.5,0,0,-9); SN.Text=T
            SN.TextColor3=P or NC.Color; SN.TextTransparency=P and 0 or NC.Transparency
            SN.TextSize = math.floor(9 * nameScale)
            SN.Visible=true
        else
            local FF=(F=="Regular") and ESP.Fonts["Sevasto"] or ESP.Fonts["Tiny5"]
            SN.Visible=false; SN.Parent=nil
            ON.Parent=RF
            pcall(function() ApplyFont(ON, FF) end)
            ON.TextSize = math.floor((FF.Size or 9) * nameScale)
            ON.Position=UDim2.new(0.5,0,0,(F=="Small") and -8 or -9)
            ON.Text=T
            ON.TextColor3=P or NC.Color; ON.TextTransparency=P and 0 or NC.Transparency
            ON.Visible=true
        end
    else SN.Visible=false; SN.Parent=nil; ON.Visible=false; ON.Parent=nil end

    do
        local OY=7
        if Flags["Esp Weapon"].Value and This.Weapon then
            local WC=Flags["Esp Weapon Color"]
            W.Parent=RF; W.Text=string.upper(This.Weapon.Name)
            W.TextColor3=P or WC.Color; W.TextTransparency=P and 0 or WC.Transparency
            W.Position=UDim2.new(0.5,0,1,OY); W.Visible=true; OY=OY+8
        else W.Visible=false; W.Parent=nil end

        if Flags["Esp Distance"].Value then
            local DC=Flags["Esp Distance Color"]
            D.Parent=RF; D.Text=math.ceil(This.Distance or 0).."M"
            D.TextColor3=P or DC.Color; D.TextTransparency=P and 0 or DC.Transparency
            D.Position=UDim2.new(0.5,0,1,OY); D.Visible=true; OY=OY+8
        else D.Visible=false; D.Parent=nil end

        if Flags["Esp Weapon Icon"].Value and This.Weapon then
            local Icon=ItemIcons[This.Weapon.Name]
            if Icon and Icon ~= "" then
                WI.Parent=RF; WI.Image=Icon
                WI.ImageTransparency=Flags["Esp Weapon Icon Color"].Transparency
                WI.Position=UDim2.new(0.5,-13,1,OY-3); WI.Visible=true
            else WI.Visible=false; WI.Parent=nil end
        else WI.Visible=false; WI.Parent=nil end
    end

    do
        local OY=0
        local EspFlags=ESP.Flags
        local Enabled=Flags["Esp Flags"].Value
        local FC=Flags["Esp Flags Color"]
        for i=1,#EspFlags do
            local Cache=EspFlags[i]; local Index=Cache[1]
            local Data=R.Flags[Index]
            if not Data then
                Data=ESP.DeepCopy(Cache[2]); R.Flags[Index]=Data
            end
            local Render=Data.Render
            if not Render then
                Render=ESP.Render("TextLabel",{
                    ZIndex=3, Text="", TextXAlignment="Left",
                    Visible=false, Position=UDim2.new(1,5,0,0),
                    TextTransparency=0, TextStrokeTransparency=0,
                    BackgroundTransparency=1,
                })
                Data.Render=Render
            end
            local FakeThis={
                Character=This.Character, Humanoid=This.Humanoid,
                RootPart=This.RootPart, SafeZone=This.SafeZone, Staff=This.Staff,
            }
            if Enabled and Data.GetVisibility(FakeThis) then
                local Color=Data.GetColor(FakeThis)
                Render.Parent=RF
                Render.Position=UDim2.new(1,5,0,OY)
                Render.Text=Data.GetText(FakeThis)
                Render.TextColor3=Color.Color
                Render.TextTransparency=Color.Transparency or FC.Transparency
                Render.Visible=true; OY=OY+8
            else
                Render.Visible=false; Render.Parent=nil
            end
        end
    end

    for i=1,#SkeletonJoints do
        local L=SK[i]
        if not Flags["Esp Skeleton"].Value then
            L.Visible=false
        else
            local A,B=SkeletonJoints[i][1],SkeletonJoints[i][2]
            local PA,PB=This.BodyParts[A],This.BodyParts[B]
            if not PA or not PB then
                L.Visible=false
            else
                local F,OnF=ESP.WorldToViewportPoint(PA.Position+(A=="UpperTorso" and Vector3.new(0,0.4,0) or Vector3.zero))
                local T2,OnT=ESP.WorldToViewportPoint(PB.Position+(B=="UpperTorso" and Vector3.new(0,0.4,0) or Vector3.zero))
                if not OnF and not OnT then
                    L.Visible=false
                else
                    L.Parent = ESP.Overlay
                    L.ZIndex = 3
                    local SC=Flags["Esp Skeleton Color"]
                    UpdateLine(L, Vector2.new(F.X,F.Y), Vector2.new(T2.X,T2.Y), P or SC.Color, 1-(P and 0 or SC.Transparency))
                end
            end
        end
    end
end

function ESP.RenderPlayerOffScreen(This, R, SK, Position)
    R.RenderFrame.Visible=false
    for i=1,#SK do SK[i].Visible=false; SK[i].Parent=nil end
    ESP.Parent(R)

    local ArrowHolder = R.OOVHolder
    local ArrowLeft   = R.OOVLeft
    local ArrowRight  = R.OOVRight
    local ArrowMiddle = R.OOVMiddle
    local SN,ON = R.ShadowName,R.OutlineName
    local W = R.Weapon
    local HI,HO = R.Health,R.HealthBack
    local D = R.Distance

    if Flags["Esp Oov"].Value then
        local Flag = Flags["Esp Oov Color"]
        local Blink = Flags["Esp Oov Blink"].Value
        local BS = Flags["Esp Oov Blink Speed"].Value
        local T = Blink and (math.sin(tick()*(4+BS))+1)/2 or Flag.Transparency
        local P = GetPriorityColor(This)
        if not Blink and P then T = 0 end

        local Rel = ESP.Camera.CFrame:PointToObjectSpace(Position)
        local Ang = math.atan2(-Rel.Y, Rel.X)
        local Dir = Vector2.new(math.cos(Ang), math.sin(Ang))

        local Radius = Flags["Esp Oov Dynamic Distance"].Value
            and math.clamp(10+(math.max(0,This.Distance)/150)*85,10,95)/400
            or Flags["Esp Oov Distance"].Value/400
        local Size = Flags["Esp Oov Dynamic Size"].Value
            and (40-math.clamp(10+(math.max(0,This.Distance)/150)*20,10,30))
            or Flags["Esp Oov Size"].Value

        local PA = (Dir*ESP.ScreenSize.X*Radius) + (ESP.ScreenSize/2)

        ArrowHolder.Parent = ESP.Overlay
        ArrowHolder.Visible = true

        local PA2, PB2, PC2
        if Flags["Esp Oov Style"].Value == "Concave" then
            PA2 = PA
            PB2 = PA - ESP.Rotate(Dir, 0.45)*Size
            PC2 = PA - ESP.Rotate(Dir, -0.45)*Size
            local PD = PA - ESP.Rotate(Dir, 0)*(Size/1.6)
            ArrowMiddle.Visible = true
            UpdateLine(ArrowMiddle, PB2, PD, P or Flag.Color, 1-T)
        else
            PA2 = PA
            PB2 = PA - ESP.Rotate(Dir, 0.5)*Size
            PC2 = PA - ESP.Rotate(Dir, -0.5)*Size
            ArrowMiddle.Visible = false
        end

        UpdateLine(ArrowLeft, PA2, PB2, P or Flag.Color, 1-T)
        UpdateLine(ArrowRight, PA2, PC2, P or Flag.Color, 1-T)

        local Elements = Flags["Esp Oov Elements"].Value
        local CenterX = PA.X
        local BottomY = PA.Y + Size
        local OY = 6

        if table.find(Elements, "Name") then
            local F = Flags["Esp Name Font"].Value
            local Txt = (F=="Small") and string.upper(This.Name) or This.Name
            local NC = Flags["Esp Name Color"]
            local nameScale = ComputeNameScale(This)
            if F=="Bold" then
                ON.Visible = false; ON.Parent = nil
                SN.Parent = ESP.Overlay
                SN.Position = UDim2.new(0, CenterX, 0, PA.Y - 12)
                SN.Text = Txt
                SN.TextColor3 = P or NC.Color
                SN.TextTransparency = T
                SN.TextSize = math.floor(9 * nameScale)
                SN.Visible = true
            else
                local FF = (F=="Regular") and ESP.Fonts["Sevasto"] or ESP.Fonts["Tiny5"]
                SN.Visible = false; SN.Parent = nil
                ON.Parent = ESP.Overlay
                pcall(function() ApplyFont(ON, FF) end)
                ON.TextSize = math.floor((FF.Size or 9) * nameScale)
                ON.Position = UDim2.new(0, CenterX, 0, PA.Y - ((F=="Small") and 14 or 12))
                ON.Text = Txt
                ON.TextColor3 = P or NC.Color
                ON.TextTransparency = T
                ON.Visible = true
            end
        end

        if table.find(Elements, "Health Bar") then
            local Hp = math.ceil(This.Health); local Percent = Hp/This.MaxHealth
            local SizeY = ESP.Lerp(HI.Size.Y.Scale, Percent, 0.1)
            HO.Parent = ESP.Overlay; HI.Parent = HO
            HI.Position = UDim2.new(0, 0, 1-SizeY, 0)
            HO.Position = UDim2.new(0, PA.X - 6, 0, PA.Y - 1)
            HI.Size = UDim2.new(0, 1.5, SizeY, 0)
            HO.Size = UDim2.new(0, 1.5, 0, Size)
            HI.BackgroundTransparency = T
            HO.BackgroundTransparency = T
            if P then
                R.HealthGradient.Enabled = false; HI.BackgroundColor3 = P
            else
                local C1 = Flags["Esp Health Color 1"].Color
                local C2 = Flags["Esp Health Color 2"].Color
                local HT2 = Flags["Esp Health Bar Type"].Value
                if HT2=="Static" then
                    R.HealthGradient.Enabled=false; R.HealthGradient.Parent=nil; HI.BackgroundColor3=C1
                elseif HT2=="Dynamic" then
                    R.HealthGradient.Enabled=false; R.HealthGradient.Parent=nil
                    HI.BackgroundColor3 = (C1==C2) and C1 or ESP.LerpColor(C2,C1,Percent)
                else
                    R.HealthGradient.Parent=HI; R.HealthGradient.Enabled=true
                    HI.BackgroundColor3=Theme.White
                    R.HealthGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, C1),
                        ColorSequenceKeypoint.new(1, C2),
                    })
                end
            end
            if Percent < 1 then
                R.HealthText.Parent = HI; R.HealthText.Text = Hp
                R.HealthText.TextColor3 = Color3.fromRGB(255,255,255)
                R.HealthText.TextTransparency = T
                R.HealthText.Visible = true
            else
                R.HealthText.Visible = false
            end
            HI.Visible = true; HO.Visible = true
        end

        if table.find(Elements, "Weapon") and This.Weapon then
            local WC = Flags["Esp Weapon Color"]
            W.Parent = ESP.Overlay
            W.Position = UDim2.new(0, CenterX, 0, BottomY + OY)
            W.Text = string.upper(This.Weapon.Name)
            W.TextColor3 = P or WC.Color
            W.TextTransparency = T
            W.Visible = true
            OY = OY + 8
        end

        if table.find(Elements, "Distance") then
            local DC = Flags["Esp Distance Color"]
            D.Parent = ESP.Overlay
            D.Position = UDim2.new(0, CenterX, 0, BottomY + OY)
            D.Text = math.ceil(This.Distance or 0).."M"
            D.TextColor3 = P or DC.Color
            D.TextTransparency = T
            D.Visible = true
        end
    else
        ArrowHolder.Visible = false
        SN.Visible = false; ON.Visible = false
        W.Visible = false; HI.Visible = false; HO.Visible = false; D.Visible = false
    end
end

function ESP.RenderChams(This)
    if not This.Renders then return end
    local Chams=This.Renders.Chams
    local BodyParts,Alive=This.BodyParts,This.Alive
    local Enabled=Flags["Chams Enabled"].Value
    local Glow=Flags["Glows Enabled"].Value
    local GlowSize=Flags["Glows Size"].Value
    local CC=Flags["Chams Color"]; local OC=Flags["Outline Color"]
    for i=1,#Chams do
        local D=Chams[i]; local Render,Name,IsOutline=D[1],D[2],D[3]
        local Part=BodyParts[Name]
        if not Part or not Alive then Render.Visible=false; Render.Adornee=nil; continue end
        Render.Adornee=Part; Render.Visible=Enabled
        if IsOutline then
            Render.Color3=OC.Color
            Render.Transparency=Glow and (OC.Transparency/GlowSize) or OC.Transparency
            Render.AlwaysOnTop=Alive and Glow
        else
            Render.Color3=CC.Color
            Render.Transparency=CC.Transparency
        end
    end
end

function ESP.RenderAllChams(InfoPlayers)
    for i=1,#InfoPlayers do ESP.RenderChams(InfoPlayers[i]) end
end

local Info = {}
Info.Players = {}
Info.LocalPlayer = {}

function Info.Add(plr)
    local IsLocal=(plr==LocalPlayer)
    local This={
        Player=plr, Name=plr.Name, IsLocalPlayer=IsLocal,
        Health=115, MaxHealth=115, Distance=0,
        Alive=false, Teammate=false, SafeZone=false,
        WeaponType="None", Weapon=nil,
        Whitelist=false, Priority=false, DisableEsp=false,
        LastRefresh=0, Cardinal=1,
        BodyParts={}, Inventory={},
        Friends="false", Staff="false",
        _SmoothX=nil, _SmoothY=nil, _SmoothW=nil, _SmoothH=nil,
        _SmoothNameScale=nil,
    }

    if IsLocal then Info.LocalPlayer=This end
    This.Renders=ESP.GetPlayerRenders(plr)
    Info.Players[#Info.Players+1]=This

    local function bindChar(char)
        local hum, root, d = nil, nil, nil
        if ESP.CharResolver then
            d = ESP.CharResolver(char)
            if d then
                hum, root = d.humanoid, d.root
                This.Health    = d.health or 0
                This.MaxHealth = d.maxHealth or 100
                This.Alive     = (d.alive ~= false)
            end
        else
            hum  = char:WaitForChild("Humanoid",10)
            root = char:WaitForChild("HumanoidRootPart",10)
            if hum then
                This.Health=hum.Health; This.MaxHealth=hum.MaxHealth; This.Alive=true
            end
        end
        if not root then return end
        This.Character=char; This.Humanoid=hum; This.RootPart=root
        table.clear(This.BodyParts); This.Weapon=nil
        local _partsSrc = (d and d.body) or char
        for _,Part in next, _partsSrc:GetChildren() do
            if Part:IsA("BasePart") and table.find(BodyPartNames,Part.Name) then
                This.BodyParts[Part.Name]=Part
            elseif Part:IsA("Tool") or (Part:IsA("Model") and Part:FindFirstChildOfClass("Tool")) then
                This.Weapon=Part
            end
        end
        if next(This.BodyParts) == nil then
            for _,Part in next, _partsSrc:GetChildren() do
                if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" then
                    This.BodyParts[Part.Name]=Part
                end
            end
        end

        _partsSrc.ChildAdded:Connect(function(Part)
            if Part:IsA("BasePart") and table.find(BodyPartNames,Part.Name) then
                This.BodyParts[Part.Name]=Part
            elseif Part:IsA("Tool") or (Part:IsA("Model") and Part:FindFirstChildOfClass("Tool")) then
                This.Weapon=Part
            end
        end)
        _partsSrc.ChildRemoved:Connect(function(Part)
            if Part:IsA("BasePart") and This.BodyParts[Part.Name] then
                This.BodyParts[Part.Name]=nil
            elseif This.Weapon==Part then
                This.Weapon=nil
            end
        end)
        if hum then
            hum.HealthChanged:Connect(function(h)
                This.Health=h; This.MaxHealth=hum.MaxHealth
                if h<=0 then This.Alive=false end
            end)
        end
    end

    if plr.Character then bindChar(plr.Character) end
    plr.CharacterAdded:Connect(bindChar)
    plr.CharacterRemoving:Connect(function()
        This.Alive=false; This.Health=0; This.Character=nil
        This.Humanoid=nil; This.RootPart=nil; table.clear(This.BodyParts)
        This._SmoothX=nil; This._SmoothY=nil; This._SmoothW=nil; This._SmoothH=nil
        This._SmoothNameScale=nil
    end)

    if not IsLocal then
        task.spawn(function()
            pcall(function()
                This.Friends=plr:IsFriendsWith(LocalPlayer.UserId) and "true" or "false"
            end)
        end)
    end
end

function Info.Remove(plr)
    if plr==LocalPlayer then return end
    for i,This in next, Info.Players do
        if This.Player==plr then
            local R=This.Renders
            for k,v in next, R do
                if k=="Skeleton" then
                    for _,l in next, v do if typeof(l)=="Instance" then l:Destroy() end end
                elseif k=="Chams" then
                    for _,c in next, v do c[1]:Destroy() end
                elseif k=="Flags" then
                    for _,f in next, v do if f.Render then f.Render:Destroy() end end
                elseif k=="CornerH" or k=="CornerV" then
                    for _,c in next, v do if typeof(c)=="Instance" then c:Destroy() end end
                elseif k=="OOVLeft" or k=="OOVRight" or k=="OOVMiddle" then
                    if typeof(v)=="Instance" then v:Destroy() end
                elseif typeof(v)=="Instance" then
                    v:Destroy()
                end
            end
            table.remove(Info.Players,i); return
        end
    end
end

local function _RemovedTrack(container, Type, buildRenders, nameFn, typeFn, rootFn)
    local list={}
    local function add(child)
        if not child:IsA("Model") then return end
        local This={
            _Type=Type,
            Name=nameFn and nameFn(child) or child.Name,
            Type=typeFn and typeFn(child) or nil,
            Character=child,
            RootPart=rootFn and rootFn(child) or child.PrimaryPart,
            Renders=buildRenders(),
            Health=child:GetAttribute("Health") or 0,
            Distance=0, LastRefresh=0, Cardinal=1,
        }
        This.Renders._Color=Flags["Esp "..Type.." Color"].Color
        This.Renders._ColorT=Flags["Esp "..Type.." Color"].Transparency
        This.Renders._Distance=Flags["Esp "..Type.." Distance"].Value
        This.Renders._DistanceColor=Flags["Esp "..Type.." Distance Color"].Color
        list[#list+1]=This
    end
    for _,c in next, container:GetChildren() do add(c) end
    container.ChildAdded:Connect(add)
    container.ChildRemoved:Connect(function(c)
        for i=#list,1,-1 do
            if list[i].Character==c then
                for _,r in next, list[i].Renders do
                    if typeof(r)=="Instance" then r:Destroy() end
                end
                table.remove(list,i)
            end
        end
    end)
    return list
end

function ESP.Step()
    local RI={}
    local now=os.clock()
    local camPos = ESP.Camera.CFrame.Position

    for i=1,#Info.Players do
        local This=Info.Players[i]; local R=This.Renders
        if ESP.CharResolver and This.Character then
            local d = ESP.CharResolver(This.Character)
            if d then
                This.Health    = d.health or This.Health
                This.MaxHealth = d.maxHealth or This.MaxHealth
                This.Alive     = (d.alive ~= false)
                if d.root then This.RootPart = d.root end
            end
        end
        local Hide = (not ESP.Enabled)
            or (not This.RootPart) or This.DisableEsp
            or ((not This.Alive) and (not ESP.ShowDead))
            or (This.IsLocalPlayer and (not ESP.TrackSelf))
            or ((camPos - This.RootPart.Position).Magnitude > Flags["Esp Max Distance"].Value)
            or (ESP.TeamCheck and ESP.TeamResolver and ESP.TeamResolver(This.Player))
        if Hide then
            R.RenderFrame.Visible=false
            R.OOVHolder.Visible=false
            for k=1,#R.Skeleton do R.Skeleton[k].Visible=false; R.Skeleton[k].Parent=nil end
            ESP.Parent(R)
        else
            This.Distance = (camPos - This.RootPart.Position).Magnitude
            This.OverrideColor = ESP.ColorResolver and ESP.ColorResolver(This.Player) or nil
            if ESP.NameResolver then This.Name = ESP.NameResolver(This.Player) or This.Name end
            if ESP.WeaponResolver then This.Weapon = ESP.WeaponResolver(This.Player) end
            local BoundingType=Flags["Esp Bounding Type"].Value
            local BP,BS=ESP.GetBoundingBox(This,This.RootPart.Position,BoundingType)
            if BP then RI[#RI+1]={"Player",This,R,BP,BS}
            else ESP.RenderPlayerOffScreen(This,R,R.Skeleton,This.RootPart.Position) end
        end
    end

    for i=1,#RI do
        local R=RI[i]
        if typeof(R[3].RenderFrame)=="Instance" then
            R[3].RenderFrame.ZIndex=math.floor(100000-(R[2].Distance or 0))
        end
        if R[1]=="Player" then ESP.RenderPlayerOnScreen(R[2],R[3],R[4],R[5]) end
    end
end

function ESP.RegisterFlag(Name, Data)
    ESP.Flags[#ESP.Flags+1]={Name,Data}
end

function ESP.DeRegisterFlag(Name)
    for i=#ESP.Flags,1,-1 do
        if ESP.Flags[i][1]==Name then table.remove(ESP.Flags,i) end
    end
    for _,This in next, Info.Players do
        if This.Renders and This.Renders.Flags[Name] then
            local f=This.Renders.Flags[Name]
            if f.Render then f.Render:Destroy() end
            This.Renders.Flags[Name]=nil
        end
    end
end

local function SyncCamera()
    local c = Workspace.CurrentCamera
    if c then
        ESP.Camera = c
        ESP.ScreenSize = c.ViewportSize
    end
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(SyncCamera)

function ESP.Init()
    SyncCamera()
    if ESP.Overlay then return ESP end
    ESP.Overlay=Instance.new("ScreenGui")
    ESP.Overlay.Name="ESP_Overlay"
    ESP.Overlay.ResetOnSpawn=false
    ESP.Overlay.IgnoreGuiInset=true
    ESP.Overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    ESP.Overlay.Parent=PlayerGui

    for _,plr in next, Players:GetPlayers() do Info.Add(plr) end
    Players.PlayerAdded:Connect(Info.Add)
    Players.PlayerRemoving:Connect(Info.Remove)

    RunService.RenderStepped:Connect(function()
        SyncCamera()
        ESP.Step()
    end)
    return ESP
end

function ESP.SetFlags(t)
    for k, v in next, t do
        if Flags[k] then
            if type(v) == "table" then
                for kk, vv in next, v do Flags[k][kk] = vv end
            else
                Flags[k].Value = v
            end
        end
    end
end

return ESP
end)()

v:Localization({
	Enabled = true,
	Prefix = "loc:",
	DefaultLanguage = "zh-cn",
	Translations = {
		["zh-cn"] = {
			WINDUI_EXAMPLE = "Sv.Sm.Op.Loy",
			WELCOME = "欢迎使用 FL",
			LIB_DESC = "一体化辅助",
			SETTINGS = "设置",
			APPEARANCE = "外观",
			FEATURES = "功能",
			UTILITIES = "工具",
			UI_ELEMENTS = "UI 元素",
			CONFIGURATION = "配置",
			SAVE_CONFIG = "保存配置",
			LOAD_CONFIG = "加载配置",
			THEME_SELECT = "选择主题",
			TRANSPARENCY = "窗口透明度",
		},
	},
})

v.TransparencyValue = 0.2

FL_AC = {
	Enabled = true,
	BlockReports = true,
	TagUIATC = true,
	RulesOverride = true,
	SafeTeleport = true,
	GuardCheckpoint = true,
	CombatBlock = false,
	NoFallDamage = false,
	BlockPrisonPull = false,
	LaserImmune = false,
	BlockVehicleCollision = true,
	PivotBypass = false,
	PrisonBlocks = 0,
	CombatBlocks = 0,
	FallBlocks = 0,
	LaserBlocks = 0,
	VehicleCollisionBlocks = 0,
	RecordVerbs = true,
	RecordAllRemotes = false,
	VerbLog = {},
	Core = nil,
	MaxCPStudsPerSec = 240,
	PlayerEvent = nil,
	GameRules = nil,
	Algorithms = nil,
	Orig = {},
	OurNamecall = nil,
	OurFireServer = nil,
	WatchdogOn = false,
	SelfChecks = 0,
	SelfHeals = 0,
	HiddenGlobals = 0,
	SweepOn = false,
	SweepThread = nil,
	SweepGen = 0,
	ReportCount = 0,
	Booted = false,
	LastCPPos = nil,
	LastCPTime = nil,
	CPRewrites = 0,
	MoverClasses = {
		BodyPosition = true,
		BodyGyro = true,
		BodyVelocity = true,
		BodyAngularVelocity = true,
		BodyForce = true,
		BodyThrust = true,
		RocketPropulsion = true,
		AlignPosition = true,
		AlignOrientation = true,
		LinearVelocity = true,
		AngularVelocity = true,
		VectorForce = true,
		Torque = true,
		LineForce = true,
		SelectionBox = true,
	},
	DropVerbs = {
		miscB = true,
		violation = true,
		developmentLogs3 = true,
	},
}

FL_AC.API = {
	getrawmetatable   = getrawmetatable,
	setreadonly       = setreadonly,
	getnamecallmethod = getnamecallmethod,
	setnamecallmethod = setnamecallmethod,
	hookfunction      = hookfunction,
	getgenv           = getgenv,
}

function FL_AC.TagCharacter()
	local players = game:GetService("Players")
	local plr = players and players.LocalPlayer
	local char = plr and plr.Character
	if not char then
		return 0
	end

	local tagged = 0
	local ok = pcall(function()
		for _, d in ipairs(char:GetDescendants()) do
			if FL_AC.MoverClasses[d.ClassName] and not d:GetAttribute("UIATC") then
				if pcall(function()
					d:SetAttribute("UIATC", true)
				end) then
					tagged = tagged + 1
				end
			end
		end
	end)

	if not ok then
		return 0
	end
	return tagged
end

function FL_AC.StartSweep()
	if FL_AC.SweepOn then
		return
	end
	FL_AC.SweepOn = true
	local gen = (FL_AC.SweepGen or 0) + 1
	FL_AC.SweepGen = gen
	FL_AC.SweepThread = task.spawn(function()
		while FL_AC.SweepOn and FL_AC.SweepGen == gen do
			if FL_AC.Enabled and FL_AC.TagUIATC then
				pcall(FL_AC.TagCharacter)
			end
			pcall(FL_AC.VerifyHooks)
			task.wait(1)
		end
		if FL_AC.SweepGen == gen then
			FL_AC.SweepThread = nil
		end
	end)
end

function FL_AC.HookGameRules()
	if not FL_AC.Enabled or not FL_AC.RulesOverride then
		return false
	end

	local rules = FL_AC.GameRules
	if not rules then
		local ok, r = pcall(function()
			return require(game:GetService("ReplicatedStorage").Modules.GameRules)
		end)
		if not ok or type(r) ~= "table" then
			return false
		end
		rules = r
		FL_AC.GameRules = rules
		FL_AC.Orig.disableAntiCheat = rules.disableAntiCheat
		FL_AC.Orig.disableHacking = rules.disableHacking
		FL_AC.Orig.antiCheatTypeStartLevelBan = rules.antiCheatTypeStartLevelBan
		FL_AC.Orig.antiCheatLevelReductionTimeInDays = rules.antiCheatLevelReductionTimeInDays
	end

	pcall(function()
		rules.disableAntiCheat = true
		rules.disableHacking = true
		rules.antiCheatTypeStartLevelBan = {
			lessReliable = { newAccount = 1, oldAccount = 1, priority = 1 },
			exploit = { newAccount = 1, oldAccount = 1, priority = 1 },
		}
		rules.antiCheatLevelReductionTimeInDays = 1
	end)

	return true
end

function FL_AC.RestoreGameRules()
	local rules = FL_AC.GameRules
	if not rules then
		return
	end
	pcall(function()
		rules.disableAntiCheat = FL_AC.Orig.disableAntiCheat
		rules.disableHacking = FL_AC.Orig.disableHacking
		rules.antiCheatTypeStartLevelBan = FL_AC.Orig.antiCheatTypeStartLevelBan
		rules.antiCheatLevelReductionTimeInDays = FL_AC.Orig.antiCheatLevelReductionTimeInDays
	end)
end

function FL_AC.IsLaserDamage(...)
	local n = select("#", ...)
	if n < 1 then
		return false
	end
	local last = select(n, ...)
	if typeof(last) == "Instance" and last.Name == "_Laser" then
		return true
	end
	return false
end

function FL_AC.HookReports()
	if FL_AC.Orig.namecall or FL_AC.Orig.fireServer then
		return true
	end

	local okPE, pe = pcall(function()
		local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote", 5)
		if not remote then
			return nil
		end
		return remote:WaitForChild("PlayerEvent", 5)
	end)
	if not okPE or typeof(pe) ~= "Instance" then
		return false
	end
	FL_AC.PlayerEvent = pe

	local okMT, mt = pcall(FL_AC.API.getrawmetatable, game)
	if okMT and type(mt) == "table" then
		local oldNamecall = rawget(mt, "__namecall")
		if type(oldNamecall) == "function" then
			local okRO = pcall(FL_AC.API.setreadonly, mt, false)
			local okSet = pcall(function()
				mt.__namecall = function(self, ...)
					if FL_AC.Enabled and FL_AC.CombatBlock
						and FL_AC.API.getnamecallmethod() == "FireServer"
						and select(1, ...) == "combatMode" then
						FL_AC.CombatBlocks = FL_AC.CombatBlocks + 1
						return nil
					end
					if FL_AC.Enabled and FL_AC.RecordAllRemotes
						and self ~= FL_AC.PlayerEvent
						and FL_AC.API.getnamecallmethod() == "FireServer" then
						local v0 = select(1, ...)
						if type(v0) == "string" then
							local nm = (typeof(self) == "Instance") and self.Name or "?"
							local key = nm .. ":" .. v0
							FL_AC.VerbLog[key] = (FL_AC.VerbLog[key] or 0) + 1
						end
					end
					if self == FL_AC.PlayerEvent and FL_AC.API.getnamecallmethod() == "FireServer" then
						local verb = select(1, ...)
						if FL_AC.RecordVerbs then
							FL_AC.VerbLog[verb] = (FL_AC.VerbLog[verb] or 0) + 1
						end
						if FL_AC.OnBullet ~= nil and verb == "bullet" then
							pcall(FL_AC.OnBullet, select(2, ...))
						end
						if FL_AC.Enabled and FL_AC.NoFallDamage and verb == "takeDamage" then
							FL_AC.FallBlocks = FL_AC.FallBlocks + 1
							return nil
						end
						if FL_AC.Enabled and FL_AC.LaserImmune and verb == "takeDamage"
							and FL_AC.IsLaserDamage(select(2, ...)) then
							FL_AC.LaserBlocks = FL_AC.LaserBlocks + 1
							return nil
						end
						if FL_AC.Enabled and FL_AC.BlockVehicleCollision
							and verb == "vehicle" and select(2, ...) == "collision" then
							FL_AC.VehicleCollisionBlocks = FL_AC.VehicleCollisionBlocks + 1
							return nil
						end
						if FL_AC.ShouldDrop(verb) then
							return nil
						end
						if FL_AC.GuardCheckpoint and verb == "charCheckpoint" then
							local out = FL_AC.FilterCheckpoint(select(2, ...))
							if out == false then
								return nil
							end
							if out ~= nil then
								return oldNamecall(self, verb, out)
							end
						end
					end
					return oldNamecall(self, ...)
				end
			end)
			if okSet then
				if okRO then
					pcall(FL_AC.API.setreadonly, mt, true)
				end
				FL_AC.Orig.namecallMT = mt
				FL_AC.Orig.namecall = oldNamecall
				FL_AC.OurNamecall = rawget(mt, "__namecall")
				return true
			end
		end
	end

	if type(FL_AC.API.hookfunction) == "function" then
		local okHook, tramp = pcall(function()
			local orig = pe.FireServer
			local t
			t = FL_AC.API.hookfunction(orig, function(self, verb, ...)
				if FL_AC.RecordVerbs then
					FL_AC.VerbLog[verb] = (FL_AC.VerbLog[verb] or 0) + 1
				end
				if FL_AC.Enabled and FL_AC.CombatBlock and verb == "combatMode" then
					FL_AC.CombatBlocks = FL_AC.CombatBlocks + 1
					return nil
				end
				if FL_AC.OnBullet ~= nil and verb == "bullet" then
					pcall(FL_AC.OnBullet, ...)
				end
				if FL_AC.Enabled and FL_AC.NoFallDamage and verb == "takeDamage" then
					FL_AC.FallBlocks = FL_AC.FallBlocks + 1
					return nil
				end
				if FL_AC.Enabled and FL_AC.LaserImmune and verb == "takeDamage"
					and FL_AC.IsLaserDamage(...) then
					FL_AC.LaserBlocks = FL_AC.LaserBlocks + 1
					return nil
				end
				if FL_AC.Enabled and FL_AC.BlockVehicleCollision
					and verb == "vehicle" and select(1, ...) == "collision" then
					FL_AC.VehicleCollisionBlocks = FL_AC.VehicleCollisionBlocks + 1
					return nil
				end
				if FL_AC.ShouldDrop(verb) then
					return nil
				end
				if FL_AC.GuardCheckpoint and verb == "charCheckpoint" then
					local out = FL_AC.FilterCheckpoint(...)
					if out == false then
						return nil
					end
					if out ~= nil then
						return t(self, verb, out)
					end
				end
				return t(self, verb, ...)
			end)
			return t
		end)
		if okHook and type(tramp) == "function" then
			FL_AC.Orig.fireServer = tramp
			FL_AC.OurFireServer = pe.FireServer
			return true
		end
	end

	return false
end

function FL_AC.VerifyHooks()
	if not FL_AC.Enabled then
		return
	end
	if FL_AC.OurNamecall then
		local ok, mt = pcall(FL_AC.API.getrawmetatable, game)
		if ok and type(mt) == "table" then
			if rawget(mt, "__namecall") ~= FL_AC.OurNamecall then
				FL_AC.Orig.namecall = nil
				FL_AC.Orig.namecallMT = nil
				FL_AC.OurNamecall = nil
				pcall(FL_AC.HookReports)
			end
		end
	end
	if FL_AC.OurFireServer then
		local pe = FL_AC.PlayerEvent
		if pe and pe.FireServer ~= FL_AC.OurFireServer then
			FL_AC.Orig.fireServer = nil
			FL_AC.OurFireServer = nil
			pcall(FL_AC.HookReports)
		end
	end
end

function FL_AC.SelfCheck()
	if not FL_AC.Enabled then
		return
	end
	FL_AC.SelfChecks = FL_AC.SelfChecks + 1

	if FL_AC.RulesOverride then
		local g = FL_AC.GameRules
		if not g or g.disableAntiCheat ~= true or g.disableHacking ~= true then
			FL_AC.SelfHeals = FL_AC.SelfHeals + 1
			pcall(FL_AC.HookGameRules)
		end
	end

	if FL_AC.OurNamecall or FL_AC.OurFireServer then
		pcall(FL_AC.VerifyHooks)
	else
		FL_AC.SelfHeals = FL_AC.SelfHeals + 1
		pcall(FL_AC.HookReports)
	end

	if not FL_AC.Orig.charPivotTo then
		FL_AC.SelfHeals = FL_AC.SelfHeals + 1
		pcall(FL_AC.HookPivot)
	end

	if not FL_AC.SweepOn then
		FL_AC.SelfHeals = FL_AC.SelfHeals + 1
		pcall(FL_AC.StartSweep)
	end

	pcall(FL_AC.HideExecutor)
end

function FL_AC.VerbReport()
	local list = {}
	for k, v in pairs(FL_AC.VerbLog) do
		list[#list + 1] = { k = k, v = v }
	end
	table.sort(list, function(a, b) return a.v > b.v end)
	local out = {}
	for i = 1, math.min(#list, 18) do
		out[#out + 1] = string.format("%s×%d", tostring(list[i].k), list[i].v)
	end
	if #out == 0 then
		return "（还没记录到）"
	end
	return table.concat(out, "  ")
end

function FL_AC.HideExecutor()
	local NILED = {
		"identifyexecutor", "getexecutorname", "getexploit",
		"iscclosure", "islclosure", "newcclosure", "checkcaller",
		"getscriptclosure", "getloadedmodules", "getinstances", "getnilinstances", "getgc",
		"getreg", "getupvalue", "getupvalues", "setupvalue",
		"getsenv", "getscripthash", "getfunctionhash",
		"getconnections", "firesignal", "fireclickdetector", "firetouchinterest",
		"getrawmetatable", "setreadonly", "getnamecallmethod", "setnamecallmethod",
		"hookfunction",
		"syn", "KRNL_LOADED", "is_sirhurt_closure", "secure_load",
	}
	FL_AC.HiddenGlobals = 0
	local function scrub(t)
		if type(t) ~= "table" then return end
		for _, k in ipairs(NILED) do
			local ok, cur = pcall(rawget, t, k)
			if ok and cur ~= nil then
				if pcall(function() t[k] = nil end) then
					FL_AC.HiddenGlobals = FL_AC.HiddenGlobals + 1
				end
			end
		end
	end
	pcall(function()
		if type(FL_AC.API.getgenv) == "function" then
			scrub(FL_AC.API.getgenv())
		end
	end)
	pcall(function() scrub(_G) end)
	pcall(function() scrub(shared) end)
end

function FL_AC.StartWatchdog()
	if FL_AC.WatchdogOn then
		return
	end
	FL_AC.WatchdogOn = true
	task.spawn(function()
		while FL_AC.Enabled do
			pcall(FL_AC.SelfCheck)
			task.wait(1)
		end
		FL_AC.WatchdogOn = false
	end)
end

function FL_AC.ShouldDrop(verb)
	if not FL_AC.Enabled or not FL_AC.BlockReports then
		return false
	end
	if type(verb) ~= "string" or not FL_AC.DropVerbs[verb] then
		return false
	end
	FL_AC.ReportCount = FL_AC.ReportCount + 1
	return true
end

function FL_AC.FilterCheckpoint(pos)
	if not FL_AC.Enabled then
		return nil
	end
	if typeof(pos) ~= "Vector3" then
		return nil
	end

	local now = os.clock()
	local last, lastT = FL_AC.LastCPPos, FL_AC.LastCPTime

	if not last or not lastT then
		FL_AC.LastCPPos, FL_AC.LastCPTime = pos, now
		return nil
	end

	local dt = now - lastT
	if dt <= 0 or dt > 120 then
		FL_AC.LastCPPos, FL_AC.LastCPTime = pos, now
		return nil
	end

	local delta = pos - last
	local dist = delta.Magnitude
	local cap = FL_AC.MaxCPStudsPerSec * dt

	if dist <= cap or dist <= 0 then
		FL_AC.LastCPPos, FL_AC.LastCPTime = pos, now
		return nil
	end

	local clamped = last + delta.Unit * cap
	FL_AC.LastCPPos, FL_AC.LastCPTime = clamped, now
	FL_AC.CPRewrites = FL_AC.CPRewrites + 1
	return clamped
end

function FL_AC.UnhookReports()
	local mt = FL_AC.Orig.namecallMT
	if mt and FL_AC.Orig.namecall then
		pcall(function()
			pcall(FL_AC.API.setreadonly, mt, false)
			mt.__namecall = FL_AC.Orig.namecall
			pcall(FL_AC.API.setreadonly, mt, true)
		end)
	end
	FL_AC.Orig.namecall = nil
	FL_AC.Orig.namecallMT = nil
	FL_AC.OurNamecall = nil
	FL_AC.OurFireServer = nil
end

function FL_AC.HookPivot()
	if FL_AC.Orig.charPivotTo then
		return true
	end
	local ok, mod = pcall(function()
		return require(game:GetService("ReplicatedStorage").Modules.Algorithms)
	end)
	if not ok or type(mod) ~= "table" or type(mod.charPivotTo) ~= "function" then
		return false
	end

	FL_AC.Algorithms = mod
	local raw = mod.charPivotTo
	FL_AC.Orig.charPivotTo = raw

	mod.charPivotTo = function(...)
		if FL_AC.PivotBypass then
			return raw(...)
		end
		if FL_AC.Enabled and FL_AC.BlockPrisonPull then
			FL_AC.PrisonBlocks = FL_AC.PrisonBlocks + 1
			return nil
		end
		return raw(...)
	end

	return true
end

function FL_AC.UnhookPivot()
	local mod = FL_AC.Algorithms
	if mod and FL_AC.Orig.charPivotTo then
		pcall(function()
			mod.charPivotTo = FL_AC.Orig.charPivotTo
		end)
	end
	FL_AC.Orig.charPivotTo = nil
end

function FL_AC.HookNotify()
	if FL_AC.Orig.notify then
		return true
	end
	local ok, core = pcall(function()
		local plr = game:GetService("Players").LocalPlayer
		local ps = plr:WaitForChild("PlayerScripts", 15)
		local fw = ps:WaitForChild("Framework", 15)
		return require(fw:WaitForChild("Core", 15))
	end)
	if not ok or type(core) ~= "table" or type(core.notify) ~= "function" then
		return false
	end

	FL_AC.Core = core
	local raw = core.notify
	FL_AC.Orig.notify = raw

	core.notify = function(arg)
		if FL_AC.Enabled and FL_AC.BlockPrisonPull and type(arg) == "table"
			and type(arg.message) == "string"
			and string.find(arg.message, "You can't leave prison yet", 1, true) then
			return nil
		end
		return raw(arg)
	end

	return true
end

function FL_AC.UnhookNotify()
	local core = FL_AC.Core
	if core and FL_AC.Orig.notify then
		pcall(function()
			core.notify = FL_AC.Orig.notify
		end)
	end
	FL_AC.Orig.notify = nil
end

function FL_AC.SetPrisonPull(on)
	FL_AC.BlockPrisonPull = on and true or false
	if FL_AC.BlockPrisonPull then
		pcall(FL_AC.HookPivot)
		pcall(FL_AC.HookNotify)
	end
	return FL_AC.BlockPrisonPull
end

function FL_AC.SafePivot(pos)
	if not FL_AC.Enabled or not FL_AC.SafeTeleport then
		return false
	end

	if not FL_AC.Algorithms or not FL_AC.Orig.charPivotTo then
		if not FL_AC.HookPivot() then
			return false
		end
	end
	if type(FL_AC.Algorithms) ~= "table" or type(FL_AC.Algorithms.charPivotTo) ~= "function" then
		return false
	end

	local players = game:GetService("Players")
	local plr = players and players.LocalPlayer
	local char = plr and plr.Character
	if not char then
		return false
	end

	FL_AC.PivotBypass = true
	local ok = pcall(function()
		FL_AC.Algorithms.charPivotTo(char, CFrame.new(pos), nil, { ignoreServer = true })
	end)
	FL_AC.PivotBypass = false
	return ok
end

function FL_AC.SafePivotCF(cf)
	if not FL_AC.Enabled or not FL_AC.SafeTeleport then
		return false
	end
	if not FL_AC.Algorithms or not FL_AC.Orig.charPivotTo then
		if not FL_AC.HookPivot() then
			return false
		end
	end
	if type(FL_AC.Algorithms) ~= "table" or type(FL_AC.Algorithms.charPivotTo) ~= "function" then
		return false
	end
	local players = game:GetService("Players")
	local plr = players and players.LocalPlayer
	local char = plr and plr.Character
	if not char then
		return false
	end
	FL_AC.PivotBypass = true
	local ok = pcall(function()
		FL_AC.Algorithms.charPivotTo(char, cf, nil, { ignoreServer = true })
	end)
	FL_AC.PivotBypass = false
	return ok
end

function FL_AC.Init()
	pcall(FL_AC.HookGameRules)
	pcall(FL_AC.HookReports)
	pcall(FL_AC.HookPivot)
	pcall(FL_AC.StartSweep)
	pcall(FL_AC.HideExecutor)
end

function FL_AC.RetryLoop(fn)
	task.spawn(function()
		local delay = 0.05
		for _ = 1, 140 do
			local ok, done = pcall(fn)
			if ok and done then
				return
			end
			task.wait(delay)
			if delay < 1 then
				delay = math.min(delay * 1.5, 1)
			end
		end
	end)
end

function FL_AC.Boot()
	if FL_AC.Booted then
		return
	end
	FL_AC.Booted = true

	FL_AC.Init()

	FL_AC.StartWatchdog()

	FL_AC.RetryLoop(FL_AC.HookGameRules)
	FL_AC.RetryLoop(FL_AC.HookReports)
	FL_AC.RetryLoop(FL_AC.HookPivot)
end

function FL_AC.Restore()
	FL_AC.SweepOn = false
	FL_AC.LastCPPos, FL_AC.LastCPTime = nil, nil
	FL_AC.PivotBypass = false
	FL_AC.RestoreGameRules()
	FL_AC.UnhookReports()
	FL_AC.UnhookPivot()
	FL_AC.UnhookNotify()
end

function FL_AC.Status()
	local rules = "未接管"
	if FL_AC.GameRules then
		rules = tostring(FL_AC.GameRules.disableAntiCheat) .. "/" .. tostring(FL_AC.GameRules.disableHacking)
	end

	local reports = "未接管"
	if FL_AC.Orig.fireServer then
		reports = "hookfunction"
	elseif FL_AC.Orig.namecall then
		reports = "__namecall"
	end

	return string.format(
		"开关=%s 上报=%s(已拦%d) GameRules=%s 打标=%s 安全瞬移=%s 心跳守护=%s(已改写%d) 战斗拦截=%s(%d) 防摔伤=%s(%d) 防越狱=%s(%d) 激光免疫=%s(%d) 撞车拦截=%s(%d)",
		tostring(FL_AC.Enabled),
		reports,
		FL_AC.ReportCount,
		rules,
		tostring(FL_AC.TagUIATC),
		tostring(FL_AC.SafeTeleport),
		tostring(FL_AC.GuardCheckpoint),
		FL_AC.CPRewrites,
		tostring(FL_AC.CombatBlock),
		FL_AC.CombatBlocks,
		tostring(FL_AC.NoFallDamage),
		FL_AC.FallBlocks,
		tostring(FL_AC.BlockPrisonPull),
		FL_AC.PrisonBlocks,
		tostring(FL_AC.LaserImmune),
		FL_AC.LaserBlocks,
		tostring(FL_AC.BlockVehicleCollision),
		FL_AC.VehicleCollisionBlocks
	) .. string.format(" | 自检=%d(补%d) | 抹全局=%d", FL_AC.SelfChecks, FL_AC.SelfHeals,
		FL_AC.HiddenGlobals or 0)
end

FL_AC.Boot()

if game:GetService("UserInputService").TouchEnabled then
end

local Players = game:GetService("Players")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local tbl2 = {
	HoldTime = 0,
	Distance = 25,
	HitboxEnabled = false,
	HitboxSize = 10,
	WhitelistEnabled = false,
	TeleportEnabled = false,
	NoclipEnabled = false,
	AimEnabled = false,
	AimSmoothness = 5,
	AimMaxDistance = 200,
	AimCheckWall = true,
	BulletTrackEnabled = false,
	ScreenMode = true,
	DistanceMode = false,
	SkeletonEnabled = false,
	TaxiEnabled = false,
	TaxiWaitTime = 7,
	NoDizziness = false,
	NoDizzinessSpeed = 24,
	AutoBusEnabled = false,
	AutoJobEnabled = false,
	AutoATMHack = false,
	AutoAllHack = false,
	AutoArrestWantedEnabled = false,
	AutoArrestWantedInterval = 1.5,
	AntiPolicePushEnabled = false,
	TrafficLightWantedEnabled = false,
}

local v3 = cloneref(game:GetService("Workspace"))
local v4 = cloneref(game:GetService("RunService"))
local v5 = cloneref(game:GetService("Players"))

local ESP_UI = {
	Enabled   = false,
	Box       = true,
	BoxMode   = "Full",
	BoxThick  = 2,
	Info      = true,
	Distance  = true,
	Weapon    = true,
	Highlight = false,
	TeamCheck = false,
	TrackSelf = false,
	ShowDead  = false,
	MaxDist   = 1200,
	Stars     = true,
	Faction   = true,
}

local _BODY_NAMES = {
	"Head","UpperTorso","LowerTorso",
	"RightUpperArm","RightLowerArm","RightHand",
	"LeftUpperArm","LeftLowerArm","LeftHand",
	"RightUpperLeg","RightLowerLeg","RightFoot",
	"LeftUpperLeg","LeftLowerLeg","LeftFoot",
}
ESP.CharResolver = function(char)
	if not char or not char.Parent then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
		or char:FindFirstChildOfClass("AnimationController")
	local root = char:FindFirstChild("HumanoidRootPart")
		or char.PrimaryPart
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
	if not root then return nil end

	local visible = false
	for _, n in ipairs(_BODY_NAMES) do
		local p = char:FindFirstChild(n)
		if p and p:IsA("BasePart")
			and p.Transparency < 1 and p.LocalTransparencyModifier < 1 then
			visible = true
			break
		end
	end

	local hp, mx, isAlive = 100, 100, true
	if hum and hum:IsA("Humanoid") then
		hp = tonumber(hum.Health) or 100
		mx = tonumber(hum.MaxHealth) or 100
		isAlive = hp > 0
	end
	if not visible then isAlive = false end

	return {
		humanoid = hum, root = root, body = char,
		health = hp, maxHealth = mx, alive = isAlive,
	}
end

ESP.TeamResolver = function(player)
	if not ESP_UI.TeamCheck then return false end
	local me = LocalPlayer
	if not me or not player or me == player then return false end
	local a, b = me.Team, player.Team
	if not a or not b then return false end
	return a == b
end

ESP.NameResolver = function(player)
	local name = player.DisplayName
	if not name or name == "" then name = player.Name end
	local parts = {}
	if ESP_UI.Faction then
		parts[#parts + 1] = (player.Team and player.Team.Name) or "?"
	end
	parts[#parts + 1] = name
	if ESP_UI.Stars then
		local lvl = tonumber(player:GetAttribute("WantedLevel")) or 0
		if lvl > 0 then
			parts[#parts + 1] = string.rep("*", math.min(lvl, 6))
		end
	end
	return table.concat(parts, " ")
end

ESP.WeaponResolver = function(player)
	local char = player.Character
	if not char then return nil end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then return tool end
	return nil
end

ESP.Enabled   = ESP_UI.Enabled
ESP.TrackSelf = ESP_UI.TrackSelf
ESP.ShowDead  = ESP_UI.ShowDead
ESP.SetFlags({
	["Esp Box"]            = ESP_UI.Box,
	["Esp Box Fill"]       = ESP_UI.Box,
	["Esp Box Style"]      = ESP_UI.BoxMode,
	["Esp Box Thickness"]  = ESP_UI.BoxThick,
	["Esp Box Color"]      = { Color = ESP.Theme.PurpleLight },
	["Esp Box Fill Color"] = { Color = ESP.Theme.PurpleMid },
	["Esp Name"]           = ESP_UI.Info,
	["Esp Health Bar"]     = ESP_UI.Info,
	["Esp Distance"]       = ESP_UI.Distance,
	["Esp Weapon"]         = ESP_UI.Weapon,
	["Esp Max Distance"]   = ESP_UI.MaxDist,
	["Chams Enabled"]      = ESP_UI.Highlight,
	["Glows Enabled"]      = ESP_UI.Highlight,
})
ESP.Init()

do
	local Players    = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	FL_WPN = FL_WPN or {}
	FL_WPN.InfiniteAmmo = false
	FL_WPN.AmmoLock     = 999
	FL_WPN.RPMOn        = false
	FL_WPN.RPM          = 1800
	FL_WPN.RPMMax       = 6000
	FL_WPN.RangeOn      = false
	FL_WPN.Range        = 5000
	FL_WPN.ModeOn       = false
	FL_WPN.Mode         = 2
	FL_WPN._orig        = {}
	FL_WPN._ammoOrig    = {}
	FL_WPN._conn        = nil
	FL_WPN._cfgCache    = nil
	FL_WPN.LastErr      = nil

	function FL_WPN.Model()
		local char = LocalPlayer.Character
		if not char then return nil end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Config") then return tool end
		for _, d in ipairs(char:GetChildren()) do
			if d:FindFirstChild("Config") then return d end
		end
		return nil
	end

	function FL_WPN.Config()
		local m = FL_WPN.Model()
		if not m then return nil, nil end
		local cfg = m:FindFirstChild("Config")
		if not cfg or not cfg:IsA("ModuleScript") then return nil, m end
		if FL_WPN._cfgCache and FL_WPN._cfgCache[1] == cfg then
			return FL_WPN._cfgCache[2], m
		end
		local ok, t = pcall(require, cfg)
		if ok and type(t) == "table" then
			FL_WPN._cfgCache = { cfg, t }
			return t, m
		end
		FL_WPN.LastErr = "require(Config) 失败"
		return nil, m
	end

	local function remember(t)
		if FL_WPN._orig[t] then return end
		FL_WPN._orig[t] = {
			RPM             = rawget(t, "RPM"),
			SHOOT_MODE      = rawget(t, "SHOOT_MODE"),
			BULLET_DISTANCE = rawget(t, "BULLET_DISTANCE"),
		}
	end

	function FL_WPN.Apply()
		local t = FL_WPN.Config()
		if not t then return false end
		remember(t)
		if FL_WPN.RPMOn then
			local rpm = tonumber(FL_WPN.RPM) or 1800
			local cap = tonumber(FL_WPN.RPMMax) or 6000
			if rpm > cap then rpm = cap end
			if rpm < 60 then rpm = 60 end
			pcall(rawset, t, "RPM", rpm)
		end
		if FL_WPN.RangeOn then
			local d = tonumber(FL_WPN.Range) or 5000
			if d < 600 then d = 600 end
			pcall(rawset, t, "BULLET_DISTANCE", d)
		end
		if FL_WPN.ModeOn then
			pcall(rawset, t, "SHOOT_MODE", tonumber(FL_WPN.Mode) or 2)
		end
		return true
	end

	function FL_WPN.Restore()
		for t, o in pairs(FL_WPN._orig) do
			if type(t) == "table" then
				if o.RPM ~= nil then pcall(rawset, t, "RPM", o.RPM) end
				if o.SHOOT_MODE ~= nil then pcall(rawset, t, "SHOOT_MODE", o.SHOOT_MODE) end
				if o.BULLET_DISTANCE ~= nil then pcall(rawset, t, "BULLET_DISTANCE", o.BULLET_DISTANCE) end
			end
		end
		FL_WPN._orig = {}
		for v, old in pairs(FL_WPN._ammoOrig) do
			pcall(function() v.Value = old end)
		end
		FL_WPN._ammoOrig = {}
	end

	local function ammoObjects()
		local m = FL_WPN.Model()
		if not m then return nil end
		local cfg = m:FindFirstChild("Config")
		if not cfg then return nil end
		return cfg:FindFirstChild("Ammo"), cfg:FindFirstChild("TotalAmmo")
	end

	local function tick()
		if FL_WPN.RPMOn or FL_WPN.RangeOn or FL_WPN.ModeOn then
			pcall(FL_WPN.Apply)
		end
		if FL_WPN.InfiniteAmmo then
			local ammo, total = ammoObjects()
			local lock = tonumber(FL_WPN.AmmoLock) or 999
			if ammo and ammo:IsA("ValueBase") then
				if FL_WPN._ammoOrig[ammo] == nil then FL_WPN._ammoOrig[ammo] = ammo.Value end
				if tonumber(ammo.Value) ~= lock then
					pcall(function() ammo.Value = lock end)
				end
			end
			if total and total:IsA("ValueBase") then
				if FL_WPN._ammoOrig[total] == nil then FL_WPN._ammoOrig[total] = total.Value end
				if tonumber(total.Value) ~= lock then
					pcall(function() total.Value = lock end)
				end
			end
		end
	end

	local function need()
		return FL_WPN.InfiniteAmmo or FL_WPN.RPMOn or FL_WPN.RangeOn or FL_WPN.ModeOn
	end

	function FL_WPN.Sync()
		if need() and not FL_WPN._conn then
			FL_WPN._conn = RunService.Heartbeat:Connect(function()
				pcall(tick)
			end)
			pcall(FL_WPN.Apply)
		elseif not need() and FL_WPN._conn then
			FL_WPN._conn:Disconnect()
			FL_WPN._conn = nil
			pcall(FL_WPN.Restore)
		end
	end

	function FL_WPN.SetInfiniteAmmo(on)
		FL_WPN.InfiniteAmmo = on and true or false
		if not FL_WPN.InfiniteAmmo then
			local ammo, total = ammoObjects()
			for _, v in ipairs({ ammo, total }) do
				if v and v:IsA("ValueBase") and FL_WPN._ammoOrig[v] ~= nil then
					local old = FL_WPN._ammoOrig[v]
					pcall(function() v.Value = old end)
					FL_WPN._ammoOrig[v] = nil
				end
			end
		end
		FL_WPN.Sync()
	end

	function FL_WPN.SetRPM(on, rpm)
		FL_WPN.RPMOn = on and true or false
		if rpm then FL_WPN.RPM = rpm end
		FL_WPN.Sync()
		if not FL_WPN.RPMOn then
			for t, o in pairs(FL_WPN._orig) do
				if type(t) == "table" and o.RPM ~= nil then pcall(rawset, t, "RPM", o.RPM) end
			end
		end
	end

	function FL_WPN.SetRange(on, dist)
		FL_WPN.RangeOn = on and true or false
		if dist then FL_WPN.Range = dist end
		FL_WPN.Sync()
		if not FL_WPN.RangeOn then
			for t, o in pairs(FL_WPN._orig) do
				if type(t) == "table" and o.BULLET_DISTANCE ~= nil then
					pcall(rawset, t, "BULLET_DISTANCE", o.BULLET_DISTANCE)
				end
			end
		end
	end

	function FL_WPN.SetMode(on, mode)
		FL_WPN.ModeOn = on and true or false
		if mode then FL_WPN.Mode = mode end
		FL_WPN.Sync()
		if not FL_WPN.ModeOn then
			for t, o in pairs(FL_WPN._orig) do
				if type(t) == "table" and o.SHOOT_MODE ~= nil then
					pcall(rawset, t, "SHOOT_MODE", o.SHOOT_MODE)
				end
			end
		end
	end

	function FL_WPN.Status()
		local t, m = FL_WPN.Config()
		return {
			Weapon  = m and m.Name or "无",
			HasCfg  = t ~= nil,
			RPM     = t and rawget(t, "RPM") or nil,
			Mode    = t and rawget(t, "SHOOT_MODE") or nil,
			Range   = t and rawget(t, "BULLET_DISTANCE") or nil,
			AmmoOn  = FL_WPN.InfiniteAmmo,
			RPMOn   = FL_WPN.RPMOn,
			RangeOn = FL_WPN.RangeOn,
			LastErr = FL_WPN.LastErr,
		}
	end

	LocalPlayer.CharacterAdded:Connect(function()
		FL_WPN._cfgCache = nil
	end)
end

do
	local Players = game:GetService("Players")
	local RS      = game:GetService("ReplicatedStorage")
	local LocalPlayer = Players.LocalPlayer

	FL_DMG = FL_DMG or {}
	FL_DMG.Enabled       = true
	FL_DMG.UseHead       = true
	FL_DMG.LeadStuds     = 1.5
	FL_DMG.RayMode       = "near"
	FL_DMG.LastDist      = nil
	FL_DMG.FallbackDamage= 5
	FL_DMG.SendBullet    = true
	FL_DMG.LastInfo      = nil
	FL_DMG.LastErr       = nil

	local function playerEvent()
		local remote = RS:FindFirstChild("Remote")
		if not remote then return nil end
		local ev = remote:FindFirstChild("PlayerEvent")
		if ev and ev:IsA("RemoteEvent") then return ev end
		return nil
	end
	FL_DMG.Event = playerEvent

	local MESH_TO_PART = {
		Head = "Head",
		UpperTorso = "Torso", LowerTorso = "Torso",
		LeftUpperArm = "LeftArm", LeftLowerArm = "LeftArm", LeftHand = "LeftArm",
		RightUpperArm = "RightArm", RightLowerArm = "RightArm", RightHand = "RightArm",
		LeftUpperLeg = "LeftLeg", LeftLowerLeg = "LeftLeg", LeftFoot = "LeftLeg",
		RightUpperLeg = "RightLeg", RightLowerLeg = "RightLeg", RightFoot = "RightLeg",
	}

	function FL_DMG.Equipped()
		local char = LocalPlayer.Character
		if not char then return nil end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then return tool end
		for _, d in ipairs(char:GetDescendants()) do
			if d:IsA("ModuleScript") and d.Name == "Config" then
				return d.Parent
			end
		end
		return nil
	end

	function FL_DMG.WeaponInfo()
		local w = FL_DMG.Equipped()
		if not w then return nil end
		local cfg = w:FindFirstChild("Config")
		if not cfg or not cfg:IsA("ModuleScript") then return nil end
		local ok, data = pcall(require, cfg)
		if not ok or type(data) ~= "table" then return nil end
		local info = {
			model    = w,
			name     = w.Name,
			damage   = tonumber(data.DAMAGE) or FL_DMG.FallbackDamage,
			category = data.CATEGORY,
			rpm      = tonumber(data.RPM),
			gun      = data.GUN == true,
			melee    = data.CATEGORY == "Melee",
		}
		FL_DMG.LastInfo = info
		return info
	end

	local function aimPart(char, wantHead)
		if not char then return nil end
		if wantHead then
			local h = char:FindFirstChild("Head")
			if h and h:IsA("BasePart") then return h, "Head" end
		end
		for _, n in ipairs({ "UpperTorso", "Torso", "LowerTorso" }) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then
				return p, MESH_TO_PART[n] or "Torso"
			end
		end
		local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
		if root and root:IsA("BasePart") then return root, "Torso" end
		return nil
	end

	local function selfEye()
		local cam = workspace.CurrentCamera
		if cam then return cam.CFrame.Position end
		local c = LocalPlayer.Character
		local r = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
		if r then return r.Position end
		return nil
	end

	function FL_DMG.BuildRay(pos, fromSelf)
		local eye = selfEye()
		local dir
		if eye then
			local d = pos - eye
			if d.Magnitude > 0.01 then dir = d.Unit end
		end
		if not dir then dir = Vector3.new(0, 0, -1) end
		if fromSelf then return eye, dir end
		return pos - dir * FL_DMG.LeadStuds, dir
	end

	function FL_DMG.Hit(target, opts)
		if not FL_DMG.Enabled or not target then return false end
		opts = opts or {}
		local rem = playerEvent()
		if not rem then FL_DMG.LastErr = "没有 PlayerEvent" return false end

		local char
		if typeof(target) == "Instance" and target:IsA("Player") then
			char = target.Character
		elseif typeof(target) == "Instance" then
			char = target
		end
		if not char or not char.Parent then FL_DMG.LastErr = "目标没有角色" return false end

		local part, partName = aimPart(char, opts.part ~= "Torso")
		if opts.part and opts.part ~= "Head" then partName = opts.part end
		if not part then FL_DMG.LastErr = "找不到可打部位" return false end

		local pos = opts.pos or part.Position
		local myEye = nil
		pcall(function()
			local c = LocalPlayer.Character
			local r = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
			if r then myEye = r.Position end
		end)
		if myEye then FL_DMG.LastDist = (pos - myEye).Magnitude end

		local fromSelf = (FL_DMG.RayMode == "self")
		local origin, dir = FL_DMG.BuildRay(pos, fromSelf)
		local factor = opts.factor or ((partName == "Head") and 1.5 or 1)

		local info = nil
		pcall(function() info = FL_DMG.WeaponInfo and FL_DMG.WeaponInfo() end)
		local isMelee = info ~= nil and info.melee == true

		if FL_DMG.SendBullet and info and info.name then
			pcall(function()
				rem:FireServer("bullet", {
					pos         = pos,
					posDestroyX = pos.X,
					weaponName  = info.name,
				})
			end)
		end

		local payload = {
			bodyParts    = { { partName, 1 } },
			shotCode     = { origin, dir },
			pos          = pos,
			target       = (typeof(target) == "Instance" and target:IsA("Player")) and target or nil,
		}
		if not isMelee then
			payload.damageFactor = factor
		end
		if not payload.target then
			payload.target = target
		end

		local ok = pcall(function() rem:FireServer("damage", payload) end)
		if not ok then FL_DMG.LastErr = "FireServer 失败" return false end
		FL_DMG.LastErr = nil
		return true
	end

	function FL_DMG.Status()
		local info = FL_DMG.WeaponInfo()
		local rem = playerEvent()
		return {
			Enabled  = FL_DMG.Enabled,
			HasEvent = rem ~= nil,
			Weapon   = info and info.name or "无",
			Damage   = info and info.damage or nil,
			Category = info and info.category or nil,
			RayMode  = FL_DMG.RayMode,
			LastDist = FL_DMG.LastDist,
			LastErr  = FL_DMG.LastErr,
		}
	end
end

do
	local Players    = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	FL_TRACK = FL_TRACK or {}
	FL_TRACK.Enabled    = false
	FL_TRACK.Full360    = true
	FL_TRACK.FOV        = 200
	FL_TRACK.MaxDist    = 99999
	FL_TRACK.Mode       = "all"
	FL_TRACK.CombatOnly = true
	FL_TRACK.ForceHit   = true
	FL_TRACK.ForceRate  = 0.12
	FL_TRACK.ShowCircle = true
	FL_TRACK.ShowLine   = true
	FL_TRACK.Color      = Color3.fromRGB(255, 90, 90)
	FL_TRACK.Target     = nil
	FL_TRACK._acc       = 0
	FL_TRACK._conn      = nil

	function FL_TRACK.Faction(plr)
		local t = plr and plr.Team
		return (t and t.Name) or "?"
	end

	function FL_TRACK.Stars(plr)
		if not plr then return 0, 0 end
		local lvl = plr:GetAttribute("WantedLevel")
		local pts = plr:GetAttribute("WantedPoints")
		return tonumber(lvl) or 0, tonumber(pts) or 0
	end

	local function alive(plr)
		local c = plr.Character
		if not c then return false end
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then return (h.Health or 0) > 0 end
		return c:FindFirstChild("Head") ~= nil
	end

	function FL_TRACK.Pass(plr)
		if not plr or plr == LocalPlayer then return false end
		if not alive(plr) then return false end
		if FL_TRACK.CombatOnly then
			if plr:GetAttribute("CombatMode") ~= true then return false end
		end
		local f = FL_TRACK.Faction(plr)
		if FL_TRACK.Mode == "police" then return f == "Police" end
		if FL_TRACK.Mode == "civilian" then return f == "Civilian" end
		return true
	end

	local gui, circle, stroke, line
	local function buildGui()
		if gui and gui.Parent then return end
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return end
		gui = Instance.new("ScreenGui")
		gui.Name = "FL_Track"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 2
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = pg

		circle = Instance.new("Frame")
		circle.Name = "FovCircle"
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.BackgroundTransparency = 1
		circle.Visible = false
		circle.Parent = gui
		local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = circle
		stroke = Instance.new("UIStroke"); stroke.Thickness = 1; stroke.Transparency = 0.35
		stroke.Parent = circle

		line = Instance.new("Frame")
		line.Name = "TrackLine"
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.BorderSizePixel = 0
		line.Visible = false
		line.ZIndex = 3
		line.Parent = gui
	end

	local function fovPx()
		local cam = workspace.CurrentCamera
		local h = cam and cam.ViewportSize.Y or 1080
		if h <= 0 then h = 1080 end
		return FL_TRACK.FOV * (h / 1080)
	end

	local function findTarget()
		local cam = workspace.CurrentCamera
		if not cam then return nil end
		local vp = cam.ViewportSize
		local center = Vector2.new(vp.X / 2, vp.Y / 2)
		local camPos = cam.CFrame.Position
		local r = fovPx()
		local full = FL_TRACK.Full360
		local best, bestD = nil, math.huge

		for _, plr in ipairs(Players:GetPlayers()) do
			if FL_TRACK.Pass(plr) then
				local c = plr.Character
				local part = c and (c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso")
					or c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
				if part then
					local dist = (part.Position - camPos).Magnitude
					if dist <= FL_TRACK.MaxDist then
						local sp = cam:WorldToViewportPoint(part.Position)
						local metric
						if full then
							metric = dist
						elseif sp.Z > 0 then
							local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
							if d <= r then metric = d end
						end
						if metric and metric < bestD then
							bestD = metric
							best = { plr = plr, part = part, world = part.Position,
							         screen = Vector2.new(sp.X, sp.Y), dist = dist }
						end
					end
				end
			end
		end
		return best
	end

	local function draw(target)
		buildGui()
		if not gui then return end
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(0, 0)
		local center = Vector2.new(vp.X / 2, vp.Y / 2)

		if circle then
			circle.Visible = FL_TRACK.Enabled and FL_TRACK.ShowCircle
				and not FL_TRACK.Full360 and target ~= nil
			if circle.Visible then
				local rr = fovPx()
				circle.Size = UDim2.fromOffset(rr * 2, rr * 2)
				stroke.Color = FL_TRACK.Color
			end
		end
		if line then
			line.Visible = false
			if FL_TRACK.Enabled and FL_TRACK.ShowLine and target and target.screen then
				local d = target.screen - center
				local len = d.Magnitude
				if len >= 1 then
					line.Position = UDim2.fromOffset(center.X, center.Y)
					line.Size = UDim2.fromOffset(len, 1)
					line.Rotation = math.deg(math.atan2(d.Y, d.X))
					line.BackgroundColor3 = FL_TRACK.Color
					line.Visible = true
				end
			end
		end
	end

	local function step(dt)
		if not FL_TRACK.Enabled then
			FL_TRACK.Target = nil
			draw(nil)
			return
		end
		local t = findTarget()
		FL_TRACK.Target = t
		draw(t)

		if t and FL_TRACK.ForceHit and FL_DMG then
			FL_TRACK._acc = FL_TRACK._acc + dt
			local rate = tonumber(FL_TRACK.ForceRate) or 0.12
			if rate < 0.05 then rate = 0.05 end
			if FL_TRACK._acc >= rate then
				FL_TRACK._acc = 0
				pcall(FL_DMG.Hit, t.plr)
			end
		end
	end

	function FL_TRACK.Set(on)
		FL_TRACK.Enabled = on and true or false
		if FL_TRACK.Enabled then
			buildGui()
			if not FL_TRACK._conn then
				FL_TRACK._conn = RunService.RenderStepped:Connect(function(dt)
					pcall(step, dt)
				end)
			end
		else
			FL_TRACK.Target = nil
			draw(nil)
			if FL_TRACK._conn then
				FL_TRACK._conn:Disconnect()
				FL_TRACK._conn = nil
			end
		end
		return FL_TRACK.Enabled
	end

	function FL_TRACK.Status()
		local t = FL_TRACK.Target
		return {
			Enabled = FL_TRACK.Enabled,
			Full360 = FL_TRACK.Full360,
			CombatOnly = FL_TRACK.CombatOnly,
			Mode    = FL_TRACK.Mode,
			FOV     = FL_TRACK.FOV,
			ForceHit= FL_TRACK.ForceHit,
			Target  = t and t.plr and t.plr.Name or "无",
			Faction = t and t.plr and FL_TRACK.Faction(t.plr) or nil,
		}
	end
end

do
	local RunService = game:GetService("RunService")
	local Players    = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	FL_TRACER = FL_TRACER or {}
	FL_TRACER.Enabled = false
	FL_TRACER.Hold    = 3
	FL_TRACER.Drift   = 1.2
	FL_TRACER.Scale   = 0.5
	FL_TRACER.MaxLive = 40
	FL_TRACER.Folder  = nil
	FL_TRACER.Count   = 0

	local MUZZLE_NAMES = { "Barrel", "Muzzle", "MuzzlePart", "MuzzleAttachment", "Tip" }

	local function folder()
		if FL_TRACER.Folder and FL_TRACER.Folder.Parent then
			return FL_TRACER.Folder
		end
		local f = workspace:FindFirstChild("FL_Tracers")
		if not f then
			f = Instance.new("Folder")
			f.Name = "FL_Tracers"
			f.Parent = workspace
		end
		FL_TRACER.Folder = f
		return f
	end

	local function muzzlePos()
		local char = LocalPlayer.Character
		if char then
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("ModuleScript") and d.Name == "Config" and d.Parent then
					for _, n in ipairs(MUZZLE_NAMES) do
						local m = d.Parent:FindFirstChild(n, true)
						if m then
							if m:IsA("BasePart") then return m.Position end
							if m:IsA("Attachment") then return m.WorldPosition end
						end
					end
				end
			end
		end
		local cam = workspace.CurrentCamera
		if cam then return cam.CFrame.Position end
		return nil
	end

	local function newPoint(parent, pos)
		local part = Instance.new("Part")
		part.Name = "TracerPoint"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery   = false
		part.CanTouch   = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(0.05, 0.05, 0.05)
		part.CFrame = CFrame.new(pos)
		part.Parent = parent
		local att = Instance.new("Attachment")
		att.Name = "TracerAttach"
		att.Parent = part
		return part, att
	end

	local function newBeam(parent, a0, a1, w0, w1, transparency, emission)
		local k = tonumber(FL_TRACER.Scale) or 0.5
		local beam = Instance.new("Beam")
		beam.Name = "TracerBeam"
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Width0 = w0 * k
		beam.Width1 = w1 * k
		beam.Segments = 1
		beam.FaceCamera = true
		beam.LightEmission = emission
		beam.LightInfluence = 0
		beam.Color = ColorSequence.new(Color3.new(1, 1, 1))
		beam.Transparency = NumberSequence.new(transparency)
		beam.Parent = parent
		return beam
	end

	local function spawnTracer(from, to)
		if typeof(from) ~= "Vector3" or typeof(to) ~= "Vector3" then return end
		if (to - from).Magnitude < 2 then return end
		local f = folder()
		if not f then return end

		local kids = f:GetChildren()
		if #kids >= FL_TRACER.MaxLive then
			for i = 1, #kids - FL_TRACER.MaxLive + 1 do
				pcall(function() kids[i]:Destroy() end)
			end
		end

		local holder = Instance.new("Folder")
		holder.Name = "Tracer"
		holder.Parent = f
		FL_TRACER.Count = FL_TRACER.Count + 1

		local p0, a0 = newPoint(holder, from)
		local p1, a1 = newPoint(holder, to)

		local core = newBeam(holder, a0, a1, 0.20, 0.06, 0.00, 1.00)
		local mid  = newBeam(holder, a0, a1, 0.55, 0.20, 0.72, 0.80)
		local halo = newBeam(holder, a0, a1, 1.30, 0.45, 0.88, 0.45)
		local k = tonumber(FL_TRACER.Scale) or 0.5

		task.spawn(function()
			task.wait(math.max(0.1, tonumber(FL_TRACER.Hold) or 3))
			if not holder.Parent then return end

			local drift = math.max(0.1, tonumber(FL_TRACER.Drift) or 1.2)
			local up = Vector3.new(0, 1, 0)
			local t = 0
			while t < drift do
				local dt = RunService.Heartbeat:Wait()
				if not holder.Parent then return end
				t = t + dt
				local e = math.clamp(t / drift, 0, 1)
				e = e * e
				core.Transparency = NumberSequence.new(e)
				mid.Transparency  = NumberSequence.new(0.72 + 0.28 * e)
				halo.Transparency = NumberSequence.new(0.88 + 0.12 * e)
				core.Width0 = 0.20 * k * (1 - 0.55 * e); core.Width1 = 0.06 * k * (1 - 0.55 * e)
				mid.Width0  = 0.55 * k * (1 + 2.6 * e);  mid.Width1  = 0.20 * k * (1 + 2.6 * e)
				halo.Width0 = 1.30 * k * (1 + 3.2 * e);  halo.Width1 = 0.45 * k * (1 + 3.2 * e)
				local shift = up * (1.4 * e)
				p0.CFrame = CFrame.new(from + shift)
				p1.CFrame = CFrame.new(to + shift * 1.8)
			end
			holder:Destroy()
		end)
	end
	FL_TRACER.Spawn = spawnTracer

	function FL_TRACER.OnBullet(payload)
		if not FL_TRACER.Enabled then return end
		if type(payload) ~= "table" then return end
		local to = payload.pos
		if typeof(to) ~= "Vector3" then return end
		local from = muzzlePos()
		if not from then return end
		pcall(spawnTracer, from, to)
	end

	function FL_TRACER.Set(on)
		FL_TRACER.Enabled = on and true or false
		if FL_TRACER.Enabled then
			folder()
			if FL_AC then FL_AC.OnBullet = FL_TRACER.OnBullet end
		else
			if FL_AC then FL_AC.OnBullet = nil end
			local f = FL_TRACER.Folder
			if f then
				for _, c in ipairs(f:GetChildren()) do
					pcall(function() c:Destroy() end)
				end
			end
		end
		return FL_TRACER.Enabled
	end

	function FL_TRACER.Status()
		return {
			Enabled  = FL_TRACER.Enabled,
			Hooked   = (FL_AC and FL_AC.OnBullet ~= nil) or false,
			Scale    = FL_TRACER.Scale,
			Hold     = FL_TRACER.Hold,
			Drift    = FL_TRACER.Drift,
			Live     = FL_TRACER.Folder and #FL_TRACER.Folder:GetChildren() or 0,
			Count    = FL_TRACER.Count,
		}
	end
end

do
	local RunService = game:GetService("RunService")
	local Players    = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	FL_CROSS = FL_CROSS or {}
	FL_CROSS.Enabled = false
	FL_CROSS.Size    = 18
	FL_CROSS.Thick   = 2
	FL_CROSS.Gap     = 6
	FL_CROSS.Center  = true
	FL_CROSS.Spin    = false
	FL_CROSS.Speed   = 90
	FL_CROSS.Rainbow = false
	FL_CROSS.HueSpeed= 0.35
	FL_CROSS.Color   = Color3.fromRGB(255, 255, 255)
	FL_CROSS._gui    = nil
	FL_CROSS._conn   = nil
	FL_CROSS._hub    = 0
	FL_CROSS._spin   = 0

	local function gui()
		if FL_CROSS._gui and FL_CROSS._gui.Parent then return FL_CROSS._gui end
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return nil end
		local g = Instance.new("ScreenGui")
		g.Name = "FL_Crosshair"
		g.IgnoreGuiInset = true
		g.ResetOnSpawn = false
		g.DisplayOrder = 99
		g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		g.Parent = pg
		FL_CROSS._gui = g

		local hub = Instance.new("Frame")
		hub.Name = "Hub"
		hub.AnchorPoint = Vector2.new(0.5, 0.5)
		hub.Position = UDim2.fromScale(0.5, 0.5)
		hub.Size = UDim2.fromOffset(2, 2)
		hub.BackgroundTransparency = 1
		hub.Parent = g
		FL_CROSS._hubInst = hub

		local bars = {}
		for i = 1, 4 do
			local b = Instance.new("Frame")
			b.Name = "Bar" .. i
			b.BorderSizePixel = 0
			b.BackgroundColor3 = FL_CROSS.Color
			b.AnchorPoint = Vector2.new(0.5, 0.5)
			b.Position = UDim2.fromScale(0.5, 0.5)
			b.Parent = hub
			bars[#bars + 1] = b
		end
		FL_CROSS._bars = bars

		local dot = Instance.new("Frame")
		dot.Name = "Dot"
		dot.BorderSizePixel = 0
		dot.BackgroundColor3 = FL_CROSS.Color
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.fromScale(0.5, 0.5)
		dot.Size = UDim2.fromOffset(2, 2)
		dot.Parent = hub
		FL_CROSS._dot = dot
		return g
	end

	local function layout()
		if not FL_CROSS._gui then return end
		local sz, th, gap = FL_CROSS.Size, FL_CROSS.Thick, FL_CROSS.Gap
		local bars = FL_CROSS._bars
		if not bars then return end
		bars[1].Size = UDim2.fromOffset(th, sz)
		bars[1].Position = UDim2.new(0.5, 0, 0.5, -(gap + sz / 2))
		bars[2].Size = UDim2.fromOffset(th, sz)
		bars[2].Position = UDim2.new(0.5, 0, 0.5, (gap + sz / 2))
		bars[3].Size = UDim2.fromOffset(sz, th)
		bars[3].Position = UDim2.new(0.5, -(gap + sz / 2), 0.5, 0)
		bars[4].Size = UDim2.fromOffset(sz, th)
		bars[4].Position = UDim2.new(0.5, (gap + sz / 2), 0.5, 0)
		FL_CROSS._dot.Visible = FL_CROSS.Center
	end

	local function paint(c)
		local bars = FL_CROSS._bars
		if not bars then return end
		for i = 1, 4 do bars[i].BackgroundColor3 = c end
		FL_CROSS._dot.BackgroundColor3 = c
	end

	function FL_CROSS.Set(on)
		FL_CROSS.Enabled = on and true or false
		if FL_CROSS.Enabled then
			if not gui() then return false end
			layout()
			FL_CROSS._gui.Enabled = true
			if not FL_CROSS._conn then
				FL_CROSS._conn = RunService.RenderStepped:Connect(function(dt)
					if not FL_CROSS.Enabled then return end
					if FL_CROSS.Spin then
						FL_CROSS._spin = (FL_CROSS._spin + (tonumber(FL_CROSS.Speed) or 90) * dt) % 360
						if FL_CROSS._hubInst then FL_CROSS._hubInst.Rotation = FL_CROSS._spin end
					elseif FL_CROSS._hubInst and FL_CROSS._hubInst.Rotation ~= 0 then
						FL_CROSS._hubInst.Rotation = 0
						FL_CROSS._spin = 0
					end
					if FL_CROSS.Rainbow then
						FL_CROSS._hub = (FL_CROSS._hub + (tonumber(FL_CROSS.HueSpeed) or 0.35) * dt) % 1
						paint(Color3.fromHSV(FL_CROSS._hub, 1, 1))
					end
				end)
			end
			if not FL_CROSS.Rainbow then paint(FL_CROSS.Color) end
			return true
		else
			if FL_CROSS._gui then FL_CROSS._gui.Enabled = false end
			if FL_CROSS._conn then
				FL_CROSS._conn:Disconnect()
				FL_CROSS._conn = nil
			end
			return true
		end
	end

	function FL_CROSS.Refresh()
		if FL_CROSS.Enabled then layout() end
		if FL_CROSS.Enabled and not FL_CROSS.Rainbow then paint(FL_CROSS.Color) end
	end

	function FL_CROSS.Status()
		return {
			Enabled = FL_CROSS.Enabled,
			Spin    = FL_CROSS.Spin,
			Speed   = FL_CROSS.Speed,
			Rainbow = FL_CROSS.Rainbow,
			Size    = FL_CROSS.Size,
		}
	end
end

do
	local RunService = game:GetService("RunService")
	local Players    = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	FL_SPIN = FL_SPIN or {}
	FL_SPIN.Enabled = false
	FL_SPIN.Speed   = 360
	FL_SPIN.Random  = false
	FL_SPIN._angle  = 0
	FL_SPIN._conn   = nil
	FL_SPIN.LastErr = nil

	local function rootPart()
		local c = LocalPlayer.Character
		if not c then return nil end
		return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
	end

	local function apply(rad)
		local r = rootPart()
		if not r then return false end
		local ok = pcall(function()
			r.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, rad, 0)
		end)
		if not ok then
			local c = LocalPlayer.Character
			ok = pcall(function()
				local p = c.PrimaryPart or r
				c:PivotTo(CFrame.new(p.Position) * CFrame.Angles(0, rad, 0))
			end)
		end
		return ok
	end

	function FL_SPIN.Step(dt)
		if not FL_SPIN.Enabled then return end
		if FL_SPIN.Random then
			FL_SPIN._angle = math.random() * math.pi * 2
		else
			FL_SPIN._angle = (FL_SPIN._angle + math.rad(tonumber(FL_SPIN.Speed) or 360) * dt)
			                 % (math.pi * 2)
		end
		if not apply(FL_SPIN._angle) then
			FL_SPIN.LastErr = "没有角色根部件"
		else
			FL_SPIN.LastErr = nil
		end
	end

	function FL_SPIN.Set(on)
		FL_SPIN.Enabled = on and true or false
		if FL_SPIN.Enabled then
			FL_SPIN._angle = 0
			if not FL_SPIN._conn then
				FL_SPIN._conn = RunService.RenderStepped:Connect(function(dt)
					pcall(FL_SPIN.Step, dt)
				end)
			end
		else
			if FL_SPIN._conn then
				FL_SPIN._conn:Disconnect()
				FL_SPIN._conn = nil
			end
			FL_SPIN._angle = 0
		end
		return FL_SPIN.Enabled
	end

	function FL_SPIN.Status()
		local r = rootPart()
		return {
			Enabled = FL_SPIN.Enabled,
			Speed   = FL_SPIN.Speed,
			Random  = FL_SPIN.Random,
			HasChar = r ~= nil,
			Yaw     = r and math.deg(FL_SPIN._angle) or nil,
			LastErr = FL_SPIN.LastErr,
		}
	end
end

do
	local Players = game:GetService("Players")
	local RS      = game:GetService("ReplicatedStorage")
	local LocalPlayer = Players.LocalPlayer

	FL_TIRE = FL_TIRE or {}
	FL_TIRE.Enabled   = false
	FL_TIRE.Range     = 400
	FL_TIRE.Interval  = 0.15
	FL_TIRE.RayMode   = "near"
	FL_TIRE.ShotInterval = 0.06
	FL_TIRE.SendBullet   = true
	FL_TIRE.Queue        = {}
	FL_TIRE.Count        = 0
	FL_TIRE.LastHit   = nil
	FL_TIRE.LastErr   = nil
	FL_TIRE.Conn      = nil
	FL_TIRE.LastFire  = 0

	local function playerEvent()
		local r = RS:FindFirstChild("Remote")
		local ev = r and r:FindFirstChild("PlayerEvent")
		if ev and ev:IsA("RemoteEvent") then return ev end
		return nil
	end
	FL_TIRE.Event = playerEvent

	local function vehicleTeam(veh)
		local cfg = veh:FindFirstChild("Config")
		local t = cfg and cfg:FindFirstChild("Type")
		local v = t and t.Value
		if v == "Special" then v = "Civilian" end
		return v
	end
	FL_TIRE.VehicleTeam = vehicleTeam

	local function vehicleDriver(veh)
		local cfg = veh:FindFirstChild("Config")
		local d = cfg and cfg:FindFirstChild("LastDrove")
		local p = d and d.Value
		if typeof(p) == "Instance" and p:IsA("Player") then return p end
		return nil
	end
	FL_TIRE.VehicleDriver = vehicleDriver

	local function isTarget(veh)
		if vehicleTeam(veh) == "Police" then return true end
		local d = vehicleDriver(veh)
		if d then
			if d.Team and d.Team.Name == "Police" then return true end
			if d:GetAttribute("CombatMode") == true then return true end
		end
		return false
	end
	FL_TIRE.IsTarget = isTarget

	local function collectTires(veh)
		local out = {}
		local thrusters = veh:FindFirstChild("Thrusters")
		if not thrusters then return out end
		for _, th in ipairs(thrusters:GetChildren()) do
			local wheel = th:FindFirstChild("Wheel")
			local tire  = wheel and wheel:FindFirstChild("Tire")
			local col   = tire and tire:FindFirstChild("WheelCollision")
			if col and col:IsA("BasePart") and col.Parent then
				if not col:GetAttribute("DontPuncture") then
					local dur = col:GetAttribute("Durability")
					if dur == nil or dur ~= 0 then
						table.insert(out, col)
					end
				end
			end
		end
		return out
	end
	FL_TIRE.CollectTires = collectTires

	local function selfEye()
		local cam = workspace.CurrentCamera
		if cam then return cam.CFrame.Position end
		local c = LocalPlayer.Character
		local r = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
		return r and r.Position or nil
	end

	local function selfPos()
		local c = LocalPlayer.Character
		local r = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
		return r and r.Position or nil
	end

	function FL_TIRE.Puncture(col)
		local rem = playerEvent()
		if not rem then FL_TIRE.LastErr = "没有 PlayerEvent" return false end
		if not col or not col.Parent then return false end
		local pos = col.Position
		local eye = selfEye()
		local dir
		if eye then
			local d = pos - eye
			if d.Magnitude > 0.01 then dir = d.Unit end
		end
		if not dir then dir = Vector3.new(0, 0, -1) end
		local origin
		if FL_TIRE.RayMode == "self" and eye then
			origin = eye
		else
			origin = pos - dir * 1.5
		end
		local ok = pcall(function()
			if FL_TIRE.SendBullet and FL_TIRE._wname then
				rem:FireServer("bullet", { pos = pos, posDestroyX = pos.X, weaponName = FL_TIRE._wname })
			end
			rem:FireServer("damage", { shotCode = { origin, dir }, pos = pos, targetTire = col })
		end)
		if not ok then FL_TIRE.LastErr = "FireServer 失败" return false end
		FL_TIRE.Count = FL_TIRE.Count + 1
		FL_TIRE.LastErr = nil
		return true
	end

	function FL_TIRE.Sweep()
		local myPos = selfPos()
		if not myPos then return 0 end
		local gameplay = workspace:FindFirstChild("Gameplay")
		local vehicles = gameplay and gameplay:FindFirstChild("Vehicles")
		if not vehicles then FL_TIRE.LastErr = "找不到 Gameplay.Vehicles" return 0 end

		local list = {}
		for _, veh in ipairs(vehicles:GetChildren()) do
			if veh:IsA("Model") and isTarget(veh) then
				local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
				local dist = root and (root.Position - myPos).Magnitude or 0
				if (not root) or dist <= FL_TIRE.Range then
					local police = (vehicleTeam(veh) == "Police")
					local d = vehicleDriver(veh)
					if d and d.Team and d.Team.Name == "Police" then police = true end
					table.insert(list, { veh = veh, police = police, dist = dist })
				end
			end
		end
		table.sort(list, function(a, b)
			if a.police ~= b.police then return a.police end
			return a.dist < b.dist
		end)

		local queue = {}
		for _, it in ipairs(list) do
			for _, col in ipairs(collectTires(it.veh)) do
				queue[#queue + 1] = col
			end
		end
		FL_TIRE.Queue = queue
		return #queue
	end

	function FL_TIRE.Step()
		local q = FL_TIRE.Queue
		if not q or #q == 0 then return end
		local col = table.remove(q, 1)
		if col and col.Parent and (col:GetAttribute("Durability") or 1) ~= 0 then
			if FL_TIRE.Puncture(col) then
				FL_TIRE.LastHit = (FL_TIRE.LastHit or 0) + 1
			end
		end
	end

	function FL_TIRE.Set(on)
		FL_TIRE.Enabled = on and true or false
		if FL_TIRE.Conn then
			FL_TIRE.Conn:Disconnect()
			FL_TIRE.Conn = nil
		end
		if FL_TIRE.SweepThread then
			FL_TIRE.SweepThread = nil
		end
		if not FL_TIRE.Enabled then
			FL_TIRE.Queue = {}
			return
		end

		local RunService = game:GetService("RunService")
		FL_TIRE._wname = nil
		pcall(function()
			local w = FL_DMG and FL_DMG.Equipped and FL_DMG.Equipped()
			FL_TIRE._wname = w and w.Name
		end)

		FL_TIRE.SweepThread = task.spawn(function()
			while FL_TIRE.Enabled do
				pcall(FL_TIRE.Sweep)
				task.wait(FL_TIRE.Interval)
			end
		end)
		local acc = 0
		FL_TIRE.Conn = RunService.Heartbeat:Connect(function(dt)
			if not FL_TIRE.Enabled then return end
			acc = acc + dt
			if acc < FL_TIRE.ShotInterval then return end
			acc = 0
			pcall(FL_TIRE.Step)
		end)
	end

	function FL_TIRE.Status()
		return {
			Enabled  = FL_TIRE.Enabled,
			Count    = FL_TIRE.Count,
			Range    = FL_TIRE.Range,
			Interval = FL_TIRE.Interval,
			RayMode  = FL_TIRE.RayMode,
			LastHit  = FL_TIRE.LastHit,
			LastErr  = FL_TIRE.LastErr,
		}
	end
end

do
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	FL_CUFF = FL_CUFF or {}
	FL_CUFF.Enabled    = false
	FL_CUFF.Ring       = 30
	FL_CUFF.Margin     = 8
	FL_CUFF.Cooldown   = 0.4
	FL_CUFF.OnlyWanted = true
	FL_CUFF.Pushes     = 0
	FL_CUFF.LastThreat = nil
	FL_CUFF.LastErr    = nil
	FL_CUFF.Conn       = nil
	FL_CUFF.LastPush   = 0

	local function selfRoot()
		local c = LocalPlayer.Character
		if not c then return nil end
		return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
	end
	FL_CUFF.SelfRoot = selfRoot

	local function isWanted()
		local w = LocalPlayer:GetAttribute("WantedLevel")
		return (w and w ~= false) and true or false
	end
	FL_CUFF.IsWanted = isWanted

	local function isArrested()
		return LocalPlayer:GetAttribute("Arrested") ~= nil
	end
	FL_CUFF.IsArrested = isArrested

	local function nearestPolice()
		local root = selfRoot()
		if not root then return nil, nil end
		local myPos = root.Position
		local best, bestD = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Police" then
				local ch = plr.Character
				local hrp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
				if hrp then
					local d = (hrp.Position - myPos).Magnitude
					if d < bestD then bestD = d; best = plr end
				end
			end
		end
		return best, bestD
	end
	FL_CUFF.NearestPolice = nearestPolice

	local function pushOut(plr)
		local root = selfRoot()
		if not root then FL_CUFF.LastErr = "没有角色" return false end
		local ch = plr and plr.Character
		local hrp = ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart)
		if not hrp then FL_CUFF.LastErr = "警察没有角色" return false end
		local delta = root.Position - hrp.Position
		local away = Vector3.new(delta.X, 0, delta.Z)
		if away.Magnitude < 0.01 then away = Vector3.new(1, 0, 0) end
		away = away.Unit
		local target = hrp.Position + away * (FL_CUFF.Ring + FL_CUFF.Margin)
		local ok = false
		if FL_AC and FL_AC.SafePivot then
			ok = FL_AC.SafePivot(target)
		else
			ok = pcall(function()
				root.CFrame = CFrame.new(target) * (root.CFrame - root.CFrame.Position)
			end)
		end
		if ok then FL_CUFF.Pushes = FL_CUFF.Pushes + 1 end
		return ok
	end
	FL_CUFF.PushOut = pushOut

	function FL_CUFF.Set(on)
		FL_CUFF.Enabled = on and true or false
		if FL_CUFF.Conn then
			FL_CUFF.Conn:Disconnect()
			FL_CUFF.Conn = nil
		end
		if FL_CUFF.Enabled then
			local RunService = game:GetService("RunService")
			FL_CUFF.Conn = RunService.Heartbeat:Connect(function()
				if not FL_CUFF.Enabled then return end
				if FL_CUFF.OnlyWanted and not isWanted() then return end
				if isArrested() then
					local now = tick()
					if now - FL_CUFF.LastPush >= FL_CUFF.Cooldown then
						FL_CUFF.LastPush = now
						pushOut(nearestPolice())
					end
					return
				end
				local plr, d = nearestPolice()
				FL_CUFF.LastThreat = plr and (plr.Name .. string.format(" (%.0f)", d or -1)) or nil
				if not plr or not d or d >= FL_CUFF.Ring then return end
				local now = tick()
				if now - FL_CUFF.LastPush < FL_CUFF.Cooldown then return end
				FL_CUFF.LastPush = now
				pushOut(plr)
			end)
		end
	end

	function FL_CUFF.Status()
		local plr, d = nearestPolice()
		return {
			Enabled    = FL_CUFF.Enabled,
			Wanted     = isWanted(),
			Arrested   = isArrested(),
			Ring       = FL_CUFF.Ring,
			Margin     = FL_CUFF.Margin,
			Nearest    = plr and plr.Name or "无",
			NearestDist= d,
			Pushes     = FL_CUFF.Pushes,
			LastErr    = FL_CUFF.LastErr,
		}
	end
end

do
	local RunService = game:GetService("RunService")

	FL_LASER = FL_LASER or {}
	FL_LASER.Enabled = false
	FL_LASER.Remove  = true
	FL_LASER.Immune  = true
	FL_LASER.Names   = { "_Laser" }
	FL_LASER.Hidden  = 0
	FL_LASER.Conn    = nil
	FL_LASER.WsConn  = nil
	FL_LASER.ScanPerFrame = 300
	FL_LASER.RescanEvery  = 5

	local function isLaserName(n)
		for _, x in ipairs(FL_LASER.Names) do
			if x == n then return true end
		end
		return false
	end
	FL_LASER.IsLaserName = isLaserName

	local function hidePart(p)
		pcall(function()
			p.Transparency = 1
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
		end)
	end
	FL_LASER.Hide = hidePart

	local q, qhead, cooldown = {}, 1, 0

	function FL_LASER.Sweep()
		q, qhead = { workspace }, 1
		cooldown = 0
		FL_LASER.Hidden = 0
		return 0
	end

	function FL_LASER.ScanStep()
		if not FL_LASER.Enabled or not FL_LASER.Remove then
			return false
		end
		local budget = FL_LASER.ScanPerFrame
		while budget > 0 and qhead <= #q do
			local inst = q[qhead]
			q[qhead] = nil
			qhead = qhead + 1
			budget = budget - 1
			if inst and inst.Parent then
				local ok, kids = pcall(function() return inst:GetChildren() end)
				if ok and type(kids) == "table" then
					for _, c in ipairs(kids) do
						q[#q + 1] = c
						if c:IsA("BasePart") and isLaserName(c.Name) then
							hidePart(c)
							FL_LASER.Hidden = FL_LASER.Hidden + 1
						end
					end
				end
			end
		end
		return qhead <= #q
	end

	function FL_LASER.Set(on)
		FL_LASER.Enabled = on and true or false

		if FL_LASER.Conn then FL_LASER.Conn:Disconnect(); FL_LASER.Conn = nil end
		if FL_LASER.WsConn then FL_LASER.WsConn:Disconnect(); FL_LASER.WsConn = nil end

		if FL_AC then FL_AC.LaserImmune = FL_LASER.Enabled and FL_LASER.Immune or false end

		if not FL_LASER.Enabled then
			q, qhead = {}, 1
			return
		end

		if FL_LASER.Remove then
			FL_LASER.Sweep()
			FL_LASER.WsConn = workspace.DescendantAdded:Connect(function(d)
				if FL_LASER.Enabled and FL_LASER.Remove
					and d:IsA("BasePart") and isLaserName(d.Name) then
					hidePart(d)
				end
			end)
			FL_LASER.Conn = RunService.Heartbeat:Connect(function(dt)
				if not FL_LASER.Enabled or not FL_LASER.Remove then return end
				if qhead > #q then
					cooldown = cooldown + dt
					if cooldown >= FL_LASER.RescanEvery then
						cooldown = 0
						FL_LASER.Sweep()
					end
					return
				end
				FL_LASER.ScanStep()
			end)
		end
	end

	function FL_LASER.Status()
		local done = (qhead > #q)
		return {
			Enabled = FL_LASER.Enabled,
			Remove  = FL_LASER.Remove,
			Immune  = FL_LASER.Immune,
			Hidden  = FL_LASER.Hidden,
			Scanning = not done,
			Names   = table.concat(FL_LASER.Names, ","),
		}
	end
end

do
	local Players    = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	FL_RAGE = FL_RAGE or {}
	FL_RAGE.Enabled    = false
	FL_RAGE.Interval   = 0.1
	FL_RAGE.Range      = 500
	FL_RAGE.AliveOnly  = true
	FL_RAGE.Mode       = "all"
	FL_RAGE.CombatOnly = false
	FL_RAGE.Hits       = 0
	FL_RAGE.LastHits   = 0
	FL_RAGE.Conn       = nil
	FL_RAGE.Acc        = 0
	FL_RAGE.LastErr    = nil

	local function alive(plr)
		local c = plr.Character
		if not c then return false end
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then return (h.Health or 0) > 0 end
		return c:FindFirstChild("Head") ~= nil
	end
	FL_RAGE.Alive = alive

	local function faction(plr)
		local t = plr.Team
		return (t and t.Name) or "?"
	end
	FL_RAGE.Faction = faction

	function FL_RAGE.Pass(plr)
		if not plr or plr == LocalPlayer then return false end
		if FL_RAGE.AliveOnly and not alive(plr) then return false end
		if FL_RAGE.CombatOnly and plr:GetAttribute("CombatMode") ~= true then return false end
		local f = faction(plr)
		if FL_RAGE.Mode == "police" then return f == "Police" end
		if FL_RAGE.Mode == "civilian" then return f == "Civilian" end
		return true
	end

	local function selfRoot()
		local c = LocalPlayer.Character
		if not c then return nil end
		return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
	end

	function FL_RAGE.Fire()
		local myRoot = selfRoot()
		local n = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if FL_RAGE.Pass(plr) then
				local inRange = true
				if myRoot then
					local c = plr.Character
					local root = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
					if root then
						inRange = (root.Position - myRoot.Position).Magnitude <= FL_RAGE.Range
					end
				end
				if inRange and FL_DMG and FL_DMG.Hit then
					local ok, done = pcall(FL_DMG.Hit, plr)
					if ok and done then n = n + 1 end
				end
			end
		end
		FL_RAGE.LastHits = n
		FL_RAGE.Hits = FL_RAGE.Hits + n
		if n > 0 then FL_RAGE.LastErr = nil end
		return n
	end

	function FL_RAGE.Set(on)
		FL_RAGE.Enabled = on and true or false
		if FL_RAGE.Conn then
			FL_RAGE.Conn:Disconnect()
			FL_RAGE.Conn = nil
		end
		if FL_RAGE.Enabled then
			FL_RAGE.Conn = RunService.Heartbeat:Connect(function(dt)
				if not FL_RAGE.Enabled then return end
				local iv = tonumber(FL_RAGE.Interval) or 0.5
				if iv < 0.1 then iv = 0.1 end
				FL_RAGE.Acc = FL_RAGE.Acc + dt
				if FL_RAGE.Acc < iv then return end
				FL_RAGE.Acc = 0
				pcall(FL_RAGE.Fire)
			end)
		end
	end

	function FL_RAGE.Status()
		return {
			Enabled    = FL_RAGE.Enabled,
			Interval   = FL_RAGE.Interval,
			Range      = FL_RAGE.Range,
			Mode       = FL_RAGE.Mode,
			AliveOnly  = FL_RAGE.AliveOnly,
			CombatOnly = FL_RAGE.CombatOnly,
			LastHits   = FL_RAGE.LastHits,
			Hits       = FL_RAGE.Hits,
			LastErr    = FL_RAGE.LastErr,
		}
	end
end

do
	local RunService = game:GetService("RunService")
	local Players    = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	FL_CAR = FL_CAR or {}
	FL_CAR.Enabled  = false
	FL_CAR.Speed    = 50
	FL_CAR.MaxSpeed = 140
	FL_CAR._conn    = nil
	FL_CAR.LastErr  = nil
	FL_CAR.Found    = nil

	local function myVehicle()
		local plr = LocalPlayer
		if not plr then return nil end

		local ok, v = pcall(function() return plr:GetAttribute("InVehicle") end)
		if ok and typeof(v) == "Instance" and v.Parent then
			return v
		end

		local seat = nil
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		seat = hum and hum.SeatPart
		if not seat then
			local ok2, s = pcall(function() return plr:GetAttribute("Seat") end)
			if ok2 and typeof(s) == "Instance" then seat = s end
		end
		if not seat then return nil end

		local p2 = seat.Parent and seat.Parent.Parent
		if p2 and p2:IsA("Model") then
			return p2
		end

		local m = seat
		while m and m ~= workspace do
			if m:IsA("Model") and m:FindFirstChild("Config") then
				return m
			end
			m = m.Parent
		end
		return nil
	end
	FL_CAR.MyVehicle = myVehicle

	local function chassisOf(veh)
		local c = veh:FindFirstChild("_Chassis")
		if c and c:IsA("BasePart") then return c end
		c = veh:FindFirstChild("Chassis")
		if c and c:IsA("BasePart") then return c end
		for _, d in ipairs(veh:GetDescendants()) do
			if d:IsA("BasePart") and d:FindFirstChild("BodyGyro") then
				return d
			end
		end
		return veh.PrimaryPart
	end

	function FL_CAR.Step()
		if not FL_CAR.Enabled then return end

		local veh = myVehicle()
		if not veh then
			FL_CAR.LastErr = "没在车里"
			return
		end
		local chassis = chassisOf(veh)
		if not chassis or not chassis:IsA("BasePart") then
			FL_CAR.LastErr = "找不到底盘 _Chassis"
			return
		end

		local cam = workspace.CurrentCamera
		if not cam then return end
		local look = cam.CFrame.LookVector
		local dir = Vector3.new(look.X, 0, look.Z)
		if dir.Magnitude < 1e-4 then return end
		dir = dir.Unit

		local sp = tonumber(FL_CAR.Speed) or 50
		if sp > FL_CAR.MaxSpeed then sp = FL_CAR.MaxSpeed end
		local want = Vector3.new(dir.X * sp, 0, dir.Z * sp)

		local used = nil
		pcall(function()
			local center = chassis:FindFirstChild("Center")
			local lv = center and center:FindFirstChild("LinearVelocity")
			if lv then
				lv.Enabled = true
				lv.RelativeTo = Enum.ActuatorRelativeTo.World
				lv.VectorVelocity = want
				used = "LinearVelocity"
			end
		end)

		pcall(function()
			local cur = chassis.AssemblyLinearVelocity
			chassis.AssemblyLinearVelocity = Vector3.new(want.X, cur.Y, want.Z)
			if not used then used = "Velocity" end
		end)

		local bg = chassis:FindFirstChild("BodyGyro")
		if bg then
			pcall(function()
				bg.CFrame = CFrame.lookAt(chassis.Position, chassis.Position + dir)
			end)
		end

		FL_CAR.Found = used or "无"
		FL_CAR.LastErr = nil
	end

	function FL_CAR.Set(on)
		FL_CAR.Enabled = on and true or false
		if FL_CAR._conn then
			FL_CAR._conn:Disconnect()
			FL_CAR._conn = nil
		end
		if not FL_CAR.Enabled then return end
		FL_CAR._conn = RunService.RenderStepped:Connect(function()
			pcall(FL_CAR.Step)
		end)
	end

	function FL_CAR.Status()
		local veh = myVehicle()
		return {
			Enabled   = FL_CAR.Enabled,
			Speed     = FL_CAR.Speed,
			MaxSpeed  = FL_CAR.MaxSpeed,
			InVehicle = veh ~= nil,
			Vehicle   = veh and veh.Name or "无",
			Mover     = FL_CAR.Found or "无",
			LastErr   = FL_CAR.LastErr,
		}
	end
end

do
	local Players = game:GetService("Players")

	FL_NPC = FL_NPC or {}
	FL_NPC.Enabled  = false
	FL_NPC.Interval = 0.5
	FL_NPC.Killed   = 0
	FL_NPC.Deleted  = 0
	FL_NPC._thread  = nil
	FL_NPC.LastErr  = nil

	local function entities()
		local g = workspace:FindFirstChild("Gameplay")
		return g and g:FindFirstChild("Entities")
	end
	FL_NPC.Entities = entities

	function FL_NPC.List()
		local out = {}
		local ent = entities()
		if not ent then
			FL_NPC.LastErr = "找不到 Gameplay.Entities"
			return out
		end
		for _, m in ipairs(ent:GetChildren()) do
			if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
				local isPlayer = false
				pcall(function()
					isPlayer = Players:GetPlayerFromCharacter(m) ~= nil
				end)
				if not isPlayer then
					out[#out + 1] = m
				end
			end
		end
		FL_NPC.LastErr = nil
		return out
	end

	function FL_NPC.Kill(m)
		if not m or not m.Parent then return false end
		local hum = m:FindFirstChildOfClass("Humanoid")
		if not hum then return false end
		pcall(function()
			if FL_DMG and FL_DMG.Hit then
				FL_DMG.Hit(m)
			end
		end)
		pcall(function()
			hum.Health = 0
		end)
		FL_NPC.Killed = FL_NPC.Killed + 1
		return true
	end

	function FL_NPC.KillAll()
		local list = FL_NPC.List()
		local n = 0
		for _, m in ipairs(list) do
			if FL_NPC.Kill(m) then n = n + 1 end
		end
		return n
	end

	function FL_NPC.DeleteAll()
		local list = FL_NPC.List()
		local n = 0
		for _, m in ipairs(list) do
			pcall(function() m:Destroy() end)
			n = n + 1
		end
		FL_NPC.Deleted = FL_NPC.Deleted + n
		return n
	end

	function FL_NPC.Set(on)
		FL_NPC.Enabled = on and true or false
		if not FL_NPC.Enabled then
			return
		end
		if FL_NPC._thread then
			return
		end
		FL_NPC._thread = task.spawn(function()
			while FL_NPC.Enabled do
				pcall(FL_NPC.KillAll)
				task.wait(FL_NPC.Interval)
			end
			FL_NPC._thread = nil
		end)
	end

	function FL_NPC.Status()
		local list = FL_NPC.List()
		return {
			Enabled  = FL_NPC.Enabled,
			Interval = FL_NPC.Interval,
			Count    = #list,
			Killed   = FL_NPC.Killed,
			Deleted  = FL_NPC.Deleted,
			LastErr  = FL_NPC.LastErr,
		}
	end
end

do
	local UIS        = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Players    = game:GetService("Players")

	FL_FLY = FL_FLY or {}
	FL_FLY.Enabled   = false
	FL_FLY.Speed     = 40
	FL_FLY.VertSpeed = 30
	FL_FLY.UseCFrame = true
	FL_FLY._conn     = nil
	FL_FLY._movers   = nil
	FL_FLY._charConn = nil
	FL_FLY._lastErr  = nil

	local STATES = {
		Enum.HumanoidStateType.Climbing,
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Flying,
		Enum.HumanoidStateType.Freefall,
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.Jumping,
		Enum.HumanoidStateType.Landed,
		Enum.HumanoidStateType.Physics,
		Enum.HumanoidStateType.PlatformStanding,
		Enum.HumanoidStateType.Ragdoll,
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.RunningNoPhysics,
		Enum.HumanoidStateType.Seated,
		Enum.HumanoidStateType.StrafingNoPhysics,
		Enum.HumanoidStateType.Swimming,
	}

	local function localChar()
		local plr = Players.LocalPlayer
		local c = plr and plr.Character
		if not c or not c.Parent then return nil end
		return c
	end

	local function parts()
		local c = localChar()
		if not c then return nil end
		local hum = c:FindFirstChildWhichIsA("Humanoid")
		local root = c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
		local torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or root
		if not hum or not root or not torso then return nil end
		return c, hum, root, torso
	end

	local function setStates(hum, enabled)
		for _, st in ipairs(STATES) do
			pcall(function() hum:SetStateEnabled(st, enabled) end)
		end
	end

	local function freezeAnim(char, frozen)
		local anim = char:FindFirstChild("Animate")
		if anim then pcall(function() anim.Disabled = frozen end) end
		pcall(function()
			local h = char:FindFirstChildOfClass("Humanoid")
				or char:FindFirstChildOfClass("AnimationController")
			if not h then return end
			for _, t in next, h:GetPlayingAnimationTracks() do
				if frozen then
					pcall(function() t:AdjustSpeed(0) end)
				else
					pcall(function() t:AdjustSpeed(1) end)
				end
			end
		end)
	end

	local function moveDir(hum)
		local f, r = 0, 0
		if UIS:IsKeyDown(Enum.KeyCode.W) then f = f + 1 end
		if UIS:IsKeyDown(Enum.KeyCode.S) then f = f - 1 end
		if UIS:IsKeyDown(Enum.KeyCode.D) then r = r + 1 end
		if UIS:IsKeyDown(Enum.KeyCode.A) then r = r - 1 end
		if f == 0 and r == 0 then
			local md = hum.MoveDirection
			if md and md.Magnitude > 0.01 then return md end
			return Vector3.zero
		end
		local cam = workspace.CurrentCamera
		if not cam then return Vector3.zero end
		local lv = cam.CFrame.LookVector
		local rv = cam.CFrame.RightVector
		local fl = Vector3.new(lv.X, 0, lv.Z)
		local fr = Vector3.new(rv.X, 0, rv.Z)
		if fl.Magnitude < 1e-4 then fl = Vector3.new(0, 0, -1) end
		if fr.Magnitude < 1e-4 then fr = Vector3.new(1, 0, 0) end
		local v = fl.Unit * f + fr.Unit * r
		if v.Magnitude < 1e-4 then return Vector3.zero end
		return v.Unit * math.min(1, math.sqrt(f * f + r * r))
	end

	local function vertical()
		local v = 0
		if UIS:IsKeyDown(Enum.KeyCode.Space) then v = v + 1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl)
			or UIS:IsKeyDown(Enum.KeyCode.RightControl) then v = v - 1 end
		return v
	end

	local function moveTo(char, root, target)
		if not FL_FLY.UseCFrame and FL_AC and type(FL_AC.SafePivot) == "function" then
			local ok, done = pcall(FL_AC.SafePivot, target)
			if ok and done then return true end
		end
		local cf = CFrame.new(target, target + (root.CFrame.LookVector or Vector3.new(0, 0, -1)))
		local ok = pcall(function() root.CFrame = cf end)
		if not ok then
			ok = pcall(function() root.CFrame = CFrame.new(target) end)
		end
		pcall(function() char:PivotTo(cf) end)
		return ok
	end

	function FL_FLY.Step(dt)
		if not FL_FLY.Enabled then return end
		local char, hum, root = parts()
		if not char or not hum or not root then return end

		local dir = moveDir(hum) * FL_FLY.Speed
		local vy = vertical() * FL_FLY.VertSpeed
		if vy ~= 0 then dir = dir + Vector3.new(0, vy, 0) end

		local m = FL_FLY._movers
		if dir.Magnitude < 0.01 then
			if m and m.bv then pcall(function() m.bv.Velocity = Vector3.zero end) end
			return
		end

		local target = root.Position + dir * dt
		moveTo(char, root, target)

		if m and m.bv then pcall(function() m.bv.Velocity = Vector3.zero end) end
		if m and m.bg then pcall(function() m.bg.CFrame = CFrame.new(target) end) end
	end

	function FL_FLY.Start()
		local char, hum, _, torso = parts()
		if not char or not hum then return false end

		freezeAnim(char, true)
		setStates(hum, false)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end)
		pcall(function() hum.PlatformStand = true end)

		local bg = Instance.new("BodyGyro")
		bg.Name = "FLFlyGyro"
		bg.P = 9e4
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.CFrame = torso.CFrame
		bg.Parent = torso

		local bv = Instance.new("BodyVelocity")
		bv.Name = "FLFlyVel"
		bv.Velocity = Vector3.zero
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Parent = torso

		FL_FLY._movers = { bg = bg, bv = bv, torso = torso }
		return true
	end

	function FL_FLY.Stop()
		FL_FLY.Enabled = false
		if FL_FLY._conn then
			pcall(function() FL_FLY._conn:Disconnect() end)
			FL_FLY._conn = nil
		end
		local m = FL_FLY._movers
		if m then
			pcall(function() if m.bg then m.bg:Destroy() end end)
			pcall(function() if m.bv then m.bv:Destroy() end end)
			FL_FLY._movers = nil
		end
		local char, hum = parts()
		if char then
			freezeAnim(char, false)
			if hum then
				setStates(hum, true)
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
				pcall(function() hum.PlatformStand = false end)
			end
		end
	end

	function FL_FLY.Set(on)
		if not on then
			FL_FLY.Stop()
			return true
		end
		if FL_FLY.Enabled then return true end
		if not FL_FLY.Start() then
			FL_FLY._lastErr = "没有角色"
			return false
		end
		FL_FLY.Enabled = true
		FL_FLY._lastErr = nil

		local acc = 0
		FL_FLY._conn = RunService.Heartbeat:Connect(function(dt)
			if not FL_FLY.Enabled then return end
			acc = acc + dt
			if acc < 0.033 then return end
			local step = acc
			acc = 0
			pcall(FL_FLY.Step, step)
		end)

		if not FL_FLY._charConn then
			FL_FLY._charConn = Players.LocalPlayer.CharacterAdded:Connect(function()
				if FL_FLY.Enabled then FL_FLY.Stop() end
			end)
		end
		return true
	end

	function FL_FLY.Status()
		local _, hum, root = parts()
		return {
			Enabled  = FL_FLY.Enabled,
			Speed    = FL_FLY.Speed,
			VertSpeed= FL_FLY.VertSpeed,
			UseCFrame= FL_FLY.UseCFrame,
			HasChar  = root ~= nil,
			PlatformStand = hum and hum.PlatformStand or false,
			Movers   = FL_FLY._movers ~= nil,
			LastErr  = FL_FLY._lastErr,
		}
	end
end

FL_FEAT = {
	Stamina      = false,
	Food         = false,
	NoRagdoll    = false,
	AutoCuff     = false,

	Range       = 200,
	CuffReach   = 10,
	TeleportMaxDist = 80,
	Interval    = 0.5,
	Teleport    = false,
	CombatCheck = false,

	Core          = nil,
	Character     = nil,
	Inventory     = nil,
	Ragdoll       = nil,
	Orig          = {},
	LoopConn      = nil,
	MoneyThread   = nil,
	CuffThread    = nil,
	Syncing       = false,
}

FL_FEAT.Players    = game:GetService("Players")
FL_FEAT.RS         = game:GetService("RunService")
FL_FEAT.CAS        = game:GetService("ContextActionService")
FL_FEAT.GuiService = game:GetService("GuiService")

function FL_FEAT.Rainbow(n)
	n = n or 5
	return Color3.fromHSV(tick() % n / n, 1, 1)
end

function FL_FEAT.FindHui()
	local hui
	pcall(function()
		if type(gethui) == "function" then
			hui = gethui()
		end
	end)
	if hui then
		return hui
	end

	pcall(function()
		hui = game:FindService("CoreGui")
	end)
	if hui then
		return hui
	end

	local plr = FL_FEAT.Players.LocalPlayer
	if plr then
		pcall(function()
			hui = plr:WaitForChild("PlayerGui", 5)
		end)
		if not hui then
			pcall(function()
				hui = plr:FindFirstChild("PlayerGui")
			end)
		end
	end
	return hui
end

function FL_FEAT.GetPlayer(player)
	player = player or FL_FEAT.Players.LocalPlayer
	if not player then
		return nil
	end

	local seen, list = {}, {}
	local function add(model)
		if model and typeof(model) == "Instance" and model:IsA("Model") and not seen[model] then
			seen[model] = true
			list[#list + 1] = model
		end
	end

	pcall(function()
		add(player.Character)
	end)
	pcall(function()
		local folder = workspace:FindFirstChild("Characters")
		if folder then
			add(folder:FindFirstChild(player.Name))
		end
	end)

	for _, char in ipairs(list) do
		local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid", true)
		local root = char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChild("Torso")
			or char:FindFirstChild("UpperTorso")
			or (humanoid and humanoid.RootPart)
		if not root then
			root = char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart")
		end
		if root then
			return char, humanoid, root
		end
	end

	return nil
end

function FL_FEAT.Alive(player)
	local _, humanoid = FL_FEAT.GetPlayer(player)
	return humanoid ~= nil and humanoid.Health > 0
end

function FL_FEAT.SafePivot(pos)
	if type(FL_AC) == "table" and type(FL_AC.SafePivot) == "function" and FL_AC.SafePivot(pos) then
		return true
	end
	local _, _, root = FL_FEAT.GetPlayer()
	if root then
		pcall(function()
			root.CFrame = CFrame.new(pos)
		end)
		return true
	end
	return false
end

function FL_FEAT.CombatOk(player, check)
	if not check then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end

function FL_FEAT.LoadFramework()
	if FL_FEAT.Core and FL_FEAT.Character then
		return true
	end
	pcall(function()
		local plr = FL_FEAT.Players.LocalPlayer
		local ps = plr:WaitForChild("PlayerScripts", 5)
		local fw = ps and ps:WaitForChild("Framework", 5)
		if not fw then
			return
		end
		FL_FEAT.Character = require(fw:WaitForChild("Character", 5))
		FL_FEAT.Core = require(fw:WaitForChild("Core", 5))
		local inv = fw.Character and fw.Character:FindFirstChild("Inventory")
		if inv then
			FL_FEAT.Inventory = require(inv)
		end
	end)
	return FL_FEAT.Core ~= nil
end

task.spawn(function()
	for _ = 1, 30 do
		if FL_FEAT.LoadFramework() then
			return
		end
		task.wait(2)
	end
end)

function FL_FEAT.SyncLoop()
	local need = FL_FEAT.Stamina or FL_FEAT.Food
	if need and not FL_FEAT.LoopConn then
		FL_FEAT.LoopConn = FL_FEAT.RS.Heartbeat:Connect(function()
			if FL_FEAT.Stamina or FL_FEAT.Food then
				local core = FL_FEAT.Core
				if core then
					if FL_FEAT.Stamina then
						pcall(function()
							core.stamina = 100
						end)
					end
					if FL_FEAT.Food then
						pcall(function()
							core.food = 100
						end)
					end
				end
			end
		end)
	elseif not need and FL_FEAT.LoopConn then
		FL_FEAT.LoopConn:Disconnect()
		FL_FEAT.LoopConn = nil
	end
end

function FL_FEAT.SetStamina(on)
	FL_FEAT.Stamina = on and true or false
	if FL_FEAT.Stamina then
		FL_FEAT.LoadFramework()
	end
	FL_FEAT.SyncLoop()
end

function FL_FEAT.SetFood(on)
	FL_FEAT.Food = on and true or false
	if FL_FEAT.Food then
		FL_FEAT.LoadFramework()
	end
	FL_FEAT.SyncLoop()
end

function FL_FEAT.HookRagdoll()
	if FL_FEAT.Orig.ragdollActivate then
		return true
	end
	local ok, mod = pcall(function()
		return require(ReplicatedStorage.Modules.Ragdoll)
	end)
	if not ok or type(mod) ~= "table" or type(mod.activate) ~= "function" then
		return false
	end

	FL_FEAT.Ragdoll = mod

	local rawActivate = mod.activate
	FL_FEAT.Orig.ragdollActivate = rawActivate
	mod.activate = function(a, b, c, ...)
		if FL_FEAT.NoRagdoll and b then
			return
		end
		return rawActivate(a, b, c, ...)
	end

	local rawServer = mod.activateServer
	if type(rawServer) == "function" then
		FL_FEAT.Orig.ragdollActivateServer = rawServer
		mod.activateServer = function(a, b, c, ...)
			if FL_FEAT.NoRagdoll and b then
				return
			end
			return rawServer(a, b, c, ...)
		end
	end

	return true
end

function FL_FEAT.UnhookRagdoll()
	local mod = FL_FEAT.Ragdoll
	if mod then
		pcall(function()
			if FL_FEAT.Orig.ragdollActivate then
				mod.activate = FL_FEAT.Orig.ragdollActivate
			end
			if FL_FEAT.Orig.ragdollActivateServer then
				mod.activateServer = FL_FEAT.Orig.ragdollActivateServer
			end
		end)
	end
	FL_FEAT.Orig.ragdollActivate = nil
	FL_FEAT.Orig.ragdollActivateServer = nil
end

function FL_FEAT.SetNoRagdoll(on)
	FL_FEAT.NoRagdoll = on and true or false
	if FL_FEAT.NoRagdoll then
		if not FL_FEAT.HookRagdoll() then
			task.spawn(function()
				for _ = 1, 60 do
					if not FL_FEAT.NoRagdoll then
						return
					end
					if FL_FEAT.HookRagdoll() then
						return
					end
					task.wait(0.5)
				end
			end)
		end
	else
		FL_FEAT.UnhookRagdoll()
	end
end

function FL_FEAT.Wanted(plr)
	local w = plr and plr:GetAttribute("WantedLevel")
	if w == true then return true end
	if type(w) == "number" then return w > 0 end
	return false
end

function FL_FEAT.CuffReachDistance()
	local r = FL_FEAT.CuffReach or 10
	pcall(function()
		local items = game.ReplicatedStorage:FindFirstChild("Gameplay")
		items = items and items:FindFirstChild("Items")
		local hc = items and items:FindFirstChild("Handcuffs")
		if hc then
			local v = hc:GetAttribute("MaxActivationDistance")
			if type(v) ~= "number" then
				local c = hc:FindFirstChild("MaxActivationDistance")
				v = c and c.Value
			end
			if type(v) == "number" and v > 0 then r = v end
		end
	end)
	return r
end

function FL_FEAT.StartAutoCuff()
	FL_FEAT.AutoCuff = true
	if FL_FEAT.CuffThread then
		return
	end

	FL_FEAT.CuffThread = task.spawn(function()
		while FL_FEAT.AutoCuff do
			local _, _, root = FL_FEAT.GetPlayer()
			if root and playerFunc then
				local me = FL_FEAT.Players.LocalPlayer
				if me.Team and me.Team.Name == "Police" then
					local reach = FL_FEAT.CuffReachDistance()
					for _, player in ipairs(FL_FEAT.Players:GetPlayers()) do
						local team = player.Team and player.Team.Name
						if player ~= me
							and FL_FEAT.Alive(player)
							and team ~= "Police" and team ~= "Medical" and team ~= "Fire"
							and team ~= "Road Service" and team ~= "Prisoner"
							and not player:GetAttribute("Arrested")
							and FL_FEAT.Wanted(player)
							and FL_FEAT.CombatOk(player, FL_FEAT.CombatCheck) then
							local _, _, targetRoot = FL_FEAT.GetPlayer(player)
							if targetRoot and (targetRoot.Position - root.Position).Magnitude <= reach then
								pcall(function()
									playerFunc:InvokeServer("handcuff", player, false)
								end)
							end
						end
					end
				end

				if FL_FEAT.Teleport then
					local bestPlayer, bestDist = nil, nil
					for _, player in ipairs(FL_FEAT.Players:GetPlayers()) do
						local wanted = player ~= me and FL_FEAT.Wanted(player)
						if wanted then
							local _, _, targetRoot = FL_FEAT.GetPlayer(player)
							if targetRoot then
								local dist = (targetRoot.Position - root.Position).Magnitude
								if dist <= FL_FEAT.Range and (not bestDist or dist < bestDist) then
									bestDist, bestPlayer = dist, player
								end
							end
						end
					end
					if bestPlayer then
						local _, _, targetRoot = FL_FEAT.GetPlayer(bestPlayer)
						if targetRoot then
							local jump = (targetRoot.Position - root.Position).Magnitude
							if jump <= (FL_FEAT.TeleportMaxDist or 80) then
								FL_FEAT.SafePivot(targetRoot.Position - targetRoot.CFrame.LookVector * 3)
							end
						end
					end
				end
			end
			task.wait(FL_FEAT.Interval)
		end
		FL_FEAT.CuffThread = nil
	end)
end

function FL_FEAT.StopAutoCuff()
	FL_FEAT.AutoCuff = false
	if FL_FEAT.CuffThread then
		task.cancel(FL_FEAT.CuffThread)
		FL_FEAT.CuffThread = nil
	end
end

function FL_FEAT.StopAll()
	FL_FEAT.Stamina = false
	FL_FEAT.Food = false
	if FL_FEAT.LoopConn then
		pcall(function()
			FL_FEAT.LoopConn:Disconnect()
		end)
		FL_FEAT.LoopConn = nil
	end

	pcall(FL_FEAT.StopAutoCuff)

	FL_FEAT.NoRagdoll = false
	pcall(FL_FEAT.UnhookRagdoll)

end

local tbl7 = {}
local tbl8 = {}
local n = 0
local flag2 = false
local tbl9 = {}
local tbl10 = {}

local function fn9()
	return {
		{ n = "车辆经销商", p = Vector3.new(3719.9502, 3.0185735, -333.31186), region = "圣奥里" },
		{ n = "医院", p = Vector3.new(3980.091, 2.8760607, -138.79454), region = "圣奥里" },
		{ n = "警察局", p = Vector3.new(3364.2732, 3.918808, -394.72336), region = "圣奥里" },
		{ n = "圣奥里修车店", p = Vector3.new(2782.4688, 2.6309958, -418.5993), region = "圣奥里" },
		{ n = "圣奥里银行", p = Vector3.new(3134.0542, 6.1160483, -171.36977), region = "圣奥里" },
		{ n = "圣奥里服装店", p = Vector3.new(3617.9126, 3.1072206, -452.82065), region = "圣奥里" },
		{ n = "圣奥里平民重生", p = Vector3.new(3741.115, 3.7205737, -438.106), region = "圣奥里" },
		{ n = "圣奥里码头", p = Vector3.new(4527.6562, -23.968239, -280.59357), region = "圣奥里" },
		{ n = "圣奥里餐饮店", p = Vector3.new(3182.4167, 3.018592, 426.5179), region = "圣奥里" },
		{ n = "消防部门", p = Vector3.new(3578.676, 8.408823, 579.6568), region = "圣奥里" },
		{ n = "宠物店", p = Vector3.new(3678.2373, 3.01792, 693.1146), region = "圣奥里" },
		{ n = "圣奥里大码头", p = Vector3.new(2736.3076, 2.630299, -1120.333), region = "圣奥里" },
		{ n = "圣奥里海滩桥下(消星点)", p = Vector3.new(3964.5044, -25.06821, -854.05725), region = "圣奥里" },
		{ n = "大景超级超市", p = Vector3.new(3936.5828, 3.038293, 1136.3264), region = "大景" },
		{ n = "转镜中心", p = Vector3.new(4152.92, 2.631675, 941.44604), region = "大景" },
		{ n = "道路服务", p = Vector3.new(4271.3325, 2.628108, 1200.0869), region = "大景" },
		{ n = "大景餐饮店", p = Vector3.new(4476.9976, 3.037825, 906.803), region = "大景" },
		{ n = "送货中心(美团外卖)", p = Vector3.new(4399.4194, 3.038999, 1609.4559), region = "大景" },
		{ n = "大景卖车店", p = Vector3.new(3434.3774, 42.931786, 2687.997), region = "大景" },
		{ n = "莱斯维尔餐饮店", p = Vector3.new(753.7578, 3.039824, 998.133), region = "莱斯维尔" },
		{ n = "莱斯维尔服装店", p = Vector3.new(820.7451, 2.766988, 1047.4457), region = "莱斯维尔" },
		{ n = "莱斯维尔自由广场", p = Vector3.new(926.5234, 2.630995, 865.7648), region = "莱斯维尔" },
		{ n = "莱斯维尔码头(游艇)", p = Vector3.new(947.8402, -22.529087, 1216.0857), region = "莱斯维尔" },
		{ n = "米尔顿左上加油站", p = Vector3.new(1145.6357, 2.630916, -864.2737), region = "米尔顿" },
		{ n = "米尔顿右下加油站", p = Vector3.new(-1646.8027, 2.630164, 1812.8947), region = "米尔顿" },
		{ n = "米尔顿上方加油站", p = Vector3.new(-900.70166, 2.630927, 1124.6831), region = "米尔顿" },
		{ n = "米尔顿居民区", p = Vector3.new(-528.56555, 2.630996, 1331.9817), region = "米尔顿" },
		{ n = "约克镇小银行", p = Vector3.new(-668.2172, 2.630995, -65.34784), region = "约克镇" },
		{ n = "约克镇修车厂", p = Vector3.new(-407.16302, 3.076807, -6.098211), region = "约克镇" },
		{ n = "约克镇枪店", p = Vector3.new(-323.8693, 3.037825, 37.14967), region = "约克镇" },
		{ n = "约克镇重生点", p = Vector3.new(-219.56032, 3.039824, -85.72543), region = "约克镇" },
		{ n = "约克镇当铺", p = Vector3.new(-168.51373, 3.039, -106.92653), region = "约克镇" },
		{ n = "约克镇卫星车", p = Vector3.new(-302.09357, 3.037825, -167.62102), region = "约克镇" },
		{ n = "约克镇中心点", p = Vector3.new(-275.9952, 2.630996, -139.98535), region = "约克镇" },
		{ n = "黑色市场", p = Vector3.new(1038.9698, -22.73295, 895.43024), region = "其他" },
		{ n = "鱼夫码头", p = Vector3.new(-50.147552, -24.555279, 1462.146), region = "其他" },
		{ n = "农场", p = Vector3.new(-1268.3392, 2.572412, 2560.0603), region = "其他" },
		{ n = "监狱门口", p = Vector3.new(-1697.9319, 2.630666, 1284.5674), region = "其他" },
		{ n = "监狱广场", p = Vector3.new(-1600.6024, 2.631028, 1268.06), region = "其他" },
		{ n = "代尔山", p = Vector3.new(847.063, 194.11575, -326.2127), region = "其他" },
		{ n = "水帘洞(消星点)", p = Vector3.new(3040.956, 109.68854, 2711.0693), region = "其他" },
		{ n = "大桥", p = Vector3.new(949.01495, 25.215754, 2897.6548), region = "其他" },
		{ n = "地图右下(消星点)", p = Vector3.new(-1651.385, 2.414712, 3225.2783), region = "其他" },
		{ n = "下部加油站", p = Vector3.new(2270.3782, 2.630927, 154.16148), region = "其他" },
		{ n = "游戏厅", p = Vector3.new(2934.8938, 2.956458, 1693.66), region = "其他" },
		{ n = "高尔夫", p = Vector3.new(2280.767, 3.037836, 1982.3573), region = "其他" },
		{ n = "修船厂", p = Vector3.new(4096.4053, -30.401447, 2865.0452), region = "其他" },
	}
end

local v7 = fn9()

local function fn10(arg)
	if not tbl2.TeleportEnabled or flag2 then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	pcall(function()
		if not FL_AC.SafePivot(arg) then
			humanoidRootPart.CFrame = CFrame.new(arg)
		end
	end)
end

local function fn11()
	if flag2 or not tbl2.NoclipEnabled then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end
end

local function fn12(noclipEnabled)
	tbl2.NoclipEnabled = noclipEnabled

	if noclipEnabled then
		fn11()
	else
		local character = localPlayer.Character

		if character then
			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = true
				end
			end
		end
	end
end

local flag3 = false
local thread = nil

local function fn13()
	return true
end

local function fn14()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local huge = math.huge
	local v8 = nil

	for _, player in ipairs(v5:GetPlayers()) do
		if player ~= localPlayer then
			local character2 = player.Character

			if character2 then
				local humanoid = character2:FindFirstChildOfClass("Humanoid")

				if not (not humanoid or humanoid.Health <= 0) then
					local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local attribute = player:GetAttribute("WantedLevel") or 0
						local attribute2 = player:GetAttribute("Team") or ""

						if attribute > 0 or attribute2 == "Criminal" then
							local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

							if magnitude < huge then
								huge = magnitude
								v8 = player
							end
						end
					end
				end
			end
		end
	end

	return v8
end

StartAutoArrestWanted = function()
	if flag3 then
		return
	end
	flag3 = true

	thread = task.spawn(function()
		while flag3 and tbl2.AutoArrestWantedEnabled do
			local flag4 = false

			if not fn13() then
				v:Notify({ Title = "自动抓捕", Content = "未装备手铐，暂停", Duration = 2 })
				task.wait(tbl2.AutoArrestWantedInterval)
				flag4 = true
			end

			if not flag4 then
				local v8 = fn14()

				if v8 then
					local character = v8.Character

					if character then
						local head = character:FindFirstChild("Head")
						local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

						if head and humanoidRootPart then
							local character2 = localPlayer.Character

							if character2 then
								local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

								if humanoidRootPart2 then
									humanoidRootPart2.CFrame = CFrame.new(head.Position + Vector3.new(0, 1.5, 0))
									task.wait(0.1)

									local ok, result = pcall(function()
										game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PlayerFunc"):InvokeServer("handcuff", v8, false)
									end)

									if ok then
										v:Notify({ Title = "自动抓捕", Content = "已抓捕 " .. v8.Name, Duration = 1 })
									else
										v:Notify({ Title = "抓捕失败", Content = result or "未知错误", Duration = 1 })
									end
								end
							end
						end
					end
				else
					v:Notify({ Title = "自动抓捕", Content = "未找到通缉玩家", Duration = 1 })
				end
			end

			local autoArrestWantedInterval = tbl2.AutoArrestWantedInterval

			while autoArrestWantedInterval > 0 and flag3 and tbl2.AutoArrestWantedEnabled do
				task.wait(0.1)
				autoArrestWantedInterval -= 0.1
			end
		end

		flag3 = false
	end)
end

StopAutoArrestWanted = function()
	flag3 = false

	if thread then
		task.cancel(thread)
		thread = nil
	end
end

local function fn15(arg)
	if not tbl2.AimCheckWall then
		return true
	end
	local currentCamera2 = workspace.CurrentCamera
	if not currentCamera2 then
		return true
	end
	local position = currentCamera2.CFrame.Position
	local unit = (arg.Position - position).Unit
	local magnitude = (arg.Position - position).Magnitude
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local hit = workspace:Raycast(position, unit * magnitude, raycastParams)

	if hit then
		local instance = hit.Instance
		if instance and instance:IsDescendantOf(arg.Parent) then
			return true
		end
		return false
	end

	return true
end

local function fn16()
	if not tbl2.AimEnabled or flag2 then
		return
	end
	local currentCamera2 = workspace.CurrentCamera
	if not currentCamera2 then
		return
	end
	local v8 = localPlayer
	if not v8.Character then
		return
	end
	local vector2 = Vector2.new(currentCamera2.ViewportSize.X / 2, currentCamera2.ViewportSize.Y / 2)
	local aimMaxDistance = tbl2.AimMaxDistance
	local huge = math.huge
	local v9 = nil

	for _, player in ipairs(v5:GetPlayers()) do
		if player ~= v8 then
			if player.Character then
				local head = player.Character:FindFirstChild("Head")

				if head then
					if not (aimMaxDistance < (head.Position - currentCamera2.CFrame.Position).Magnitude) then
						local v10, v11 = currentCamera2:WorldToScreenPoint(head.Position)

						if v11 then
							if fn15(head) then
								local magnitude = (Vector2.new(v10.X, v10.Y) - vector2).Magnitude

								if magnitude <= 200 and magnitude < huge then
									huge = magnitude
									v9 = head
								end
							end
						end
					end
				end
			end
		end
	end

	if v9 then
		local n2 = 1 / (tbl2.AimSmoothness + 1)
		currentCamera2.CFrame = currentCamera2.CFrame:Lerp(CFrame.lookAt(currentCamera2.CFrame.Position, v9.Position), n2)
	end
end

ApplyHitbox = function()
	if flag2 or not tbl2.HitboxEnabled then
		return
	end
	local players = v5:GetPlayers()
	local tbl11 = {}

	for i = 1, #players do
		local v8 = players[i]

		if v8 ~= localPlayer and v8.Character then
			if not (tbl2.WhitelistEnabled and tbl7[v8.UserId]) then
				local character = v8.Character
				local head = character:FindFirstChild("Head")
				local humanoid = character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 and head then
					head.Size = Vector3.new(tbl2.HitboxSize, tbl2.HitboxSize, tbl2.HitboxSize)
					head.Transparency = 1
					head.Color = Color3.fromRGB(255, 215, 0)
					head.Material = Enum.Material.Neon
					head.CanCollide = false
					tbl11[head] = true
				end
			end
		end
	end

	for k in pairs(tbl8) do
		if not tbl11[k] and k and k.Parent then
			k.Size = Vector3.new(2, 1, 1)
			k.Transparency = 0
			k.CanCollide = true
			k.Color = Color3.new(1, 1, 1)
			k.Material = Enum.Material.Plastic
		end
	end

	tbl8 = tbl11
end

ResetHitbox = function()
	for k in pairs(tbl8) do
		if k and k.Parent then
			k.Size = Vector3.new(2, 1, 1)
			k.Transparency = 0
			k.CanCollide = true
			k.Color = Color3.new(1, 1, 1)
			k.Material = Enum.Material.Plastic
		end
	end

	tbl8 = {}
end

UpdateWhitelist = function()
	if flag2 then
		return
	end
	tbl7 = {}
	local players = v5:GetPlayers()

	for i = 1, #players do
		local v8 = players[i]

		if v8 ~= localPlayer then
			pcall(function()
				if v8:IsFriendsWith(localPlayer.UserId) then
					tbl7[v8.UserId] = true
				end
			end)
		end
	end
end

local Players3 = game:GetService("Players")
local RunService_ = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Workspace")
local localPlayer3 = Players3.LocalPlayer
local playerEvent = ReplicatedStorage2:WaitForChild("Remote"):WaitForChild("PlayerEvent")
local flag5 = false
local connection2 = nil
local tbl11 = {}
local tbl12 = {}
local tbl13 = {}
local n4 = 0
local n5 = 20
local n6 = 30
local n7 = 2500

local function fn19()
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoidRootPart or not humanoid then
		return
	end
	local attribute = localPlayer:GetAttribute("WantedLevel")

	if not attribute or attribute <= 0 then
		for _, v8 in pairs(tbl12) do
			pcall(function()
				v8:Destroy()
			end)
		end

		for _, v8 in pairs(tbl13) do
			pcall(function()
				v8:Destroy()
			end)
		end

		table.clear(tbl12)
		table.clear(tbl13)
		return
	end

	local position = humanoidRootPart.Position
	local huge = math.huge
	local v8 = nil
	local flag6 = false

	for _, player in ipairs(Players3:GetPlayers()) do
		if player ~= localPlayer and player.Team and player.Team.Name == "Police" then
			local character2 = player.Character

			if character2 and character2:FindFirstChild("HumanoidRootPart") then
				local position2 = character2.HumanoidRootPart.Position
				local n8 = position.X - position2.X
				local n9 = position.Z - position2.Z
				local n10 = n8 * n8 + n9 * n9
				local flag7 = false

				if tbl11[player] then
					local v9 = tbl11[player]

					if n7 < (v9.X - position2.X) ^ 2 + (v9.Z - position2.Z) ^ 2 then
						n4 = 10
						flag7 = true
					end
				end

				tbl11[player] = position2

				if not tbl12[player] then
					local highlight = Instance.new("Highlight")
					highlight.FillColor = Color3.fromRGB(255, 0, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
					highlight.FillTransparency = 0.3
					highlight.OutlineTransparency = 0
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = character2
					tbl12[player] = highlight
				end

				local head = character2:FindFirstChild("Head")

				if head and not tbl13[player] then
					local billboardGui = Instance.new("BillboardGui")
					billboardGui.AlwaysOnTop = true
					billboardGui.Size = UDim2.new(0, 120, 0, 50)
					billboardGui.StudsOffset = Vector3.new(0, 3.5, 0)
					local textLabel = Instance.new("TextLabel")
					textLabel.Size = UDim2.new(1, 0, 1, 0)
					textLabel.BackgroundTransparency = 1
					textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
					textLabel.TextStrokeTransparency = 0
					textLabel.TextScaled = true
					textLabel.Font = Enum.Font.GothamBlack
					textLabel.Parent = billboardGui
					billboardGui.Parent = head
					tbl13[player] = billboardGui
				end

				if tbl13[player] then
					local v9 = math.sqrt(n10)
					tbl13[player].TextLabel.Text = string.format("[警察]\n%.1fm", v9)
				end

				if n10 < huge then
					huge = n10
					v8 = position2
					flag6 = flag7
				end
			end
		end
	end

	for k in pairs(tbl11) do
		if not k.Parent or not k.Team or k.Team.Name ~= "Police" then
			if tbl12[k] then
				pcall(function()
					tbl12[k]:Destroy()
				end)

				tbl12[k] = nil
			end

			if tbl13[k] then
				pcall(function()
					tbl13[k]:Destroy()
				end)

				tbl13[k] = nil
			end

			tbl11[k] = nil
		end
	end

	if v8 and huge < ((n4 > 0 or flag6) and n6 * n6 or n5 * n5) then
		local v9 = math.sqrt(huge)
		local n8 = position.X - v8.X
		local n9 = position.Z - v8.Z
		local n10, n11

		if v9 > 0.001 then
			n10 = n8 / v9
			n11 = n9 / v9
		else
			local n12 = math.random() * 2 * 3.1415926535897931
			n10 = math.cos(n12)
			n11 = math.sin(n12)
		end

		local noDizzinessSpeed = tbl2.NoDizzinessSpeed or 24

		if humanoid and humanoid.SeatPart then
			pcall(function()
				local seatPart = humanoid.SeatPart
				seatPart.Velocity = Vector3.new(n10 * 40, seatPart.Velocity.Y, n11 * 40)
			end)
		else
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(n10 * noDizzinessSpeed, humanoidRootPart.AssemblyLinearVelocity.Y, n11 * noDizzinessSpeed)
		end
	end

	if localPlayer:GetAttribute("EscortedBy") then
		localPlayer:SetAttribute("EscortedBy", nil)

		if v8 then
			local n8 = position.X - v8.X
			local n9 = position.Z - v8.Z
			local v9 = math.sqrt(n8 * n8 + n9 * n9)

			if v9 > 0.001 then
				humanoidRootPart.CFrame = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position + position + Vector3.new(n8 / v9, 0, n9 / v9) * 15
			end
		end
	end

	if humanoid.Sit then
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end

	if n4 > 0 then
		n4 -= 1
	end
end

local function fn20()
	if flag5 then
		return
	end
	flag5 = true
	tbl2.AntiPolicePushEnabled = true

	connection2 = RunService_.RenderStepped:Connect(function()
		if not tbl2.AntiPolicePushEnabled then
			StopAntiPolice()
			return
		end
		fn19()
	end)
end

local function fn21()
	flag5 = false
	tbl2.AntiPolicePushEnabled = false

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	for _, v8 in pairs(tbl12) do
		pcall(function()
			v8:Destroy()
		end)
	end

	for _, v8 in pairs(tbl13) do
		pcall(function()
			v8:Destroy()
		end)
	end

	table.clear(tbl12)
	table.clear(tbl13)
	table.clear(tbl11)
	n4 = 0
end

ToggleAntiPolice = function(antiPolicePushEnabled)
	tbl2.AntiPolicePushEnabled = antiPolicePushEnabled

	if antiPolicePushEnabled then
		fn20()
	else
		fn21()
	end
end

local connection3 = nil

local function fn22()
	local world = workspace:FindFirstChild("World")
	world = world and world:FindFirstChild("Interactive")
	world = world and world:FindFirstChild("Intersections")
	if not world then
		return
	end

	for _, descendant in ipairs(world:GetDescendants()) do
		if descendant.Name == "_TrafficLightArea" then
			pcall(function()
				descendant:Destroy()
			end)
		end
	end
end

local function fn23()
	if connection3 then
		return
	end
	fn22()
	local world = workspace:FindFirstChild("World")
	world = world and world:FindFirstChild("Interactive")
	world = world and world:FindFirstChild("Intersections")
	if not world then
		return
	end

	connection3 = world.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "_TrafficLightArea" then
			task.defer(function()
				if descendant and descendant.Parent then
					pcall(function()
						descendant:Destroy()
					end)
				end
			end)
		end
	end)
end

local function fn24()
	if connection3 then
		connection3:Disconnect()
		connection3 = nil
	end
end

local connection4 = nil

StartNoDizziness = function()
	if connection4 then
		return
	end

	connection4 = RunService_.RenderStepped:Connect(function()
		local character = localPlayer.Character
		if not character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not humanoidRootPart then
			return
		end
		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then
			local noDizzinessSpeed = tbl2.NoDizzinessSpeed or 24
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(moveDirection.X * noDizzinessSpeed, humanoidRootPart.AssemblyLinearVelocity.Y, moveDirection.Z * noDizzinessSpeed)
		end
	end)
end

StopNoDizziness = function()
	if connection4 then
		connection4:Disconnect()
		connection4 = nil
	end

	local character = localPlayer.Character

	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid and humanoidRootPart then
			local moveDirection = humanoid.MoveDirection

			if moveDirection.Magnitude > 0 then
				local walkSpeed = humanoid.WalkSpeed
				humanoidRootPart.AssemblyLinearVelocity = Vector3.new(moveDirection.X * walkSpeed, humanoidRootPart.AssemblyLinearVelocity.Y, moveDirection.Z * walkSpeed)
			end
		end
	end
end

task.spawn(function()
	task.wait(0.5)
	local currentCamera2 = workspace.CurrentCamera

	local function fn25()
		if not tbl2.BulletTrackEnabled then
			return nil
		end
		local cFrame = currentCamera2.CFrame
		local position = cFrame.Position
		local lookVector = cFrame.LookVector
		local screenMode = tbl2.ScreenMode
		local distanceMode = tbl2.DistanceMode

		if not screenMode and not distanceMode then
			screenMode = true
		end

		if distanceMode and not screenMode then
			local huge = math.huge
			local v8 = nil

			for _, player in ipairs(Players3:GetPlayers()) do
				if not (player == localPlayer or not player.Character) then
					local head = player.Character:FindFirstChild("Head")

					if head then
						local magnitude = (head.Position - position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v8 = head
						end
					end
				end
			end

			return v8
		end

		local n8 = -1
		local v8 = nil

		for _, player in pairs(Players3:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local head = player.Character:FindFirstChild("Head")

				if head then
					local v9 = lookVector:Dot((head.Position - position).Unit)

					if v9 > 0.2 and v9 > n8 then
						n8 = v9
						v8 = head
					end
				end
			end
		end

		if v8 then
			return v8
		end
		local huge = math.huge
		local v9 = nil

		for _, player in pairs(Players3:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local head = player.Character:FindFirstChild("Head")

				if head then
					local magnitude = (head.Position - position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v9 = head
					end
				end
			end
		end

		return v9
	end

	local ok, result = pcall(require, game:GetService("ReplicatedStorage").Modules.Algorithms)

	if ok and result and type(result.bulletSpread) == "function" then
		local bulletSpread = result.bulletSpread

		result.bulletSpread = function(arg, arg2)
			local _t = FL_TRACK and FL_TRACK.Target
			if _t and _t.part and _t.part.Parent then
				local _d = _t.part.Position - currentCamera2.CFrame.Position
				if _d.Magnitude > 0.01 then
					return bulletSpread(_d.Unit, 0)
				end
			end

			return bulletSpread(arg, arg2)
		end

		local tbl14 = getmetatable(result) or {}
		setmetatable(result, { __index = tbl14.__index, __newindex = tbl14.__newindex })
	end
end)

local thread2 = nil
local flag6 = false
local hackingMinigame = nil
local v8 = nil

local function fn27()
	if flag6 then
		return true
	end
	local localPlayer4 = game.Players.LocalPlayer
	local framework = localPlayer4:FindFirstChild("PlayerScripts") and localPlayer4.PlayerScripts:FindFirstChild("Framework")
	if not framework then
		return false
	end
	local ok, result = pcall(require, framework.Character)
	if not ok then
		return false
	end

	if not result or type(result.hackingMinigame) ~= "function" then
		return false
	end
	v8 = result
	hackingMinigame = result.hackingMinigame

	result.hackingMinigame = function(arg, arg2, arg3, arg4)
		if arg == "ATM Hack" then
			return true
		end
		return hackingMinigame(arg, arg2, arg3, arg4)
	end

	flag6 = true
	return true
end

local function fn28()
	if thread2 then
		return
	end

	thread2 = task.spawn(function()
		while true do
			if tbl2.AutoATMHack and not flag2 then
				if not fn27() then
					task.wait(0.3)
					continue
				end
			end

			break
		end
	end)
end

local function fn29()
	if thread2 then
		task.cancel(thread2)
		thread2 = nil
	end

	if flag6 and v8 and hackingMinigame then
		v8.hackingMinigame = hackingMinigame
		flag6 = false
		v8 = nil
		hackingMinigame = nil
	end
end

local flag7 = false
local hackingMinigame2 = nil
local v9 = nil
local thread3 = nil

local function fn30()
	if flag7 then
		return true
	end
	local localPlayer4 = game.Players.LocalPlayer
	local framework = localPlayer4:FindFirstChild("PlayerScripts") and localPlayer4.PlayerScripts:FindFirstChild("Framework")
	if not framework then
		return false
	end
	local ok, result = pcall(require, framework.Character)
	if not ok then
		return false
	end

	if not result or type(result.hackingMinigame) ~= "function" then
		return false
	end
	v9 = result
	hackingMinigame2 = result.hackingMinigame

	result.hackingMinigame = function()
		return true
	end

	flag7 = true
	return true
end

local function fn31()
	if not flag7 then
		return
	end

	if v9 and hackingMinigame2 then
		v9.hackingMinigame = hackingMinigame2
	end

	flag7 = false
	hackingMinigame2 = nil
	v9 = nil
end

local function fn33()
	if thread3 then
		task.cancel(thread3)
		thread3 = nil
	end

	fn31()
end

local BACKGROUND_IDS = {
	79035780602083, 115285451809270, 126071927593389, 105661627105291,
	77508472999355, 107872248048503, 72869227895853, 126952765872927,
	83853972032276,
}
local RANDOM_BG = "rbxassetid://" .. tostring(BACKGROUND_IDS[math.random(1, #BACKGROUND_IDS)])

local function preloadImage(url)
	local img = Instance.new("ImageLabel")
	img.Image = url
	img.Size = UDim2.new(0, 1, 0, 1)
	img.BackgroundTransparency = 1
	img.Parent = LocalPlayer:WaitForChild("PlayerGui")
	local loaded = false
	local timeout = tick() + 5
	if img.IsLoaded then loaded = true end
	while not loaded and tick() < timeout do
		if img.IsLoaded then loaded = true end
		task.wait(0.05)
	end
	img:Destroy()
	return loaded
end

preloadImage(RANDOM_BG)

local v10 = v:CreateWindow({
	Title = "FL",
	Icon = "snowflake",
	Author = "CX",
	Folder = "FL",
	Size = UDim2.fromOffset(620, 480),
	Transparent = false,
	Theme = "Dark",
	User = { Enabled = true, Anonymous = true },
	SideBarWidth = 200,
	HideSearchBar = false,
	ScrollBarEnabled = true,
	ToggleKey = Enum.KeyCode.RightShift,
	Background = RANDOM_BG,
	BackgroundImageTransparency = 0,
})

pcall(function()
	v10:Tag({ Title = "v1.0" })
end)

do
	local TOGGLE_KEY = Enum.KeyCode.RightShift

	local libBound = false
	if type(v10.SetToggleKey) == "function" then
		libBound = pcall(function() v10:SetToggleKey(TOGGLE_KEY) end)
	end
	if v10.ToggleKey ~= nil then libBound = true end

	if not libBound then
		pcall(function()
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.KeyCode == TOGGLE_KEY and type(v10.Toggle) == "function" then
					v10:Toggle()
				end
			end)
		end)
	end
end

local BG_TRANSPARENCY = 0

local function applyBackgroundImage(url)
	if not url or url == "" then return false end

	local ok = false

	local ok1 = pcall(function()
		v10:SetBackgroundImage(url)
		v10:SetBackgroundImageTransparency(BG_TRANSPARENCY)
	end)
	if ok1 then ok = true end

	local ok2 = pcall(function()
		local ui = v10.UIElements
		local main = ui and ui.Main
		if not main then return end
		local bgLayer = main:FindFirstChild("Background")
			or main:FindFirstChildWhichIsA("ImageLabel")
		if not bgLayer then return end

		if bgLayer:IsA("ImageLabel") then
			bgLayer.Image = url
			bgLayer.ImageTransparency = BG_TRANSPARENCY
			bgLayer.ScaleType = Enum.ScaleType.Crop
		end

		for _, child in ipairs(bgLayer:GetDescendants()) do
			if child:IsA("ImageLabel") then
				if child.Image == "" then child.Image = url end
				child.ImageTransparency = BG_TRANSPARENCY
				child.ScaleType = Enum.ScaleType.Crop
			end
		end

		if bgLayer:IsA("GuiObject") then
			bgLayer.ZIndex = 0
		end
	end)
	if ok2 then ok = true end

	return ok
end

applyBackgroundImage(RANDOM_BG)

pcall(function()
	if type(v10.CreateTopbarButton) ~= "function" then
		return
	end

	v10:CreateTopbarButton("theme-switcher", "moon", function()
		pcall(function()
			local cur = "Dark"
			if type(v.GetCurrentTheme) == "function" then
				local okCur, got = pcall(function() return v:GetCurrentTheme() end)
				if okCur and type(got) == "string" then cur = got end
			end

			local nextTheme = (cur == "Indigo") and "Dark" or "Indigo"
			v:SetTheme(nextTheme)

			if type(v.Notify) == "function" then
				v:Notify({ Title = "主题", Content = "切换为 " .. nextTheme, Duration = 2 })
			end
		end)
	end, 990)
end)

local v11 = v10:Section({ Title = "主要功能", Opened = true })
FL_FEAT_TAB = v11:Tab({ Title = "主要功能", Icon = "sliders-h" })
local v12 = v11:Tab({ Title = "交互设置", Icon = "hand" })

v12:Slider({
	Title = "按住时间",
	Value = { Min = 0, Max = 10, Default = 0 },
	Callback = function(holdTime)
		tbl2.HoldTime = holdTime

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				descendant.HoldDuration = holdTime
			end
		end
	end,
})

v12:Slider({
	Title = "触发距离",
	Value = { Min = 5, Max = 150, Default = 25 },
	Callback = function(distance)
		tbl2.Distance = distance

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				descendant.MaxActivationDistance = distance
			end
		end
	end,
})

local v13 = v11:Tab({ Title = "警察", Icon = "badge" })

v13:Toggle({
	Title = "自动全图逮捕",
	Value = false,
	Callback = function(autoArrestWantedEnabled)
		tbl2.AutoArrestWantedEnabled = autoArrestWantedEnabled

		if autoArrestWantedEnabled then
			StartAutoArrestWanted()
		else
			StopAutoArrestWanted()
		end
	end,
})

v13:Slider({
	Title = "逮捕间隔",
	Value = { Min = 0.5, Max = 10, Default = 1.5 },
	Callback = function(autoArrestWantedInterval)
		tbl2.AutoArrestWantedInterval = autoArrestWantedInterval
	end,
})

v12:Divider()

v12:Toggle({
	Title = "启用人物穿墙",
	Value = false,
	Callback = function(arg)
		fn12(arg)
	end,
})

local v14 = v11:Tab({ Title = "战斗", Icon = "crosshair" })

do
	local tireSec = v14:Section({ Title = "卸除车辆轮胎" })

	tireSec:Toggle({ Title = "自动秒卸除范围内车辆轮胎", Value = FL_TIRE.Enabled,
		Callback = function(v) FL_TIRE.Set(v) end })

	tireSec:Slider({ Title = "作用范围", Value = { Min = 50, Max = 3000, Default = FL_TIRE.Range },
		Callback = function(v) if type(v) == "number" then FL_TIRE.Range = v end end })

	tireSec:Slider({ Title = "扫描间隔（×100 秒）", Value = { Min = 5, Max = 100, Default = 15 },
		Callback = function(v) if type(v) == "number" then FL_TIRE.Interval = v / 100 end end })

	tireSec:Dropdown({ Title = "射线形状", Values = { "贴脸（不限距离/可穿墙）", "从自己出发（像真开枪）" },
		Value = "贴脸（不限距离/可穿墙）",
		Callback = function(v) FL_TIRE.RayMode = (v == "从自己出发（像真开枪）") and "self" or "near" end })

	tireSec:Button({ Title = "自检：当前可打轮胎", Callback = function()
		local d = FL_TIRE.Status()
		local msg = string.format("已开 %s | 累计打爆 %d | 上次命中 %s\n范围 %d | 间隔 %.2fs | 形状 %s\n目标：警察车 + 驾驶者战斗模式的车\n%s",
			tostring(d.Enabled), d.Count, tostring(d.LastHit), d.Range, d.Interval, d.RayMode, tostring(d.LastErr or ""))
		pcall(function() v10:Notify({ Title = "打轮胎自检", Content = msg, Duration = 12 }) end)
	end })
end

do
	local cuffSec = v14:Section({ Title = "防手铐（阻止触发）" })

	cuffSec:Toggle({ Title = "阻止警察靠近（进圈就挪出）", Value = FL_CUFF.Enabled,
		Callback = function(v) FL_CUFF.Set(v) end })

	cuffSec:Slider({ Title = "警戒圈半径", Value = { Min = 12, Max = 80, Default = FL_CUFF.Ring },
		Callback = function(v) if type(v) == "number" then FL_CUFF.Ring = v end end })

	cuffSec:Slider({ Title = "挪出圈外距离", Value = { Min = 2, Max = 40, Default = FL_CUFF.Margin },
		Callback = function(v) if type(v) == "number" then FL_CUFF.Margin = v end end })

	cuffSec:Toggle({ Title = "只在被通缉时", Value = FL_CUFF.OnlyWanted,
		Callback = function(v) FL_CUFF.OnlyWanted = v end })

	cuffSec:Button({ Title = "自检：附近警察", Callback = function()
		local d = FL_CUFF.Status()
		local msg = string.format("已开 %s | 本机通缉 %s | 已挪开 %d 次\n最近警察 %s | 距离 %s\n警戒圈 %d / 挪出 %d",
			tostring(d.Enabled), tostring(d.Wanted), d.Pushes, tostring(d.Nearest),
			d.NearestDist and string.format("%.0f", d.NearestDist) or "-", d.Ring, d.Margin)
		pcall(function() v10:Notify({ Title = "防手铐自检", Content = msg, Duration = 12 }) end)
	end })
end

do
	local laserSec = v14:Section({ Title = "移除红色激光" })

	laserSec:Toggle({ Title = "移除红色激光", Value = FL_LASER.Enabled,
		Callback = function(v) FL_LASER.Set(v) end })

	laserSec:Toggle({ Title = "免疫激光伤害", Value = FL_LASER.Immune,
		Callback = function(v)
			FL_LASER.Immune = v
			if FL_AC then FL_AC.LaserImmune = FL_LASER.Enabled and v or false end
		end })

	laserSec:Button({ Title = "自检：激光", Callback = function()
		local d = FL_LASER.Status()
		local msg = string.format("已开 %s | 已隐藏 %d 个激光 | 免疫 %s\n扫描中 %s（分帧扫，不卡）| 部件名 %s",
			tostring(d.Enabled), d.Hidden, tostring(d.Immune),
			tostring(d.Scanning), d.Names)
		pcall(function() v10:Notify({ Title = "激光自检", Content = msg, Duration = 12 }) end)
	end })
end

do
	local rageSec = v14:Section({ Title = "RageBot" })

	rageSec:Toggle({ Title = "RageBot（范围内全员命中包）", Value = FL_RAGE.Enabled,
		Callback = function(v) FL_RAGE.Set(v) end })

	rageSec:Dropdown({ Title = "目标阵营", Values = { "全部", "只打警察", "只打平民" }, Value = "全部",
		Callback = function(v)
			if v == "只打警察" then FL_RAGE.Mode = "police"
			elseif v == "只打平民" then FL_RAGE.Mode = "civilian"
			else FL_RAGE.Mode = "all" end
		end })

	rageSec:Toggle({ Title = "存活检测", Value = FL_RAGE.AliveOnly,
		Callback = function(v) FL_RAGE.AliveOnly = v end })

	rageSec:Toggle({ Title = "战斗检测（只打战斗模式的人）", Value = FL_RAGE.CombatOnly,
		Callback = function(v) FL_RAGE.CombatOnly = v end })

	rageSec:Slider({ Title = "作用范围（最高 500）", Value = { Min = 50, Max = 500, Default = math.min(FL_RAGE.Range or 500, 500) },
		Callback = function(v) if type(v) == "number" then FL_RAGE.Range = math.min(v, 500) end end })

	rageSec:Slider({ Title = "发包间隔（×0.1 秒；1 = 0.1s，10 = 1s）", Value = { Min = 1, Max = 100, Default = math.max(1, math.floor((FL_RAGE.Interval or 0.1) * 10 + 0.5)) },
		Callback = function(v) if type(v) == "number" then FL_RAGE.Interval = math.max(0.1, v / 10) end end })

	rageSec:Button({ Title = "自检：RageBot", Callback = function()
		local d = FL_RAGE.Status()
		local msg = string.format("已开 %s | 间隔 %.1fs | 范围 %d | 阵营 %s\n存活 %s | 战斗 %s | 上轮 %d | 累计 %d",
			tostring(d.Enabled), d.Interval, d.Range, d.Mode,
			tostring(d.AliveOnly), tostring(d.CombatOnly), d.LastHits, d.Hits)
		pcall(function() v10:Notify({ Title = "RageBot自检", Content = msg, Duration = 12 }) end)
	end })
end

do
	local npcSec = v14:Section({ Title = "任务 NPC（抢劫/侠盗猎车）" })

	npcSec:Toggle({ Title = "自动秒杀任务 NPC", Value = FL_NPC.Enabled,
		Callback = function(v) FL_NPC.Set(v) end })

	npcSec:Button({ Title = "立刻秒杀全部", Callback = function()
		local n = FL_NPC.KillAll()
		pcall(function() v10:Notify({ Title = "任务 NPC", Content = "秒杀 " .. n .. " 个", Duration = 8 }) end)
	end })

	npcSec:Button({ Title = "直接删除全部", Callback = function()
		local n = FL_NPC.DeleteAll()
		pcall(function() v10:Notify({ Title = "任务 NPC", Content = "删除 " .. n .. " 个", Duration = 8 }) end)
	end })

	npcSec:Button({ Title = "自检：任务 NPC", Callback = function()
		local d = FL_NPC.Status()
		local msg = string.format("已开 %s | 当前 %d 个 | 累计秒杀 %d | 删除 %d\n%s",
			tostring(d.Enabled), d.Count, d.Killed, d.Deleted, tostring(d.LastErr or "ok"))
		pcall(function() v10:Notify({ Title = "任务 NPC 自检", Content = msg, Duration = 12 }) end)
	end })
end

v14:Toggle({
	Title = "启用头部碰撞箱",
	Value = false,
	Callback = function(hitboxEnabled)
		tbl2.HitboxEnabled = hitboxEnabled

		if hitboxEnabled then
			ApplyHitbox()
		else
			ResetHitbox()
		end
	end,
})

v14:Slider({
	Title = "头部大小",
	Value = { Min = 5, Max = 40, Default = 10 },
	Callback = function(hitboxSize)
		tbl2.HitboxSize = hitboxSize

		if tbl2.HitboxEnabled then
			ApplyHitbox()
		end
	end,
})

v14:Divider()

v14:Toggle({
	Title = "无限子弹",
	Value = false,
	Callback = function(on)
		FL_WPN.SetInfiniteAmmo(on)
	end,
})

v14:Slider({
	Title = "锁定弹药数",
	Value = { Min = 10, Max = 9999, Default = 999 },
	Callback = function(v)
		if type(v) == "number" then FL_WPN.AmmoLock = v end
	end,
})

v14:Divider()

v14:Toggle({
	Title = "修改射速",
	Value = false,
	Callback = function(on)
		FL_WPN.SetRPM(on)
	end,
})

v14:Slider({
	Title = "目标 RPM",
	Value = { Min = 60, Max = 6000, Default = 1800 },
	Callback = function(v)
		if type(v) == "number" then
			FL_WPN.RPM = v
			if FL_WPN.RPMOn then FL_WPN.SetRPM(true, v) end
		end
	end,
})

v14:Divider()

v14:Toggle({
	Title = "修改射程（打多远）",
	Value = false,
	Callback = function(on)
		FL_WPN.SetRange(on)
	end,
})

v14:Slider({
	Title = "射程（studs）",
	Value = { Min = 600, Max = 20000, Default = 5000 },
	Callback = function(v)
		if type(v) == "number" then
			FL_WPN.Range = v
			if FL_WPN.RangeOn then FL_WPN.SetRange(true, v) end
		end
	end,
})

v14:Dropdown({
	Title = "开火模式",
	Values = { "不改", "单发", "连发", "点射" },
	Value = "不改",
	Callback = function(v)
		if v == "不改" then
			FL_WPN.SetMode(false)
		else
			local m = (v == "单发") and 1 or ((v == "连发") and 2 or 3)
			FL_WPN.SetMode(true, m)
		end
	end,
})

v14:Button({
	Title = "自检：武器",
	Callback = function()
		local d = FL_WPN.Status()
		local msg = string.format("武器 %s | Config %s\nRPM %s | 开火模式 %s | 射程 %s\n无限子弹 %s | 射速 %s | 射程开关 %s | %s",
			tostring(d.Weapon), tostring(d.HasCfg), tostring(d.RPM), tostring(d.Mode),
			tostring(d.Range), tostring(d.AmmoOn), tostring(d.RPMOn), tostring(d.RangeOn),
			tostring(d.LastErr or "ok"))
		pcall(function() v:Notify({ Title = "武器自检", Content = msg, Duration = 14 }) end)
	end,
})

v14:Toggle({
	Title = "好友检测 (白名单)",
	Value = false,
	Callback = function(whitelistEnabled)
		tbl2.WhitelistEnabled = whitelistEnabled

		if whitelistEnabled then
			UpdateWhitelist()
		end
	end,
})

v14:Divider()

v14:Divider()

local v15 = v14

do
	local crossSec = v15:Section({ Title = "准星" })

	crossSec:Toggle({ Title = "显示准星", Value = FL_CROSS.Enabled,
		Callback = function(v) FL_CROSS.Set(v) end })

	crossSec:Toggle({ Title = "准星旋转", Value = FL_CROSS.Spin,
		Callback = function(v) FL_CROSS.Spin = v end })

	crossSec:Slider({ Title = "旋转速度（度/秒）", Value = { Min = 10, Max = 720, Default = 90 },
		Callback = function(v) if type(v) == "number" then FL_CROSS.Speed = v end end })

	crossSec:Toggle({ Title = "彩虹准星", Value = FL_CROSS.Rainbow,
		Callback = function(v)
			FL_CROSS.Rainbow = v
			if not v and FL_CROSS.Enabled then FL_CROSS.Refresh() end
		end })

	crossSec:Slider({ Title = "彩虹速度（×100 圈/秒）", Value = { Min = 5, Max = 200, Default = 35 },
		Callback = function(v) if type(v) == "number" then FL_CROSS.HueSpeed = v / 100 end end })

	crossSec:Slider({ Title = "准星长度", Value = { Min = 4, Max = 60, Default = 18 },
		Callback = function(v) if type(v) == "number" then FL_CROSS.Size = v; FL_CROSS.Refresh() end end })

	crossSec:Slider({ Title = "准星粗细", Value = { Min = 1, Max = 8, Default = 2 },
		Callback = function(v) if type(v) == "number" then FL_CROSS.Thick = v; FL_CROSS.Refresh() end end })

	crossSec:Slider({ Title = "中心留空", Value = { Min = 0, Max = 40, Default = 6 },
		Callback = function(v) if type(v) == "number" then FL_CROSS.Gap = v; FL_CROSS.Refresh() end end })

	crossSec:Toggle({ Title = "中心点", Value = FL_CROSS.Center,
		Callback = function(v) FL_CROSS.Center = v; FL_CROSS.Refresh() end })

	pcall(function()
		crossSec:Colorpicker({ Title = "准星颜色", Default = FL_CROSS.Color,
			Callback = function(c)
				if typeof(c) == "Color3" then FL_CROSS.Color = c; FL_CROSS.Refresh() end
			end })
	end)
end

v15:Toggle({
	Title = "启用自瞄",
	Value = false,
	Callback = function(aimEnabled)
		tbl2.AimEnabled = aimEnabled
	end,
})

v15:Slider({
	Title = "平滑度",
	Value = { Min = 1, Max = 20, Default = 5 },
	Callback = function(aimSmoothness)
		tbl2.AimSmoothness = aimSmoothness
	end,
})

v15:Slider({
	Title = "检测距离",
	Value = { Min = 50, Max = 500, Default = 200 },
	Callback = function(aimMaxDistance)
		tbl2.AimMaxDistance = aimMaxDistance
	end,
})

v15:Toggle({
	Title = "墙壁检测",
	Value = true,
	Callback = function(aimCheckWall)
		tbl2.AimCheckWall = aimCheckWall
	end,
})

local v16 = v11:Tab({ Title = "移动", Icon = "move" })

do
	local carSec = v16:Section({ Title = "飞车" })

	carSec:Toggle({ Title = "飞车（车辆自动驾驶，视角方向即车头）", Value = FL_CAR.Enabled,
		Callback = function(v) FL_CAR.Set(v) end })

	carSec:Slider({ Title = "速度（最高 140）", Value = { Min = 10, Max = 140, Default = FL_CAR.Speed },
		Callback = function(v) if type(v) == "number" then FL_CAR.Speed = math.min(v, FL_CAR.MaxSpeed) end end })

	carSec:Button({ Title = "自检：飞车", Callback = function()
		local d = FL_CAR.Status()
		pcall(function() v10:Notify({ Title = "飞车自检", Content = string.format("已开 %s | 速度 %d / 上限 %d\n在车里 %s（%s）| 推进器 %s\n%s", tostring(d.Enabled), d.Speed, d.MaxSpeed, tostring(d.InVehicle), tostring(d.Vehicle), tostring(d.Mover), tostring(d.LastErr or "ok")), Duration = 10 }) end)
	end })
end

v16:Toggle({
	Title = "无眩晕",
	Value = false,
	Callback = function(noDizziness)
		tbl2.NoDizziness = noDizziness

		if noDizziness then
			StartNoDizziness()
		else
			StopNoDizziness()
		end
	end,
})

v16:Slider({
	Title = "移动速度",
	Value = { Min = 5, Max = 250, Default = 24 },
	Callback = function(noDizzinessSpeed)
		tbl2.NoDizzinessSpeed = noDizzinessSpeed
	end,
})

do
	local spinSec = v16:Section({ Title = "人物旋转" })

	spinSec:Toggle({ Title = "人物旋转", Value = FL_SPIN.Enabled,
		Callback = function(v) FL_SPIN.Set(v) end })

	spinSec:Slider({ Title = "转速（度/秒）", Value = { Min = 30, Max = 2160, Default = 360 },
		Callback = function(v) if type(v) == "number" then FL_SPIN.Speed = v end end })

	spinSec:Toggle({ Title = "随机角度", Value = FL_SPIN.Random,
		Callback = function(v) FL_SPIN.Random = v end })

	spinSec:Button({ Title = "自检：人物旋转", Callback = function()
		local d = FL_SPIN.Status()
		local msg = string.format("已开 %s | 转速 %s 度/秒 | 随机 %s\n角色 %s | 当前角度 %s | %s",
			tostring(d.Enabled), tostring(d.Speed), tostring(d.Random),
			tostring(d.HasChar), tostring(d.Yaw and string.format("%.0f", d.Yaw)),
			tostring(d.LastErr or "ok"))
		pcall(function() v:Notify({ Title = "人物旋转自检", Content = msg, Duration = 12 }) end)
	end })
end

v16:Toggle({
	Title = "飞行",
	Value = false,
	Callback = function(flFly)
		FL_FLY.Set(flFly)
	end,
})

v16:Slider({
	Title = "飞行速度",
	Value = { Min = 5, Max = 300, Default = 40 },
	Callback = function(flFlySpeed)
		FL_FLY.Speed = flFlySpeed
	end,
})

v16:Slider({
	Title = "飞行升降速度",
	Value = { Min = 5, Max = 200, Default = 30 },
	Callback = function(flFlyVert)
		FL_FLY.VertSpeed = flFlyVert
	end,
})

v16:Toggle({
	Title = "飞行用 CFrame 直写",
	Value = true,
	Callback = function(flFlyCf)
		FL_FLY.UseCFrame = flFlyCf
	end,
})

local espTab = v11:Tab({ Title = "ESP透视", Icon = "eye" })

local espSec = espTab:Section({ Title = "透视设置" })
espSec:Toggle({ Title = "启用ESP透视", Desc = "显示玩家盒子、血量、名称等", Value = ESP_UI.Enabled,
	Callback = function(v) ESP_UI.Enabled = v; ESP.Enabled = v end })
espSec:Toggle({ Title = "方框 ESP", Value = ESP_UI.Box,
	Callback = function(v) ESP_UI.Box = v; ESP.SetFlags({ ["Esp Box"] = v, ["Esp Box Fill"] = v }) end })
espSec:Dropdown({ Title = "方框模式", Values = { "Full", "Corners" }, Value = ESP_UI.BoxMode,
	Callback = function(v) ESP_UI.BoxMode = v; ESP.SetFlags({ ["Esp Box Style"] = v }) end })
espSec:Slider({ Title = "方框粗细", Value = { Min = 1, Max = 5, Default = ESP_UI.BoxThick },
	Callback = function(v) if type(v) == "number" then ESP_UI.BoxThick = v; ESP.SetFlags({ ["Esp Box Thickness"] = v }) end end })
espSec:Toggle({ Title = "信息面板", Desc = "名字 + 血条", Value = ESP_UI.Info,
	Callback = function(v) ESP_UI.Info = v; ESP.SetFlags({ ["Esp Name"] = v, ["Esp Health Bar"] = v }) end })
espSec:Toggle({ Title = "显示距离", Value = ESP_UI.Distance,
	Callback = function(v) ESP_UI.Distance = v; ESP.SetFlags({ ["Esp Distance"] = v }) end })
espSec:Toggle({ Title = "显示武器", Value = ESP_UI.Weapon,
	Callback = function(v) ESP_UI.Weapon = v; ESP.SetFlags({ ["Esp Weapon"] = v }) end })
espSec:Toggle({ Title = "人物高亮", Desc = "隔墙也能看到轮廓", Value = ESP_UI.Highlight,
	Callback = function(v) ESP_UI.Highlight = v; ESP.SetFlags({ ["Chams Enabled"] = v, ["Glows Enabled"] = v }) end })
espSec:Toggle({ Title = "忽略队友", Value = ESP_UI.TeamCheck,
	Callback = function(v) ESP_UI.TeamCheck = v; ESP.TeamCheck = v end })
espSec:Toggle({ Title = "追踪自己", Value = ESP_UI.TrackSelf,
	Callback = function(v) ESP_UI.TrackSelf = v; ESP.TrackSelf = v end })
espSec:Toggle({ Title = "显示死亡玩家", Value = ESP_UI.ShowDead,
	Callback = function(v) ESP_UI.ShowDead = v; ESP.ShowDead = v end })
espSec:Slider({ Title = "最大距离", Value = { Min = 50, Max = 2000, Default = ESP_UI.MaxDist },
	Callback = function(v) if type(v) == "number" then ESP_UI.MaxDist = v; ESP.SetFlags({ ["Esp Max Distance"] = v }) end end })
espSec:Toggle({ Title = "显示阵营", Value = ESP_UI.Faction,
	Callback = function(v) ESP_UI.Faction = v end })
espSec:Toggle({ Title = "显示通缉星级", Value = ESP_UI.Stars,
	Callback = function(v) ESP_UI.Stars = v end })

do
	local featTab = FL_FEAT_TAB

	featTab:Toggle({
		Title = "无限体力",
		Value = false,
		Callback = function(on)
			FL_FEAT.SetStamina(on)
		end,
	})

	featTab:Toggle({
		Title = "无限饥饿",
		Value = false,
		Callback = function(on)
			FL_FEAT.SetFood(on)
		end,
	})

	featTab:Toggle({
		Title = "战斗拦截",
		Value = false,
		Callback = function(on)
			FL_AC.CombatBlock = on and true or false
		end,
	})

	featTab:Toggle({
		Title = "防布娃娃",
		Value = false,
		Callback = function(on)
			FL_FEAT.SetNoRagdoll(on)
		end,
	})

	featTab:Toggle({
		Title = "防摔伤",
		Value = false,
		Callback = function(on)
			FL_AC.NoFallDamage = on and true or false
		end,
	})

	featTab:Toggle({
		Title = "防越狱拉回",
		Value = false,
		Callback = function(on)
			FL_AC.SetPrisonPull(on)
		end,
	})

	featTab:Toggle({
		Title = "记录所有 remote 的上报（诊断用）",
		Value = false,
		Callback = function(on)
			FL_AC.RecordAllRemotes = on and true or false
		end,
	})

	featTab:Button({
		Title = "查看上报动词（找漏拦的通道）",
		Callback = function()
			local st, txt = "反作弊层未就绪", "（无）"
			pcall(function()
				if type(FL_AC) == "table" then
					if type(FL_AC.Status) == "function" then st = FL_AC.Status() end
					if type(FL_AC.VerbReport) == "function" then txt = FL_AC.VerbReport() end
				end
			end)
			pcall(function()
				v10:Notify({ Title = "反作弊状态 + 上报动词", Content = st .. "\n\n上报动词：\n" .. txt, Duration = 25 })
			end)
		end,
	})

	v13:Toggle({
		Title = "自动铐（仅警察生效，只铐通缉者）",
		Value = false,
		Callback = function(on)
			if on then
				FL_FEAT.StartAutoCuff()
			else
				FL_FEAT.StopAutoCuff()
			end
		end,
	})

	v13:Toggle({
		Title = "自动铐 · 传送到目标",
		Value = false,
		Callback = function(on)
			FL_FEAT.Teleport = on and true or false
		end,
	})

	v13:Toggle({
		Title = "自动铐 · 仅战斗状态",
		Value = false,
		Callback = function(on)
			FL_FEAT.CombatCheck = on and true or false
		end,
	})

	v13:Slider({
		Title = "自动铐搜索范围",
		Value = { Min = 10, Max = 500, Default = 200 },
		Callback = function(dist)
			if type(dist) == "number" then
				FL_FEAT.Range = dist
			end
		end,
	})

	v13:Slider({
		Title = "自动铐间隔",
		Value = { Min = 0.1, Max = 3, Default = 0.5 },
		Callback = function(waitTime)
			if type(waitTime) == "number" then
				FL_FEAT.Interval = waitTime
			end
		end,
	})

	v13:Slider({
		Title = "传送最大距离（越小越安全）",
		Value = { Min = 10, Max = 300, Default = 80 },
		Callback = function(dist)
			if type(dist) == "number" then
				FL_FEAT.TeleportMaxDist = dist
			end
		end,
	})
end

local v17 = FL_FEAT_TAB:Section({ Title = "自动赚钱", Opened = false })

v17:Toggle({
	Title = "自动破解ATM",
	Value = false,
	Callback = function(autoATMHack)
		tbl2.AutoATMHack = autoATMHack

		if autoATMHack then
			fn28()
		else
			fn29()
		end
	end,
})

local v18 = v14

do
	local trackSec = v18:Section({ Title = "追踪设置" })

	trackSec:Toggle({ Title = "启用子弹追踪（强制命中）", Value = FL_TRACK.Enabled,
		Callback = function(v)
			FL_TRACK.Set(v)
			pcall(function() tbl2.BulletTrackEnabled = v end)
		end })

	trackSec:Toggle({ Title = "360° 全向锁定（不看屏幕位置）", Value = FL_TRACK.Full360,
		Callback = function(v) FL_TRACK.Full360 = v end })

	trackSec:Dropdown({ Title = "目标阵营", Values = { "全部", "只锁警察", "只锁平民" }, Value = "全部",
		Callback = function(v)
			if v == "只锁警察" then FL_TRACK.Mode = "police"
			elseif v == "只锁平民" then FL_TRACK.Mode = "civilian"
			else FL_TRACK.Mode = "all" end
		end })

	trackSec:Toggle({ Title = "只锁进入战斗模式的人", Value = FL_TRACK.CombatOnly,
		Callback = function(v) FL_TRACK.CombatOnly = v end })

	trackSec:Toggle({ Title = "强制命中（不管多远 / 是否隔墙）", Value = FL_TRACK.ForceHit,
		Callback = function(v) FL_TRACK.ForceHit = v end })

	trackSec:Slider({ Title = "强制命中间隔（×100 秒）", Value = { Min = 5, Max = 100, Default = 12 },
		Callback = function(v) if type(v) == "number" then FL_TRACK.ForceRate = v / 100 end end })

	trackSec:Slider({ Title = "FOV 半径（1080p 基准）", Value = { Min = 20, Max = 800, Default = FL_TRACK.FOV },
		Callback = function(v) if type(v) == "number" then FL_TRACK.FOV = v end end })

	trackSec:Dropdown({ Title = "强制命中射线形状", Values = { "贴脸（不限距离/可穿墙）", "从自己出发（像真开枪）" },
		Value = "贴脸（不限距离/可穿墙）",
		Callback = function(v)
			FL_DMG.RayMode = (v == "从自己出发（像真开枪）") and "self" or "near"
		end })

	trackSec:Slider({ Title = "锁定最大距离（99999 = 不限）", Value = { Min = 500, Max = 99999, Default = FL_TRACK.MaxDist },
		Callback = function(v) if type(v) == "number" then FL_TRACK.MaxDist = v end end })

	trackSec:Toggle({ Title = "显示 FOV 圈", Value = FL_TRACK.ShowCircle,
		Callback = function(v) FL_TRACK.ShowCircle = v end })

	trackSec:Toggle({ Title = "显示追踪线", Value = FL_TRACK.ShowLine,
		Callback = function(v) FL_TRACK.ShowLine = v end })

	pcall(function()
		trackSec:Colorpicker({ Title = "颜色", Default = FL_TRACK.Color,
			Callback = function(c) if typeof(c) == "Color3" then FL_TRACK.Color = c end end })
	end)

	trackSec:Button({ Title = "自检：当前枪械 / 目标", Callback = function()
		local d = FL_DMG and FL_DMG.Status() or {}
		local t = FL_TRACK.Status()
		local lvl, pts = FL_TRACK.Stars(game:GetService("Players").LocalPlayer)
		local msg = string.format("当前枪械 %s（%s）伤害 %s\nPlayerEvent %s | 目标 %s（%s）\n本机通缉 %d 星 / %d 点",
			tostring(d.Weapon), tostring(d.Category), tostring(d.Damage),
			tostring(d.HasEvent), tostring(t.Target), tostring(t.Faction), lvl, pts)
		pcall(function() v10:Notify({ Title = "子弹追踪自检", Content = msg, Duration = 12 }) end)
	end })
end

do
	local traceSec = v18:Section({ Title = "弹道绘制" })

	traceSec:Toggle({ Title = "弹道绘制（开枪就画）", Value = FL_TRACER.Enabled,
		Callback = function(v) FL_TRACER.Set(v) end })

	traceSec:Slider({ Title = "弹道停留（秒）", Value = { Min = 0.5, Max = 10, Step = 0.5, Default = 3 },
		Callback = function(v) if type(v) == "number" then FL_TRACER.Hold = v end end })

	traceSec:Slider({ Title = "飘散时长（秒）", Value = { Min = 0.2, Max = 5, Step = 0.1, Default = 1.2 },
		Callback = function(v) if type(v) == "number" then FL_TRACER.Drift = v end end })

	traceSec:Slider({ Title = "弹道粗细（×100）", Value = { Min = 10, Max = 200, Default = 50 },
		Callback = function(v) if type(v) == "number" then FL_TRACER.Scale = v / 100 end end })

	traceSec:Button({ Title = "自检：弹道绘制", Callback = function()
		local d = FL_TRACER.Status()
		local msg = string.format("已开 %s | 已挂钩 %s | 粗细 %.2f | 停留 %.1fs / 飘散 %.1fs\n在场 %d 条 | 累计 %d 条",
			tostring(d.Enabled), tostring(d.Hooked), d.Scale, d.Hold, d.Drift, d.Live, d.Count)
		pcall(function() v10:Notify({ Title = "弹道绘制自检", Content = msg, Duration = 12 }) end)
	end })
end

local v19 = v11:Tab({ Title = "远程商店", Icon = "cart" })
v19:Section({ Title = "黑市道具", Opened = true })

v19:Button({
	Title = "解密电路",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/1", "Decryption Circuit", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "绿色USB",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/5", "Green USB", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "喷漆",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/8", "Crew Graffiti", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "购买C4",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/4", "C4", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "购买入侵工具",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/3", "Hacking Tool", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "购买撬锁工具",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Black Market/2", "Lockpick Device", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Divider()
v19:Section({ Title = "近战武器", Opened = true })

v19:Button({
	Title = "小刀",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Weapons/1", "Knife", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "斧子",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Weapons/2", "Battle Axe", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "棒球棍",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Weapons/3", "Bat", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "大砍刀",
	Callback = function()
		local ok, result = pcall(function()
			local v20, v21 = BuyItem("Weapons/4", "Machete", 1, false)
			v:Notify({ Title = v20 and "购买成功" or "购买失败", Content = tostring(v21), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Divider()
v19:Section({ Title = "通用物品", Opened = true })

v19:Button({
	Title = "望远镜",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Binoculars", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "降落伞",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Black Parachute", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "钓鱼竿",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Fishing Rod", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "金属探测仪",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Metal Detector", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "铲子",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Trowel", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "摄像头",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "News Camera", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "麦克风",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "News Microphone", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "口袋",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Pocket", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "雨伞",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Red Umbrella", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "车辆维修包",
	Callback = function()
		local ok, result = pcall(function()
			local Items, v20 = BuyItem("Items", "Repair Kit", 1, false)
			v:Notify({ Title = Items and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Divider()
v19:Section({ Title = "食品补给", Opened = true })

v19:Button({
	Title = "小蛋糕",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Cupcake", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "三明治",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Sandwich", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "汽水",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Soda Can", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "沙拉",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Salad", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "饼干",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Cookie", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "冰茶",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Iced Tea", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "松饼卷",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Croissant", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "苹果",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Apple", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "苹果汁",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Apple Juice", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

v19:Button({
	Title = "牛奶",
	Callback = function()
		local ok, result = pcall(function()
			local Food, v20 = BuyItem("Food", "Box Of Milk", 1, false)
			v:Notify({ Title = Food and "购买成功" or "购买失败", Content = tostring(v20), Duration = 2 })
		end)

		if not ok then
			v:Notify({ Title = "按钮执行错误", Content = tostring(result), Duration = 3 })
		end
	end,
})

local v20 = FL_FEAT_TAB:Section({ Title = "罪犯", Opened = false })

v20:Toggle({
	Title = "躲避警察",
	Value = false,
	Callback = function(arg)
		ToggleAntiPolice(arg)
	end,
})

v20:Divider()

v20:Toggle({
	Title = "取消红绿灯通缉",
	Value = false,
	Callback = function(trafficLightWantedEnabled)
		tbl2.TrafficLightWantedEnabled = trafficLightWantedEnabled

		if trafficLightWantedEnabled then
			fn23()
		else
			fn24()
		end
	end,
})

local v21 = v10:Section({ Title = "传送点", Opened = true }):Tab({ Title = "传送", Icon = "map-pin" })

v21:Toggle({
	Title = "启用传送",
	Value = false,
	Callback = function(teleportEnabled)
		tbl2.TeleportEnabled = teleportEnabled
	end,
})

v21:Divider()

local function fn35()
	local tbl16 = {}

	for _, v22 in ipairs(v7) do
		if not tbl16[v22.region] then
			tbl16[v22.region] = {}
		end

		table.insert(tbl16[v22.region], v22)
	end

	local tbl17 = {}

	for k in pairs(tbl16) do
		table.insert(tbl17, k)
	end

	table.sort(tbl17)

	for _, v22 in ipairs(tbl17) do
		v21:Divider()

		for _, v23 in ipairs(tbl16[v22]) do
			v21:Button({
				Title = v22 .. " - " .. v23.n,
				Callback = function()
					fn10(v23.p)
					v:Notify({ Title = "传送", Content = "正在传送至: " .. v23.n, Duration = 2 })
				end,
			})
		end
	end
end

task.spawn(function()
	task.wait(0.5)

	if not flag2 then
		fn35()
	end
end)

local _setTab = v10:Section({ Title = "设置", Opened = true }):Tab({ Title = "设置", Icon = "settings" })
do
	local BG_MASK_NAME = "BackgroundMask"
	local MASK_DEFAULT = 0.30

	local function applyBackgroundMask(strength)
		strength = math.clamp(tonumber(strength) or 0, 0, 1)
		pcall(function()
			local main = v10.UIElements and v10.UIElements.Main
			if not main then return end
			local bgLayer = main:FindFirstChild("Background")
			if not bgLayer then return end
			local mask = bgLayer:FindFirstChild(BG_MASK_NAME)
			if not mask then
				mask = Instance.new("Frame")
				mask.Name = BG_MASK_NAME
				mask.Size = UDim2.new(1, 0, 1, 0)
				mask.Position = UDim2.new(0, 0, 0, 0)
				mask.BorderSizePixel = 0
				mask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				mask.ZIndex = 10
				mask.Parent = bgLayer
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 16)
				corner.Parent = mask
			end
			mask.Visible = strength > 0
			mask.BackgroundTransparency = 1 - strength
		end)
	end

	task.spawn(function()
		local tries = 0
		while tries < 20 do
			local main = v10.UIElements and v10.UIElements.Main
			if main and main:FindFirstChild("Background") then break end
			task.wait(0.1)
			tries = tries + 1
		end
		applyBackgroundMask(MASK_DEFAULT)
	end)

	local _uiSec = _setTab:Section({ Title = "界面" })
	_uiSec:Slider({
		Title = "背景遮罩(×100)",
		Value = { Min = 0, Max = 80, Default = MASK_DEFAULT * 100 },
		Callback = function(v)
			if type(v) == "number" then applyBackgroundMask(v / 100) end
		end,
	})
	_uiSec:Slider({
		Title = "背景图透明度(×100)",
		Value = { Min = 0, Max = 90, Default = 0 },
		Callback = function(v)
			if type(v) == "number" then pcall(function() v10:SetBackgroundImageTransparency(v / 100) end) end
		end,
	})
end
_setTab:Button({
	Title = "卸载 FL",
	Callback = function()
		v10:Destroy()
	end,
	Danger = true,
})

local function onUnload()
	if flag2 then
		return
	end
	flag2 = true
	ResetHitbox()
	StopNoDizziness()
	StopRPMHack()
	StopInfiniteAmmo()
	fn29()
	fn33()
	StopAutoArrestWanted()
	fn21()
	fn24()

	if tbl2.NoclipEnabled then
		fn12(false)
	end

	for _, v22 in ipairs(tbl9) do
		pcall(function()
			v22:Disconnect()
		end)
	end

	for _, v22 in ipairs(tbl10) do
		pcall(function()
			v22:Disconnect()
		end)
	end

	pcall(function()
		ESP.Enabled = false
		if ESP.Overlay then
			ESP.Overlay:Destroy()
			ESP.Overlay = nil
		end
	end)

	pcall(function()
		FL_FEAT.StopAll()
	end)

	pcall(function()
		FL_FLY.Stop()
	end)

	pcall(function()
		FL_TRACK.Set(false)
	end)

	pcall(function()
		FL_TRACER.Set(false)
	end)

	pcall(function()
		FL_WPN.Restore()
	end)

	pcall(function()
		FL_CROSS.Set(false)
	end)

	pcall(function()
		FL_SPIN.Set(false)
	end)

	pcall(function()
		FL_TIRE.Set(false)
		FL_CUFF.Set(false)
		FL_LASER.Set(false)
		FL_RAGE.Set(false)
		FL_CAR.Set(false)
		FL_NPC.Set(false)
	end)

	pcall(function()
		FL_AC.Restore()
	end)
end

if type(v10.OnDestroy) == "function" then
	pcall(function()
		v10:OnDestroy(onUnload)
	end)
end

do
	local origDestroy = v10.Destroy
	if type(origDestroy) == "function" then
		v10.Destroy = function(self, ...)
			pcall(onUnload)
			return origDestroy(self, ...)
		end
	end
end

local function fn36(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)

		if tbl2.HitboxEnabled and not flag2 then
			task.wait(0.5)
			ApplyHitbox()
		end

		if tbl2.NoclipEnabled and not flag2 then
			task.wait(0.1)
			fn11()
		end
	end)

	if tbl2.WhitelistEnabled and not flag2 then
		UpdateWhitelist()
	end
end

for _, player in ipairs(Players3:GetPlayers()) do
	fn36(player)
end

local connection7 = Players3.PlayerAdded:Connect(fn36)
table.insert(tbl9, connection7)

local connection8 = RunService_.RenderStepped:Connect(function()
	if flag2 then
		return
	end

	if tbl2.HitboxEnabled then
		n += 1

		if n % 3 == 0 then
			ApplyHitbox()
		end
	end

	if tbl2.NoclipEnabled then
		fn11()
	end

	if tbl2.AimEnabled then
		fn16()
	end
end)

table.insert(tbl9, connection8)

task.spawn(function()
	while not flag2 do
		task.wait(10)

		if tbl2.WhitelistEnabled and not flag2 then
			UpdateWhitelist()
		end
	end
end)

local function fn37()
	if flag2 then
		return
	end

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			descendant.HoldDuration = tbl2.HoldTime
			descendant.MaxActivationDistance = tbl2.Distance
		end
	end
end

fn37()

local connection9 = workspace.DescendantAdded:Connect(function(descendant)
	if flag2 then
		return
	end

	if descendant:IsA("ProximityPrompt") then
		descendant.HoldDuration = tbl2.HoldTime
		descendant.MaxActivationDistance = tbl2.Distance
	end
end)

table.insert(tbl9, connection9)