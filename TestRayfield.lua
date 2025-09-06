local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/Rayfield.lua"))()
local Window = Rayfield:CreateWindow({Name="Test GUI"})
local Tab = Window:CreateTab("Tab 1")
Tab:CreateToggle({Name="Test Toggle", Callback=function(v) print(v) end})
