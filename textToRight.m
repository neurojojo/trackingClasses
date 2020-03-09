function textToRight( figHandle )

    textObjs = findobj( figHandle, 'Type', 'text' );
    figSize_x = get( figHandle, 'Xlim');
    figSize_y = get( figHandle, 'Ylim');
    text_Height = textObjs(1).Extent(4);
    text_Width = textObjs(1).Extent(3);
    for i = 1:numel(textObjs)
       textObjs(i).Position = [ (figSize_x(2)-text_Width), figSize_y(2)-(i*text_Height), 0 ];
    end

end