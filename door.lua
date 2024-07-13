local dfpwm = require("cc.audio.dfpwm")

local playerDetector = peripheral.find("playerDetector")
local sequencedGearshit = peripheral.wrap("right")
local speaker = peripheral.find("speaker")
if not playerDetector then
    print("No player detector found")
    return
end
if not sequencedGearshit then
    print("No sequenced gearshift found")
    return
end
if not speaker then
    print("No speaker found")
    return
end

local decoder = dfpwm.make_decoder()

local range = 8
local lastState = "closed"
local isMoving = false
local audio = "doofenshmirtz"

local function playSound()
    for chunk in io.lines(audio .. ".dfpwm", 16 * 1024) do
        local buffer = decoder(chunk)
    
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

local function openDoor()
    sequencedGearshit.move(3,-1)
    playSound()
end

local function closeDoor()
    sequencedGearshit.move(3,1)
end

while true do
    isMoving = sequencedGearshit.isRunning()

    local playersInRange = playerDetector.getPlayersInRange(range)

    if #playersInRange > 0 then
        if not isMoving then
            if lastState == "closed" then
                openDoor()
                lastState = "open"
            end
        end
    else
        if not isMoving then
            if lastState == "open" then
                closeDoor()
                lastState = "closed"
            end
        end
    end
end
