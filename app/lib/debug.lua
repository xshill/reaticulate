function DebugArray(Array)
    for index, value in pairs(Array) do
        reaper.ShowConsoleMsg("["..tostring(index).."] = "..tostring(value).."\n")
    end
end

return DebugArray
