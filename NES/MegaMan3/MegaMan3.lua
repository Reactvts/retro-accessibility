-- Mega Man 3 Accessibility Script
-- Version 0.1
-- Author: Seve Savoie Teruel
-- Date: 2024-03-18
-- Description: This script is designed to make Mega Man 3 more accessible to people with disabilities
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
atBoss = false
pitState = null
alive = true

setup_window = forms.newform(340, 260, "Mega Man 3 - Retro Accessibility Options", main_cleanup)
local picture = forms.pictureBox( setup_window, 0, 0, 340, 70 );
y = y + 70
forms.drawRectangle( picture, 0, 0, 600, 300, "#F6E05E", "#F6E05E");
forms.drawText( picture, 225, 25, "Retro Accessibility Options", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );
forms.drawText( picture, 225, 60, "Mega Man 3", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );


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



megaman2_watch = function()
    -- current mario size    

    onGround = memory.read_u8(0x0030, "RAM") == 0x00 -- on ground



    -- if atBoss == false and memory.read_u8(0x006c0, "RAM") > 0x00 then
    --     atBoss = true
    -- end

    -- if  memory.read_u8(0x00bd, "RAM") == 0x01 then
    --     atBoss = false
    --     return
    -- end
    -- if  memory.read_u8(0x0029, "RAM") ~= 0x0e then
    --     return
    -- end



    if forms.ischecked(infiniteHealthCheck) == true then
        memory.write_u8(0x00a2, 0x9c, "RAM")
    end;
    if forms.ischecked(invincibleCheck) == true and memory.read_u8(0x39) < 0x9  then
        memory.write_u8(0x39, 0xff, "RAM")
    end;

    if forms.ischecked(infiniteLivesCheck) == true and memory.read_u8(0xae) < 9  then
        memory.write_u8(0xae, 0x09, "RAM")
    end;



    if forms.ischecked(autoPit) and alive then
        if onGround and frame_count % 30 == 0 and memory.read_u8(0x0016, "RAM") == 0x00 then -- if on ground and not moving, create savestate every second
            pitState = memorysavestate.savecorestate()
        end
        if memory.read_u8(0x030, "RAM") == 0x0e then
            if memory.read_u8(0x010, "RAM") ~= 0x10  and memory.read_u8(0x00a2, "RAM") > 0x80 and memory.read_u8(0x00b2, "RAM") >= 0x80 then -- if megaman is falling into a pit
                memorysavestate.loadcorestate(pitState)
            end
            if memory.read_u8(0x00e0, "RAM") == 0xf0 and memory.read_u8(0x06c0, "RAM") > 0x0  then -- if megaman hit a spike or lava
                memorysavestate.loadcorestate(pitState)
            end
        end
    end;

    if forms.ischecked(infiniteWeaponCheck) then
        if memory.read_u8(0xa3, "RAM") >= 0x80 then
            memory.write_u8(0xa3, 0x9c, "RAM") 
        end
        if memory.read_u8(0xa4, "RAM") >= 0x80 then
            memory.write_u8(0xa4, 0x9c, "RAM")
        end
        if memory.read_u8(0xa5, "RAM") >= 0x80 then
            memory.write_u8(0xa5, 0x9c, "RAM")
        end
        if memory.read_u8(0xa6, "RAM") >= 0x80 then
            memory.write_u8(0xa6, 0x9c, "RAM")
        end
        if memory.read_u8(0xa7, "RAM") >= 0x80 then
            memory.write_u8(0xa7, 0x9c, "RAM")
        end
        if memory.read_u8(0xa8, "RAM") >= 0x80 then
            memory.write_u8(0xa8, 0x9c, "RAM")
        end
        if memory.read_u8(0xa9, "RAM") >= 0x80 then
            memory.write_u8(0xa9, 0x9c, "RAM")
        end
        if memory.read_u8(0xaa, "RAM") >= 0x80 then
            memory.write_u8(0xaa, 0x9c, "RAM")
        end
        if memory.read_u8(0xab, "RAM") >= 0x80 then
            memory.write_u8(0xab, 0x9c, "RAM")
        end
        if memory.read_u8(0xac, "RAM") >= 0x80 then
            memory.write_u8(0xac, 0x9c, "RAM")
        end
        if memory.read_u8(0xad, "RAM") >= 0x80 then
            memory.write_u8(0xad, 0x9c, "RAM")
        end
    end;

end

while true do
    frame_count = frame_count + 1
    megaman2_watch()
	emu.frameadvance()
end


