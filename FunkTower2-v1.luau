
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Project-Eliminator/as/refs/heads/main/lib.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Funk Tower 2",
   LoadingTitle = "Funk Tower 2",
   LoadingSubtitle = "by @xendr4x",
   Theme = "Default",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Funk Tower 2",
      Subtitle = "by @xendr4x",
      Note = "Hello! Key: @xendr4x",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"@xendr4x"}
   }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
local SpeedTab = Window:CreateTab("SpeedHack", 4483362458)
local ExitTab = Window:CreateTab("Exit", 4483362458)

Rayfield:Notify({
   Title = "Funk Tower 2 Loaded",
   Content = "Script successfully loaded!",
   Duration = 5,
})


-- Переменные
local speedEnabled = false
local walkSpeedValue = 16
local speedUnlocked = true
local jumpHackEnabled = false
local jumpHeightValue = 50
local autoCollectEnabled = false
local autoCollectConnection = nil
local noclipEnabled = false
local noclipConnection = nil
local flyEnabled = false
local flyConnection = nil
local godmodeEnabled = false
local godmodeConnection = nil
local killAuraEnabled = false
local killAuraConnection = nil
local fovValue = 70
local fovConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Plr = Players.LocalPlayer

-- Функция для проверки, является ли объект лестницей
local function IsLadder(part)
    return part.Name:lower():find("ladder") or part:IsA("TrussPart") or part:FindFirstChild("Ladder")
end

-- Функция для обновления скорости
local function UpdateSpeed(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if speedEnabled then
            humanoid.WalkSpeed = walkSpeedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
end

-- Функция для обновления силы прыжка
local function UpdateJumpHack(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if jumpHackEnabled then
            humanoid.JumpHeight = jumpHeightValue
        else
            humanoid.JumpHeight = speedEnabled and walkSpeedValue or 50
        end
    end
end

-- Функция для обновления FOV
local function UpdateFOV()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = fovValue
    end
end

-- Функция для Noclip
local function UpdateNoclip()
    if not noclipEnabled then return end
    local character = Plr.Character
    if character then
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("BasePart") and not IsLadder(v) then
                v.CanCollide = false
            end
        end
    end
end

-- Функция для управления полётом
local function UpdateFly()
    local character = Plr.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not character or not humanoidRootPart then return end

    if flyEnabled then
        -- Создаём или обновляем BodyVelocity и BodyGyro
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = humanoidRootPart
        end
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 10000
            bodyGyro.Parent = humanoidRootPart
        end

        -- Управление направлением
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection + Vector3.new(0, 0, 1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Vector3.new(1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDirection = moveDirection + Vector3.new(0, -1, 0)
        end

        -- Применяем направление с учётом ориентации камеры
        local camera = Workspace.CurrentCamera
        local lookDirection = camera.CFrame.LookVector
        local flatLook = Vector3.new(lookDirection.X, 0, lookDirection.Z).Unit
        bodyVelocity.Velocity = camera.CFrame:VectorToWorldSpace(moveDirection * walkSpeedValue)
        bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), flatLook)
    else
        -- Отключаем полёт
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
    end
end

-- Функция для Godmode
local function UpdateGodmode()
    if not godmodeEnabled then return end
    local character = Plr.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

-- Функция для KillAura
local function UpdateKillAura()
    if not killAuraEnabled then return end
    local character = Plr.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                if distance <= 20 then -- Радиус 20 единиц
                    targetRoot.CFrame = CFrame.new(0, 1000, 0) -- Телепортируем других игроков
                    print("Teleported player: " .. player.Name)
                end
            end
        end
    end
end

-- Функция для получения очков без телепортации
local function AutoCollectPoints()
    local pointsValue = Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Points")
    if pointsValue then
        pointsValue.Value = pointsValue.Value + 500
        print("Points added directly: +500")
        return true
    else
        -- Альтернатива: вызов RemoteEvent (если известно имя)
        -- Пример: local remote = game.ReplicatedStorage:FindFirstChild("PointsRemote")
        -- if remote then remote:FireServer(500) end
        print("No leaderstats.Points found. Check for RemoteEvent or other mechanics.")
        return false
    end
end

local function SetInfinitePoints()
    local pointsValue = Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Points")
    if pointsValue then
        pointsValue.Value = 999999999999999999
        print("Points set to maximum! Current value: " .. tostring(pointsValue.Value))
        return true
    else
        print("No leaderstats.Points found. Check for RemoteEvent or other mechanics.")
        return false
    end
end

-- ===== MAIN TAB =====
-- Noclip Toggle
local NoclipToggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      noclipEnabled = Value
      
      if noclipConnection then
         noclipConnection:Disconnect()
         noclipConnection = nil
      end
      
      if Value then
         Rayfield:Notify({
            Title = "Noclip",
            Content = "ENABLED - You can walk through walls (ladders work)",
            Duration = 3,
         })
         
         UpdateNoclip()
         
         noclipConnection = RunService.Stepped:Connect(function()
            if noclipEnabled then
               UpdateNoclip()
            end
         end)
      else
         Rayfield:Notify({
            Title = "Noclip",
            Content = "DISABLED",
            Duration = 2,
         })
         local character = Plr.Character
         if character then
            for _, v in pairs(character:GetChildren()) do
               if v:IsA("BasePart") then
                  v.CanCollide = true
               end
            end
         end
      end
   end,
})

