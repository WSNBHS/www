-- 加载WindUI核心库
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 创建主窗口
local Window = WindUI:CreateWindow({
    Title = "游戏辅助脚本",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "WindUI 汉化版",
    Folder = "GameScript",
    Size = UDim2.fromOffset(600, 500),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = false },
    SideBarWidth = 220,
    ScrollBarEnabled = true,
})

-- 编辑主窗口打开按钮
Window:EditOpenButton({
    Title = "打开辅助脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    Draggable = true,
})

-- 定义所有Section和Tab（功能分区）
local Tabs = {}
do
    -- 主分区：对应原脚本的各个功能模块
    Tabs.RaidSection = Window:Section({ Title = "副本突袭", Icon = "skull", Opened = true })
    Tabs.HomeSection = Window:Section({ Title = "家园农场", Icon = "home", Opened = true })
    Tabs.VisualSection = Window:Section({ Title = "视觉辅助", Icon = "eye", Opened = true })
    Tabs.FruitSection = Window:Section({ Title = "果实相关", Icon = "apple", Opened = true })
    Tabs.PlayerSection = Window:Section({ Title = "玩家功能", Icon = "user", Opened = true })
    Tabs.StatusSection = Window:Section({ Title = "状态显示", Icon = "bar-chart", Opened = true })
    Tabs.PVPSection = Window:Section({ Title = "玩家对战", Icon = "crosshair", Opened = true })

    -- 各分区主Tab
    Tabs.RaidMain = Tabs.RaidSection:Tab({ Title = "副本功能", Icon = "skull" })
    Tabs.HomeMain = Tabs.HomeSection:Tab({ Title = "农场功能", Icon = "home" })
    Tabs.VisualMain = Tabs.VisualSection:Tab({ Title = "视觉功能", Icon = "eye" })
    Tabs.FruitMain = Tabs.FruitSection:Tab({ Title = "果实功能", Icon = "apple" })
    Tabs.PlayerMain = Tabs.PlayerSection:Tab({ Title = "玩家功能", Icon = "user" })
    Tabs.StatusMain = Tabs.StatusSection:Tab({ Title = "状态功能", Icon = "bar-chart" })
    Tabs.PVPMain = Tabs.PVPSection:Tab({ Title = "对战功能", Icon = "crosshair" })
end

-- 默认选中第一个Tab
Window:SelectTab(1)

-- =====================================================
-- 副本突袭分区
-- =====================================================
Tabs.RaidMain:Toggle({
    Title = "自动突袭",
    Value = false,
    Callback = function(state) print("自动突袭: " .. tostring(state)) end
})
Tabs.RaidMain:Toggle({
    Title = "自动地下城",
    Value = false,
    Callback = function(state) print("自动地下城: " .. tostring(state)) end
})
Tabs.RaidMain:Toggle({
    Title = "自动选择增益 (测试版)",
    Value = false,
    Callback = function(state) print("自动选择增益: " .. tostring(state)) end
})

-- =====================================================
-- 家园农场分区
-- =====================================================
Tabs.HomeMain:Toggle({
    Title = "自动刷等级",
    Value = false,
    Callback = function(state) print("自动刷等级: " .. tostring(state)) end
})
Tabs.HomeMain:Toggle({
    Title = "自动刷骨头",
    Value = false,
    Callback = function(state) print("自动刷骨头: " .. tostring(state)) end
})
Tabs.HomeMain:Toggle({
    Title = "竞技场刷怪",
    Value = false,
    Callback = function(state) print("竞技场刷怪: " .. tostring(state)) end
})
Tabs.HomeMain:Toggle({
    Title = "竞技场距离限制",
    Value = false,
    Callback = function(state) print("竞技场距离限制: " .. tostring(state)) end
})

-- =====================================================
-- 视觉辅助分区
-- =====================================================
Tabs.VisualMain:Toggle({
    Title = "玩家透视",
    Value = false,
    Callback = function(state) print("玩家透视: " .. tostring(state)) end
})
Tabs.VisualMain:Toggle({
    Title = "敌人透视",
    Value = false,
    Callback = function(state) print("敌人透视: " .. tostring(state)) end
})
Tabs.VisualMain:Toggle({
    Title = "全局照明",
    Value = false,
    Callback = function(state) print("全局照明: " .. tostring(state)) end
})

-- =====================================================
-- 果实相关分区
-- =====================================================
Tabs.FruitMain:Toggle({
    Title = "果实透视",
    Value = false,
    Callback = function(state) print("果实透视: " .. tostring(state)) end
})
Tabs.FruitMain:Toggle({
    Title = "自动收集果实",
    Value = false,
    Callback = function(state) print("自动收集果实: " .. tostring(state)) end
})

-- =====================================================
-- 玩家功能分区
-- =====================================================
Tabs.PlayerMain:Toggle({
    Title = "移速提升",
    Value = false,
    Callback = function(state) print("移速提升: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "穿墙模式",
    Value = false,
    Callback = function(state) print("穿墙模式: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "电脑端传送",
    Value = false,
    Callback = function(state) print("电脑端传送: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "移动端传送",
    Value = false,
    Callback = function(state) print("移动端传送: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(state) print("无限跳跃: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "自动武装色",
    Value = false,
    Callback = function(state) print("自动武装色: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "自动见闻色",
    Value = false,
    Callback = function(state) print("自动见闻色: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "自动释放技能",
    Value = false,
    Callback = function(state) print("自动释放技能: " .. tostring(state)) end
})
Tabs.PlayerMain:Toggle({
    Title = "自动觉醒",
    Value = false,
    Callback = function(state) print("自动觉醒: " .. tostring(state)) end
})

-- =====================================================
-- 状态显示分区
-- =====================================================
Tabs.StatusMain:Paragraph({
    Title = "月相状态",
    Desc = "当前游戏内月相状态展示",
    Icon = "moon"
})
Tabs.StatusMain:Paragraph({
    Title = "玩家计数",
    Desc = "当前服务器玩家数量展示",
    Icon = "users"
})

-- =====================================================
-- 玩家对战分区
-- =====================================================
Tabs.PVPMain:Toggle({
    Title = "跟随玩家",
    Value = false,
    Callback = function(state) print("跟随玩家: " .. tostring(state)) end
})
Tabs.PVPMain:Toggle({
    Title = "电脑端自瞄",
    Value = false,
    Callback = function(state) print("电脑端自瞄: " .. tostring(state)) end
})
Tabs.PVPMain:Toggle({
    Title = "移动端自瞄",
    Value = false,
    Callback = function(state) print("移动端自瞄: " .. tostring(state)) end
})
Tabs.PVPMain:Toggle({
    Title = "快速攻击敌人",
    Value = false,
    Callback = function(state) print("快速攻击敌人: " .. tostring(state)) end
})
Tabs.PVPMain:Toggle({
    Title = "快速攻击玩家",
    Value = false,
    Callback = function(state) print("快速攻击玩家: " .. tostring(state)) end
})
Tabs.PVPMain:Toggle({
    Title = "自动逃脱",
    Value = false,
    Callback = function(state) print("自动逃脱: " .. tostring(state)) end
})
Tabs.PVPMain:Button({
    Title = "恢复原始高度",
    Callback = function() print("已恢复玩家原始高度") end
})

-- =====================================================
-- 窗口回调与初始化提示
-- =====================================================
Window:OnClose(function()
    print("游戏辅助脚本已关闭")
end)

task.wait(0.2)
WindUI:Notify({
    Title = "初始化成功",
    Content = "脚本加载完成 ✅",
    Duration = 3,
    Icon = "check"
})
print("脚本加载完成 ✅")
