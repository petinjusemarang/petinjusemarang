repeat task.wait() until game:IsLoaded()

local player = game:GetService("Players").LocalPlayer
local DealerList = player.PlayerGui:WaitForChild("Dealership")
    :WaitForChild("Container")
    :WaitForChild("Dealership")
    :WaitForChild("Dealerlist")

local Remote = game:GetService("ReplicatedStorage")
    .NetworkContainer.RemoteFunctions.Dealership

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,300,0,350)
Main.Position = UDim2.new(0.5,-150,0.5,-175)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- TITLE
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "LIMITED CONTROL"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold

-- BUY ALL BUTTON
local BuyAll = Instance.new("TextButton", Main)
BuyAll.Size = UDim2.new(1,-10,0,30)
BuyAll.Position = UDim2.new(0,5,0,40)
BuyAll.Text = "BUY ALL LIMITED"
BuyAll.BackgroundColor3 = Color3.fromRGB(40,40,40)
BuyAll.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", BuyAll)

-- SCROLL
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1,-10,1,-80)
Scroll.Position = UDim2.new(0,5,0,75)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0,4)

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y+5)
end)

-- DATA
local limitedList = {}
local buttons = {}

-- BUY FUNCTION
local function buy(model, brand)
    pcall(function()
        Remote:InvokeServer("Buy", model, "White", brand)
        print("BUY:", model)
    end)
end

-- CREATE BUTTON
local function createButton(brand, model)
    local key = brand.."_"..model
    if buttons[key] then return end

    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1,0,0,30)
    Btn.Text = model.." ("..brand..")"
    Btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn)

    buttons[key] = Btn
    limitedList[key] = {model = model, brand = brand}

    Btn.MouseButton1Click:Connect(function()
        buy(model, brand)
    end)
end

-- REMOVE BUTTON
local function removeButton(key)
    if buttons[key] then
        buttons[key]:Destroy()
        buttons[key] = nil
        limitedList[key] = nil
    end
end

-- BUY ALL
BuyAll.MouseButton1Click:Connect(function()
    for _, data in pairs(limitedList) do
        buy(data.model, data.brand)
        task.wait(0.1)
    end
end)

-- SCAN LOOP
task.spawn(function()
    while true do
        for _, dealer in pairs(DealerList:GetChildren()) do
            for _, car in pairs(dealer:GetChildren()) do

                local limited = car:FindFirstChild("Frame")
                    and car.Frame:FindFirstChild("Type")
                    and car.Frame.Type:FindFirstChild("Limited")

                local key = dealer.Name.."_"..car.Name

                if limited and limited.Visible then
                    createButton(dealer.Name, car.Name)
                else
                    removeButton(key)
                end

            end
        end

        task.wait(0.5)
    end
end)
