-- [[ QUANG MOD - V16 VIP EDITION ]] --
-- Tính năng: Anti-Ban, Water Walk, Invisible, Fix Store --

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Cài đặt VIP
_G.SafeSpeed = 330
_G.Invisible = true
_G.WaterWalk = true

-- 1. CHỌN TEAM (Pirates)
pcall(function()
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Pirates")
end)

-- 2. HÀM TÀNG HÌNH & ĐI TRÊN NƯỚC (ANTI-DROWN)
local function ApplyVipEffects()
    pcall(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        -- Tàng hình
        if _G.Invisible then
            for _, v in pairs(char:GetDescendants()) do
                if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 1
                end
            end
        end
        -- Đi trên nước (Tạo platform giả dưới chân)
        if _G.WaterWalk then
            if not char:FindFirstChild("WaterPlatform") then
                local p = Instance.new("Part", char)
                p.Name = "WaterPlatform"
                p.Size = Vector3.new(10, 1, 10)
                p.Transparency = 1
                p.Anchored = true
                p.CanCollide = true
                spawn(function()
                    while p.Parent do
                        p.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
                        task.wait()
                    end
                end)
            end
        end
    end)
end
spawn(ApplyVipEffects)
Player.CharacterAdded:Connect(ApplyVipEffects)

-- 3. GIAO DIỆN (Bo góc 20%, Chữ QUANG MOD trên viền)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 120)
MainFrame.Position = UDim2.new(0.5, -160, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0.2, 0)

-- Chữ QUANG MOD trên viền
local ModTitle = Instance.new("TextLabel", MainFrame)
ModTitle.Size = UDim2.new(0, 100, 0, 20)
ModTitle.Position = UDim2.new(0.5, -50, 0, -10)
ModTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ModTitle.Text = "QUANG MOD"
ModTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ModTitle.TextSize = 14
ModTitle.Font = Enum.Font.GothamBold
Instance.new("UICorner", ModTitle).CornerRadius = UDim.new(0.5, 0)
local StrokeTitle = Instance.new("UIStroke", ModTitle)
StrokeTitle.Thickness = 2

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 3
spawn(function()
    while task.wait(0.01) do 
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        UIStroke.Color = color
        StrokeTitle.Color = color
    end
end)

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 1, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 16
Status.Text = "QUANG MOD: Hệ thống đang quét..."
Status.Parent = MainFrame

-- Nút phi tiêu xoay
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
ToggleBtn.Text = "✵"
ToggleBtn.TextSize = 35
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
RunService.RenderStepped:Connect(function() ToggleBtn.Rotation = ToggleBtn.Rotation + 4 end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 4. HÀM CẤT TRÁI (FIX CHUẨN REDZ HUB)
function StoreFruit()
    pcall(function()
        for _, v in pairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name, "Fruit") then
                -- Lấy OriginalName để gửi lệnh chuẩn
                local originalName = v:GetAttribute("OriginalName") or v.Name
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", originalName, v)
            end
        end
    end)
end

-- 5. SERVER HOP (1-3 NGƯỜI)
function ServerHop()
    Status.Text = "🛡️ Đang tìm server 1-3 người..."
    pcall(function()
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local servers = HttpService:JSONDecode(game:HttpGet(Api)).data
        local targets = {}
        for _, s in pairs(servers) do
            if s.playing >= 1 and s.playing <= 3 and s.id ~= game.JobId then
                table.insert(targets, s.id)
            end
        end
        if #targets > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targets[math.random(1, #targets)], Player)
        else
            task.wait(1)
            ServerHop()
        end
    end)
end

-- 6. HÀM BAY AN TOÀN (BYPASS)
function GrabFruit(fruit)
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    local target = fruit:FindFirstChild("Handle") or fruit:FindFirstChildWhichIsA("BasePart")
    if not hrp or not target then return end

    Status.Text = "✈️ Bay cao né nước tới: " .. fruit.Name
    
    -- Bay cao lên trời rồi mới hạ xuống nhặt để tránh kẹt địa hình
    local targetPos = target.CFrame
    local dist = (hrp.Position - target.Position).Magnitude
    
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/_G.SafeSpeed, Enum.EasingStyle.Linear), {CFrame = targetPos})
    tween:Play()
    tween.Completed:Wait()

    task.wait(1.5) -- Delay an toàn chống Ban
    StoreFruit() -- Cất rương
    Status.Text = "✅ Đã cất " .. fruit.Name
end

-- 7. VÒNG LẶP CHÍNH
spawn(function()
    while true do
        -- Anti-Admin Check
        for _, p in pairs(Players:GetPlayers()) do
            if p:GetRankInGroup(2830050) > 0 then ServerHop() end
        end

        local found = false
        for _, v in pairs(game.Workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Blox")) then
                found = true
                GrabFruit(v)
            end
        end
        
        if not found then
            task.wait(5)
            ServerHop()
        end
        task.wait(2)
    end
end)