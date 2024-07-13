local channels = {
    channel = "GLOBAL",
    enable = false,
    children = {
        {
            channel = "DL",
            enable = false,
            children = {
                { channel = "DL1", enable = false },
                { channel = "DL2", enable = false },
                { channel = "DL3", enable = false },
                { channel = "DL4", enable = false },
            },
        },
        {
            channel = "DR",
            enable = false,
            children = {
                { channel = "DR1", enable = false },
                { channel = "DR2", enable = false },
                { channel = "DR3", enable = false },
                { channel = "DR4", enable = false },
            },
        },
        {
            channel = "U",
            enable = false,
            children = {
                { channel = "U1", enable = false },
                { channel = "U2", enable = false },
                { channel = "U3", enable = false },
                { channel = "U4", enable = false },
                { channel = "U5", enable = false },
                { channel = "U6", enable = false },
            },
        },
    }
}

local fxChannels = {
    channel = "GLOBALFX",
    enable = false,
    children = {
        {
            channel = "SMOKE1",
            enable = false,
        }
    }
}


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
        name = "Smoke",
        active = false,
    },
}

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
modem.open(31001)

local screenWidth, screenHeight = monitor.getSize()

local function sendMessage(channel, action)
    modem.transmit(31001, 31001, {channel = channel, action = action})
end

local function enableChannel(channel)
    channel.enable = true
    sendMessage(channel.channel, "on")
    if channel.children then
        for _, child in pairs(channel.children) do
            enableChannel(child)
        end
    end
end

local function disableChannel(channel)
    channel.enable = false
    sendMessage(channel.channel, "off")
    if channel.children then
        for _, child in pairs(channel.children) do
            disableChannel(child)
        end
    end
end

local function turnOnAllChannels()
    enableChannel(channels)
end

local function turnOffAllChannels()
    disableChannel(channels)
end

local function toggleChannel(channel)
    if channel.enable then
        disableChannel(channel)
    else
        enableChannel(channel)
    end
end

local function getRandomChannel(channels)
    local randomChannel = channels[math.random(#channels)]
    if randomChannel.children then
        return getRandomChannel(randomChannel.children)
    end
    return randomChannel
end

local function strobEffect()
    local randomChannel = getRandomChannel(channels.children)
    toggleChannel(randomChannel)
    sleep(0.01)
    toggleChannel(randomChannel)
    randomChannel = getRandomChannel(channels.children)
    toggleChannel(randomChannel)
    sleep(0.01)
    toggleChannel(randomChannel)
end

local function toggleStrob()
    if effects[1].active then
        effects[1].active = false
        strobActivated = false
    else
        effects[1].active = true
        strobActivated = true
        parallel.waitForAny(
            function()
                while strobActivated do
                    strobEffect()
                    sleep(0.1)  -- Added to prevent busy-waiting
                end
            end,
            function()
                while strobActivated do
                    sleep(0.1)
                end
            end
        )
    end
end


local function toggleSmoke()
    if fxChannels.enable then
        fxChannels.enable = false
        effects[4].active = false
        sendMessage(fxChannels.channel, "off")
    else
        fxChannels.enable = true
        effects[4].active = true
        sendMessage(fxChannels.channel, "on")
    end    
end

local function drawUI()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("BeamOS")
    monitor.setCursorPos(1, 2)
    monitor.write("Channels:")
    for i, channel in pairs(channels.children) do
        monitor.setCursorPos(1, 2 + i)
        monitor.write(i .. ". " .. channel.channel)
        monitor.setCursorPos(screenWidth - 1, 2 + i)
        monitor.write(channel.enable and "X" or " ")
    end
    monitor.setCursorPos(1, screenHeight - #effects - 1)
    monitor.write("Effects:")
    for i, effect in pairs(effects) do
        monitor.setCursorPos(1, screenHeight - #effects + i - 1)
        monitor.write(i .. ". " .. effect.name)
        monitor.setCursorPos(screenWidth - 1, screenHeight - #effects + i - 1)
        monitor.write(effect.active and "X" or " ")
    end
end

local function handleClick(x, y)
    if y > 2 and y < 2 + #channels.children + 1 then
        print("Toggling channel " .. y - 2)
        toggleChannel(channels.children[y - 2])
    elseif y > screenHeight - #effects - 1 and y < screenHeight then
        local effect = effects[y - (screenHeight - #effects) + 1]
        if effect.name == "Strob" then
            toggleStrob()
        elseif effect.name == "Turn on all" then
            turnOnAllChannels()
        elseif effect.name == "Turn off all" then
            turnOffAllChannels()
        elseif effect.name == "Smoke" then
            toggleSmoke()
        end
    end
    drawUI()
end

drawUI()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    handleClick(x, y)
end
