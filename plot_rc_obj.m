function info_table=plot_rc_obj( rc_obj, ...
    remove_ends,...
    minlength,...
    Quantity1,...
    Quantity2,...
    figdetails,...
    xlims,...
    ylims,...
    sorting,...
    colors,...
    query,...
    newfig,...
    only1length)
    
    if and(remove_ends,only1length)
        fprintf('Cannot remove ends and also only include single segments!\n');
        return
    end
    
    if remove_ends
        rc_obj.consolidateSuperclusterLifetimes('remove_ends',minlength);
        removeflag=sprintf('removed (length %i)\n',minlength); 
        fprintf('%s',removeflag);
    else; end

    if only1length
        rc_obj.consolidateSuperclusterLifetimes('only1length');
        removeflag=sprintf('Only 1 length segments\n'); 
        fprintf('%s',removeflag);
    else; end

    if and( not(only1length), not(remove_ends) )
        fprintf('Including all segment types\n');
        rc_obj.consolidateSuperclusterLifetimes(); removeflag=''; 
    end
    
    if or(newfig,isempty( findobj('Type','Figure') ))
        close all
        f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','xlim',[0,0.7],'ylim',[0,0.2]); 
    end
    
    ax_ = gca;
    variableNames = {'Supercluster','Nentries','Prc25','Med','Prc75','mu_minus_sd','mu','mu_plus_sd'};
    [Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, query );
    
    % NEW STEP %
    Superclusters = rc_obj.clustersTable.Supercluster(Superclusters);
    mycluster_colors = Superclusters;

    OrganizeTable = table( 'size',[numel(Superclusters),2],'VariableTypes',{'double','categorical'},'VariableNames',{'Supercluster','Clustertext'} );
    OrganizeTable.Supercluster = Superclusters;
    OrganizeTable.Clustertext = repmat( Quantity1, numel(Superclusters), 1 );

    % get_supercluster_stats defined for this table
    mytable = rc_obj.consolidatedLifetimes;
    get_supercluster_stats = @( supercluster, quantity ) table( supercluster,...
               sum( mytable.Supercluster == supercluster ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 25 ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 50 ),...
               prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 75 ),...
               nanmean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ) - ...
                    (1 / sqrt(sum( mytable.Supercluster == supercluster )) )*nanstd( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
               nanmean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
               nanmean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ) + ...
                    (1 / sqrt(sum( mytable.Supercluster == supercluster )) )*nanstd( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
           'VariableNames',variableNames);
    dc1_output = rowfun( get_supercluster_stats, OrganizeTable );
    dc1_output = array2table( table2array( dc1_output.Var1), 'VariableNames', variableNames );
    % End of this quantity

    OrganizeTable = table( 'size',[numel(Superclusters),2],'VariableTypes',{'double','categorical'},'VariableNames',{'Supercluster','Clustertext'} );
    OrganizeTable.Supercluster = Superclusters;
    OrganizeTable.Clustertext = repmat( Quantity2, numel(Superclusters), 1 );

    oc1_output = rowfun( get_supercluster_stats, OrganizeTable );
    oc1_output = array2table( table2array( oc1_output.Var1), 'VariableNames', variableNames );

    parametersToJoin = {'Supercluster','Nentries','mu_minus_sd','mu','mu_plus_sd'};
    crossTable = join( dc1_output(:,parametersToJoin),  ...
        oc1_output(:,parametersToJoin) , 'key', {'Supercluster','Nentries'});
    crossTable.color = [1:size(crossTable,1)]';
    if and( sum(sorting)>0, eq(numel(sorting),size(crossTable,1)) ); crossTable.sorting = sorting'; else; crossTable.sorting = [1:size(crossTable,1)]'; end

    crossTable.ax = repmat( ax_, size(crossTable,1), 1);
    
    % Produce the legend
    crossTable.legend = rc_obj.clustersTable( find( ismember( rc_obj.clustersTable.Supercluster, crossTable.Supercluster ) == 1 ), : ).Clustertext;

    combineMed = @(name,Nentries,med1,med2) {sprintf('%s (N=%i) (x=%1.2f y=%1.2f)',name{1},Nentries,med1,med2)}; 
    newlegend = rowfun( combineMed, crossTable(:,[end,2,4,7]) );
    crossTable.legend = newlegend.Var1;

    if sum(sorting)>0; crossTable = sortrows(crossTable, 'sorting' ); end;
    % Color after sorting
    crossTable.color = [1:size(crossTable,1)]';
    crossTable.colors = repmat( colors, size(crossTable,1), 1);

    obj1 = rowfun( @crossObj, crossTable );

    xlabel(sprintf('%s',Quantity1))
    ylabel(sprintf('%s',Quantity2))

    set(gca,'Xlim',xlims,'YLim',ylims);
    set(gcf,'WindowState','maximized')
    
    figname = regexprep(figname,'\(|\)|(\|)','_');
    if remove_ends; title(sprintf('Transitioning segments (min length=%i)',minlength+1)); else; title('Single segments'); end
    
    %Remove if you want to print
    %print( gcf, sprintf('figure_%s_%s_%s.png',figdetails,figname,removeflag), '-dpng', '-r0' )
    
    % Get occupancy stats
    mytable = rc_obj.diffusionTableNaNs;
    get_supercluster_occupancies = @( supercluster ) nanmean(mytable(mytable.Supercluster == supercluster,:).Occupancy1);
    forbars = arrayfun( get_supercluster_occupancies, Superclusters, 'UniformOutput', true );

    % Produce an info table for coloring and sorting
    info_table = table('size',[numel(obj1),2],'variableTypes',{'double','cell'},'variablenames',{'Superclusters','Color'} );
    for i = 1:numel(obj1); info_table(i,:) = table( obj1(i,:).Var1.label, {[obj1(i,:).Var1.color]} ); end
   
    info_table = { info_table }; % Cell-ify in order to be handled by fun operations
    
end