-- Fly Toggle
local FlyToggle = MainTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flyEnabled = Value
      
      if flyConnection then
         flyConnection:Disconnect()
         flyConnection = nil
      end
      
      if Value then
         Rayfield:Notify({
            Title = "Fly",
            Content = "ENABLED - Use WASD, E (up), Q (down) to fly",
            Duration = 3,
         })
         
         UpdateFly()
         
         flyConnection = RunService.RenderStepped:Connect(function()
            if flyEnabled then
               UpdateFly()
            end
         end)
      else
         Rayfield:Notify({
            Title = "Fly",
            Content = "DISABLED",
            Duration = 2,
         })
         UpdateFly() -- Отключаем BodyVelocity и BodyGyro
      end
   end,
})

-- Godmode Toggle
local GodmodeToggle = MainTab:CreateToggle({
   Name = "Godmode",
   CurrentValue = false,
   Flag = "GodmodeToggle",
   Callback = function(Value)
      godmodeEnabled = Value
      
      if godmodeConnection then
         godmodeConnection:Disconnect()
         godmodeConnection = nil
      end
      
      if Value then
         Rayfield:Notify({
            Title = "Godmode",
            Content = "ENABLED - You are invulnerable",
            Duration = 3,
         })
         
         UpdateGodmode()
         
         godmodeConnection = RunService.Stepped:Connect(function()
            if godmodeEnabled then
               UpdateGodmode()
            end
         end)
      else
         Rayfield:Notify({
            Title = "Godmode",
            Content = "DISABLED",
            Duration = 2,
         })
      end
   end,
})

-- JumpHack Toggle
local JumpHackToggle = MainTab:CreateToggle({
   Name = "JumpHack",
   CurrentValue = false,
   Flag = "JumpHackToggle",
   Callback = function(Value)
      jumpHackEnabled = Value
      local character = Plr.Character
      if character then
         UpdateJumpHack(character)
      end
      Rayfield:Notify({
         Title = "JumpHack",
         Content = Value and "ENABLED - Super high jumps" or "DISABLED",
         Duration = 3,
      })
   end,
})

local JumpSlider = MainTab:CreateSlider({
   Name = "Jump Height",
   Range = {0, 500},
   Increment = 1,
   Suffix = " units",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      jumpHeightValue = Value
      local character = Plr.Character
      if character and jumpHackEnabled then
         UpdateJumpHack(character)
      end
   end,
})

