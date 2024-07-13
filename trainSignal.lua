local redstoneSideInput = "left"
local redstoneSideOutput = "right"

-- Allumer redstone sortie : redstone.setOutput(redstoneSideOutput, true)
-- Eteindre redstone sortie : redstone.setOutput(redstoneSideOutput, false)
-- Lire redstone entrée : redstone.getInput(redstoneSideInput)

local state = 0 -- 0 OUVERT, 1 FERME, 2 FERME (TRAIN EN SORTIE)

while true do
    local input = redstone.getInput(redstoneSideInput)
    if input == true then
        if state == 0 then
            redstone.setOutput(redstoneSideOutput, true)
            state = 1
        elseif state == 2 then
            state = 3
        end
    else
        if state == 1 then
            state = 2
        elseif state == 3 then
            redstone.setOutput(redstoneSideOutput, false)
            state = 0
        end
    end
    sleep(0.1)
end