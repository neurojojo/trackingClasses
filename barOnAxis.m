function barOnAxis( barHeights, ygain, y0, x0, w, colors, mytitle )

    %Defaults:
    %---------
    %ygain=25;
    %y0=65;
    %x0=50;
    %w=5;
    %colors = {'blues';'greens';'tans'};
    
    
    % Setting up colors
    if iscell(colors)
        mycolors = cell2mat( colors );
    else
        mycolors = cell2mat( cellfun(@(x) palette(x), colors , 'UniformOutput', false) );
        mycolors = mycolors([1:numel(barHeights)],:);
    end
    
    % Plotting bottom layer
    mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*ones(numel(barHeights),1), min( mycolors*1.1, 1) );
    rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )
    
    % Plotting top layer
    mytable = table( x0+[0:numel(barHeights)-1]'*w, ygain*barHeights, mycolors );
    rowfun( @(x,height,color) barObj( 'a', x, y0, w, height, gca, color ), mytable )

    mytext = text( x0, y0+ygain, mytitle, 'VerticalAlignment', 'bottom', 'horizontalalignment','left' );
    
    % Add labels for fast and slow state %
    text( x0+1, y0+ygain-2, 'Slow', 'color', 'w');
    text( x0+1, y0+2, 'Fast', 'color', 'w');
    
    myaxis = axisObj( x0, y0, ygain, 1, linspace(y0,y0+ygain,5)', num2str( linspace(0,1,5)' ) );

end