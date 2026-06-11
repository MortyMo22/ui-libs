local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MortyMo22/ui-libs/main/RoundedUI/init.lua?v=20260611"
))()

local function dumpTable(t)
    local out = {}
    for k, v in pairs(t or {}) do
        table.insert(out, tostring(k) .. "=" .. tostring(v))
    end
    return "{" .. table.concat(out, ", ") .. "}"
end

local app = UI.CreateWindow("LuckyWinner", "Showcase")
app:SetHeader("RoundedUI Demo", "User: 1761488099")

UI:Notify("RoundedUI loaded")
UI:Notify({
    Title = "Showcase",
    Content = "All controls are ready",
    Type = "Success",
    Duration = 4
})

local main = app:AddSection("Main")
local left, right = main:AddUnderSections("Actions", "Settings")

left:Label("Base Controls", {
    bold = true,
    topMargin = 10
})

left:Button("Simple Button", function()
    print("[Button] clicked")
    UI:Notify({
        Title = "Button",
        Content = "Button clicked",
        Type = "Info",
        Duration = 3
    })
end)

left:Separator()

local autoBuy = left:Toggle("Auto Buy", {
    Default = false,
    Callback = function(state)
        print("[Toggle] Auto Buy:", state)
    end
})

left:Button("Set Auto Buy ON", function()
    autoBuy.Set(true)
end)

left:ToggleWithBind("Auto Collect", {
    Default = false,
    Bind = Enum.KeyCode.F,
    Callback = function(state, key)
        print("[ToggleWithBind] Auto Collect:", state, "Bind:", key.Name)
    end,
    Trigger = function(state, key)
        UI:Notify({
            Title = "Bind Triggered",
            Content = "Auto Collect: " .. tostring(state) .. " / " .. key.Name,
            Type = "Info",
            Duration = 3
        })
    end
})

left:ToggleBind("Quick Mode", {
    Default = false,
    Bind = Enum.KeyCode.R,
    Callback = function(state)
        print("[ToggleBind] Quick Mode:", state)
    end
})

left:Slider("Speed", {
    min = 16,
    max = 100,
    default = 32,
    suffix = "%",
    showPercent = true,
    showReset = true
}, function(value)
    print("[Slider] Speed:", value)
end)

left:DropDown("Hitscan Priority", {
    "Head",
    "Torso",
    "Arms",
    "Legs"
}, "Head", function(choice)
    print("[DropDown] Priority:", choice)
end)

left:List("Body Parts", {
    "Head",
    "Torso",
    "Arms",
    "Legs"
}, function(selected)
    print("[List] Selected:", dumpTable(selected))
end)

right:Label("Input + Colors", {
    bold = true,
    topMargin = 10
})

right:TextBox("Type something...", function(text, enterPressed)
    print("[TextBox]", text, "Enter:", enterPressed)
end)

local search = right:SearchBox("Search player...", function(text)
    print("[SearchBox]", text)
end)

right:Button("Fill SearchBox", function()
    search:SetText("Morty")
end)

right:TextBind("UI Toggle Bind", Enum.KeyCode.RightShift, function()
    print("[TextBind] RightShift pressed")
    UI:Notify({
        Title = "Keybind",
        Content = "RightShift pressed",
        Type = "Warning",
        Duration = 3
    })
end)

right:ToggleColor("ESP Enabled", false, Color3.fromRGB(213, 31, 31), function(state, color)
    print("[ToggleColor] ESP:", state, color)
end)

right:ToggleDualColor(
    "Chams",
    false,
    Color3.fromRGB(213, 31, 31),
    Color3.fromRGB(50, 150, 255),
    function(state, c1, c2)
        print("[ToggleDualColor] Chams:", state, c1, c2)
    end
)

right:Separator()

right:Button("Notify Success", function()
    UI:Notify({
        Title = "Success",
        Content = "Everything works",
        Type = "Success",
        Duration = 4
    })
end)

right:Button("Notify Error", function()
    UI:Notify({
        Title = "Error",
        Content = "Example error notification",
        Type = "Error",
        Duration = 4
    })
end)

