-- Super Mario Bros 2 Accessibility Script
-- Version 0.1
-- Author: Seve Savoie Teruel
-- Date: 2024-03-11
-- Description: This script is designed to make Super Mario Bros 3 more accessible to people with disabilities
-- Requires: Bizhawk Emulator
-- Usage: Load the rom and then load this script. A window will appear with options to enable or disable certain features.
--
-- Current Features:
--  - Infinite Lives
--  - Infinite Times
--  - Small Mario can't be hurt (Can still die in pits or lava)
--  - Auto Quicksave every half second when on ground and not moving, if the player falls into a pit, the game will reload the last safe platform
-- 







-- Helper Functions
function decToBin(dec)
    local bin = ""
    while dec > 0 do
        bin = tostring(dec % 2) .. bin
        dec = math.floor(dec / 2)
    end
    while #bin < 8 do
        bin = "0" .. bin
    end
    local binArray = {}
    for digit in bin:gmatch(".") do
        table.insert(binArray, tonumber(digit))
    end
    return binArray
end




-- FORM SETUP

forms.destroyall()
setup_window = null
local y = 10

pitState = null

onGround = true



setup_window = forms.newform(340, 260, "Super Mario Bros. - Retro Accessibility Options", main_cleanup)
local picture = forms.pictureBox( setup_window, 0, 0, 340, 70 );
y = y + 70
forms.drawRectangle( picture, 0, 0, 600, 300, "#F6E05E", "#F6E05E");
forms.drawText( picture, 225, 25, "Retro Accessibility Options", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );
forms.drawText( picture, 225, 60, "Super Mario 2 Bros", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );

forms.label(setup_window, "Infinite Lives", 25, y+3, 600, 20)
local infiniteLivesCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25


forms.label(setup_window, "Small Mario can't be hurt (Can still die in pits or lava)", 25, y+3, 600, 20)
local deathCheck = forms.checkbox( setup_window, "", 10, y );

y = y + 25
forms.label(setup_window, "Falling Into a Pit Autoreload to Last Safe Platform", 25, y+3, 600, 20)
local autoPit = forms.checkbox( setup_window, "", 10, y );





event.onexit(function()
    forms.destroy(setup_window)
end)

-- END FORM


function reverse(t)
    local n = #t
    local i = 1
    while i < n do
        t[i], t[n] = t[n], t[i]
        i = i + 1
        n = n - 1
    end
end

function binToHex(buttons)
    local nexHex = string.format("%x", tonumber(table.concat(buttons), 2))
    return nexHex
end


local frame_count = 0
mario_dead = false

mario2_watch = function()
    -- current mario size 
    local mario_size = memory.read_u8(0x04c2, "RAM")
    

    onGround = memory.read_u8(0x0099, "RAM") == 0

    if forms.ischecked(infiniteLivesCheck) == true and memory.read_u8(0x04ed) < 0x09  then
        memory.write_u8(0x04ed, 0x09, "RAM")
    end;

    

    if ( forms.ischecked(deathCheck) and mario_size == 0x0f) then
        if memory.read_u8(0x0085, "System Bus") < 0x60 then
            memory.write_u8(0x0085, 0x80, "System Bus") 
        end
    end;

    if forms.ischecked(autoPit) and mario_dead == false then
        if onGround and frame_count % 30 == 0 and memory.read_u8(0x003c, "RAM") == 0x00 then -- if on ground and not moving, create savestate every second
            pitState = memorysavestate.savecorestate()
        end
        if memory.read_u8(0x04c2, "RAM") == 0x00 and memory.read_u8(0x042a, "RAM") == 0x01 then -- if mario is falling into a pit
            memorysavestate.loadcorestate(pitState)
        end
    end;
    if mario_dead == false then
        mario_dead = memory.read_u8(0x04c2, "RAM") == 0x00
    end
    if mario_dead and memory.read_u8(0x06f2, "RAM") == 3 and mario_size == 0x1f then
        mario_dead = false
    end
    
    
    

end

while true do
    frame_count = frame_count + 1
    mario2_watch()
	emu.frameadvance()
end


