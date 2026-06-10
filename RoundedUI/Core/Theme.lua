-- Core/Theme.lua
-- Central color palette and font constants.
-- Edit values here to restyle the entire library.

local Theme = {
    bg          = Color3.fromRGB(20,  20,  24),
    panel       = Color3.fromRGB(28,  28,  34),
    panel2      = Color3.fromRGB(32,  32,  40),
    stroke      = Color3.fromRGB(60,  60,  70),
    accent      = Color3.fromRGB(140, 90,  255),
    accentDim   = Color3.fromRGB(110, 70,  210),
    text        = Color3.fromRGB(230, 230, 240),
    textDim     = Color3.fromRGB(180, 180, 190),
    good        = Color3.fromRGB(90,  200, 120),
    warn        = Color3.fromRGB(230, 80,  80),
    control     = Color3.fromRGB(45,  45,  55),
    hover       = Color3.fromRGB(55,  55,  70),
    -- Notification type accent colors
    notifSuccess = Color3.fromRGB(70,  180, 100),
    notifError   = Color3.fromRGB(210, 60,  60),
    notifWarning = Color3.fromRGB(220, 150, 40),
    notifInfo    = Color3.fromRGB(80,  140, 220),
}

local FONT   = Enum.Font.Gotham
local FONT_B = Enum.Font.GothamBold

return { Theme = Theme, FONT = FONT, FONT_B = FONT_B }
