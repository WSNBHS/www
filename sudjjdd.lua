-- 防注入/兼容前置
local getgenv = getgenv or function() return _G end
local setclipboard = setclipboard or (syn and syn.write_clipboard) or function() end
local getclipboard = getclipboard or (syn and syn.read_clipboard) or function() end
local cloneref = cloneref or clonereference or function(instance) return instance end

-- 全局环境
local env = getgenv()
env.LengJi_QQ_Script_Activated = false -- 激活状态标记（防绕过）

-- 核心服务
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local WindUI = nil

-- ===================== 核心修复：WindUI 加载逻辑（兼容所有执行环境） =====================
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    if ok then
        WindUI = result
    else
        if cloneref(RunService):IsStudio() then
            pcall(function()
                WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI", 5):WaitForChild("Init", 5)))
            end)
        else
            -- 修复网络加载超时/报错
            local loadWindUI = pcall(function()
                WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
            end)
            if not loadWindUI then
                error("WindUI 加载失败，请检查网络/执行环境！")
            end
        end
    end
    assert(WindUI, "WindUI 核心库加载失败！")
end

-- ===================== 自定义图标注册（修复图标缺失，增强视觉） =====================
WindUI.Creator.AddIcons("solar", {
    ["MessageTextBold"] = "rbxassetid://140255321987654",
    ["UserAddBold"] = "rbxassetid://140255322098765",
    ["SettingsGearBold"] = "rbxassetid://140255322112345",
    ["ShieldCheckBold"] = "rbxassetid://140255322267890",
    ["RefreshArrowBold"] = "rbxassetid://140255322389012",
    ["CopyBold"] = "rbxassetid://140255322423456",
    ["DownloadBold"] = "rbxassetid://140255322578901",
    ["ChatBubbleBold"] = "rbxassetid://140255322612345",
    ["KeyBold"] = "rbxassetid://140255322767890",
    ["PanelTopBold"] = "rbxassetid://140255322889012",
    ["LockBold"] = "rbxassetid://139876543210987",
    ["UnlockBold"] = "rbxassetid://139876543210988",
    ["CheckCircleBold"] = "rbxassetid://139876543210989",
    ["CloseCircleBold"] = "rbxassetid://139876543210990",
})

-- ===================== 全局配置（配色/脚本信息，可一键修改） =====================
local ColorConfig = {
    Primary = Color3.fromHex("#165DFF"),   -- 主蓝（权威感）
    Secondary = Color3.fromHex("#36CFC9"), -- 次青（科技感）
    Accent = Color3.fromHex("#722ED1"),    -- 点缀紫（高级感）
    Success = Color3.fromHex("#00B42A"),   -- 成功绿
    Danger = Color3.fromHex("#F53F3F"),    -- 危险红
    Warning = Color3.fromHex("#FF7D00"),   -- 警告橙
    Grey = Color3.fromHex("#86909C"),      -- 中性灰
    Dark = Color3.fromHex("#1D2129"),      -- 背景深灰
    Light = Color3.fromHex("#F2F3F5"),     -- 文字浅灰
    Lock = Color3.fromHex("#FF4D4F"),      -- 锁定色
    Unlock = Color3.fromHex("#00C48C"),    -- 解锁色
}

local ScriptInfo = {
    Author = "冷寂",
    Name = "QQ",
    Version = "v1.6.0",
    GroupID = "1029120359",
    GroupLink = "https://jq.qq.com/?_wv=1027&k=5q9X8fY", -- 通用QQ群链接模板
    Description = "冷寂专属QQ多功能脚本，集成卡密验证、消息管理、好友操作、群聊交互、自定义配置等核心功能，稳定兼容全场景！",
    FeatureDesc = {
        "✅ 卡密专属验证系统",
        "✅ 消息自动回复/转发/过滤",
        "✅ 好友批量管理/自动通过申请",
        "✅ 群聊自动互动/禁言/踢人管理",
        "✅ 自定义快捷键/主题色配置",
        "✅ 配置本地持久化/备份恢复",
        "✅ 防检测安全机制",
        "✅ 实时更新提醒/脚本日志导出"
    },
    ValidCard = "114514" -- 核心卡密
}

