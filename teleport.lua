-- Fungsi untuk teleport pemain ke lokasi yang ditentukan
local function teleportToLocation()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = CFrame.new(539, 23, -1965)
        player.Character.HumanoidRootPart.CFrame = targetPosition
    else
        print("Karakter atau HumanoidRootPart tidak ditemukan.")
    end
end

-- Panggil fungsi teleport ketika script dijalankan
teleportToLocation()
