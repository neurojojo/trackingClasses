classdef maskObj < handle
    
    properties
        image
        layers
    end
    
    methods
        function obj = maskObj()
            obj.image = zeros(300,300);
        end
        
        function addLayer(obj,x,y)
            
            tmp = zeros(300,300);
            if and(isa(x,'double'),isa(y,'double'))
                
                tmp( fix(x), fix(y) ) = 1;
                obj.image = obj.image + tmp;
                
            else
                if and(isa(x,'cell'),isa(y,'cell'))
                    
                    tmp(str2double([300,300],x{1},y{1})) = 1;
                    obj.image = obj.image + tmp;
                    
                end
            end
        end
    end
    
end

