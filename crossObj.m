classdef crossObj < handle
    
    properties
        label
        x0
        x1
        xcenter
        y0
        y1
        ycenter
        color
        parent
    end
    
    methods
        function obj = crossObj( label, Nentries, x0, xcenter, x1, y0, ycenter, y1, color, maxColor, parent, legend, colors )
            
            if iscell(colors); colors = colors{1}; end
            colors = palette( colors );
            
            % Only plot non-NaN entries
            if eq( sum(isnan([x0,xcenter,x1,y0,ycenter,y1])), 0 ) & ((x1-x0)>0 & (y1-y0)>0)
                
                line( [x0,x1], [ycenter, ycenter], 'color', colors(color,:), 'parent', parent, 'linewidth', 8 );
                line( [xcenter,xcenter], [y0, y1], 'color', colors(color,:), 'parent', parent, 'linewidth', 8 );
                
                text( x0, y1, legend, 'color', colors(color,:), 'parent', parent );
                obj.color = colors(color,:);
                [obj.label,obj.x0,obj.x1,obj.xcenter,obj.y0,obj.y1,obj.ycenter,obj.parent] = deal (label,x0,x1,xcenter,y0,y1,ycenter,parent);
            end
            
        end
    end
end