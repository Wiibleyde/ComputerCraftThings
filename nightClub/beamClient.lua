local redstoneSideOutput = "top"
local channels = {1, "column", "left", "bottom"}

function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

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
modem.open(31002)

while true do
    local event, param1, param2, param3, param4, param5 = os.pullEvent()

    if event == "modem_message" then
        local channel, replyChannel, message, distance = param2, param3, param4, param5
        if tableContains(channels, message.channel) then
            if message.action == "on" then
                redstone.setOutput(redstoneSideOutput, true)
            elseif message.action == "off" then
                redstone.setOutput(redstoneSideOutput, false)
            end
        end
    end
end