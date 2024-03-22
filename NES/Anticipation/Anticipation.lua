-- Anticipation Accessibility Script
-- Version 0.1
-- Author: Seve Savoie Teruel
-- Date: 2024-03-21
-- Description: This script is designed to make Anticipation more accessible to people with disabilities
-- Requires: Bizhawk Emulator
-- Usage: Load the rom and then load this script. A window will appear with options to enable or disable certain features.
--
-- Current Features:
--  - Infinite Guess Time
--  - Allow Keyboard Input

-- NOTE ABOUT KEYBOARD INPUT 
-- This script will allow you to type in the answer to the puzzle using your keyboard, 
-- it will automatically select the letter you are typing and press the A button on both controllers (so it works in multipler
-- That being said this won't work if you are using default Bizhawk keyboard bindings, becase by default, Bizhawk has a few controller bindings
-- and hotkeys that will interfere with this script. You can change the hotkeys in the Bizhawk settings and the controller 
-- bindings in the Config->Controllers menu



-- FORM SETUP

forms.destroyall()
setup_window = null
local y = 10


onGround = true
pitState = null


setup_window = forms.newform(340, 260, "Anticipation - Retro Accessibility Options", main_cleanup)
local picture = forms.pictureBox( setup_window, 0, 0, 340, 70 );
y = y + 70
forms.drawRectangle( picture, 0, 0, 600, 300, "#F6E05E", "#F6E05E");
forms.drawText( picture, 225, 25, "Retro Accessibility Options", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );
forms.drawText( picture, 225, 60, "Anticipation", "black", "#F6E05E", 30, "Inter", "600", "center", "middle" );


forms.label(setup_window, "Infinite Guess Time", 25, y+3, 600, 20)
local infiniteGuessTimeCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25


forms.label(setup_window, "Enable Keyboard Typing for entering guesses", 25, y+3, 600, 20)
local keyboardCheck = forms.checkbox( setup_window, "", 10, y );
y = y + 25
forms.label(setup_window, "NOTE: Make sure you have no Controller or hotkeys bound to letters\n               Combination hotkeys (Shift-F, Ctrl-C) work fine.", 25, y+3, 600, 40)




event.onexit(function()
    forms.destroy(setup_window)
end)

-- END FORM

local keyDown = false

local frame_count = 0

function getLetterCursorPosition(letter)
    if #letter == 1 and letter:match("%u") then
        local index = string.byte(letter) - 64
        return index * 0x8
    else
        return nil
    end
end




anticipation_watch = function()

    if forms.ischecked(infiniteGuessTimeCheck) == true then
        memory.write_u8(0x86, 0x19, "RAM")
    end;

    if forms.ischecked(keyboardCheck) == true and memory.read_u8(0x046e) ~= 0 then
        local keys = input.get()
        local nextKey = next(keys)
        
        
        if nextKey ~= nil then            
            local cursor = getLetterCursorPosition(nextKey)            
            if cursor ~= nil then
                memory.write_u8(0x81, cursor, "RAM")
                joypad.set({A=true},1)
                joypad.set({A=true},2)
            end
        end;

        keyDown = nextKey == nil


    end;

   

end

while true do
    frame_count = frame_count + 1
    anticipation_watch()
	emu.frameadvance()
end


