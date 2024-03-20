-- Mega Man Accessibility Script
-- Version 0.1
-- Author: Seve Savoie Teruel
-- Date: 2024-03-17
-- Description: This script is designed to make Mega Man more accessible to people with disabilities
-- Requires: Bizhawk Emulator
-- Usage: Load the rom and then load this script. A window will appear with options to enable or disable certain features.
--
-- Current Features:
--  - Infinite Lives
--  - Infinite Weapon Energy
--  - Infinite Health
--  - Invincible
--  - Auto Quicksave every half second when on ground and not moving, if the player falls into a pit, the game will reload the last safe platform









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


onGround = true
pitState = null


setup_window = forms.newform(340, 260, "Mega Man - Retro Accessibility Options", main_cleanup)
local picture = forms.pictureBox( setup_window, 0, 0, 340, 70 );
y = y + 70
forms.drawRectangle( picture, 0, 0, 600, 300, "#F6E05E", "#F6E05E");
forms.drawText( picture, 225, 25, "Retro Accessibility Options", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );
forms.drawText( picture, 225, 60, "Mega Man", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );


forms.label(setup_window, "Infinite Lives", 25, y+3, 600, 20)
local infiniteLivesCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25

forms.label(setup_window, "Infinite Health (Can still take knockback)", 25, y+3, 600, 20)
local infiniteHealthCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25

forms.label(setup_window, "Invincible (No Knockback)", 25, y+3, 600, 20)
local invincibleCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25

forms.label(setup_window, "Infinite Weapon Energy", 25, y+3, 600, 20)
local infiniteWeaponCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25

-- y = y + 25
-- forms.label(setup_window, "Auto Run:", 25, y+3, 60, 20)
-- local autoRun = forms.checkbox( setup_window, "Auto Run", 100, y );
forms.label(setup_window, "Falling Into Spikes or a Pit Auto-Reloads to Last Safe Platform", 25, y+3, 600, 20)
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

megaman_watch = function()
    -- current mario size    

    if(memory.read_u8(0x0054, "RAM") == 0x00) then
        return
    end

    onGround = memory.read_u8(0x0400, "RAM") == 0

    if forms.ischecked(infiniteHealthCheck) == true then
        memory.write_u8(0x6a, 0x1c, "RAM")
    end;
    if forms.ischecked(invincibleCheck) == true and memory.read_u8(0x55) < 0x9  then
        memory.write_u8(0x55, 0xff, "RAM")
    end;

    if forms.ischecked(infiniteLivesCheck) == true and memory.read_u8(0xa6) < 9  then
        memory.write_u8(0xa6, 0x09, "RAM")
    end;

    if forms.ischecked(autoPit) then
        if onGround and frame_count % 30 == 0 and memory.read_u8(0x0014, "RAM") == 0x00 then -- if on ground and not moving, create savestate every second
            pitState = memorysavestate.savecorestate()
        end
        if memory.read_u8(0x0600, "RAM") == 0xf8 and memory.read_u8(0x0580, "RAM") == 0xfe then -- if megaman is falling into a pit
            memorysavestate.loadcorestate(pitState)
        end
        if memory.read_u8(0x006a, "RAM") ~= 0x00 and memory.read_u8(0x0580, "RAM") == 0xfe and memory.read_u8(0x0581, "RAM") == 0xff and memory.read_u8(0x0400, "RAM") < 0x12  then -- if megaman hit a spike
            print('hit spike ' .. memory.read_u8(0x0054, "RAM"))
            memorysavestate.loadcorestate(pitState)
        end
    end;

    if forms.ischecked(infiniteWeaponCheck) then
        memory.write_u8(0x6b, 0x1c, "RAM") 
        memory.write_u8(0x6c, 0x1c, "RAM") 
        memory.write_u8(0x6d, 0x1c, "RAM") 
        memory.write_u8(0x6e, 0x1c, "RAM") 
        memory.write_u8(0x6f, 0x1c, "RAM") 
        memory.write_u8(0x70, 0x1c, "RAM") 
        memory.write_u8(0x71, 0x1c, "RAM") 
        
    end;

end

while true do
    frame_count = frame_count + 1
    megaman_watch()
	emu.frameadvance()
end


