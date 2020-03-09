function textToTop( figHandle )

    textObjs = findobj( figHandle, 'Type', 'text' );
    figSize_x = get( figHandle, 'Xlim');
    figSize_y = get( figHandle, 'Ylim');
    text_Height = textObjs(1).Extent(4);
    for i = 1:numel(textObjs)
       textObjs(i).Position = [ 0.01*(figSize_x(2)-figSize_x(1)), figSize_y(2)-(i*text_Height), 0 ];
    end

end