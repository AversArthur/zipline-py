lastChange = hs.pasteboard.changeCount()
function checkClipboard()
    local newChange = hs.pasteboard.changeCount()
    if newChange ~= lastChange then
        lastChange = newChange
        if hs.pasteboard.readImage() then
            local tmpPath = "/tmp/hs-clipboard-img.png"
            local img = hs.pasteboard.readImage()
            img:saveToFile(tmpPath)
            local handle = io.popen("/Users/arthur_avers/PycharmProjects/zipline_py/zipline-script-file.sh " .. tmpPath)
            local url = handle:read("*a")
            handle:close()
            url = url:gsub("%s+$", "")
            hs.pasteboard.writeObjects(url)
        end
    end
end

timer = hs.timer.doEvery(1, checkClipboard) 