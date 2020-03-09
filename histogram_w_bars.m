%%
% Playing
mydata = rc_obj.lifetimesTable.tracksInSeg;
piestats = [    numel(find( mydata<=2) ),...
                numel(find( and(mydata>2,mydata<=15 ) ) ),...
                numel(find( mydata>15 ) )];
pielegend = {'<=2','>2 and <=15','>15'};
mytable = table( pielegend', piestats'/sum(piestats) );
mylegend = rowfun( @(x,y) sprintf('%s (%1.2f)',x{1},y), mytable,  'outputformat', 'cell' );
histstats = rc_obj.lifetimesTable.tracksInSeg;

[xshift,yshift] = deal(4,2);
[xscale,yscale] = deal(1.5,.2);
palette_out = palette('blues')
f=figure('color','w');
histogram( histstats, 'normalization', 'pdf', 'binwidth', 1 ); box off;
set(gca,'TickDir','out','XTick',[1:15],'XTickLabel',[1:15])
xlim([1,15]);
hold on;
h=pie( piestats,[1,1,1],'parent',f,mylegend);
colormap(palette_out)
g=findobj(gca,'Type','patch');
for i = 1:numel(g);
    g(i).Vertices = [xshift*ones( size(g(i).Vertices,1),1 ),yshift*ones( size(g(i).Vertices,1),1 )] + g(i).Vertices;
    g(i).Vertices = g(i).Vertices * [xscale,0;0,yscale];
    g(i).EdgeColor = [1,1,1];
    textpos(i,:) = mean(g(i).Vertices,1);
end
g=findobj(gca,'Type','text');
for i = 1:numel(g);
    g(i).Position = [textpos(i,:),0];
    g(i).BackgroundColor = [1,1,1];
end
set(gcf,'Position',[270,500,775,250]);

%%
% Playing
title_ = 'State2 (slow)';
mydata = rc_obj.lifetimesTable(rc_obj.lifetimesTable.State==2,:).tracksInSeg;
piestats = [    numel(find( mydata<=2) ),...
                numel(find( and(mydata>2,mydata<=15 ) ) ),...
                numel(find( mydata>15 ) )];
pielegend = {'<=2','>2 and <=15','>15'};
mytable = table( pielegend', piestats'/sum(piestats) );
mylegend = rowfun( @(x,y) sprintf('%s (%1.2f)',x{1},y), mytable,  'outputformat', 'cell' );
histstats = rc_obj.lifetimesTable.tracksInSeg;

[xshift,yshift] = deal(4,2);
[xscale,yscale] = deal(1.5,.2);
palette_out = palette('blues')
f=figure('color','w');
histogram( histstats, 'normalization', 'pdf', 'binwidth', 1 ); box off;
set(gca,'TickDir','out','XTick',[1:15],'XTickLabel',[1:15])
xlim([1,15]);
hold on;
h=pie( piestats,[1,1,1],'parent',f,mylegend);
colormap(palette_out)
g=findobj(gca,'Type','patch');
for i = 1:numel(g);
    g(i).Vertices = [xshift*ones( size(g(i).Vertices,1),1 ),yshift*ones( size(g(i).Vertices,1),1 )] + g(i).Vertices;
    g(i).Vertices = g(i).Vertices * [xscale,0;0,yscale];
    g(i).EdgeColor = [1,1,1];
    textpos(i,:) = mean(g(i).Vertices,1);
end
g=findobj(gca,'Type','text');
for i = 1:numel(g);
    g(i).Position = [textpos(i,:),0];
    g(i).BackgroundColor = [1,1,1];
end
set(gcf,'Position',[270,500,775,250]);
title(title_);