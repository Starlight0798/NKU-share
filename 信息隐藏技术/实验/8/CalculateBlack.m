function blackCount = CalculateBlack(pixelBlock, startIdx)
    blackCount = 0;
    for idx = startIdx : startIdx + 3
        if pixelBlock(idx) == 0
            blackCount = blackCount + 1;
        end
    end
end



