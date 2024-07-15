
local lights = require("/shared/lights")
local strobActivated = false

local function showMessage(message, color)
    term.setTextColor(color)
    print(message)
    term.setTextColor(colors.white)
end

local function showBootMessage(message)
    showMessage("BeamOS " .. message, colors.yellow)
end

local modem = peripheral.find("modem")
if not modem then
    showMessage("Modem not found.", colors.red)
    return
end
local monitor = peripheral.find("monitor")
if not monitor then
    showMessage("Monitor not found.", colors.red)
    return
end
modem.open(31002)

local screenWidth, screenHeight = monitor.getSize()

local function sendMessage(channel, action)
    modem.transmit(31002, 31002, {channel = channel, action = action})
end

local function enableLight(light)
    light.enabled = true
    sendMessage(light.id, "on")
end

local function disableLight(light)
    light.enabled = false
    sendMessage(light.id, "off")
end

local function toggleLight(light)
    if light.enabled then
        disableLight(light)
    else
        enableLight(light)
    end
end

local function turnOnAllLights()
    for _, light in pairs(lights) do
        enableLight(light)
    end
end

local function turnOnAllDiagonnalLights()
    for _, light in pairs(lights) do
        if light.type == "diagonnal" then
            enableLight(light)
        end
    end
end

local function turnOffAllDiagonnalLights()
    for _, light in pairs(lights) do
        if light.type == "diagonnal" then
            disableLight(light)
        end
    end
end

local function turnOnAllColumnLights()
    for _, light in pairs(lights) do
        if light.type == "column" then
            enableLight(light)
        end
    end
end

local function turnOffAllColumnLights()
    for _, light in pairs(lights) do
        if light.type == "column" then
            disableLight(light)
        end
    end
end

local function turnOffAllLights()
    for _, light in pairs(lights) do
        disableLight(light)
    end
end

local function getRandomLight(lights)
    return lights[math.random(1, #lights)]
end

local function strobEffect()
    while strobActivated do
        local randomLight = getRandomLight(lights)
        toggleLight(randomLight)
        sleep(0.003)
        toggleLight(randomLight)
    end
end

local function toggleStrob()
    strobActivated = true
    parallel.waitForAny(strobEffect, function()
        os.pullEvent("monitor_touch")
        strobActivated = false
    end)
    turnOffAllLights()
end

local effects = {
    {
        name = "Strob",
        active = false,
    },
    {
        name = "Turn on all",
        active = false,
    },
    {
        name = "Turn off all",
        active = false,
    },
    {
        name = "Toggle all diagonnal",
        active = false,
    },
    {
        name = "Toggle all column",
        active = false,
    },
}

local function drawUI()
    monitor.setTextColor(colors.white)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("BeamOS")
    monitor.setCursorPos(1, 2)
    monitor.write("Lights:")

    local columns = 4
    local lightsPerColumn = math.ceil(#lights / columns)
    local columnWidth = math.floor(screenWidth / columns)

    for col = 1, columns do
        for row = 1, lightsPerColumn do
            local lightIndex = (col - 1) * lightsPerColumn + row
            if lights[lightIndex] then
                local light = lights[lightIndex]
                local x = (col - 1) * columnWidth + 1
                local y = 2 + row
                if light.enabled then
                    monitor.setTextColor(colors.green)
                else
                    monitor.setTextColor(colors.red)
                end
                monitor.setCursorPos(x, y)
                monitor.write(light.id)
            end
        end
    end

    monitor.setTextColor(colors.white)
    monitor.setCursorPos(1, screenHeight - #effects - 1)
    monitor.write("Effects:")
    for i, effect in pairs(effects) do
        monitor.setCursorPos(1, screenHeight - #effects + i - 1)
        if effect.active then
            monitor.setTextColor(colors.green)
        else
            monitor.setTextColor(colors.red)
        end
        monitor.write(i .. ". " .. effect.name)
        monitor.setCursorPos(screenWidth - 1, screenHeight - #effects + i - 1)
    end
end

local function handleClick(x, y)
    local columns = 4
    local lightsPerColumn = math.ceil(#lights / columns)
    local columnWidth = math.floor(screenWidth / columns)
    local clickedColumn = math.ceil(x / columnWidth)
    local clickedRow = y - 2
    local lightIndex = (clickedColumn - 1) * lightsPerColumn + clickedRow
    if y > 2 and y < 2 + lightsPerColumn + 1 and lightIndex <= #lights then
        toggleLight(lights[lightIndex])
    elseif y > screenHeight - #effects - 1 and y < screenHeight then
        local effectIndex = y - (screenHeight - #effects) + 1
        local effect = effects[effectIndex]
        if effect.name == "Strob" then
            toggleStrob()
        elseif effect.name == "Turn on all" then
            turnOnAllLights()
        elseif effect.name == "Turn off all" then
            turnOffAllLights()
        elseif effect.name == "Toggle all diagonnal" then
            if effect.active then
                turnOffAllDiagonnalLights()
                effect.active = false
            else
                turnOnAllDiagonnalLights()
                effect.active = true
            end
        elseif effect.name == "Toggle all column" then
            if effect.active then
                turnOffAllColumnLights()
                effect.active = false
            else
                turnOnAllColumnLights()
                effect.active = true
            end
        end
    end
    drawUI()
end

drawUI()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    handleClick(x, y)
end