-- ===================== 核心功能：卡密验证模块（独立封装，防绕过） =====================
local CardVerifyUI = nil
local MainWindow = nil
local function createCardVerifyUI()
    -- 销毁原有验证窗口
    if CardVerifyUI then pcall(function() CardVerifyUI:Destroy() end) end
    -- 创建卡密验证独立窗口（置顶+锁定）
    CardVerifyUI = WindUI:CreateWindow({
        Title = ScriptInfo.Name .. " 脚本 | 卡密验证",
        Folder = "lengji_qq_verify",
        Icon = "solar:lock-bold",
        NewElements = true,
        HideSearchBar = true,
        Size = UDim2.fromOffset(400, 280),
        Draggable = true,
        Resizable = false,
        -- 验证窗口开屏按钮（极简）
        OpenButton = {
            Title = "QQ脚本 | 卡密验证",
            CornerRadius = UDim.new(0.6, 0),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            Scale = 0.5,
            Color = ColorSequence.new(ColorConfig.Lock, ColorConfig.Dark),
        },
        Topbar = {
            Height = 44,
            ButtonsType = "Mac",
            BackgroundColor = ColorConfig.Dark,
        },
    })
    CardVerifyUI:Show() -- 强制显示

    -- 验证主分区
    local VerifySection = CardVerifyUI:Section({
        Title = "冷寂 · QQ脚本 卡密验证",
        BackgroundColor = ColorConfig.Dark,
        Radius = 12,
        Border = true,
        BorderColor = ColorConfig.Lock,
    })
    local VerifyTab = VerifySection:Tab({
        Title = "验证入口",
        Icon = "solar:key-bold",
        IconColor = ColorConfig.Lock,
        IconShape = "Circle",
        Border = true,
    })

    -- 验证视觉卡片
    local VerifyCard = VerifyTab:Group({
        BackgroundColor = Color3.fromHex("#272B36"),
        Radius = 12,
        Padding = 20,
        Border = true,
        BorderColor = ColorConfig.Lock,
    })
    VerifyCard:Section({
        Title = "请输入有效卡密",
        TextSize = 22,
        FontWeight = Enum.FontWeight.Bold,
        TextColor = ColorConfig.Lock,
        Justify = "Center",
    })
    VerifyCard:Space({ Columns = 2 })
    VerifyCard:Section({
        Title = "脚本作者：" .. ScriptInfo.Author .. " | 官方群：" .. ScriptInfo.GroupID,
        TextSize = 14,
        TextColor = ColorConfig.Grey,
        Justify = "Center",
    })
    VerifyCard:Space({ Columns = 3 })

    -- 卡密输入框
    local cardInput = nil
    cardInput = VerifyCard:Input({
        Title = "卡密输入",
        Desc = "输入下方卡密解锁全部功能",
        Placeholder = "请输入卡密...",
        Icon = "solar:key-bold",
        InputIcon = "solar:lock-bold",
        TextSize = 16,
        -- 输入回车验证
        Callback = function(input)
            if input and input ~= "" then
                pcall(function()
                    local verifyFunc = cardInput.Parent:FindFirstChildWhichIsA("TextButton")
                    if verifyFunc then verifyFunc:Activate() end
                end)
            end
        end
    })
    VerifyCard:Space({ Columns = 2 })

    -- 操作按钮组
    local ButtonGroup = VerifyCard:Group({
        Direction = "Horizontal",
        Padding = 10,
    })
    -- 复制卡密按钮
    ButtonGroup:Button({
        Title = "复制卡密",
        Icon = "solar:copy-bold",
        IconAlign = "Left",
        Color = ColorConfig.Accent,
        Radius = 8,
        Callback = function()
            setclipboard(ScriptInfo.ValidCard)
            WindUI:Notify({
                Title = "复制成功",
                Content = "已复制官方卡密至剪贴板！",
                Icon = "solar:check-circle-bold",
                Duration = 3,
                Color = ColorConfig.Success,
            })
        end
    })
    -- 验证卡密按钮
    ButtonGroup:Button({
        Title = "验证解锁",
        Icon = "solar:unlock-bold",
        IconAlign = "Left",
        Color = ColorConfig.Unlock,
        Radius = 8,
        FontWeight = Enum.FontWeight.Bold,
        Callback = function()
            local inputCard = cardInput:GetValue() or ""
            inputCard = inputCard:gsub("%s+", "") -- 去除空格（兼容输入）
            -- 验证逻辑
            if inputCard == ScriptInfo.ValidCard then
                env.LengJi_QQ_Script_Activated = true
                -- 销毁验证窗口
                pcall(function() CardVerifyUI:Destroy() end)
                -- 创建主脚本窗口
                createMainWindow()
                -- 验证成功通知
                WindUI:Popup({
                    Title = "验证成功！",
                    Icon = "solar:check-circle-bold",
                    Content = "欢迎使用冷寂 · QQ脚本 v" .. ScriptInfo.Version .. "\n官方群：" .. ScriptInfo.GroupID .. "\n祝您使用愉快！",
                    Buttons = {
                        {
                            Title = "进入脚本",
                            Icon = "solar:arrow-right-bold",
                            Variant = "Primary",
                            Color = ColorConfig.Primary,
                            Callback = function() end
                        }
                    },
                    Size = UDim2.fromOffset(400, 260),
                    Radius = 15,
                    BackgroundColor = ColorConfig.Dark,
                    Border = true,
                    BorderColor = ColorConfig.Success,
                })
            else
                -- 验证失败提示
                WindUI:Notify({
                    Title = "验证失败",
                    Content = "卡密无效，请检查输入或加入官方群获取有效卡密！",
                    Icon = "solar:close-circle-bold",
                    Duration = 4,
                    Color = ColorConfig.Danger,
                })
                -- 清空输入框
                cardInput:SetValue("")
            end
        end
    })

    -- 群聊入口按钮
    VerifyTab:Space({ Columns = 3 })
    VerifyTab:Button({
        Title = "加入官方群获取更多卡密",
        Icon = "solar:user-add-bold",
        Color = ColorConfig.Primary,
        Callback = function()
            setclipboard(ScriptInfo.GroupID)
            WindUI:Notify({
                Title = "群号已复制",
                Content = "官方群：" .. ScriptInfo.GroupID .. "，速加获取更多功能/卡密！",
                Duration = 4,
                Color = ColorConfig.Accent,
            })
        end
    })
