function txt = myupdatefcn(empt,event_obj)
% Customizes text of data tips

pos = get(event_obj,'Position');
x_ = get(gcf,'UserData');
[mydata, myraw, myxvar, myyvar, mylabels] = deal(x_.data,x_.raw,x_.xVar,x_.yVar,x_.thisClusterText_table);
figurePos = x_.figurePosition;
color = x_.color;

idx_in_data = find( mydata.(myxvar) == pos(1) & mydata.(myyvar) == pos(2) );

[sc,cell] = deal( mydata.Supercluster_State1(idx_in_data), mydata.Cell_State1(idx_in_data) );

previousOverlay = findobj('Tag','overlay');
if ~isempty(previousOverlay); delete( previousOverlay ); end

plot( mydata( mydata.Supercluster_State1==sc, :).(myxvar), mydata( mydata.Supercluster_State1==sc, :).(myyvar), 'o', 'color', color, 'MarkerFaceColor', color, 'MarkerSize',12,'Tag','overlay' );

figure('color','w');%,'position', figurePos); 
for i = 1:2
    thisData = myraw( (myraw.State == i) & (myraw.Supercluster==sc & myraw.Cell==cell), :).Lifetime;
    subplot(1,2,i); histogram( thisData, 'Normalization', 'pdf' ); 
    set(gca,'TickDir','out','box','off','Ylim',[0,.04]); xlabel(sprintf('State %i Lifetime',i)); ylabel('Fraction');
end
sgtitle( sprintf('%s (SC:%i Cell:%i)',mylabels(sc,:).ClusterName{1}, sc, cell) );
    
txt = {[ mylabels(sc,:).ClusterName{1} ],...
       ['SC: ', num2str(sc), ' Cell: ', num2str(cell)],...
       ['Cell: ', num2str(cell)],...
       %['x: ',num2str(pos(1))],...
       %['y: ',num2str(pos(2))]};
       };


   
end