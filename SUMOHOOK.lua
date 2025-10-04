-- PRE-EXEC CHECK
--if getreg().SH_UNLOAD then
--	getreg().SH_UNLOAD()
--end

-- BASE DEFINITIONS
local DataModel = game
local Workspace = workspace
local Enviroment = getfenv()
local StartTime = os.clock()

-- BASE METHODS
local IsA = DataModel.IsA
local JobID = DataModel.JobId
local Destroy = DataModel.Destroy
local PlaceID = DataModel.PlaceId
local GetService = DataModel.GetService
local GetChildren = DataModel.GetChildren
local FindFirstChild = DataModel.FindFirstChild
local SetPrimaryCFrame = Workspace.SetPrimaryPartCFrame
local IsDescendantOf = DataModel.IsDescendantOf
local WaitForChild = DataModel.WaitForChild
-- local HttpGet = DataModel.HttpGet
local Clone = DataModel.Clone

-- EVENT METHODS -> Need Better Way to Do This
local Connect = DataModel.Loaded.Connect
local TempCon = Connect(DataModel.Loaded, function() end)
local Disconnect = TempCon.Disconnect; Disconnect(TempCon)

-- SERVICES
local Players = GetService(DataModel, "Players")
local CoreGui = GetService(DataModel, "CoreGui")
local Lighting = GetService(DataModel, "Lighting")
local StarterGui =  GetService(DataModel, "StarterGui")
local RunService = GetService(DataModel, "RunService")
local GuiService = GetService(DataModel, "GuiService")
local InputService = GetService(DataModel, "UserInputService")
local HttpService = GetService(DataModel, "HttpService")
local TweenService = GetService(DataModel, "TweenService")
local TeleportService = GetService(DataModel, "TeleportService")
local ReplicatedStorage = GetService(DataModel, "ReplicatedStorage")
local ReplicatedFirst = GetService(DataModel, "ReplicatedFirst")

-- FUNCTION CACHE -> Im aware its ugly but 30% faster is worth it fuck GETGLOBAL
local IsReadOnly, SetReadOnly = isreadonly, setreadonly -- rename this
local Rawget, Rawset = rawget, rawset
local Insert, Remove = table.insert, table.remove
local Concat, Sort = table.concat, table.sort
local Unpack, Find = table.unpack, table.find
local Select, GetGC = select, getgc

local Char, Byte = string.char, string.byte
local Upper, Lower = string.upper, string.lower
local Match, Format = string.match, string.format
local GSub, Sub = string.gsub, string.sub
local ToString = tostring

local NewCSK, NewCS = ColorSequenceKeypoint.new, ColorSequence.new
local RGB, HSV, HEX = Color3.fromRGB, Color3.fromHSV, Color3.fromHEX
local V2, V3 = Vector2.new, Vector3.new
local U1, U2 = UDim.new, UDim2.new
local C3, CF = Color3.new, CFrame.new

local Print, Error, Warn = print, error, warn
-- local Getupvl, Getcnst = getupvalue, getconstant
-- local Setupvl, Setcnst = setupvalue, setconstant
local GetType, GetInfo = typeof, getinfo

-- local CheckCaller  = checkcaller
local LoadString, HookFunc = loadstring, hookfunction
-- local IsLuaFunc, WrapLClosure = islclosure, newcclosure
local PCall, XPCall = pcall, xpcall

-- local ReadFile, WriteFile = readfile, writefile
-- local IsFile, IsFolder = isfile, isfolder
-- local ListFiles = listfiles

local Floor, Ceil = math.floor, math.ceil
local Sign, Abs = math.sign, math.abs
local Clamp, Random = math.clamp, math.random

local NewTweenInfo, CreateTween = TweenInfo.new, TweenService.Create
-- local NewDrawing, NewInstance = Drawing.new, Instance.new
-- local Fonts = Drawing.Fonts

local RequireModule = require
-- local GetModules = getloadedmodules

local Resume, Yield, Wrap = coroutine.resume, coroutine.yield, coroutine.wrap
local Wait, Spawn, Delay = task.wait, task.spawn, task.delay

local Getmetatable, Setmetatable = getmetatable, setmetatable
-- local HookMethod, NewProxy = hookmetamethod, newproxy

local Clock, Date = os.clock, os.date
local Tick = tick

-- SUB VARs
local Dot = V3().Dot

-- COMMON VARS (Used alot)
local GetPlayers = Players.GetPlayers
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer.GetMouse(LocalPlayer)
local Inset = GuiService.GetGuiInset(GuiService).Y

-- FUNCTIONS
local function Create(Class, Properties)
	local Instance = Instance.new(Class)

	if GetType(Properties) == "table" then
		for Property, Value in next, Properties do
			Instance[Property] = Value
		end
	end

	return Instance
end

local function Draw(Class, Properties)
	local Drawing = NewDrawing(Class)

	if GetType(Properties) == "table" then
		for Property, Value in next, Properties do
			Drawing[Property] = Value
		end
	end

	return Drawing
end

