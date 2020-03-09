classdef axisObj < handle
    
    
    properties
        majorAxis
        tickLength
        divisions
        ticks
        ticklabels
    end
    
    methods
        function obj = axisObj( x0, y0, h, tickLength, divisions, divisionlabels )
            obj.majorAxis = line( [x0,x0],[y0,y0+h],'color','k','linewidth',.5 );
            %[obj.tickLength,obj.divisions] = deal(tickLength,divisions);
            obj.ticks = arrayfun( @(y_) line( [x0-tickLength,x0],[y_,y_],'color','k','linewidth',.5 ), divisions );
            %obj.ticklabels = rowfun( @(y_,mytext) text( x0 - tickLength,y_,mytext, 'horizontalalignment', 'right' ), table( divisions, num2str(divisions) ) );
            obj.ticklabels = rowfun( @(y_,mytext) text( x0-1.5*tickLength,y_,mytext,'horizontalalignment','right'), table( divisions, divisionlabels ) ); 
        end
    end
end

