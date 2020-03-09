function fig=plot_bar_obj( rc_obj, query, colors )
    
    mytable = rc_obj.diffusionTableNaNs;
    get_supercluster_occupancies = @( supercluster ) nanmean(mytable(mytable.Supercluster == supercluster,:).Occupancy1);
    get_supercluster_diffusions_1 = @( supercluster ) nanmean(mytable(mytable.Supercluster == supercluster,:).DC1);
    get_supercluster_diffusions_2 = @( supercluster ) nanmean(mytable(mytable.Supercluster == supercluster,:).DC2);

    
    Superclusters = [];
    for i = 1:size(query,1);
        Superclusters = [Superclusters;multipleRegex( rc_obj.clustersTable.Clustertext, query{i} )];
    end

    forbars = arrayfun( get_supercluster_occupancies, Superclusters, 'UniformOutput', true );
    
    DCs1 = arrayfun( get_supercluster_diffusions_1, Superclusters, 'UniformOutput', true );
    DCs2 = arrayfun( get_supercluster_diffusions_2, Superclusters, 'UniformOutput', true );
    
    
    mytable = table( Superclusters, rc_obj.clustersTable.Clustertext(Superclusters), forbars, DCs1, DCs2 ); 
    mytable.Properties.VariableNames = {'Superclusters','Clustertext','Occupancy', 'DC1', 'DC2'};
    mytable = sortrows(mytable,'Occupancy');
    figure('color','w'); g=bar(ones(1,numel(mytable.Occupancy))); hold on; h=bar(mytable.Occupancy); camroll(-90)
    %mytable.Clustertext = 1;
    newlegend = rowfun(@(x,y,z) sprintf('%s (DC1=%1.2f, DC2=%1.2f)',x{1},y,z), table( mytable.Clustertext, mytable.DC1, mytable.DC2 ),'OutputFormat','cell' )
    set(gca,'XTick',[1:numel(mytable.Superclusters)],'XTickLabel',newlegend,'TickDir','out');
    box off;
    ylabel_=ylabel('State 1 Occupancy')
    set(ylabel_,'Color',h.FaceColor)
    
    bars = get(h);
    
    
end