-- Core/Animation.lua
-- Centralised tween helper.
-- Usage:
--   local Anim = require(path.Core.Animation)
--   Anim:Play(frame, Anim.Fast, { BackgroundColor3 = color })

local TweenService = game:GetService("TweenService")

local Anim = {}

local function info(t, style, dir)
    return TweenInfo.new(
        t,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
end

-- Preset TweenInfos
Anim.Fast   = info(0.12)
Anim.Normal = info(0.22)
Anim.Slow   = info(0.35)
Anim.Spring = info(0.3,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)
Anim.Ease   = info(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- Play a tween; returns it so callers can store/cancel it.
function Anim:Play(instance, tweenInfo, goals)
    local t = TweenService:Create(instance, tweenInfo, goals)
    t:Play()
    return t
end

-- Cancel the stored tween (if still playing) then start a new one.
-- Useful for hover states where rapid enter/leave would stack tweens.
function Anim:Replace(stored, instance, tweenInfo, goals)
    if stored and stored.PlaybackState == Enum.PlaybackState.Playing then
        stored:Cancel()
    end
    return self:Play(instance, tweenInfo, goals)
end

-- Wire hover color transitions onto a GuiButton.
-- Optionally pass a Cleanup registry so connections are tracked.
function Anim:Hover(btn, normalColor, hoverColor, registry)
    local function addConn(conn)
        if registry then registry:Add(conn) end
        return conn
    end
    local c1 = addConn(btn.MouseEnter:Connect(function()
        Anim:Play(btn, Anim.Fast, { BackgroundColor3 = hoverColor })
    end))
    local c2 = addConn(btn.MouseLeave:Connect(function()
        Anim:Play(btn, Anim.Fast, { BackgroundColor3 = normalColor })
    end))
    return { c1, c2 }
end

return Anim