-- FOV Slider
local FOVSlider = MainTab:CreateSlider({
   Name = "FOV",
   Range = {0, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOVSlider",
   Callback = function(Value)
      fovValue = Value
      UpdateFOV()
   end,
})

-- KillAura Toggle
local KillAuraToggle = MainTab:CreateToggle({
   Name = "KillAura",
   CurrentValue = false,
   Flag = "KillAuraToggle",
   Callback = function(Value)
      killAuraEnabled = Value
      
      if killAuraConnection then
         killAuraConnection:Disconnect()
         killAuraConnection = nil
      end
      
      if Value then
         Rayfield:Notify({
            Title = "KillAura",
            Content = "ENABLED - Teleporting nearby players away",
            Duration = 3,
         })
         
         UpdateKillAura()
         
         killAuraConnection = RunService.Heartbeat:Connect(function()
            if killAuraEnabled then
               UpdateKillAura()
            end
         end)
      else
         Rayfield:Notify({
            Title = "KillAura",
            Content = "DISABLED",
            Duration = 2,
         })
      end
   end,
})

local InfinitePointsButton = VisualTab:CreateButton({
   Name = "Set Max Points (999999999999999999)",
   Callback = function()
      if SetInfinitePoints() then
         local pointsValue = Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Points")
         local currentPoints = pointsValue and tostring(pointsValue.Value) or "unknown"
         Rayfield:Notify({
            Title = "Max Points",
            Content = "Points set to maximum! Current: " .. currentPoints,
            Duration = 3,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Failed to set max points! Check leaderstats or RemoteEvent.",
            Duration = 3,
         })
      end
   end,
})

-- Give Green Laser Gun Button
local GiveLaserGunButton = MainTab:CreateButton({
   Name = "Give Green Laser Gun",
   Callback = function()
      local laser = game.ReplicatedStorage:FindFirstChild("Laser")
      if laser and laser:IsA("Tool") then
         local clonedLaser = laser:Clone()
         clonedLaser.Parent = Plr.Backpack
         print("Green Laser Gun added to backpack!")
         Rayfield:Notify({
            Title = "Give",
            Content = "Green Laser Gun given!",
            Duration = 3,
         })
      else
         -- Альтернатива: вызов RemoteEvent для выдачи предмета
         -- Пример: local remote = game.ReplicatedStorage:FindFirstChild("GiveTool")
         -- if remote then remote:FireServer("Laser") end
         print("Laser not found in ReplicatedStorage or is not a Tool.")
         Rayfield:Notify({
            Title = "Error",
            Content = "Failed to give Green Laser Gun! Check ReplicatedStorage.Laser.",
            Duration = 3,
         })
      end
   end,
})

-- ===== AUTO FARM TAB =====
-- Кнопка для сбора очков
local CollectButton = AutoFarmTab:CreateButton({
   Name = "Collect Points",
   Callback = function()
      if AutoCollectPoints() then
         Rayfield:Notify({
            Title = "Points Collected",
            Content = "Successfully added 500 points!",
            Duration = 3,
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Failed to add points! Check leaderstats or RemoteEvent.",
            Duration = 3,
         })
      end
   end,
})

-- Автоматический сбор очков Toggle
local AutoCollectToggle = AutoFarmTab:CreateToggle({
   Name = "Auto Collect Points",
   CurrentValue = false,
   Flag = "AutoCollectToggle",
   Callback = function(Value)
      autoCollectEnabled = Value
      
      if autoCollectConnection then
         autoCollectConnection:Disconnect()
         autoCollectConnection = nil
      end
      
      if Value then
         Rayfield:Notify({
            Title = "Auto Collect",
            Content = "ENABLED - Adding 500 points every 1 second",
            Duration = 3,
         })
         
         autoCollectConnection = RunService.Heartbeat:Connect(function()
            if autoCollectEnabled then
               AutoCollectPoints()
               wait(1)
            end
         end)
      else
         Rayfield:Notify({
            Title = "Auto Collect",
            Content = "DISABLED",
            Duration = 2,
         })
      end
   end,
})

local TeleportTFButton = MainTab:CreateButton({
   Name = "Teleport to Finish",
   Callback = function()
      local character = Plr.Character or Plr.CharacterAdded:Wait()
      local root = character:WaitForChild("HumanoidRootPart")
      root.CFrame = CFrame.new(93, 473, 50)
      
      Rayfield:Notify({
         Title = "Teleport",
         Content = "Teleported to Finish!",
         Duration = 3,
      })
   end,
})

-- ===== SPEEDHACK TAB =====
-- Speed Hack Toggle
local SpeedToggle = SpeedTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      speedEnabled = Value
      local character = Plr.Character
      if character then
         UpdateSpeed(character)
         UpdateJumpHack(character)
      end
   end,
})

local SpeedSlider = SpeedTab:CreateSlider({
   Name = "Walk Speed",
   Range = {0, 500},
   Increment = 1,
   Suffix = " units",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      if speedUnlocked then
         walkSpeedValue = Value
         local character = Plr.Character
         if character and speedEnabled then
            UpdateSpeed(character)
         end
         if character and not jumpHackEnabled then
            UpdateJumpHack(character)
         end
         if flyEnabled then
            UpdateFly()
         end
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Please unlock the Speed Slider first!",
            Duration = 3,
         })
      end
   end,
})

-- ===== EXIT TAB =====
local CollectButton = ExitTab:CreateButton({
   Name = "Exit",
   Callback = function()
      Rayfield:Destroy()
      if flyConnection then
         flyConnection:Disconnect()
         flyConnection = nil
      end
      if godmodeConnection then
         godmodeConnection:Disconnect()
         godmodeConnection = nil
      end
      if killAuraConnection then
         killAuraConnection:Disconnect()
         killAuraConnection = nil
      end
      if fovConnection then
         fovConnection:Disconnect()
         fovConnection = nil
      end
      if bodyVelocity then
         bodyVelocity:Destroy()
         bodyVelocity = nil
      end
      if bodyGyro then
         bodyGyro:Destroy()
         bodyGyro = nil
      end
   end,
})

-- Автоматическое применение настроек при respawn и изменении камеры
Plr.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    wait(0.1)
    UpdateSpeed(character)
    UpdateJumpHack(character)
    UpdateNoclip()
    UpdateFOV()
    if flyEnabled then
        UpdateFly()
        if flyConnection then
            flyConnection:Disconnect()
        end
        flyConnection = RunService.RenderStepped:Connect(function()
            if flyEnabled then
                UpdateFly()
            end
        end)
    end
    if godmodeEnabled then
        UpdateGodmode()
        if godmodeConnection then
            godmodeConnection:Disconnect()
        end
        godmodeConnection = RunService.Stepped:Connect(function()
            if godmodeEnabled then
                UpdateGodmode()
            end
        end)
    end
    if killAuraEnabled then
        UpdateKillAura()
        if killAuraConnection then
            killAuraConnection:Disconnect()
        end
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if killAuraEnabled then
                UpdateKillAura()
            end
        end)
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    UpdateFOV()
end)

-- Применяем настройки при запуске
if Plr.Character then
    UpdateSpeed(Plr.Character)
    UpdateJumpHack(Plr.Character)
    UpdateNoclip()
    UpdateFly()
    UpdateGodmode()
    UpdateKillAura()
    UpdateFOV()
end