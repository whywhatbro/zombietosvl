-- [[ SLAP TO SURVIVE - FIXED HITBOX AURA (MOBILE) ]] --
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SlapMobileHub") then
    CoreGui.SlapMobileHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlapMobileHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Nút mở/đóng menu trên mobile
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Name = "ToggleMenuBtn"
ToggleMenuBtn.Parent = ScreenGui
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuBtn.Font = Enum.Font.GothamBold
ToggleMenuBtn.Text = "MENU"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.TextSize = 12
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleMenuBtn

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
MainFrame.Size = UDim2.new(0, 350, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local menuVisible = true
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "  Slap to Survive [Fixed Hitbox Aura]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local Container = Instance.new("ScrollingFrame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 10, 0, 50)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.CanvasSize = UDim2.new(0, 0, 1.4, 0)
Container.ScrollBarThickness = 3

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local function addToggle(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Container
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.Font = Enum.Font.GothamMedium
    Btn.Text = "  " .. text .. " [ TẮT ]"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = Btn
    
    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Btn.Text = "  " .. text .. " [ BẬT ]"
            Btn.TextColor3 = Color3.fromRGB(50, 255, 150)
            Btn.BackgroundColor3 = Color3.fromRGB(35, 65, 45)
        else
            Btn.Text = "  " .. text .. " [ TẮT ]"
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
        callback(enabled)
    end)
end

local hitboxAura = false
local floatMode = false
local espEnabled = false

-- 1. Fixed Hitbox Aura (Kéo thẳng phần Hitbox vật lý vào vị trí người chơi)
addToggle("Fixed Hitbox Aura (Hút chuẩn hitbox)", function(state)
    hitboxAura = state
end)

task.spawn(function()
    while true do
        if hitboxAura then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local tool = char:FindFirstChildOfClass("Tool")
                
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v.Name == "HumanoidRootPart" and v.Parent ~= char then
                        local model = v.Parent
                        if model and model:FindFirstChild("Humanoid") then
                            if not Players:GetPlayerFromCharacter(model) then
                                local humanoid = model.Humanoid
                                if v.Position.Y > -50 and humanoid.Health > 0 then
                                    -- Ép buộc dịch chuyển trực tiếp HRP (Hitbox thật) của zombie dính sát vào mặt bạn
                                    v.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                                    
                                    -- Kích hoạt công cụ tát để găng tay nhận diện va chạm với hitbox vừa kéo tới
                                    if tool then
                                        pcall(function()
                                            tool:Activate()
                                        end)
                                    end
                                    
                                    -- Phòng hờ game chống gian lận gắt, kết hợp trừ máu trực tiếp nếu hitbox chạm nhưng chưa chết
                                    pcall(function()
                                        humanoid:TakeDamage(50)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- 2. Chế độ Bay lơ lửng (Float Mode)
addToggle("Float Mode (Bay né zombie)", function(state)
    floatMode = state
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if floatMode then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "CustomFloatVelocity"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Velocity = Vector3.new(0, 0, 0)
        else
            if hrp:FindFirstChild("CustomFloatVelocity") then
                hrp.CustomFloatVelocity:Destroy()
            end
        end
    end
end)

-- 3. Zombie ESP
addToggle("Zombie ESP (Nhìn xuyên tường)", function(state)
    espEnabled = state
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
            local existing = v:FindFirstChild("ZESP")
            if state and not existing then
                local hl = Instance.new("Highlight")
                hl.Name = "ZESP"
                hl.Adornee = v
                hl.FillColor = Color3.fromRGB(255, 30, 30)
                hl.Parent = v
            elseif not state and existing then
                existing:Destroy()
            end
        end
    end
end)

print("Đã cập nhật Fixed Hitbox Aura thành công!")
