function printCentered(text, color, x, y)
    color = color or colors.white
    len = string.len(text)
    start = x - len / 2
    term.setTextColor(color)
    term.setCursorPos(start + 1,y)
    term.write(text)
end