local layoutTab = app:AddSection("Layouts")
local layoutLeft, layoutRight = layoutTab:AddUnderSections("Cards", "Lists")

layoutLeft:Label("Card API", {
    bold = true,
    topMargin = 10
})

local card = layoutLeft:Card()
card:Label("Profile Card", {
    bold = true,
    size = 15
})
card:Label("Cards can contain labels, buttons and rows.")
card:Button("Card Button", function()
    print("[Card] button clicked")
end)

local row = card:Row({
    Height = 30,
    Spacing = 6,
    Align = "Left"
})
row:Label("Row:")
row:Button("A", function()
    print("[Card Row] A")
end, { width = 42 })
row:Button("B", function()
    print("[Card Row] B")
end, { width = 42 })

layoutLeft:Separator()

layoutLeft:Label("Container", {
    bold = true,
    topMargin = 10
})

local container = layoutLeft:Container({
    Height = 90,
    Scrollable = false
})

local customText = Instance.new("TextLabel")
customText.Size = UDim2.fromScale(1, 1)
customText.BackgroundTransparency = 1
customText.Text = "Custom Roblox Instance mounted inside Container"
customText.TextColor3 = Color3.fromRGB(230, 230, 240)
customText.TextWrapped = true
customText.Font = Enum.Font.Gotham
customText.TextSize = 14

container:Mount(customText)

layoutRight:Label("ScrollList", {
    bold = true,
    topMargin = 10
})

local scrollList = layoutRight:ScrollList("Scrollable Cards", {
    Height = 180,
    Padding = 6
})

for i = 1, 6 do
    local item = scrollList:Card()
    item:Label("Scroll Item #" .. i, {
        bold = true
    })
    item:Button("Select " .. i, function()
        print("[ScrollList] selected:", i)
    end)
end

layoutRight:Separator()

layoutRight:Label("Pagination", {
    bold = true,
    topMargin = 10
})

local currentPage = 1
local totalPages = 5

local pager = layoutRight:Pagination({
    Align = "Center"
})

local function updatePager()
    pager:SetPage(currentPage, totalPages)
    pager:SetHasPrev(currentPage > 1)
    pager:SetHasNext(currentPage < totalPages)
end

pager.OnPrev = function()
    currentPage -= 1
    updatePager()
    print("[Pagination] page:", currentPage)
end

pager.OnNext = function()
    currentPage += 1
    updatePager()
    print("[Pagination] page:", currentPage)
end

updatePager()

local virtualTab = app:AddSection("Virtual")
local vLeft, vRight = virtualTab:AddUnderSections("VirtualList", "Info")

vLeft:Label("VirtualList", {
    bold = true,
    topMargin = 10
})

local virtual = vLeft:VirtualList({
    Height = 260,
    ItemHeight = 62,
    Padding = 6
})

local items = {}
for i = 1, 100 do
    table.insert(items, {
        Name = "Player_" .. i,
        Level = math.random(1, 100)
    })
end

virtual:SetRenderer(function(data, index)
    local vCard = virtual:Card()
    vCard:Label(index .. ". " .. data.Name, {
        bold = true
    })
    vCard:Label("Level: " .. tostring(data.Level), {
        size = 12
    })
    return vCard:GetFrame()
end)

virtual:SetItems(items)

vRight:Label("Runtime Actions", {
    bold = true,
    topMargin = 10
})

vRight:Button("Update Item #1", function()
    virtual:UpdateItem(1, {
        Name = "Updated_Player",
        Level = 999
    })
    print("[VirtualList] item #1 updated")
end)

vRight:Button("Clear VirtualList", function()
    virtual:Clear()
    print("[VirtualList] cleared")
end)

vRight:Button("Reload VirtualList", function()
    virtual:SetItems(items)
    print("[VirtualList] reloaded")
end)

vRight:Label("Demo complete", {
    align = Enum.TextXAlignment.Center,
    bold = true,
    topMargin = 12
})
