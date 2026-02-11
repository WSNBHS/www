return function(Tabs)
    -- 挂载到WindUI的PlayerMain Tab（与主脚本的Player分区对应）
    local PlayerTab = Tabs.PlayerMain
    local player = game.Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- =====================================================
    -- 移速提升（带输入框调节）
    -- =====================================================
    do
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local isActive = false
        local speedValue = 3
        local distancePerTeleport = 1.5

        -- 移速输入框
        local speedInput = PlayerTab:Input({
            Title = "移速倍率",
            Value = tostring(speedValue),
            Placeholder = "1-10",
            Callback = function(input)
                local newSpeed = tonumber(input)
                if newSpeed and newSpeed > 0 and newSpeed <= 10 then
                    speedValue = newSpeed
                else
                    speedInput:SetValue(tostring(speedValue))
                end
            end
        })

        -- 移速开关
        local speedToggle = PlayerTab:Toggle({
            Title = "移速提升",
            Value = false,
            Callback = function(state)
                isActive = state
            end
        })

        -- 瞬移步函数
        local function TeleportStep()
            if not isActive or not character or not humanoidRootPart then return end
            local moveDirection = character:FindFirstChild("Humanoid") and character.Humanoid.MoveDirection or Vector3.zero
            if moveDirection.Magnitude > 0 then
                local newPos = humanoidRootPart.Position + (moveDirection * distancePerTeleport)
                humanoidRootPart.CFrame = CFrame.new(newPos, newPos + moveDirection)
            end
        end

        -- 每帧执行
        RunService.RenderStepped:Connect(function()
            if isActive then
                for _ = 1, speedValue do
                    TeleportStep()
                end
            end
        end)

        -- 重生更新角色
        player.CharacterAdded:Connect(function(char)
            character = char
            humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        end)
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 穿墙模式
    -- =====================================================
    do
        local noclipEnabled = false
        local character = player.Character or player.CharacterAdded:Wait()
        local noclipConnection

        -- 设置穿墙
        local function setNoclip(state)
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = not state
                    end
                end
            end
        end

        -- 穿墙开关
        PlayerTab:Toggle({
            Title = "穿墙模式",
            Value = false,
            Callback = function(state)
                noclipEnabled = state
                if noclipEnabled then
                    if noclipConnection then noclipConnection:Disconnect() end
                    noclipConnection = RunService.Stepped:Connect(function()
                        if noclipEnabled and character then
                            setNoclip(true)
                        end
                    end)
                else
                    if noclipConnection then noclipConnection:Disconnect() end
                    setNoclip(false)
                end
            end
        })

        -- 重生重置
        player.CharacterAdded:Connect(function(newChar)
            character = newChar
            noclipEnabled = false
            setNoclip(false)
            if noclipConnection then noclipConnection:Disconnect() end
        end)
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 电脑端按键传送（带按键选择+动画）
    -- =====================================================
    do
        local teleportEnabled = false
        local selectedKey = nil
        local TP_ANIM_ID = "17555632156"

        -- 传送按键选择
        local keybind = PlayerTab:Keybind({
            Title = "传送绑定按键",
            Value = "None",
            Callback = function(v)
                selectedKey = v
            end
        })

        -- 传送开关
        local tpToggle = PlayerTab:Toggle({
            Title = "电脑端按键传送",
            Value = false,
            Callback = function(state)
                teleportEnabled = state
            end
        })

        -- 播放传送动画
        local function playTpAnim(character)
            if not character or not character.Parent then character = player.Character end
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. TP_ANIM_ID
            local ok, track = pcall(function()
                local animator = humanoid:FindFirstChildOfClass("Animator")
                return animator and animator:LoadAnimation(anim) or humanoid:LoadAnimation(anim)
            end)

            if ok and track then
                pcall(function() track.Priority = Enum.AnimationPriority.Action end)
                track:Play()
                delay(0.8, function()
                    pcall(function() if track.IsPlaying then track:Stop() end anim:Destroy() end)
                end)
            else
                pcall(function() anim:Destroy() end)
            end
        end

        -- 传送到鼠标位置
        local function teleportToMouse()
            if not teleportEnabled or not selectedKey or selectedKey == "None" then return end
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local mouse = player:GetMouse()
            if not hrp or not mouse.Hit then return end

            local pos = mouse.Hit.Position
            local dx = hrp.Position.X - pos.X
            local dz = hrp.Position.Z - pos.Z
            if (dx * dx + dz * dz) ^ 0.5 > 250 then return end

            hrp.CFrame = CFrame.new(pos.X, pos.Y + 4, pos.Z)
            playTpAnim(character)
        end

        -- 按键触发
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not teleportEnabled or not selectedKey then return end
            if input.KeyCode.Name == selectedKey then
                teleportToMouse()
            end
        end)

        -- 重生保留设置
        player.CharacterAdded:Connect(function(newChar)
            newChar:WaitForChild("HumanoidRootPart")
        end)
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 移动端屏幕传送（带悬浮按钮）
    -- =====================================================
    do
        local teleportEnabled = false
        local tpButtonActive = false
        local mouse = player:GetMouse()

        -- 移动端传送开关
        local peTpToggle = PlayerTab:Toggle({
            Title = "移动端屏幕传送",
            Value = false,
            Callback = function(state)
                teleportEnabled = state
                MobileTPButton.Visible = state
                tpButtonActive = false
                MobileTPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        })

        -- 创建悬浮传送按钮（CoreGui防重置）
        local screenGui = Instance.new("ScreenGui", game.CoreGui)
        screenGui.ResetOnSpawn = false
        local MobileTPButton = Instance.new("TextButton", screenGui)
        MobileTPButton.Size = UDim2.new(0, 40, 0, 40)
        MobileTPButton.Position = UDim2.new(0.92, 0, 0.5, -13)
        MobileTPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        MobileTPButton.BackgroundTransparency = 0.5
        MobileTPButton.Text = "⚡"
        MobileTPButton.TextScaled = true
        MobileTPButton.TextColor3 = Color3.new(1, 1, 1)
        MobileTPButton.Visible = false
        local UICorner = Instance.new("UICorner", MobileTPButton)
        UICorner.CornerRadius = UDim.new(1, 0)

        -- 悬浮按钮点击
        MobileTPButton.MouseButton1Click:Connect(function()
            tpButtonActive = not tpButtonActive
            MobileTPButton.BackgroundColor3 = tpButtonActive and Color3.fromRGB(0, 0, 139) or Color3.fromRGB(100, 100, 100)
        end)

        -- 传送到点击位置
        local function TeleportToMouse()
            if not teleportEnabled or not tpButtonActive then return end
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local targetPosition = mouse.Hit.Position
            if not rootPart then return end

            local distance = (rootPart.Position - targetPosition).Magnitude
            if distance <= 250 then
                rootPart.CFrame = CFrame.new(targetPosition)
                tpButtonActive = false
                MobileTPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        end

        -- 电脑端鼠标/移动端触摸触发
        mouse.Button1Down:Connect(TeleportToMouse)
        UserInputService.TouchTap:Connect(function(_, processed)
            if not processed then TeleportToMouse() end
        end)

        -- 重生重置
        player.CharacterAdded:Connect(function()
            teleportEnabled = false
            tpButtonActive = false
            peTpToggle:SetValue(false)
            MobileTPButton.Visible = false
        end)
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 无限跳跃
    -- =====================================================
    do
        local infiniteJumpEnabled = false

        -- 无限跳开关
        PlayerTab:Toggle({
            Title = "无限跳跃",
            Value = false,
            Callback = function(state)
                infiniteJumpEnabled = state
            end
        })

        -- 跳跃请求监听
        UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled then
                local char = player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 自动武装色
    -- =====================================================
    do
        local autoBuso = false
        local CHECK_INTERVAL = 3

        -- 自动武装色开关
        local busoToggle = PlayerTab:Toggle({
            Title = "自动武装色",
            Value = false,
            Callback = function(state)
                autoBuso = state
                player:SetAttribute("AutoBuso", state)
            end
        })

        -- 初始化属性
        if player:GetAttribute("AutoBuso") == nil then
            player:SetAttribute("AutoBuso", false)
        else
            autoBuso = player:GetAttribute("AutoBuso")
            busoToggle:SetValue(autoBuso)
        end

        -- 获取角色模型
        local function getCharacterModel()
            local chars = workspace:FindFirstChild("Characters")
            return chars and chars:FindFirstChild(player.Name)
        end

        -- 检测武装色是否开启
        local function isBusoOn()
            local char = getCharacterModel()
            return char and char:FindFirstChild("HasBuso") ~= nil
        end

        -- 开启武装色
        local function turnOnBuso()
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end)
        end

        -- 自动检测循环
        task.spawn(function()
            while true do
                if autoBuso and not isBusoOn() then
                    turnOnBuso()
                end
                task.wait(CHECK_INTERVAL)
            end
        end)

        -- 属性监听同步
        player:GetAttributeChangedSignal("AutoBuso"):Connect(function()
            autoBuso = player:GetAttribute("AutoBuso")
            busoToggle:SetValue(autoBuso)
        end)

        -- 共享变量支持
        shared = shared or {}
        shared.ToggleAutoBuso = function(val)
            player:SetAttribute("AutoBuso", val)
        end
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 自动见闻色
    -- =====================================================
    do
        local autoObserve = false
        local INTERVAL = 5

        -- 自动见闻色开关
        local observeToggle = PlayerTab:Toggle({
            Title = "自动见闻色",
            Value = false,
            Callback = function(state)
                autoObserve = state
                player:SetAttribute("AutoObserve", state)
                if state then enableObserve() end
            end
        })

        -- 初始化属性
        if player:GetAttribute("AutoObserve") == nil then
            player:SetAttribute("AutoObserve", false)
        else
            autoObserve = player:GetAttribute("AutoObserve")
            observeToggle:SetValue(autoObserve)
        end

        -- 开启见闻色
        local function enableObserve()
            pcall(function()
                ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
            end)
        end

        -- 自动循环
        task.spawn(function()
            while true do
                if autoObserve then
                    enableObserve()
                    task.wait(INTERVAL)
                else
                    task.wait(0.3)
                end
            end
        end)

        -- 属性监听同步
        player:GetAttributeChangedSignal("AutoObserve"):Connect(function()
            autoObserve = player:GetAttribute("AutoObserve")
            observeToggle:SetValue(autoObserve)
        end)

        -- 共享变量支持
        shared = shared or {}
        shared.ToggleAutoObserve = function(val)
            player:SetAttribute("AutoObserve", val)
        end
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 自动技能 + 自动觉醒
    -- =====================================================
    do
        local autoAbility = false
        local autoAwakening = false
        local INTERVAL = 2
        local awakeningBusy = false
        local awakenAttemptId = 0
        local MAX_AWAIT = 4

        -- 自动技能开关
        local abilityToggle = PlayerTab:Toggle({
            Title = "自动释放技能",
            Value = false,
            Callback = function(state)
                autoAbility = state
                player:SetAttribute("AutoAbility", state)
                if state then fireAbility() end
            end
        })

        -- 自动觉醒开关
        local awakenToggle = PlayerTab:Toggle({
            Title = "自动果实觉醒",
            Value = false,
            Callback = function(state)
                autoAwakening = state
                player:SetAttribute("AutoAwakening", state)
                if state then attemptAwakening() end
            end
        })

        -- 初始化属性
        if player:GetAttribute("AutoAbility") == nil then player:SetAttribute("AutoAbility", false) else autoAbility = player:GetAttribute("AutoAbility") abilityToggle:SetValue(autoAbility) end
        if player:GetAttribute("AutoAwakening") == nil then player:SetAttribute("AutoAwakening", false) else autoAwakening = player:GetAttribute("AutoAwakening") awakenToggle:SetValue(autoAwakening) end

        -- 释放技能
        local function fireAbility()
            pcall(function()
                if ReplicatedStorage.Remotes and ReplicatedStorage.Remotes.CommE then
                    ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
                end
            end)
        end

        -- 尝试觉醒
        local function attemptAwakening()
            if awakeningBusy then return end
            awakenAttemptId = awakenAttemptId + 1
            local myId = awakenAttemptId
            awakeningBusy = true
            local awakeningStartedAt = tick()

            task.spawn(function()
                local succeeded = false
                local bp = player:FindFirstChild("Backpack")
                local waited = 0
                while waited < 3 and (not bp or not bp:FindFirstChild("Awakening")) do
                    task.wait(0.18)
                    waited = waited + 0.18
                    bp = player:FindFirstChild("Backpack")
                end

                local awak = bp and bp:FindFirstChild("Awakening")
                if awak then
                    local rf = awak:FindFirstChild("RemoteFunction")
                    if rf then
                        local ok = pcall(function() rf:InvokeServer(true) end)
                        if ok then succeeded = true end
                    end
                end

                if awakenAttemptId == myId then awakeningBusy = false end
            end)
        end

        -- 心跳循环执行
        local lastAwakenTick = 0
        local lastAbilityTick = 0
        RunService.Heartbeat:Connect(function(dt)
            -- 自动技能
            if autoAbility then
                if (tick() - lastAbilityTick) >= INTERVAL then
                    lastAbilityTick = tick()
                    fireAbility()
                end
            else
                lastAbilityTick = tick() - INTERVAL - 0.01
            end

            -- 自动觉醒看门狗
            if awakeningBusy and (tick() - awakeningStartedAt) > MAX_AWAIT then
                awakeningBusy = false
                awakenAttemptId = awakenAttemptId + 1
            end

            -- 自动觉醒
            if autoAwakening then
                if (tick() - lastAwakenTick) >= INTERVAL and not awakeningBusy then
                    lastAwakenTick = tick()
                    attemptAwakening()
                end
            else
                lastAwakenTick = tick() - INTERVAL - 0.01
            end
        end)

        -- 属性监听同步
        player:GetAttributeChangedSignal("AutoAbility"):Connect(function()
            autoAbility = player:GetAttribute("AutoAbility")
            abilityToggle:SetValue(autoAbility)
        end)
        player:GetAttributeChangedSignal("AutoAwakening"):Connect(function()
            autoAwakening = player:GetAttribute("AutoAwakening")
            awakenToggle:SetValue(autoAwakening)
        end)

        -- 重生重置
        local function onCharacter(char)
            awakeningBusy = false
            awakenAttemptId = awakenAttemptId + 1
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Died:Connect(function()
                    awakeningBusy = false
                    awakenAttemptId = awakenAttemptId + 1
                end)
            end
        end
        if player.Character then onCharacter(player.Character) end
        player.CharacterAdded:Connect(onCharacter)

        -- 共享变量支持
        shared = shared or {}
        shared.ToggleAutoAbility = function(v) player:SetAttribute("AutoAbility", v) end
        shared.ToggleAutoAwakening = function(v) player:SetAttribute("AutoAwakening", v) end
    end

    PlayerTab:Divider()
    -- =====================================================
    -- 阵营选择（海军/海盗，带10s冷却）
    -- =====================================================
    do
        local isCooldown = false
        local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

        -- 海军按钮
        local marinesBtn = PlayerTab:Button({
            Title = "选择海军阵营",
            Callback = function()
                if isCooldown then return end
                pcall(function() CommF:InvokeServer("SetTeam", "Marines") end)
                handleCooldown()
            end
        })

        -- 海盗按钮
        local piratesBtn = PlayerTab:Button({
            Title = "选择海盗阵营",
            Callback = function()
                if isCooldown then return end
                pcall(function() CommF:InvokeServer("SetTeam", "Pirates") end)
                handleCooldown()
            end
        })

        -- 冷却处理
        local function handleCooldown()
            isCooldown = true
            marinesBtn:SetLocked(true)
            piratesBtn:SetLocked(true)
            WindUI:Notify({
                Title = "阵营切换",
                Content = "冷却中，剩余10秒",
                Duration = 10,
                Icon = "clock"
            })

            task.wait(10)
            isCooldown = false
            marinesBtn:SetLocked(false)
            piratesBtn:SetLocked(false)
        end
    end

    -- 加载成功提示
    task.wait(0.2)
    WindUI:Notify({
        Title = "加载成功",
        Content = "玩家功能模块 v0.10 已加载",
        Duration = 2,
        Icon = "check"
    })
    print("玩家功能模块 v0.10 加载成功✅")
end
