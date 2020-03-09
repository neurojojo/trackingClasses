
myre = @(x) regexprep(x,'SM ','');
rc_obj.clustersTable.Clustertext=cellfun( myre, rc_obj.clustersTable.Clustertext,'UniformOutput',false );

myre = @(x) regexprep(x,'d2','D2');
rc_obj.clustersTable.Clustertext=cellfun( myre, rc_obj.clustersTable.Clustertext,'UniformOutput',false );

myre = @(x) regexprep(x,'no','No');
rc_obj.clustersTable.Clustertext=cellfun( myre, rc_obj.clustersTable.Clustertext,'UniformOutput',false );

myre = @(x) regexprep(x,'Treat','treat');
rc_obj.clustersTable.Clustertext=cellfun( myre, rc_obj.clustersTable.Clustertext,'UniformOutput',false );

myre = @(x) regexprep(x,'[s|S]ulperide','Sulpiride');
rc_obj.clustersTable.Clustertext=cellfun( myre, rc_obj.clustersTable.Clustertext,'UniformOutput',false );


%% Lifetime state 1/Lifetime state 2 (NOT CLUSTERED BY SUPERCLUSTER)

Quantity1 = 'Lifetime';
Quantity2 = 'Lifetime';
xlims = [0, 100];
ylims = [0, 100];

close all
f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','xlim',[0,0.7],'ylim',[0,0.2]); 

state1_table = rc_obj.lifetimesTable(rc_obj.lifetimesTable.State == 1, : );
state1_table = state1_table( (state1_table.tracksInSeg>2) & (state1_table.Identifier==0) , : );
state2_table = rc_obj.lifetimesTable(rc_obj.lifetimesTable.State == 2, : );
state2_table = state2_table( (state2_table.tracksInSeg>2) & (state2_table.Identifier==0) , : );

variableNames = {'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma'};

[Superclusters,figname] = multipleRegex( rc_obj.clustersTable.Clustertext, 'Myr' );

mycluster_colors = Superclusters;

OrganizeTable = table( Superclusters,...
    repmat( Quantity1, numel(Superclusters), 1 ));

% get_supercluster_stats defined for this table
mytable = state1_table;
get_supercluster_stats = @( supercluster, quantity ) table( supercluster,...
           sum( mytable.Supercluster == supercluster ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 25 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 50 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 75 ),...
           mean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
           std( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
       'VariableNames',{'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma'} );
dc1_output = rowfun( get_supercluster_stats, OrganizeTable );
dc1_output = array2table( table2array( dc1_output.Var1), 'VariableNames', variableNames );
% End of this quantity

OrganizeTable = table( Superclusters,...
    repmat( Quantity2, numel(Superclusters), 1 ));
mytable = state2_table;
get_supercluster_stats = @( supercluster, quantity ) table( supercluster,...
           sum( mytable.Supercluster == supercluster ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 25 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 50 ),...
           prctile( mytable( mytable.Supercluster == supercluster , : ).(quantity), 75 ),...
           mean( mytable( mytable.Supercluster == supercluster , : ).(quantity) ), ...
           std( mytable( mytable.Supercluster == supercluster , : ).(quantity) ),...
       'VariableNames',{'Supercluster','Nentries','Prc25','Med','Prc75','mu','sigma'} );

oc1_output = rowfun( get_supercluster_stats, OrganizeTable );
oc1_output = array2table( table2array( oc1_output.Var1), 'VariableNames', variableNames );

crossTable = join( dc1_output(:,[1,3,4,5]),  oc1_output(:,[3,4,5,1]) , 'key', {'Supercluster'});
crossTable.color = [1:size(crossTable,1)]';
crossTable.maxColor = repmat( size(crossTable,1), size(crossTable,1), 1);
crossTable.ax = repmat( ax_, size(crossTable,1), 1);

crossTable.legend = rc_obj.clustersTable( find( ismember( rc_obj.clustersTable.Supercluster, crossTable.Supercluster ) == 1 ), : ).Clustertext;
combineMed = @(name,med1,med2) {sprintf('%s (x=%1.2f y=%1.2f)',name{1},med1,med2)}; newlegend = rowfun( combineMed, crossTable(:,[end,3,6]) );
crossTable.legend = newlegend.Var1;

crossTable = sortrows(crossTable, 'legend' );
rowfun( @crossObj, crossTable );

xlabel(sprintf('%s State1',Quantity1))
ylabel(sprintf('%s State2',Quantity2))

set(gca,'Xlim',xlims,'YLim',ylims);
set(gcf,'WindowState','maximized')
pause(0.5);
textToTop(gca);

%%
mymove = [30,0,0]
moveright = @(x) set(x,'Position',get(x,'Position')+mymove); rowfun(moveright, table( findobj(gca,'Type','text')), 'outputformat','cell' );