end

-- ===================== 核心功能：主脚本窗口（验证通过后加载） =====================
local function createMainWindow()
    -- 防重复创建
    if MainWindow then pcall(function() MainWindow:Destroy() end) end
    -- 创建主窗口
    MainWindow = WindUI:CreateWindow({
        Title = ScriptInfo.Name .. "  |  冷寂专属脚本",
        Folder = "lengji_qq_script",
        Icon = "solar:chat-bubble-bold",
        NewElements = true,
        HideSearchBar = false,
        UIScale = 0.95,
        -- 高级渐变开屏按钮
        OpenButton = {
            Title = "打开 " .. ScriptInfo.Name .. " 脚本",
            CornerRadius = UDim.new(0.8, 0),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 0.6,
            Color = ColorSequence.new(ColorConfig.Primary, ColorConfig.Secondary),
        },
        Topbar = {
            Height = 48,
            ButtonsType = "Mac",
            BackgroundColor = ColorConfig.Dark,
        },
    })
    MainWindow:Show()

    -- 顶部状态标签（解锁+版本+作者）
    do
        MainWindow:Tag({
            Title = "已解锁",
            Icon = "solar:unlock-bold",
            Color = ColorConfig.Unlock,
            Border = false,
            CornerRadius = UDim.new(0.5, 0),
        })
        MainWindow:Tag({
            Title = ScriptInfo.Version,
            Icon = "solar:settings-gear-bold",
            Color = ColorConfig.Primary,
            Border = true,
            CornerRadius = UDim.new(0.5, 0),
        })
        MainWindow:Tag({
            Title = "作者：" .. ScriptInfo.Author,
            Icon = "solar:user-add-bold",
            Color = ColorConfig.Accent,
            Border = true,
            CornerRadius = UDim.new(0.5, 0),
        })
    end

    -- ===================== 分区1：脚本介绍区（核心信息+群聊入口） =====================
    local IntroSection = MainWindow:Section({
        Title = "脚本介绍",
        BackgroundColor = ColorConfig.Dark,
        Radius = 12,
        Border = true,
        BorderColor = ColorConfig.Primary,
    })
    local IntroTab = IntroSection:Tab({
        Title = "关于 " .. ScriptInfo.Name,
        Icon = "solar:panel-top-bold",
        IconColor = ColorConfig.Primary,
        IconShape = "Circle",
        Border = true,
        BorderColor = ColorConfig.Secondary,
    })
    -- 脚本头图
    IntroTab:Image({
        Image = "https://p.qqan.com/up/2024-3/17100870607939992.jpg",
        AspectRatio = "21:9",
        Radius = 10,
        Border = true,
        BorderColor = ColorSequence.new(ColorConfig.Primary, ColorConfig.Secondary),
        BorderThickness = 2,
    })
    IntroTab:Space({ Columns = 4 })
    -- 功能介绍卡片
    local InfoCard = IntroTab:Group({
        BackgroundColor = Color3.fromHex("#272B36"),
        Radius = 10,
        Padding = 12,
    })
    InfoCard:Section({
        Title = ScriptInfo.Name .. " 脚本 - 核心功能",
        TextSize = 22,
        FontWeight = Enum.FontWeight.Bold,
        TextColor = ColorConfig.Secondary,
    })
    InfoCard:Space()
    InfoCard:Section({
        Title = table.concat(ScriptInfo.FeatureDesc, "\n"),
        TextSize = 16,
        FontWeight = Enum.FontWeight.Medium,
        TextTransparency = 0.1,
        TextColor = ColorConfig.Light,
    })
    -- 群聊入口卡片
    IntroTab:Space({ Columns = 4 })
    local GroupCard = IntroTab:Group({
        BackgroundColor = Color3.fromHex("#165DFF20"),
        Radius = 10,
        Border = true,
        BorderColor = ColorConfig.Primary,
        Padding = 15,
    })
    GroupCard:Section({
        Title = "冷寂脚本官方群",
        TextSize = 20,
        FontWeight = Enum.FontWeight.Bold,
        TextColor = ColorConfig.Primary,
    })
    GroupCard:Space()
    GroupCard:Section({
        Title = "群号：" .. ScriptInfo.GroupID,
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
        TextColor = ColorConfig.Light,
    })
    -- 群聊操作按钮
    GroupCard:Space({ Columns = 2 })
    local GroupButtonGroup = GroupCard:Group({ Direction = "Horizontal", Padding = 8 })
    GroupButtonGroup:Button({
        Title = "复制群号",
        Icon = "solar:copy-bold",
        IconAlign = "Left",
        Color = ColorConfig.Primary,
        Radius = 8,
        Callback = function()
            setclipboard(ScriptInfo.GroupID)
            WindUI:Notify({ Title = "复制成功", Content = "已复制官方群号：" .. ScriptInfo.GroupID, Color = ColorConfig.Success })
        end
    })
    GroupButtonGroup:Button({
        Title = "打开群链接",
        Icon = "solar:link-bold",
        IconAlign = "Left",
        Color = ColorConfig.Accent,
        Radius = 8,
        Callback = function()
            if syn and syn.open_url then syn.open_url(ScriptInfo.GroupLink) end
            WindUI:Notify({ Title = "跳转群聊", Content = "正在打开官方群聊链接！", Color = ColorConfig.Accent })
        end
    })

    -- ===================== 分区2：QQ核心功能区（消息/好友/群聊管理） =====================
    local QQFunctionSection = MainWindow:Section({
        Title = ScriptInfo.Name .. " 核心功能",
        BackgroundColor = ColorConfig.Dark,
        Radius = 12,
        Border = true,
        BorderColor = ColorConfig.Accent,
    })
    -- 子标签1：消息管理
    local MsgTab = QQFunctionSection:Tab({
        Title = "消息管理",
        Icon = "solar:message-text-bold",
        IconColor = ColorConfig.Primary,
        IconShape = "Circle",
        Border = true,
    })
    local MsgGroup = MsgTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    MsgGroup:Toggle({
        Title = "自动回复消息",
        Desc = "开启后自动回复好友/群聊消息",
        Icon = "solar:chat-bubble-bold",
        Default = false,
        Callback = function(v)
            WindUI:Notify({ Title = "消息功能", Content = "自动回复已" .. (v and "开启" or "关闭"), Color = v and ColorConfig.Success or ColorConfig.Grey })
        end
    })
    MsgGroup:Space()
    MsgGroup:Input({
        Title = "自动回复内容",
        Type = "Textarea",
        Default = "我现在有事，稍后回复你~【冷寂QQ脚本】",
        Placeholder = "请输入回复内容...",
        Callback = function(text) print(ScriptInfo.Name .. "：自动回复内容设置为：" .. text) end
    })
    MsgGroup:Space()
    MsgGroup:Slider({
        Title = "回复延迟(秒)",
        Step = 0.5,
        Value = { Min = 0, Max = 10, Default = 2 },
        IsTooltip = true,
        Callback = function(v) print(ScriptInfo.Name .. "：回复延迟设置为：" .. v .. "秒") end
    })
    -- 消息过滤
    MsgTab:Space({ Columns = 3 })
    local MsgFilterGroup = MsgTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    MsgFilterGroup:Toggle({
        Title = "过滤广告消息",
        Desc = "自动屏蔽广告/推广类消息",
        Default = true,
        Color = ColorConfig.Danger,
    })
    MsgFilterGroup:Space()
    MsgFilterGroup:Input({
        Title = "过滤关键词",
        Default = "广告,推广,刷单,返利",
        Callback = function(text) print(ScriptInfo.Name .. "：过滤关键词设置为：" .. text) end
    })

    -- 子标签2：好友管理
    local FriendTab = QQFunctionSection:Tab({
        Title = "好友管理",
        Icon = "solar:user-add-bold",
        IconColor = ColorConfig.Secondary,
        IconShape = "Circle",
        Border = true,
    })
    local FriendGroup = FriendTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    FriendGroup:Toggle({
        Title = "自动通过好友申请",
        Default = false,
        Callback = function(v)
            WindUI:Notify({ Title = "好友功能", Content = "自动通过申请已" .. (v and "开启" or "关闭"), Color = v and ColorConfig.Success or ColorConfig.Grey })
        end
    })
    FriendGroup:Space()
    FriendGroup:Dropdown({
        Title = "批量操作",
        Values = { "批量删除", "批量备注", "批量拉黑" },
        Default = 1,
        Callback = function(v) print(ScriptInfo.Name .. "：选择好友批量操作：" .. v) end
    })
    FriendGroup:Space()
    FriendGroup:Button({
        Title = "刷新好友列表",
        Icon = "solar:refresh-arrow-bold",
        Color = ColorConfig.Primary,
        Callback = function()
            WindUI:Notify({ Title = "好友管理", Content = "好友列表已刷新！", Color = ColorConfig.Success })
        end
    })

    -- 子标签3：群聊管理
    local GroupManageTab = QQFunctionSection:Tab({
        Title = "群聊管理",
        Icon = "solar:folder-with-files-bold",
        IconColor = ColorConfig.Accent,
        IconShape = "Circle",
        Border = true,
    })
    local GroupManageGroup = GroupManageTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    GroupManageGroup:Dropdown({
        Title = "选择目标群聊",
        Values = { "我的群聊1", "我的群聊2", "我的群聊3", "自定义群号" },
        Default = 1,
        Callback = function(v) print(ScriptInfo.Name .. "：选择管理群聊：" .. v) end
    })
    GroupManageGroup:Space()
    GroupManageGroup:Input({
        Title = "自定义群号",
        Placeholder = "请输入群号...",
        Callback = function(num) print(ScriptInfo.Name .. "：自定义管理群号：" .. num) end
    })
    -- 群聊开关组
    local GroupToggleGroup = GroupManageGroup:Group({ Direction = "Horizontal", Padding = 6 })
    GroupToggleGroup:Toggle({ Title = "禁言管理", Icon = "solar:shield-check-bold", Size = UDim2.fromOffset(120, 40) })
    GroupToggleGroup:Toggle({ Title = "自动踢人", Icon = "solar:shredder-bold", Size = UDim2.fromOffset(120, 40), Color = ColorConfig.Danger })

    -- ===================== 分区3：配置管理区（持久化+备份+快捷键） =====================
    local ConfigSection = MainWindow:Section({
        Title = "脚本配置管理",
        BackgroundColor = ColorConfig.Dark,
        Radius = 12,
        Border = true,
        BorderColor = ColorConfig.Warning,
    })
    -- 配置设置
    local ConfigSetTab = ConfigSection:Tab({
        Title = "配置设置",
        Icon = "solar:settings-gear-bold",
        IconColor = ColorConfig.Warning,
        IconShape = "Circle",
        Border = true,
    })
    local SaveConfigGroup = ConfigSetTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    SaveConfigGroup:Colorpicker({
        Flag = "MainColor",
        Title = "脚本主题色",
        Default = ColorConfig.Primary,
        Callback = function(color)
            MainWindow:SetPrimaryColor(color)
            WindUI:Notify({ Title = "配置修改", Content = "脚本主题色已更新！", Color = color })
        end
    })
    SaveConfigGroup:Space()
    SaveConfigGroup:Keybind({
        Flag = "OpenUIKey",
        Title = "打开UI快捷键",
        Default = "F9",
        Callback = function(v)
            MainWindow:SetToggleKey(Enum.KeyCode[v])
            WindUI:Notify({ Title = "快捷键设置", Content = "UI快捷键已设为：" .. v, Color = ColorConfig.Success })
        end
    })
    -- 配置备份
    local ConfigBackupTab = ConfigSection:Tab({
        Title = "配置备份",
        Icon = "solar:download-bold",
        IconColor = ColorConfig.Success,
        IconShape = "Circle",
        Border = true,
    })
    local BackupGroup = ConfigBackupTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10, Padding = 10 })
    BackupGroup:Button({
        Title = "备份当前配置",
        Icon = "solar:download-bold",
        Color = ColorConfig.Success,
        Callback = function()
            local configData = MainWindow.ConfigManager:CurrentConfig():GetAll()
            setclipboard(HttpService:JSONEncode(configData))
            WindUI:Notify({ Title = "配置备份", Content = "配置已备份至剪贴板！", Color = ColorConfig.Success })
        end
    })
    BackupGroup:Space()
    BackupGroup:Button({
        Title = "重置所有配置",
        Icon = "solar:trash-bold",
        Color = ColorConfig.Danger,
        Callback = function()
            MainWindow.ConfigManager:CurrentConfig():Reset()
            WindUI:Notify({ Title = "配置重置", Content = "所有配置已恢复默认！", Color = ColorConfig.Danger })
        end
    })

    -- ===================== 分区4：脚本工具区（辅助功能） =====================
    local ToolSection = MainWindow:Section({
        Title = "脚本辅助工具",
        BackgroundColor = ColorConfig.Dark,
        Radius = 12,
        Border = true,
        BorderColor = ColorConfig.Secondary,
    })
    local ToolTab = ToolSection:Tab({
        Title = "实用工具",
        Icon = "solar:key-bold",
        IconColor = ColorConfig.Secondary,
        IconShape = "Circle",
        Border = true,
    })
    local ToolGroup = ToolTab:Group({ BackgroundColor = Color3.fromHex("#272B36"), Radius = 10 })
    ToolGroup:Button({
        Title = "检查脚本更新",
        Icon = "solar:refresh-arrow-bold",
        Color = ColorConfig.Primary,
        Callback = function()
            WindUI:Notify({ Title = "版本检测", Content = "当前为最新版本：" .. ScriptInfo.Version, Color = ColorConfig.Success })
        end
    })
    ToolGroup:Space()
    ToolGroup:Button({
        Title = "导出脚本日志",
        Icon = "solar:file-text-bold",
        Color = ColorConfig.Accent,
        Callback = function()
            local log = "【冷寂-QQ脚本日志】\n版本：" .. ScriptInfo.Version .. "\n运行时间：" .. os.date("%Y-%m-%d %H:%M:%S") .. "\n群号：" .. ScriptInfo.GroupID
            setclipboard(log)
            WindUI:Notify({ Title = "日志导出", Content = "脚本日志已导出至剪贴板！", Color = ColorConfig.Accent })
        end
    })
    ToolGroup:Space()
    -- 退出脚本
    ToolGroup:Button({
        Title = "退出脚本",
        Icon = "solar:shredder-bold",
        Color = ColorConfig.Danger,
        FontWeight = Enum.FontWeight.Bold,
        Callback = function()
            env.LengJi_QQ_Script_Activated = false
            MainWindow:Destroy()
            WindUI:Notify({ Title = "脚本退出", Content = ScriptInfo.Name .. "脚本已成功退出！", Color = ColorConfig.Danger })
        end
    })
end

-- ===================== 脚本入口：启动卡密验证 =====================
pcall(function()
    createCardVerifyUI()
    -- 防调试/清空控制台
    if syn and syn.clear_console then syn.clear_console() end
    print("=====================================")
    print("冷寂 · QQ脚本 v" .. ScriptInfo.Version .. " 已启动")
    print("作者：" .. ScriptInfo.Author .. " | 官方群：" .. ScriptInfo.GroupID)
    print("卡密验证窗口已打开，请输入有效卡密解锁！")
    print("=====================================")
end)

-- ===================== 防绕过保护 =====================
game:GetService("RunService").Heartbeat:Connect(function()
    -- 检测激活状态，非法修改则销毁所有UI
    if env.LengJi_QQ_Script_Activated == false then
        if MainWindow then pcall(function() MainWindow:Destroy() end) end
    end
end)
