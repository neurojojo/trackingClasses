function txt = myupdatefcn_disp(~,event_obj)

    thisPoint = get(event_obj,'Target');

    makeFigure = @()  figure('position',[27,46,1876,300],'color','w');

    idx = get(event_obj, 'DataIndex');
    txt = { idx };    

end