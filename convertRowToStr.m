function mystr = convertRowToStr( varargin )

mystr = '';

for i = 1:numel( varargin )
    thistext = varargin{i};
    thistext = thistext{1};
    if ~isempty( thistext )
        mystr = strcat( [mystr ' ' thistext ]);
    end
end
mystr = {mystr(2:end)};

end