classdef evolveline < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
        t
        i
        ax_
    end
    
    methods
        
        function obj = evolveline(mytable,ax_)
            [obj.x,obj.y,obj.t] = deal( mytable.x, mytable.y, mytable.t );
            obj.i=2;
            obj.ax_ = ax_;
        end
        
        function iterate(obj)
           i = obj.i;
           %set( obj.ax_, 'XLim', [0,300], 'YLim', [0,300] );
           
           plot( obj.ax_, obj.x([1:i-1]), obj.y([1:i-1]), 'r-' )
           plot( obj.ax_, obj.x([i-1:i]), obj.y([i-1:i]), 'b-' )
           
           fprintf('%i\n',obj.i);
           
           obj.i=obj.i+1;
        end
        
    end
end

