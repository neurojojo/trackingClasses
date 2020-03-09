function txt = myupdatefcn_signe(~,event_obj)

lineWidths = findobj('Type','Line');
for i = 1:numel(lineWidths)
    set( lineWidths(i), 'Visible', 'off' );
end

thisLine = get(event_obj,'Target');
set(thisLine,'Visible','on');

end