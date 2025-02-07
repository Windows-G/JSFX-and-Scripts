-- Function to toggle selection state for MIDI events in a take
local function inverseSelectionInTake(take)
    if not take or not reaper.ValidatePtr(take, "MediaItem_Take*") then return end

    local _, noteCount, ccCount, sysexCount = reaper.MIDI_CountEvts(take)

    -- Inverse selection for notes
    for i = 0, noteCount - 1 do
        local _, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        reaper.MIDI_SetNote(take, i, not selected, muted, startppqpos, endppqpos, chan, pitch, vel, true)
    end

    -- Inverse selection for CC events
    for i = 0, ccCount - 1 do
        local _, selected, muted, ppqpos, chanmsg, chan, msg2, msg3 = reaper.MIDI_GetCC(take, i)
        reaper.MIDI_SetCC(take, i, not selected, muted, ppqpos, chanmsg, chan, msg2, msg3, true)
    end

    -- Inverse selection for text/sysex events
    for i = 0, sysexCount - 1 do
        local _, selected, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt(take, i)
        reaper.MIDI_SetTextSysexEvt(take, i, not selected, muted, ppqpos, type, msg, true)
    end

    -- Ensure changes are applied
    reaper.MIDI_Sort(take)
end

-- Main logic
local midiEditor = reaper.MIDIEditor_GetActive()

if midiEditor then
    -- Process all editable takes in the MIDI Editor
    local takeIndex = 0
    while true do
        local take = reaper.MIDIEditor_EnumTakes(midiEditor, takeIndex, true) -- true for editable takes
        if not take then break end
        inverseSelectionInTake(take)
        takeIndex = takeIndex + 1
    end
else
    -- Process selected media items for Inline MIDI Editor
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    for i = 0, numSelectedItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            local take = reaper.GetActiveTake(item)
            if take and reaper.TakeIsMIDI(take) then
                inverseSelectionInTake(take)
            end
        end
    end
end
