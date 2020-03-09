function varargout = experimentShowFxn(mytable)


global thetable
thetable = mytable;

fig = figure;

menu = uicontrol('Style','listbox','String',mytable.Genotype,'Callback',@myfxn);
valuebox = uicontrol('Style','text');

[h,w] = deal(420,560);

set(fig,'Position',[100 100 w h])
set(menu,'Position',[10 200 w/2 h/2])
set(valuebox,'Position',[0 100 100 100],'string','Stuff','HorizontalAlignment','left')

end

function varargout = myfxn(x,y)

global thetable
thisExp = get(x,'Value')
thetable(thisExp,:).Keys{1}

end