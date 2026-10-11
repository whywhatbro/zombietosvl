-- [[ SLAP TO SURVIVE - ZONE FILTER AURA (MOBILE) ]] --
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SlapVoidHub") then
    CoreGui.SlapVoidHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlapVoidHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Nút nổi mở/đóng menu trên mobile
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Name = "ToggleMenuBtn"
ToggleMenuBtn.Parent = ScreenGui
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 0)
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
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
MainFrame.Size = UDim2.new(0, 350, 0, 280)
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
Title.Text = "  Slap to Survive [Zone Clean Aura]"
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
    Btn.Text = "  " .. text + " [ TẮT ]" -- sửa text an toàn
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

-- Bộ lọc thông minh kèm kiểm tra vùng an toàn (Shop Area)
local function isValidZombie(model)
    if not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    
    local humanoid = model:FindFirstChild("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end

    local name = model.Name:lower()
    
    -- Chặn từ khóa shop, npc, dummy, test
    if name:find("shop") or name:find("store") or name:find("dealer") or name:find("merchant") or name:find("npc") or name:find("dummy") or name:find("test") then
        return false
    end

    -- LOẠI BỎ KHU VỰC QUẦY SHOP VÀ CỘT XUNG QUANH (Dựa trên tọa độ cố định của khu shop trong map)
    -- Thường khu vực shop nằm ở giữa/đầu map với tầm bán kính nhất định. Ta có thể chặn nếu đứng quá gần tọa độ trung tâm shop.
    -- Hoặc kiểm tra xem có đứng yên một chỗ hay không (WalkSpeed == 0 hoặc không di chuyển)
    if humanoid.WalkSpeed == 0 then
        return false
    end

    if humanoid.Health <= 0 or hrp.Position.Y < -50 then
        return false
    end

    return true
end

local voidAura = false
local floatAbove = false
local espEnabled = false

-- 1. Zone Clean Void Aura
addToggle("Zone Clean Aura (Chỉ tát quái ngoài bãi)", function(state)
    voidAura = state
end)

task.spawn(function()
    while true do
        if voidAura then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local tool = char:FindFirstChildOfClass("Tool")
                
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("Model") and isValidZombie(v) then
                        local targetHrp = v.HumanoidRootPart
                        local humanoid = v.Humanoid
                        
                        -- Lướt lên đầu zombie thật ngoài bãi chiến đấu
                        local targetPos = targetHrp.Position + Vector3.new(0, 8, 0)
                        hrp.CFrame = CFrame.new(targetPos, targetHrp.Position) * CFrame.Angles(math.rad(45), 0, 0)
                        
                        if tool then
                            pcall(function()
                                tool:Activate()
                            end)
                        end
                        
                        pcall(function()
                            targetHrp.Velocity = Vector3.new(0, -180, 0)
                        end)
                        
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- 2. Chế độ Bay trên đầu an toàn
addToggle("Float Above (Bay lơ lửng trên không)", function(state)
    floatAbove = state
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if floatAbove then
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

-- 3. ESP chuẩn xác
addToggle("Zombies ESP (Chỉ tô màu quái)", function(state)
    espEnabled = state
    for _, v in ipairs(Workspace:GetDescendants()) do
        if isValidZombie(v) then
            local existing = v:FindFirstChild("ZESP")
            if state and not existing then
                local hl = Instance.new("Highlight")
                hl.Name = "ZESP"
                hl.Adornee = v
                hl.FillColor = Color3.fromRGB(255, 69, 0)
                hl.Parent = v
            elseif not state and existing then
                existing:Destroy()
            end
        end
    end
end)

print("Đã cập nhật bộ lọc chống hình nộm dummy thành công!")