local Interface, Flags = {Tabs = {}, Logs = {}, Cons = {}, Open = false}, {} do -- Replaced cus mt version was not much faster
	Interface.Flags = Flags

	local MouseInputTypes = {
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.MouseButton2,
		Enum.UserInputType.MouseButton3
	}

	local InputBlacklist = {
		Enum.KeyCode.Unknown,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D,
		Enum.KeyCode.Slash,
		Enum.KeyCode.Tab,
		Enum.KeyCode.Escape
	}

	local InputAliases = Setmetatable({
		One = "1",
		Two = "2",
		Three = "3",
		Four = "4",
		Five = "5",
		Six = "6",
		Seven = "7",
		Eight = "8",
		Nine = "9",
		Zero = "0",
		Delete = "Del",
		Insert = "Ins",
		LeftAlt = "LAlt",
		LeftShift = "LShift",
		LeftControl = "LCtrl",
		RightAlt = "RAlt",
		RightShift = "RShift",
		RightControl = "RCtrl",
		MouseButton1 = "M1",
		MouseButton2 = "M2",
		MouseButton3 = "M3"
	}, {
		__index = function(Self, Key)
			return Rawget(Self, Key) or Key
		end
	})

	function Interface:Clamp(X, Min, Max) -- Clamp both ways
		return Max >= Min and Clamp(X, Min, Max) or Clamp(X, Max, Min)
	end

	function Interface:Round(X, Bracket) -- From jan lib
		local Res = Floor(X / Bracket + (Sign(X) * 0.5)) * Bracket

		return Res >= 0 and Res or Res + Bracket
	end

	function Interface:Connect(Signal, Callback) -- Connections that need to be disconnected when unloaded
		local Connection = Connect(Signal, Callback)

		Insert(self.Cons, Connection)
		return Connection
	end

	function Interface:Tween(Instance, Properties, Duration, ...)
		local Tween = CreateTween(TweenService, Instance, NewTweenInfo(Duration, ...), Properties)

		Tween:Play()

		return Tween
	end

	function Interface:AddTab(Name)
		local Tab = {Sections = {}, Selected = #self.Tabs == 0, Index = #self.Tabs, Name = Name}

		function Tab:AddSection(Name, Side)
			local Section = {Elements = {}, Name = Name, Side = Side or GSub(Lower(Side), "^%l", Upper)}

			function Section:AddButton(Name, Options)
				local Button = {}

				Button.Name = GetType(Name) == "string" and Name or "Button"
				Button.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil

				function Button:Init()
					self.Base = Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, 26),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					local IndecatorA = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, 0, 0, 18),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					local IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = IndecatorA
					})

					local NameLabel = Create("TextLabel", {
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(0, 200, 0, 18),
						TextSize = 13,
						Text = self.Name,
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = IndecatorB
					})

					Interface:Connect(self.Base.InputBegan, function(Input, GameProcessedEvent)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							self:Click()
						end
					end)
				end

				function Button:Click()
					if self.Callback then
						self.Callback()
					end
				end

				Insert(self.Elements, Button)
				return Button
			end

			function Section:AddToggle(Name, Options)
				local Toggle = {}

				Toggle.Name = GetType(Name) == "string" and Name or "Toggle"
				Toggle.Flag = GetType(Options.Flag) == "string" and Options.Flag or nil
				Toggle.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil
				Toggle.Unload = GetType(Options.Unload) == "function" and Options.Unload or nil
				Toggle.State = GetType(Options.State) == "boolean" and Options.State or false

				if Toggle.Flag then
					Interface.Flags[Toggle.Flag] = Toggle.State
				end

				function Toggle:AddSlider(SubOptions)
					SubOptions = GetType(SubOptions) == "table" and SubOptions or {}
					SubOptions.Sub = true

					return Section:AddSlider(nil, SubOptions)
				end

				function Toggle:AddList(SubOptions)
					SubOptions = GetType(SubOptions) == "table" and SubOptions or {}
					SubOptions.Sub = true

					return Section:AddList(nil, SubOptions)
				end

				function Toggle:AddBind(SubOptions)
					SubOptions = GetType(SubOptions) == "table" and SubOptions or {}
					SubOptions.Sub = true

					function SubOptions:GetBase()
						return Toggle.SubSector
					end

					self.SmallInteract = true
					return Section:AddBind(nil, SubOptions)
				end

				function Toggle:AddColor(SubOptions)
					SubOptions = GetType(SubOptions) == "table" and SubOptions or {}
					SubOptions.Sub = true

					function SubOptions:GetBase()
						return Toggle.SubSector
					end

					self.SmallInteract = true
					return Section:AddColor(nil, SubOptions)
				end

				function Toggle:Init()
					self.Base = Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, 22),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					local IndecatorA = Create("Frame", {
						AnchorPoint = V2(0, 0.5),
						Size = U2(0, 14, 0, 14),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					self.IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = self.State and RGB(120, 70, 255) or RGB(30, 30, 30),
						Parent = IndecatorA
					})

					self.Shimmer = Create("ImageLabel", {
						Visible = self.State,
						ImageTransparency = 0.6,
						Image = "rbxassetid://2454009026",
						Size = U2(1, 0, 1, 0),
						ImageColor3 = RGB(0, 0, 0),
						BackgroundTransparency = 1,
						Parent = self.IndecatorB
					})

					local NameLabel = Create("TextLabel", {
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(0, 0.5),
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = U2(0, 200, 0, 18),
						TextSize = 13,
						Text = self.Name,
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0, 18, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = self.Base
					})

					self.SubSector = Create("Frame", {
						AnchorPoint = V2(1, 0.5),
						Size = U2(1, 0, 1, 0),
						Position = U2(1, 0, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = self.Base
					})

					local SubLayout = Create("UIListLayout", {
						Padding = U1(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Parent = self.SubSector
					})

					Interface:Connect((self.SmallInteract and IndecatorA or self.Base).InputBegan, function(Input, GameProcessedEvent)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							self:SetState()
						end
					end)
				end

				function Toggle:SetState(State)
					if State ~= nil then
						self.State = State
					else
						self.State = not self.State
					end

					if self.Flag then
						Interface.Flags[self.Flag] = self.State
					end

					if self.Callback then
						self.Callback(self.State)
					end

					if self.IndecatorB then
						Interface:Tween(self.IndecatorB, {BackgroundColor3 = self.State and RGB(120, 70, 255) or RGB(30, 30, 30)}, 0.04)

						self.Shimmer.Visible = self.State
					end
				end

				Insert(self.Elements, Toggle)
				return Toggle
			end

			function Section:AddSlider(Name, Options)
				local Slider = {}

				Slider.Name = GetType(Name) == "string" and Name or "Slider"
				Slider.Flag = GetType(Options.Flag) == "string" and Options.Flag or nil
				Slider.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil
				Slider.Float = GetType(Options.Float) == "number" and Options.Float or 1
				Slider.Min = GetType(Options.Min) == "number" and Options.Min or 0
				Slider.Max = GetType(Options.Max) == "number" and Options.Max or 100
				Slider.Value = GetType(Options.Value) == "number" and Options.Value or Slider.Min
				Slider.Suffix = GetType(Options.Suffix) == "string" and Options.Suffix or ""
				Slider.Sub = GetType(Options.Sub) == "boolean" and Options.Sub or false

				if Slider.Flag then
					Interface.Flags[Slider.Flag] = Slider.Value
				end

				function Slider:Init()
					self.Base = Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, self.Sub and 22 or 36),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					local IndecatorA = Create("Frame", {
						AnchorPoint = V2(0.5, 0),
						Size = U2(1, 0, 0, 14),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0.5, 0, 0, self.Sub and 4 or 18),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					local IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = IndecatorA
					})

					self.Fill = Create("Frame", {
						Size = U2((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(120, 70, 255),
						Parent = IndecatorB
					})

					local Shimmer = Create("ImageLabel", {
						ImageTransparency = 0.6,
						Image = "rbxassetid://2454009026",
						Size = U2(1, 0, 1, 0),
						ImageColor3 = RGB(0, 0, 0),
						BackgroundTransparency = 1,
						Parent = self.Fill
					})

					self.ValueLabel = Create("TextLabel", {
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						Size = U2(1, 0, 1, 0),
						TextSize = 13,
						Text = self.Value .. self.Suffix,
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						BackgroundTransparency = 1,
						Parent = IndecatorB
					})

					if not self.Sub then
						local NameLabel = Create("TextLabel", {
							LineHeight = 1.1,
							BackgroundColor3 = RGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = U2(0, 200, 0, 18),
							TextSize = 13,
							Text = self.Name,
							TextColor3 = RGB(255, 255, 255),
							Font = Enum.Font.Gotham,
							BackgroundTransparency = 1,
							Parent = self.Base
						})
					end

					local function Update()
						local Mx = IndecatorA.AbsoluteSize.X
						local Px = Clamp(Mouse.X - IndecatorA.AbsolutePosition.X, 0, Mx) / Mx
						local Vl = self.Min + ((self.Max - self.Min) * Px)

						self:SetValue(Vl)
					end

					Interface:Connect(IndecatorA.InputBegan, function(InputA, GameProcessedEvent)
						if InputA.UserInputType == Enum.UserInputType.MouseButton1 then
							local MouseMovement
							local InputEnded

							Update()

							MouseMovement = Interface:Connect(InputService.InputChanged, function(InputB, GameProcessedEventB)
								if InputB.UserInputType == Enum.UserInputType.MouseMovement then
									Update()
								end
							end)

							InputEnded = Interface:Connect(InputService.InputEnded, function(InputB, GameProcessedEventB)
								if InputB.UserInputType == Enum.UserInputType.MouseButton1 then
									Disconnect(MouseMovement)
									Disconnect(InputEnded)
								end
							end)
						end
					end)
				end

				function Slider:SetValue(Value)
					self.Value = Value or self.Min
					self.Value = Interface:Round(self.Value, self.Float)

					if self.Flag then
						Interface.Flags[self.Flag] = self.Value
					end

					if self.Callback then
						self.Callback(self.Value)
					end

					if self.Fill then
						self.ValueLabel.Text = self.Value .. self.Suffix

						Interface:Tween(self.Fill, {Size = U2((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)}, 0.04)
					end
				end

				Insert(self.Elements, Slider)
				return Slider
			end

			function Section:AddBind(Name, Options)
				local Bind = {}

				Bind.Name = GetType(Name) == "string" and Name or "Bind"
				Bind.Flag = GetType(Options.Flag) == "string" and Options.Flag or nil
				Bind.Hold = GetType(Options.Hold) == "boolean" and Options.Hold or false
				Bind.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil
				Bind.Key = GetType(Options.Key) == "string" and Options.Key or GetType(Options.Key) == "EnumItem" and Options.Key.Name or nil
				Bind.Sub = GetType(Options.Sub) == "boolean" and Options.Sub or false
				Bind.GetBase = GetType(Options.GetBase) == "function" and Options.GetBase or function()end

				function Bind:Init()
					self.Base = self:GetBase() or Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, 22),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					self.IndecatorA = Create("Frame", {
						AnchorPoint = self.Sub and V2(0, 0) or V2(1, 0.5),
						Size = U2(0, 24, 0, 14),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(1, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					local IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = self.IndecatorA
					})

					self.KeyLabel = Create("TextLabel", {
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						Size = U2(1, 0, 1, 0),
						TextSize = 13,
						Text = Format("[%s]", InputAliases[self.Key or "-"]),
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						BackgroundTransparency = 1,
						Parent = IndecatorB
					})

					if not self.Sub then
						local NameLabel = Create("TextLabel", {
							LineHeight = 1.1,
							BackgroundColor3 = RGB(255, 255, 255),
							AnchorPoint = V2(0, 0.5),
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = U2(0, 200, 0, 18),
							TextSize = 13,
							Text = self.Name,
							TextColor3 = RGB(255, 255, 255),
							Font = Enum.Font.Gotham,
							Position = U2(0, 0, 0.5, 0),
							BackgroundTransparency = 1,
							Parent = self.Base
						})
					end

					self.IndecatorA.Size = U2(0, self.KeyLabel.TextBounds.X + 2, 0, 14)

					Interface:Connect((self.Sub and self.IndecatorA or self.Base).InputEnded, function(Input, GameProcessedEvent)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Binding then
							self.Binding = true
							self.KeyLabel.Text = "..."
							self.IndecatorA.Size = U2(0, self.KeyLabel.TextBounds.X + 2, 0, 14)
						end
					end)

					Interface:Connect(InputService.InputBegan, function(Input, GameProcessedEvent)
						-- might be better so you could use larrow / rarrow
						-- if InputService:GetFocusedTextBox() then return end
						-- if GameProcessedEvent then return end 

						if self.Binding and (not Find(InputBlacklist, Input.KeyCode) or Find(MouseInputTypes, Input.UserInputType)) then
							self:SetKey(Find(MouseInputTypes, Input.UserInputType) and Input.UserInputType or Input.KeyCode)
						else
							if Input.KeyCode.Name == self.Key or Input.UserInputType.Name == self.Key and not self.Binding then
								if self.Callback then
									self.Callback()
								end
							end
						end
					end)
				end

				function Bind:SetKey(Key)
					self.Binding = false
					self.Key = GetType(Key) == "string" and Key or GetType(Key) == "EnumItem" and Key.Name or nil

					if self.KeyLabel then
						self.KeyLabel.Text = Format("[%s]", InputAliases[self.Key or "-"])
						self.IndecatorA.Size = U2(0, self.KeyLabel.TextBounds.X + 2, 0, 14)
					end
				end

				Insert(self.Elements, Bind)
				return Bind
			end

			function Section:AddList(Name, Options)
				local List = {}

				List.Name = GetType(Name) == "string" and Name or "List"
				List.Flag = GetType(Options.Flag) == "string" and Options.Flag or nil
				List.Search = GetType(Options.Search) == "boolean" and Options.Search or false
				List.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil
				List.Value = (GetType(Options.Value) == "string" or GetType(Options.Value) == "table") and Options.Value or nil
				List.Values = GetType(Options.Values) == "table" and Options.Values or {}
				List.Multi = GetType(Options.Multi) == "boolean" and Options.Multi or (GetType(List.Value) == "table")
				List.Max = GetType(Options.Max) == "number" and Options.Max or 4 -- Max options show at once
				List.Sub = GetType(Options.Sub) == "boolean" and Options.Sub or false

				if List.Flag then
					Interface.Flags[List.Flag] = List.Value
				end

				function List:Init()
					self.Base = Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, self.Sub and 26 or 40),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					local IndecatorA = Create("Frame", {
						AnchorPoint = V2(0.5, 1),
						Size = U2(1, 0, 0, 18),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0.5, 0, 1, -4),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					local IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = IndecatorA
					})

					self.ValueLabel = Create("TextLabel", {
						LineHeight = 1.1,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundColor3 = RGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = U2(1, -28, 1, 0),
						TextSize = 13,
						Text = "A, B",
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0, 4, 0, 0),
						BackgroundTransparency = 1,
						Parent = IndecatorB
					})

					local IndecatorC = Create("TextLabel", {
						LineHeight = 1,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(1, 0),
						TextXAlignment = Enum.TextXAlignment.Right,
						Size = U2(0, 28, 1, 0),
						TextSize = 15,
						Text = "+",
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(1, -4, 0, 0),
						BackgroundTransparency = 1,
						Parent = IndecatorB
					})

					if not self.Sub then
						local NameLabel = Create("TextLabel", {
							LineHeight = 1.1,
							BackgroundColor3 = RGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = U2(0, 200, 0, 18),
							TextSize = 13,
							Text = self.Name,
							TextColor3 = RGB(255, 255, 255),
							Font = Enum.Font.Gotham,
							BackgroundTransparency = 1,
							Parent = self.Base                        
						})
					end

					self.Container = Create("Frame", {
						ZIndex = 2,
						Visible = false,
						Size = U2(0, 215, 0, 72), --> 8 + (Clamp(#self.Values, 0, self.Max) * 16))
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 0, 0, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Interface.Base
					})

					local Inline = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = self.Container
					})

					self.Content = Create("ScrollingFrame", {
						ZIndex = 2,
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						ScrollBarImageColor3 = RGB(0, 0, 0),
						ScrollBarThickness = 0,
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = Inline
					})

					local Layout = Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = U1(0, 1),
						Parent = self.Content
					})

					for _, Value in next, self.Values do
						self:AddValue(Value)
					end

					self:Update()

					Interface:Connect(Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						self.Content.CanvasSize = U2(0, 0, 0, Layout.AbsoluteContentSize.Y)
					end)

					Interface:Connect(IndecatorA.InputBegan, function(Input, GameProcessedEvent)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							if Interface.External then
								Interface.External.Visible = false
							end

							if Interface.External == self.Container then
								Interface.External = nil
							else
								Interface.External = self.Container; 
								Interface.External.Position = U2(0, IndecatorA.AbsolutePosition.X, 0, IndecatorA.AbsolutePosition.Y + IndecatorA.Size.Y.Offset + 1)
								Interface.External.Visible = true
							end
						end
					end)
				end

				function List:Update() --> Whems luau going to add private and public classes ??? :troll:
					self.ValueLabel.Text = self.Multi and Concat(self.Value, ", ") or self.Value
					self.Container.Size = U2(0, 215, 0, 8 + (Clamp(#self.Values, 0, self.Max) * 16))

					for _, Item in next, GetChildren(self.Content) do
						if IsA(Item, "Frame") then
							local ValueLabel = GetChildren(Item)[1]
							local Value = ValueLabel.Text

							-- ValueLabel.TextTransparency = (self.Multi and Find(self.Value, Value) or self.Value == Value) and 0 or 0.5
							Interface:Tween(ValueLabel, {TextTransparency = (self.Multi and Find(self.Value, Value) or self.Value == Value) and 0 or 0.5}, 0.1)
						end
					end
				end

				function List:AddValue(Value)
					if not Find(self.Values, Value) then
						Insert(self.Values, 1, Value) -- Add to front
					end

					local Item = Create("Frame", { 
						ZIndex = 2,
						Size = U2(1, 0, 0, 16),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(25, 25, 25),
						Parent = self.Content
					})

					local ValueLabel = Create("TextButton", { -- TextLabel -> again cus click through :(
						ZIndex = 2,
						LineHeight = 1.1,
						TextTruncate = Enum.TextTruncate.AtEnd,
						BackgroundColor3 = RGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						Size = U2(1, -28, 1, 0),
						TextTransparency = 0.5,
						TextSize = 13,
						Text = Value,
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0, 4, 0, 0),
						BackgroundTransparency = 1,
						Parent = Item
					})

					Interface:Connect(ValueLabel.MouseButton1Click, function()
						if self.Multi then
							local Index = Find(self.Value, Value)

							if Index then
								Remove(self.Value, Index)
							else
								Insert(self.Value, Value)
							end
						else
							self.Value = Value

							if self.Flag then
								Interface.Flags[self.Flag] = self.Value
							end
						end

						if self.Callback then
							self.Callback(self.Value)
						end

						self:Update()
					end)
				end

				function List:RemValue(Value)
					if self.Multi then
						local Index = Find(self.Value, Value)

						if Index then
							Remove(self.Value, Index)
						end
					elseif self.Value == Value then
						self.Value = nil

						if self.Flag then
							Interface.Flags[self.Flag] = self.Value
						end
					end

					for _, Item in next, GetChildren(self.Content) do
						if IsA(Item, "Frame") then
							local ValueLabel = GetChildren(Item)[1]
							local _Value = ValueLabel.Text

							if _Value == Value then
								Destroy(Item)
							end
						end
					end

					self:Update() -- ???
				end

				function List:SetValue(Value)
					if self.Multi then --> Value should be a table
						for _, _Value in next, Value do
							if not Find(self.Values, _Value) then
								self:AddValue(_Value) --> Make sure the value has been added
							end
						end
					else
						if not Find(self.Values, Value) then
							self:AddValue(_Value) --> Make sure the value has been added
						end
					end

					self.Value = Value
					self:Update() --> Update visually
				end

				Insert(self.Elements, List)
				return List
			end

			function Section:AddColor(Name, Options)
				local Color = {}

				Color.Name = GetType(Name) == "string" and Name or "Color"
				Color.Flag = GetType(Options.Flag) == "string" and Options.Flag or nil
				Color.Callback = GetType(Options.Callback) == "function" and Options.Callback or nil
				Color.Color = GetType(Options.Color) == "Color3" and Options.Color or RGB(255, 255, 255)
				Color.Alpha = GetType(Options.Alpha) == "number" and Options.Alpha or nil
				Color.Sub = GetType(Options.Sub) == "boolean" and Options.Sub or false
				Color.GetBase = GetType(Options.GetBase) == "function" and Options.GetBase or function()end

				Color.Hue, Color.Sat, Color.Val = Color.Color:ToHSV()

				if Color.Flag then
					Interface.Flags[Color.Flag] = Color.Color
				end

				function Color:Init()
					self.Base = self:GetBase() or Create("Frame", {
						LayoutOrder = #Section.Elements,
						Size = U2(1, -10, 0, 22),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Section.Content
					})

					self.IndecatorA = Create("Frame", {
						AnchorPoint = self.Sub and V2(0, 0) or V2(1, 0.5),
						Size = U2(0, 24, 0, 14),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(1, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = self.Base
					})

					self.IndecatorB = Create("Frame", {
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = self.Color,
						Parent = self.IndecatorA
					})

					local Shimmer = Create("ImageLabel", {
						ImageTransparency = 0.6,
						Image = "rbxassetid://2454009026",
						Size = U2(1, 0, 1, 0),
						ImageColor3 = RGB(0, 0, 0),
						BackgroundTransparency = 1,
						Parent = self.IndecatorB
					})

					if not self.Sub then
						local NameLabel = Create("TextLabel", {
							LineHeight = 1.1,
							BackgroundColor3 = RGB(255, 255, 255),
							TextXAlignment = Enum.TextXAlignment.Left,
							Size = U2(0, 200, 0, 18),
							TextSize = 13,
							Text = self.Name,
							TextColor3 = RGB(255, 255, 255),
							Font = Enum.Font.Gotham,
							BackgroundTransparency = 1,
							Parent = self.Base                        
						})
					end

					self.Container = Create("Frame", {
						ZIndex = 2,
						Visible = false,
						Size = U2(0, 210, 0, self.Alpha == nil and 213 or 235),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 0, 0, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Interface.Base
					})

					local Inline = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(25, 25, 25),
						Parent = self.Container
					})

					local Accent = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0),
						ZIndex = 2,
						Size = U2(1, -2, 0, 1),
						Position = U2(0.5, 0, 0, 1),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(120, 70, 255),
						Parent = Inline
					})

					local SVBox = Create("Frame", {
						ZIndex = 2,
						Size = U2(1, -28, 0, 180),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 3, 0, 6),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Inline
					})

					self.SatVal = Create("ImageButton", { -- ImageLabel
						ZIndex = 2,
						AutoButtonColor = false,
						Position = U2(0.5, 0, 0.5, 0),
						AnchorPoint = V2(0.5, 0.5),
						Image = "rbxassetid://4155801252",
						BorderSizePixel = 0,
						Size = U2(1, -2, 1, -2),
						BackgroundColor3 = RGB(255, 0, 4),
						Parent = SVBox
					})

					self.SVPickerA = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(0, 6, 0, 6),
						Position = U2(self.Sat, 0, 1 - self.Val, 0),
						BackgroundColor3 = RGB(0, 0, 0),
						Parent = SVBox
					})

					local SVPickerAR = Create("UICorner", {
						Parent = self.SVPickerA
					})

					local SVPickerB = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = self.SVPickerA
					})

					local SVPickerBR = Create("UICorner", {
						Parent = SVPickerB
					})

					local Inputs = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 1),
						Size = U2(1, -10, 0, 20),
						Position = U2(0.5, 0, 1, -1),
						BackgroundTransparency = 1,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Inline
					})

					Create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = U1(0, 4),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Parent = Inputs
					})

					local HexInput = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(0.5, 0, 0, 18),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Inputs
					})

					local HexBlock = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = HexInput
					})

					self.HexBox = Create("TextBox", {
						ZIndex = 2,
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, 0, 1, 0),
						TextSize = 13,
						Text = self.Color:ToHex(),
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = HexBlock
					})

					local RgbInput = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(0.5, 0, 0, 18),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0, 0, 0.5, 0),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Inputs
					})

					local RgbBlock = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(30, 30, 30),
						Parent = RgbInput
					})

					self.RgbBox = Create("TextBox", {
						ZIndex = 2,
						LineHeight = 1.1,
						BackgroundColor3 = RGB(255, 255, 255),
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, 0, 1, 0),
						TextSize = 13,
						Text = ToString(self.Color),
						TextColor3 = RGB(255, 255, 255),
						Font = Enum.Font.Gotham,
						Position = U2(0.5, 0, 0.5, 0),
						BackgroundTransparency = 1,
						Parent = RgbBlock
					})

					local Hue = Create("TextButton", {
						ZIndex = 2,
						AutoButtonColor = false,
						Text = "",
						AnchorPoint = V2(1, 0),
						Size = U2(0, 18, 0, 180),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(1, -3, 0, 6),
						BackgroundColor3 = RGB(50, 50, 50),
						Parent = Inline
					})

					self.HueHold = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0.5),
						Size = U2(1, -2, 1, -2),
						Position = U2(0.5, 0, 0.5, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = Hue
					})

					local HueColor = Create("UIGradient", {
						Color = NewCS({
							NewCSK(0.00, RGB(255, 0, 0)),
							NewCSK(0.17, RGB(255, 0, 255)), 
							NewCSK(0.33, RGB(0, 0, 255)), 
							NewCSK(0.50, RGB(0, 255, 255)), 
							NewCSK(0.67, RGB(0, 255, 0)), 
							NewCSK(0.83, RGB(255, 255, 0)), 
							NewCSK(1.00, RGB(255, 0, 0))
						}),
						Rotation = 90,
						Parent = self.HueHold
					})

					self.HuePicker = Create("Frame", {
						ZIndex = 2,
						AnchorPoint = V2(0.5, 0),
						Size = U2(1, 0, 0, 1),
						BorderColor3 = RGB(0, 0, 0),
						Position = U2(0.5, 0, 1 - (self.Hue == 0 and 1 or self.Hue), 0),
						BorderSizePixel = 0,
						BackgroundColor3 = RGB(255, 255, 255),
						Parent = self.HueHold
					})

					local Alpha
					local AlphaGrid
					local AlphaColor

					if self.Alpha ~= nil then
						Alpha = Create("Frame", {
							ZIndex = 2,
							AnchorPoint = V2(0.5, 0),
							Size = U2(1, -6, 0, 18),
							BorderColor3 = RGB(0, 0, 0),
							Position = U2(0.5, 0, 0, 190),
							BackgroundColor3 = RGB(50, 50, 50),
							Parent = Inline
						})

						AlphaGrid = Create("ImageLabel", {
							ZIndex = 2,
							Position = U2(0.5, 0, 0.5, 0),
							AnchorPoint = V2(0.5, 0.5),
							Image = "rbxassetid://3887014957",
							TileSize = U2(0, 11, 0, 12),
							BorderSizePixel = 0,
							Size = U2(1, -2, 1, -2),
							ScaleType = Enum.ScaleType.Tile,
							BorderColor3 = RGB(0, 0, 0),
							BackgroundColor3 = RGB(255, 255, 255),
							Parent = Alpha
						})

						AlphaColor = Create("ImageLabel", {
							ZIndex = 2,
							Image = "rbxassetid://3887017050",
							BorderSizePixel = 0,
							Size = U2(1, 0, 1, 0),
							ImageColor3 = RGB(255, 0, 4),
							BackgroundTransparency = 1,
							BackgroundColor3 = RGB(255, 255, 255),
							Parent = AlphaGrid
						})

						self.AlphaPicker = Create("Frame", {
							ZIndex = 2,
							AnchorPoint = V2(0, 0.5),
							Size = U2(0, 1, 1, 0),
							BorderColor3 = RGB(0, 0, 0),
							Position = U2(0, 0, 0.5, 0),
							BorderSizePixel = 0,
							BackgroundColor3 = RGB(255, 255, 255),
							Parent = AlphaGrid
						})
					end

					local function updateSV(Input)
						X = (self.SatVal.AbsolutePosition.X + self.SatVal.AbsoluteSize.X) - self.SatVal.AbsolutePosition.X
						Y = (self.SatVal.AbsolutePosition.Y + self.SatVal.AbsoluteSize.Y) - self.SatVal.AbsolutePosition.Y
						X = Clamp((Input.Position.X - self.SatVal.AbsolutePosition.X) / X, 0.005, 1)
						Y = Clamp((Input.Position.Y - self.SatVal.AbsolutePosition.Y) / Y, 0, 0.995)

						self:SetColor(HSV(self.Hue, X, 1 - Y))
					end

					local function updateH(Input)
						Y = (self.HueHold.AbsolutePosition.Y + self.HueHold.AbsoluteSize.Y) - self.HueHold.AbsolutePosition.Y
						Y = Clamp((Input.Position.Y - self.HueHold.AbsolutePosition.Y) / Y, 0, 0.995)

						self:SetColor(HSV(1 - Y, self.Sat, self.Val))
					end

					Interface:Connect(self.SatVal.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							local Changed
							local Ended

							Changed = Interface:Connect(InputService.InputChanged, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseMovement then
									updateSV(Input)
								end
							end)

							Ended = Interface:Connect(self.SatVal.InputEnded, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseButton1 then
									Disconnect(Changed)
									Disconnect(Ended)
								end
							end)

							updateSV(Input)
						end
					end)

					Interface:Connect(self.HueHold.InputBegan, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							local Changed
							local Ended

							Changed = Interface:Connect(InputService.InputChanged, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseMovement then
									updateH(Input)
								end
							end)

							Ended = Interface:Connect(self.HueHold.InputEnded, function(Input)
								if Input.UserInputType == Enum.UserInputType.MouseButton1 then
									Disconnect(Changed)
									Disconnect(Ended)
								end
							end)

							updateH(Input)
						end
					end)

					Interface:Connect(self.IndecatorA.InputBegan, function(Input, GameProcessedEvent)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 then
							if Interface.External then
								Interface.External.Visible = false
							end

							if Interface.External == self.Container then
								Interface.External = nil
							else
								Interface.External = self.Container; 
								Interface.External.Position = U2(0, self.IndecatorA.AbsolutePosition.X + self.IndecatorA.Size.X.Offset - self.Container.Size.X.Offset, 0, self.IndecatorA.AbsolutePosition.Y + self.IndecatorA.Size.Y.Offset + 1)
								Interface.External.Visible = true
							end
						end
					end)
				end

				function Color:SetColor(Color, Alpha)
					self.Alpha = Alpha
					self.Color = Color

					self.Hue, self.Sat, self.Val = self.Color:ToHSV()
					self.Hue = self.Hue == 0 and 1 or self.Hue

					if self.Flag then
						Interface.Flags[self.Flag] = self.Color
					end

					if self.Callback then
						self.Callback(self.Color, self.Alpha)
					end

					if self.Container then
						local R, G, B = Floor(self.Color.R * 255), Floor(self.Color.G * 255), Floor(self.Color.B * 255)

						self.SatVal.BackgroundColor3 = HSV(self.Hue, 1, 1)
						self.IndecatorB.BackgroundColor3 = Color

						self.HuePicker.Position = U2(0.5, 0, 1 - self.Hue, 0)
						self.SVPickerA.Position = U2(self.Sat, 0, 1 - self.Val, 0)

						self.HexBox.Text = Upper(Format("#%02x%02x%02x", R, G, B))
						self.RgbBox.Text = Concat({R, G, B}, ",")
					end
				end

				Insert(self.Elements, Color)
				return Color
			end

			function Section:Init()
				local Base = Create("Frame", {
					Size = U2(1, 0, 0, 400),
					BorderSizePixel = 0,
					BackgroundColor3 = RGB(50, 50, 50),
					Parent = Tab[self.Side]
				})

				self.Content = Create("Frame", {
					AnchorPoint = V2(0.5, 0.5),
					Size = U2(1, -4, 1, -4),
					BorderColor3 = RGB(0, 0, 0),
					Position = U2(0.5, 0, 0.5, 0),
					BackgroundColor3 = RGB(25, 25, 25),
					Parent = Base
				})

				local Layout = Create("UIListLayout", {
					Padding = U1(0, -2),
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Parent = self.Content
				})

				local Header = Create("Frame", {
					LayoutOrder = 0,
					Size = U2(1, 0, 0, 23),
					BackgroundTransparency = 1,
					BackgroundColor3 = RGB(255, 255, 255),
					Parent = self.Content
				})

				local Accent = Create("Frame", {
					AnchorPoint = V2(0.5, 0),
					ZIndex = 2,
					Size = U2(1, -2, 0, 1),
					Position = U2(0.5, 0, 0, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = RGB(120, 70, 255),
					Parent = Header
				})

				local NameLabel = Create("TextLabel", {
					LineHeight = 1.1,
					BackgroundColor3 = RGB(255, 255, 255),
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = U2(0, 200, 0, 18),
					TextSize = 13,
					Text = self.Name,
					TextColor3 = RGB(255, 255, 255),
					Font = Enum.Font.Gotham,
					Position = U2(0, 5, 0, 4),
					BackgroundTransparency = 1,
					Parent = Header
				})

				Interface:Connect(Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					Base.Size = U2(1, 0, 0, Layout.AbsoluteContentSize.Y + 5)
				end)

				for _, Element in next, self.Elements do
					Element:Init()
				end
			end

			Insert(self.Sections, Section)
			return Section
		end

		function Tab:Init()
			self.Content = Create("Frame", {
				Visible = self.Selected,
				Size = U2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BackgroundColor3 = RGB(255, 255, 255),
				Parent = Interface.Content
			})

			self.Left = Create("ScrollingFrame", {
				BorderSizePixel = 0,
				BackgroundColor3 = RGB(255, 255, 255),
				AnchorPoint = V2(0, 0.5),
				Size = U2(0.5, -6, 1, -8),
				ScrollBarImageColor3 = RGB(0, 0, 0),
				ScrollBarThickness = 0,
				Position = U2(0, 4, 0.5, 0),
				BackgroundTransparency = 1,
				Parent = self.Content
			})

			local LeftLayout = Create("UIListLayout", {
				Padding = U1(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Parent = self.Left
			})

			self.Right = Create("ScrollingFrame", {
				BorderSizePixel = 0,
				BackgroundColor3 = RGB(255, 255, 255),
				AnchorPoint = V2(1, 0.5),
				Size = U2(0.5, -6, 1, -8),
				ScrollBarImageColor3 = RGB(0, 0, 0),
				ScrollBarThickness = 0,
				Position = U2(1, -4, 0.5, 0),
				BackgroundTransparency = 1,
				Parent = self.Content
			})

			local RightLayout = Create("UIListLayout", {
				Padding = U1(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Parent = self.Right
			})

			self.Button = Create("Frame", {
				LayoutOrder = #Interface.Tabs,
				BorderColor3 = RGB(0, 0, 0),
				BackgroundColor3 = RGB(50, 50, 50),
				Parent = Interface.Navbar
			})

			self.NavContent = Create("Frame", {
				AnchorPoint = V2(0.5, 0.5),
				Size = U2(1, -2, 1, -2),
				Position = U2(0.5, 0, 0.5, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = self.Selected and RGB(30, 30, 30) or RGB(25, 25, 25),
				Parent = self.Button
			})

			self.BlockA = Create("Frame", {
				AnchorPoint = V2(0.5, 1),
				Size = U2(1, 4, 0, 1),
				Position = U2(0.5, self.Index == 0 and 1 or 0, 1, 2),
				BorderSizePixel = 0,
				BackgroundColor3 = RGB(50, 50, 50),
				Parent = self.NavContent
			})

			self.BlockB = Create("Frame", {
				AnchorPoint = V2(0.5, 1),
				Size = U2(1, 0, 0, self.Selected and 2 or 1),
				Position = U2(0.5, 0, 1, self.Selected and 2 or 1),
				BorderSizePixel = 0,
				BackgroundColor3 = self.Selected and RGB(30, 30, 30) or RGB(25, 25, 25),
				Parent = self.NavContent
			})

			self.Accent = Create("Frame", {
				Visible = false, -- self.Selected,
				AnchorPoint = V2(0.5, 0),
				Size = U2(1, -2, 0, 1),
				Position = U2(0.5, 0, 0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = RGB(120, 70, 255),
				Parent = self.NavContent
			})

			self.NameLabel = Create("TextLabel", {
				TextStrokeTransparency = 0,
				BackgroundColor3 = RGB(255, 255, 255),
				AnchorPoint = V2(0.5, 0.5),
				Size = U2(1, 0, 1, 0),
				TextTransparency = self.Selected and 0 or 0.2,
				TextSize = 13,
				Text = self.Name,
				TextColor3 = RGB(255, 255, 255), -- self.Selected and RGB(120, 70, 255) or RGB(255, 255, 255),
				Font = Enum.Font.Gotham,
				Position = U2(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Parent = self.NavContent
			})

			self.Button.Size = U2(0, self.NameLabel.TextBounds.X + 12, 1, -1)

			Interface:Connect(self.Button.InputBegan, function(Input, GameProcessedEvent)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					self:Select()
				end
			end)

			Interface:Connect(self.Left:GetPropertyChangedSignal("CanvasPosition"), function()
				if Interface.External then
					Interface.External.Visible = false
					Interface.External = nil
				end
			end)

			Interface:Connect(LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				self.Left.CanvasSize = U2(0, 0, 0, LeftLayout.AbsoluteContentSize.Y)
			end)

			Interface:Connect(self.Right:GetPropertyChangedSignal("CanvasPosition"), function()
				if Interface.External then
					Interface.External.Visible = false
					Interface.External = nil
				end
			end)

			Interface:Connect(RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				self.Right.CanvasSize = U2(0, 0, 0, RightLayout.AbsoluteContentSize.Y)
			end)

			for _, Section in next, self.Sections do
				Section:Init()
			end
		end

		function Tab:Select()
			if Interface.External then
				Interface.External.Visible = false
				Interface.External = nil
			end

			for _, Tab in next, Interface.Tabs do
				self.Selected = Tab == self

				-- Tab.Accent.Visible = self.Selected
				Tab.Content.Visible = self.Selected
				Interface:Tween(Tab.NameLabel, {TextTransparency = self.Selected and 0 or 0.2}, 0.1)
				-- Tab.NameLabel.TextTransparency = self.Selected and 0 or 0.2
				-- Tab.NameLabel.TextColor3 = self.Selected and RGB(120, 70, 255) or RGB(255, 255, 255)
				Tab.NavContent.BackgroundColor3 = self.Selected and RGB(30, 30, 30) or RGB(25, 25, 25)
				Tab.BlockB.BackgroundColor3 = self.Selected and RGB(30, 30, 30) or RGB(25, 25, 25)
				Tab.BlockB.Position = U2(0.5, 0, 1, self.Selected and 2 or 1)
				Tab.BlockB.Size = U2(1, 0, 0, self.Selected and 2 or 1)
			end
		end

		Insert(self.Tabs, Tab)
		return Tab
	end

	function Interface:Init(Name, Folder, Extra)
		self.Name = Name
		self.Folder = Folder

		self.Base = Create("ScreenGui", {
			Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
		})

		self.Scaler = Create("UIScale", {
			Scale = 1,
			Parent = self.Base
		})

		local Main = Create("Frame", {
			Size = U2(0, 500, 0, 600),
			BorderColor3 = RGB(0, 0, 0),
			Position = U2(0, Camera.ViewportSize.X / 2 - 250, 0, Camera.ViewportSize.Y / 2 - 300),
			BackgroundColor3 = RGB(120, 70, 255),
			Parent = self.Base
		})

		local InlineA = Create("Frame", {
			AnchorPoint = V2(0.5, 0.5),
			Size = U2(1, -4, 1, -4),
			BorderColor3 = RGB(0, 0, 0),
			Position = U2(0.5, 0, 0.5, 0),
			BackgroundColor3 = RGB(50, 50, 50),
			Parent = Main
		})

		local InlineB = Create("Frame", {
			AnchorPoint = V2(0.5, 0.5),
			Size = U2(1, -2, 1, -2),
			BorderColor3 = RGB(27, 42, 53),
			Position = U2(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = RGB(30, 30, 30),
			Parent = InlineA
		})

		local ContentA = Create("Frame", {
			AnchorPoint = V2(0.5, 1),
			Size = U2(1, -10, 1, -28),
			BorderColor3 = RGB(50, 50, 50),
			Position = U2(0.5, 0, 1, -5),
			BackgroundColor3 = RGB(0, 0, 0),
			Parent = InlineB
		})

		local ContentB = Create("Frame", {
			AnchorPoint = V2(0.5, 0.5),
			Size = U2(1, -2, 1, -2),
			Position = U2(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = RGB(25, 25, 25),
			Parent = ContentA
		})

		local ContentC = Create("Frame", {
			AnchorPoint = V2(0.5, 1),
			Size = U2(1, -10, 1, -34),
			BorderColor3 = RGB(0, 0, 0),
			Position = U2(0.5, 0, 1, -5),
			BackgroundColor3 = RGB(50, 50, 50),
			Parent = ContentB
		})

		local Topbar = Create("Frame", {
			Size = U2(1, 0, 0, 20),
			BackgroundTransparency = 1,
			BackgroundColor3 = RGB(255, 255, 255),
			Parent = InlineB
		})

		self.Content = Create("Frame", {
			AnchorPoint = V2(0.5, 0.5),
			Size = U2(1, -2, 1, -2),
			Position = U2(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = RGB(30, 30, 30),
			Parent = ContentC
		})

		self.Navbar = Create("Frame", {
			AnchorPoint = V2(0.5, 0),
			Size = U2(1, -10, 0, 25),
			Position = U2(0.5, 0, 0, 5),
			BackgroundTransparency = 1,
			BackgroundColor3 = RGB(255, 255, 255),
			Parent = ContentB
		})

		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = U1(0, 6),
			Parent = self.Navbar
		})

		Create("TextLabel", {
			RichText = true,
			TextStrokeTransparency = 0,
			BackgroundColor3 = RGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = U2(0, 200, 0, 16),
			TextSize = 13,
			Text = Name,
			TextColor3 = RGB(255, 255, 255),
			Font = Enum.Font.GothamMedium,
			Position = U2(0, 6, 0, 2),
			BackgroundTransparency = 1,
			Parent = Topbar
		})

		Create("TextLabel", {
			Visible = GetType(Extra) == "string",
			RichText = true,
			AnchorPoint = V2(1, 0),
			TextStrokeTransparency = 0,
			BackgroundColor3 = RGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = U2(0, 200, 0, 16),
			TextSize = 13,
			Text = Extra,
			TextColor3 = RGB(255, 255, 255),
			Font = Enum.Font.GothamMedium,
			Position = U2(1, -6, 0, 2),
			BackgroundTransparency = 1,
			Parent = Topbar
		})

		Interface:Connect(Topbar.InputBegan, function(InputA, GameProcessedEventA)
			if InputA.UserInputType == Enum.UserInputType.MouseButton1 then
				local MouseX = Mouse.X
				local MouseY = Mouse.Y

				local MouseMovement
				local InputEnded

				MouseMovement = Interface:Connect(InputService.InputChanged, function(InputB, GameProcessedEventB)
					if InputB.UserInputType == Enum.UserInputType.MouseMovement then
						local NewMouseX = Mouse.X
						local NewMouseY = Mouse.Y

						Main.Position = Main.Position + U2(0, NewMouseX - MouseX, 0, NewMouseY - MouseY)

						if Interface.External then
							Interface.External.Visible = false
							Interface.External = nil
						end

						MouseX = NewMouseX
						MouseY = NewMouseY
					end
				end)

				InputEnded = Interface:Connect(InputService.InputEnded, function(InputB, GameProcessedEventB)
					if InputB.UserInputType == Enum.UserInputType.MouseButton1 then
						Disconnect(MouseMovement)
						Disconnect(InputEnded)
					end
				end)
			end
		end)

		for _, Tab in next, self.Tabs do
			Tab:Init()
		end

		--getreg().SH_UNLOAD = function()
		--	Interface:Unload()

		--	getreg().SH_UNLOAD = nil
		--end
	end

	function Interface:Toggle()
		if self.Base then
			self.Base.Enabled = not self.Base.Enabled
		end
	end

	function Interface:Unload()
		if self.Base then
			Destroy(self.Base)
		end

		if self.LogUpdater then
			Disconnect(self.LogUpdater)

			for Index = 1, #self.Logs do
				local Log = self.Logs[Index]

				Spawn(Log.Destroy, Log)
			end
		end

		for TabIndex = 1, #self.Tabs do
			local Tab = self.Tabs[TabIndex]

			for SectionIndex = 1, #Tab.Sections do
				local Section = Tab.Sections[SectionIndex]

				for ElementIndex = 1, #Section.Elements do
					local Element = Section.Elements[ElementIndex]

					if Element.Unload then
						Element.Unload()
					end
				end
			end
		end

		for Index = 1, #self.Cons do
			local Connection = self.Cons[Index]

			if Connection then
				Disconnect(Connection)
			end
		end

		self.Unloaded = true
	end

	function Interface:Watermark(Format, Open)
		local Watermark = {}

		function Watermark:Update(Format)

		end

		function Watermark:Toggle()
			if self.Base then
				self.Base.Enabled = not self.Base.Enabled
			end
		end

		Watermark:Init()

		return Watermark
	end

	function Interface:Assert(Value, Message)
		if not Value then
			Interface:Log(Message, 5, RGB(255, 0, 0))

			return Yield()
		end
	end

	function Interface:AddSettings()
		local Settings = Interface:AddTab("Config")
		local SettingsM = Settings:AddSection("Menu", "Left")
		local SettingsC = Settings:AddSection("Config", "Right")

		SettingsM:AddBind("Panic", {
			Key = "End",
			Callback = function()
				Interface:Unload()
			end
		})

		SettingsM:AddBind("UI Toggle", {
			Key = "RightShift",
			Callback = function()
				Interface:Toggle()
			end
		})

		SettingsM:AddList("UI DPI", {
			Values = {"50%", "100%", "150%", "200%"},
			Value = "100%",
			Callback = function(Value)
				Interface.Scaler.Scale = ToNumber(({GSub(Value, "%%", "")})[1]) / 100 
			end
		})

		SettingsM:AddButton("Unload", {
			Callback = function()
				Interface:Unload()
			end
		})

		SettingsM:AddButton("Rejoin", {
			Callback = function()
				TeleportService:TeleportToPlaceInstance(PlaceID, JobID, LocalPlayer)
			end
		})

		return Settings, SettingsM, SettingsC
	end

	function Interface:Log(Txt, Life, Color) -- Log extention (pasted from integerisqt | https://v3rmillion.net/member.php?action=profile&uid=831907)
		Txt = GetType(Txt) == "table" and Concat(Txt, " ") or ToString(Txt)

		local Log = {
			Text = Txt,
			Time = Tick(),
			Life = Life or 5,
			Label = Draw("Text", {
				Center = false,
				Outline = false,
				Color = Color or RGB(255, 255, 255),
				Transparency = 1,
				Text = Txt,
				Size = 13,
				Font = 2,
				Visible = false
			}),
			Shadow = Draw("Text", {
				Center = false,
				Outline = false,
				Color = RGB(),
				Transparency = 200 / 255,
				Text = Txt,
				Size = 13,
				Font = 2,
				Visible = false
			})
		}

		function Log:Destroy()
			local Label = self.Label
			local LabelOrigin = Label.Position
			local LabelTrans = Label.Transparency

			local Shadow = self.Shadow
			local ShadowOrigin = Shadow.Position
			local ShadowTrans = Shadow.Transparency

			for Index = 0, 1, 1 / 60 do
				Label.Position = LabelOrigin:Lerp(V2(), Index)
				Label.Transparency = LabelTrans  * (1 - Index)

				Shadow.Position = ShadowOrigin:Lerp(V2(), Index)
				Shadow.Transparency = ShadowTrans  * (1 - Index)

				Wait()
			end

			Label:Remove()
			Shadow:Remove()
		end

		Insert(self.Logs, Log)
		return Log
	end

	Interface.LogUpdater = Connect(RunService.RenderStepped, function(Delta)
		local Logs = Interface.Logs
		local Maxd = false
		local Count = #Logs

		for Index = 1, Count do
			local Time = Tick()
			local Log = Logs[Index]

			if Log then
				if Time - Log.Time > Log.Life then
					Spawn(Log.Destroy, Log)
					Remove(Logs, Index)
				elseif Count > 10 and not Maxd then
					local First = Remove(Logs, 1)
					Spawn(First.Destroy, First)
					Maxd = true
				else
					local Previous = Logs[Index - 1]
					local Position = Previous and V2(4, Previous.Label.Position.Y + Previous.Label.TextBounds.Y + 1) or V2(4, 4)

					Log.Label.Position = Position
					Log.Label.Visible =  true

					Log.Shadow.Position = Position  + V2(1, 1)
					Log.Shadow.Visible = true
				end
			end
		end
	end)
end

-- INITIATE
local Legit = Interface:AddTab("Legit")
local LegitA = Legit:AddSection("Aimbot", "Left")
local LegitRC = Legit:AddSection("Recoil Control", "Left")
local LegitBR = Legit:AddSection("Bullet Redirection", "Right")
local LegitTB = Legit:AddSection("Trigger Bot", "Right")

LegitA:AddToggle("Enabled", {
	Unload = function()
		if Client.ChamsHolder then
			Destroy(Client.ChamsHolder)
		end
	end,
}):AddBind({
	Key = "MouseButton1"
})

LegitA:AddSlider("Aimbot FOV", {
	Max = 200,
	Value = 80,
	Suffix = "°"
})

LegitA:AddSlider("Smoothing Factor", {
	Suffix = "%"
})

LegitA:AddSlider("Randomization", {
	Max = 20
})

--[[LegitA:AddSlider("Deadzone FOV", {
    Suffix = "/10°"
})]]

LegitA:AddList("Hitscan Priority", {
	Values = {"Head", "Torso"},
	Value = "Head"
})

LegitA:AddList("Hitscan Points", {
	Values = {"Head", "Torso"},
	Value = {"Head", "Torso"}
})

LegitRC:AddToggle("Weapon RCS", {

})

LegitRC:AddSlider("Recoil Control X", {
	Suffix = "%"
})

LegitRC:AddSlider("Recoil Control Y", {
	Suffix = "%"
})

LegitBR:AddToggle("Enabled", {
	Flag = "BulletRedirection"
})

LegitBR:AddSlider("Silent Aim FOV", {
	Flag = "BRFov",
	Max = 200,
	Value = 80,
	Suffix = "°"
})

LegitBR:AddSlider("Hit Chance", {
	Flag = "BRHitChance",
	Value = 100,
	Suffix = "%"
})

LegitBR:AddSlider("Accuracy", {
	Flag = "BRAccuracy",
	Value = 100,
	Suffix = "%"
})

LegitBR:AddToggle("Prediction", {
	Flag = "BRPrediction",
	State = true
})

LegitBR:AddList("Hitscan Priority", {
	Flag = "BRHitscanPriority",
	Values = {"Head", "Torso"},
	Value = "Head"
})

LegitBR:AddList("Hitscan Points", {
	Flag = "BRHitscanPoints",
	Values = {"Head", "Torso"},
	Value = {"Head", "Torso"}
})

LegitTB:AddToggle("Enabled", {

}):AddBind({

})

LegitTB:AddSlider("Reaction Time", {
	Max = 300,
	Value = 30,
	Suffix = "ms"
})

LegitTB:AddList("Method", {
	Values = {
		"Raycast", --> Ray.new
		"GetPlayerFromCharacter", --> GPFC
		"GetPartsObscuringTarget"  --> GPOT 
	},
	Value = "Raycast"
})

local Rage = Interface:AddTab("Rage")
local RageR = Rage:AddSection("Ragebot", "Left")
local RageAA = Rage:AddSection("Anti Aim", "Right")

RageR:AddToggle("Enabled", {

})

local Visuals = Interface:AddTab("Visuals")
--local VisualsEE = Visuals:AddSection("Enemy ESP", "Left") --> Need to add multi tabs for 
--local VisualsTE = Visuals:AddSection("Team ESP", "Left") --> Need to add multi tabs for 

for _, Team in next, {"Enemy", "Team"} do
	local ESPSection = Visuals:AddSection(Format("%s ESP", Team), "Left")

	ESPSection:AddToggle("Enabled", {
		Flag = Team .. "ESP"
	})

	ESPSection:AddToggle("Visible Chams", {
		Flag = Team .. "VisChams"
	}):AddColor({

	})

	ESPSection:AddToggle("Hidden Chams", {
		Flag = Team .. "HidChams"
	}):AddColor({

	})

	ESPSection:AddToggle("Names", {
		Flag = Team .. "Names"
	}):AddColor({
		Flag = Team .. "NamesColor"
	})

	ESPSection:AddToggle("Boxes", {
		Flag = Team .. "Boxes"
	}):AddColor({
		Flag = Team .. "BoxesColor"
	})

	ESPSection:AddToggle("Weapon", {
		Flag = Team .. "Weapon"
	}):AddColor({
		Flag = Team .. "WeaponColor"
	})

	ESPSection:AddToggle("Distance", {
		Flag = Team .. "Distance"
	}):AddColor({
		Flag = Team .. "DistanceColor"
	})

	ESPSection:AddToggle("Skeleton", {
		Flag = Team .. "Skeleton"
	}):AddColor({
		Flag = Team .. "SkeletonColor"
	})

	ESPSection:AddToggle("Fill Boxes", {
		Flag = Team .. "FillBoxes"
	}):AddColor({
		Flag = Team .. "FillBoxesColor"
	})

	ESPSection:AddToggle("Health", {
		Flag = Team .. "Health"
	}):AddColor({
		Flag = Team .. "HealthColor"
	})

	local HBToggle = ESPSection:AddToggle("Health Bar", {
		Flag = Team .. "HealthBar"
	}) do
		HBToggle:AddColor({
			Flag = Team .. "HealthBarColor1"
		})

		HBToggle:AddColor({
			Flag = Team .. "HealthBarColor2"
		})
	end

	local RDChams = ESPSection:AddToggle("Ragdoll Chams", {
		Flag = Team .. "RagdollChams"
	}) do
		RDChams:AddColor({
			Flag = Team .. "RagdollChamsColor"
		})

		RDChams:AddList({
			Values = {
				"Neon",
				"Plastic",
				"ForceFeild"
			},
			Value = "Plastic"
		})
	end

	ESPSection:AddList("Flags", {
		Values = {
			"Aiming",
			"Lethal",
			"Visible",
			"Wallbang",
			-- "Fake Equip", -- compare updater to server profile
			-- "Cheating", -- detect shit like velocity, bullet time, size etc
			--"Alt" -- account age check
		},
		Value = {

		},
		Flag = Team .. "Flags"
	})
end

local VisualsDE = Visuals:AddSection("Dropped ESP", "Left")
local VisualsES = Visuals:AddSection("ESP Settings", "Left")
local VisualsC = Visuals:AddSection("Camera", "Right")
local VisualsL = Visuals:AddSection("Local", "Right")
local VisualsW = Visuals:AddSection("World", "Right")
local VisualsM = Visuals:AddSection("Misc", "Right")

VisualsDE:AddToggle("Weapon Name", {

}):AddColor({

})

VisualsDE:AddToggle("Weapon Ammo", {

}):AddColor({

})

VisualsDE:AddToggle("Nade Warning", {

}):AddColor({

})

VisualsES:AddList("Font", {
	Values = {
		"UI",
		"System",
		"Plex",
		"Monospace"
	},
	Value = "UI"
})

VisualsES:AddSlider("Font Size", {
	Max = 20,
	Value = 13
})

VisualsES:AddList("Text Casing", {
	Values = {
		"Lower",
		"Upper",
		"Normal"
	},
	Value = "Upper"
})

VisualsES:AddSlider("Text Length", {
	Max = 20,
	Value = 5
})

VisualsC:AddToggle("Custom FOV", {
	Flag = "Custom FOV"
}):AddSlider({
	Min = 60,
	Max = 120,
	Value = 60,
	Suffix = "°"
})

VisualsC:AddToggle("No Camera Bob", {

})

VisualsC:AddToggle("No Scope Sway", {

})

VisualsC:AddToggle("Disable ADS FOV", {

})

VisualsC:AddToggle("No Scope Boarder", {

})

VisualsC:AddToggle("No Visual Suppresion", {

})

VisualsC:AddToggle("Reduce Camera Recoil", {

}):AddSlider({

})

local ACToggle = VisualsL:AddToggle("Arm Chams", {

}) do
	ACToggle:AddColor({

	})

	ACToggle:AddList({
		Values = {
			"Neon",
			"Plastic",
			"ForceFeild"
		},
		Value = "Plastic"
	})
end

local WCToggle = VisualsL:AddToggle("Weapon Chams", {

}) do
	WCToggle:AddColor({

	})

	WCToggle:AddList({
		Values = {
			"Neon",
			"Plastic",
			"ForceFeild"
		},
		Value = "Plastic"
	})
end

local TPToggle = VisualsL:AddToggle("Third Person", {
	Flag = "ThirdPerson"
}) do
	TPToggle:AddBind({

	})

	TPToggle:AddSlider({

	})
end

--[[VisualsL:AddToggle("Show Player Model", {

})]]

local PMCToggle = VisualsL:AddToggle("Player Model Chams", {

}) do
	PMCToggle:AddColor({

	})

	PMCToggle:AddList({
		Values = {
			"Neon",
			"Plastic",
			"ForceFeild"
		},
		Value = "Plastic"
	})
end

local BIToggle = VisualsL:AddToggle("Buttet Impacts", {
	Flag = "BulletImpacts"
}) do
	BIToggle:AddColor({
		Flag = "BulletImpactColor"
	})

	BIToggle:AddList({
		Flag = "BulletImpactType",
		Values = {
			"Neon",
			"Plastic",
			"ForceFeild",
			"Lightning",
			"Drawing"
		},
		Value = "Plastic"
	})
end

local BTToggle = VisualsL:AddToggle("Bullet Tracers", {
	Flag = "BulletTracers"
}) do
	BTToggle:AddColor({

	})

	BTToggle:AddList({
		Values = {
			"Neon",
			"Plastic",
			"ForceFeild",
			"Drawing"
		},
		Value = "Plastic"
	})
end

local AToggle = VisualsW:AddToggle("Ambience", {
    --[[Flag = "ChangeAmbience",
    Callback = function(State)
        Lighting.Ambient = State and RGB(255, 0, 0) or Client.Ambience
    end,
    Unload = function()
        Lighting.Ambient = Client.Ambience
    end]]
}) do
	AToggle:AddColor({

	})

	AToggle:AddColor({

	})
end

VisualsW:AddToggle("Force Time", {

}):AddSlider({

})

local SToggle = VisualsW:AddToggle("Custom Saturation", {

}) do
	SToggle:AddColor({

	})

	SToggle:AddSlider({

	})
end

local VGToggle = VisualsM:AddToggle("Velocity Graph", {

}) do
	VGToggle:AddSlider({
		Value = 50,
		Suffix = "%"
	})

	VGToggle:AddSlider({
		Value = 90,
		Suffix = "%"
	})
end

local NGToggle = VisualsM:AddToggle("Network Graph", {

}) do
	NGToggle:AddSlider({
		Value = 5,
		Suffix = "%"
	})

	NGToggle:AddSlider({
		Value = 60,
		Suffix = "%"
	})
end

Interface:AddSettings()

Interface:Init("Sumohook", "Sumohook\\", Date("%d %b %Y"))
-- Interface:Log(Format("Initialized in %.2f", Clock() - StartTime))