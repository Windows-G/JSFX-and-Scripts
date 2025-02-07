-- Function to process muted MIDI events in a take
local function processMutedEventsInTake(take)
    if not take or not reaper.ValidatePtr(take, "MediaItem_Take*") then return end
    
    -- Loop through all MIDI events in the current take
    local retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)
    
    for i = 0, notes - 1 do
        local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        if muted then
            reaper.MIDI_SetNote(take, i, true, muted, startppqpos, endppqpos, chan, pitch, vel, true)
        end
    end

    for i = 0, ccs - 1 do
        local retval, selected, muted, ppqpos, chanmsg, chan, msg2, msg3 = reaper.MIDI_GetCC(take, i)
        if muted then
            reaper.MIDI_SetCC(take, i, true, muted, ppqpos, chanmsg, chan, msg2, msg3, true)
        end
    end

    for i = 0, sysex - 1 do
        local retval, selected, muted, ppqpos, msg = reaper.MIDI_GetTextSysexEvt(take, i, true, muted, ppqpos, msg)
        if muted then
            reaper.MIDI_SetTextSysexEvt(take, i, true, muted, ppqpos, msg, true)
        end
    end

    -- Ensure the changes are applied for this take
    reaper.MIDI_Sort(take)
end

-- Main logic
local midiEditor = reaper.MIDIEditor_GetActive()

if midiEditor then
    -- Process takes in the MIDI editor
    local takeIndex = 0
    while true do
        local take = reaper.MIDIEditor_EnumTakes(midiEditor, takeIndex, true) -- true for editable takes
        if not take then break end
        processMutedEventsInTake(take)
        takeIndex = takeIndex + 1
    end
else
    -- Process selected media items for inline MIDI editor
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    for i = 0, numSelectedItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            local take = reaper.GetActiveTake(item)
            if take and reaper.TakeIsMIDI(take) then
                processMutedEventsInTake(take)
            end
        end
    end
end
