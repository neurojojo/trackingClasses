classdef barObj < handle
    % Help file
    %
    % obj = barObj(label, x0, y0, w, h, parent, color)
    
    properties
        handle
    end
    
    properties(Access = private)
       label
        x0
        y0
        w
        h
        color
        parent 
    end
    
    properties(Constant)
    end
    
    methods
        function obj = barObj( label, x0, y0, w, h, parent, color )
            if ((h>0) & (w>0))    
                obj.handle=patch([x0,x0+w,x0+w,x0,x0],[y0,y0,y0+h,y0+h,y0],color,'parent', parent, 'edgecolor', 'white' );
            end
            [obj.label,obj.x0,obj.y0,obj.h,obj.w,obj.parent,obj.color] = deal(label, x0, y0, h, w, parent, color);
        end
    end
end