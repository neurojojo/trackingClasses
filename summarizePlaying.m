rc_obj.clustersTable = sortrows( rc_obj.clustersTable, 'AbsoluteIndexToSubfolders' )

%% Put together the cluster info into a cell array

%Supercluster_table = table( thisClusterText', 'VariableNames', {'ClusterName'} );
%Supercluster_table( cellfun(@isempty, Supercluster_table.ClusterName), : ).ClusterName = {''}
%clearvars thisClusterText

variableNames = {'AbsoluteIdxToSubfolders','State','Nentries','Noutliers','Prc25','Med','Prc75','mu','sigma'};

% Use with rc_obj.lifetimesTable
mytable = rc_obj.lifetimesTable;
get_cell_stats = @(cell, quantity, state ) table( cell,...
           state,...
           sum( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ) ),...
           findExtremes( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity) ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity), 25 ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity), 50 ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity), 75 ),...
           mean( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity) ), ...
           std( mytable( ( mytable.State == state ) & ( mytable.Obj_Idx == cell ), : ).(quantity) ),...
       'VariableNames', variableNames );

get_supercluster_stats = @(mytable, supercluster, quantity, state ) table( supercluster,...
           state,...
           sum( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ) ),...
           findExtremes( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity) ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity), 25 ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity), 50 ),...
           prctile( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity), 75 ),...
           mean( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity) ), ...
           std( mytable( ( mytable.State == state ) & ( mytable.Supercluster == supercluster ), : ).(quantity) ),...
       'VariableNames',{'Supercluster','State','Nentries','Noutliers','Prc25','Med','Prc75','mu','sigma'} );

%findExtremes = @(x) numel( find( pdf( makedist('Normal','mu',mean(x),'sigma',std(x)), x ) < 0.01 ) );
findExtremes = @(x) numel( find( pdf( makedist('Exponential','mu',mean(x)), x ) < 0.01 ) );

%%
% {'Supercluster'}{'Cell'}{'Obj_Idx'}{'trackIdx'}{'segIdx'}{'hmmSegIdx'}{'State'}{'hmmSegStart'}{'Lifetime'}{'tracksInSeg'}{'Index'}{'Identifier'}
Nstates = 2;
myobjs_list = unique( rc_obj.lifetimesTable.Obj_Idx );
OrganizeTable = table( repmat( myobjs_list, 2, 1 ),...
    repmat( 'Lifetime', Nstates * numel(myobjs_list), 1),...
    [repmat(1, numel(myobjs_list), 1);repmat(2, numel(myobjs_list), 1)])
output = rowfun( get_cell_stats, OrganizeTable );
% Next line is an absolute hack but no other way to get the table without
% two headings of variableNames
output = array2table( table2array(output.Var1), 'VariableNames', variableNames );

%% Join with superclusters table to get labeled info
joined_output = join( output, rc_obj.subfoldersTable, 'key', 'AbsoluteIdxToSubfolders' );
joined_output = joined_output(:,{'AbsoluteIdxToSubfolders','Cluster','Subcluster','Supercluster','State','Nentries','Noutliers','Prc25','Med','Prc75','mu','sigma'});

joined_output = joined_output( joined_output.Cluster==9, : );

state1_tbl = joined_output(joined_output.State == 1,{'AbsoluteIdxToSubfolders','Prc25','Med','Prc75','Subcluster'}); state1_tbl.Properties.VariableNames = {'AbsoluteIdxToSubfolders','State1_Prc25','State1_Med','State1_Prc75','Subcluster'};
state2_tbl = joined_output(joined_output.State == 2,{'AbsoluteIdxToSubfolders','Prc25','Med','Prc75','Subcluster'}); state2_tbl.Properties.VariableNames = {'AbsoluteIdxToSubfolders','State2_Prc25','State2_Med','State2_Prc75','Subcluster'};

state_tbl = join( state1_tbl, state2_tbl, 'key', {'AbsoluteIdxToSubfolders','Subcluster'} );
state_tbl = state_tbl(:,{'AbsoluteIdxToSubfolders','State1_Prc25','State1_Med','State1_Prc75','State2_Prc25','State2_Med','State2_Prc75','Subcluster'});

f=figure('color','w'); ax_ = axes('parent',f,'tickdir','out','Xlim',[0,200],'Ylim',[0,200]);
state_tbl.Parent = repmat(ax_,size(state_tbl,1),1);

rowfun( @crossObj, state_tbl(:,:) )
%%

% Only take tracks with more than 2 segments that are not end-segments
search = intersect( find(rc_obj.lifetimesTable.tracksInSeg>2), find(rc_obj.lifetimesTable.Identifier==0) );
new_lifetimesTable = rc_obj.lifetimesTable(search, :);
tableToAnalyze = new_lifetimesTable;

x=table();
for i = unique( tableToAnalyze.Supercluster )'
    subtable = tableToAnalyze( tableToAnalyze.Supercluster == i, : );
    for j = unique( subtable.Cell )'
       subsubtable = subtable( subtable.Cell == j, : );
       % Supercluster#, Cell#, # State1, # State2, Ratio 1/2, State1 25th, State1 Median, State 1 75th, State2 25th, State2 Median, State2 75th,  
       subsubtable.logLifetime = log( subsubtable.Lifetime );
       
       try
        x = [ x; get_stats( subsubtable, 'Lifetime', 1 ); get_stats( subsubtable, 'Lifetime', 2 ); ];
       catch
           fprintf('Failed with numel of x equal to %i\n', size(x,1) );
       end
    end
end

state1_tbl = x(x.State==1,:);
state2_tbl = x(x.State==2,:);

text_ = 'State1'; appendtext = @(x) sprintf('%s_%s',x,text_); state1_tbl.Properties.VariableNames = cellfun( appendtext, state1_tbl.Properties.VariableNames, 'UniformOutput', 0 );
text_ = 'State2'; appendtext = @(x) sprintf('%s_%s',x,text_); state2_tbl.Properties.VariableNames = cellfun( appendtext, state2_tbl.Properties.VariableNames, 'UniformOutput', 0 );

state1_tbl.Properties.VariableNames{1} = 'Supercluster'
state2_tbl.Properties.VariableNames{1} = 'Supercluster'

%% Execute searches 

figure('color','w', 'position', [50,357,1362,356]); for i = 1:4; ax_(i) = subplot(2,2,i); hold on; end

query = 'ins4'
searchcells = @(x) ~isempty( regexpi(x,query,'match') )
SCnums = find( cellfun( searchcells, Supercluster_table.ClusterName ) == 1 );
med = state1_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Med_State1;
scs = state1_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Supercluster;
boxplot( med, scs, 'parent',ax_(1) );

query = 'myr'
searchcells = @(x) ~isempty( regexpi(x,query,'match') )
SCnums = find( cellfun( searchcells, Supercluster_table.ClusterName ) == 1 );
med = state1_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Med_State1;
scs = state1_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Supercluster;
boxplot( med, scs, 'parent',ax_(2) )

query = 'ins4'
searchcells = @(x) ~isempty( regexpi(x,query,'match') )
SCnums = find( cellfun( searchcells, Supercluster_table.ClusterName ) == 1 );
med = state2_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Med_State2;
scs = state2_tbl( find(ismember(state1_tbl.Supercluster,SCnums)==1) , :).Supercluster;
boxplot( med, scs, 'parent',ax_(3) )

query = 'myr'
searchcells = @(x) ~isempty( regexpi(x,query,'match') )
SCnums = find( cellfun( searchcells, Supercluster_table.ClusterName ) == 1 );
med = state2_tbl( find(ismember(state2_tbl.Supercluster,SCnums)==1) , :).Med_State2;
scs = state2_tbl( find(ismember(state2_tbl.Supercluster,SCnums)==1) , :).Supercluster;
boxplot( med, scs, 'parent',ax_(4) )

for i = 1:4; set(ax_(i),'Ylim',[0,80],'TickDir', 'out', 'XGrid', 'on', 'YGrid', 'on'); grid on; end

%%

mycolors = jet(27);
myplot = @(x1,x2,y1,y2) plot((x1./x2),(y1./y2),'ro')
myline = @(x0,x1,y,c) line([x0,x1],[y,y],'color',mycolors(c,:));


%% Where the magic happens

close all
getCol = @(column,mytable) mytable(:, find( cellfun( @numel, regexp( mytable.Properties.VariableNames, column ) ) == 1 ));

newred = [1,0,0];

myplot = @(x,y) plot(x,y,'o','Color',newred,'MarkerFaceColor','w','MarkerSize',12);
% Comment: 'ButtonDownFcn',@mybuttondownfcn does not work in datacursormode

fig = figure('color','k','windowstate','maximized'); 
f = plot(0,0); 
set(gca,'color','k','Xcolor','w','YColor','w','TickDir','out','box','off'); hold on; 

%xVar = 'RatioNState2_to_NState1';
xVar = 'Med_State1';
yVar = 'Med_State2';

x_.RatioNState2_to_NState1 = x_.Nentries_State2./x_.Nentries_State1;
rowfun( myplot, [getCol(xVar,x_), getCol(yVar,x_)] );

% Prepare structure for the figure to receive for tooltips and
% identification
figureDataStruct = struct();
figureDataStruct.figurePosition = [710,1199,815,282];
figureDataStruct.data = x_;
figureDataStruct.raw = rc_obj.lifetimesTable;
figureDataStruct.thisClusterText_table = thisClusterText_table;
figureDataStruct.xVar = xVar;
figureDataStruct.yVar = yVar;
figureDataStruct.metadata.title = 'A table containing all of the summary statistics for 27 clusters from Signe';
figureDataStruct.metadata.date = datestr(now);
figureDataStruct.color = [1,0,0];

set(gcf,'userdata',figureDataStruct);
xlabel( regexprep( xVar, '_', ' ') ); ylabel(  regexprep( yVar, '_', ' ')  )

dcm_obj = datacursormode(fig);
set(dcm_obj,'UpdateFcn',@myupdatefcn);
set(dcm_obj,'enable','on'); 


%% Some other stuff

%%

thisSC=11;
thisCell=2;
thisState=1;
queryLifetimes = @(rc_obj, SC, Cell, State) rc_obj.lifetimesTable( rc_obj.lifetimesTable.Supercluster == thisSC & ...
                        rc_obj.lifetimesTable.Cell == thisCell & ...
                        rc_obj.lifetimesTable.State == thisState, : ).Lifetime
                    
median( log(queryLifetimes( rc_obj, 11, 2, 1 )) )

%%

mycolors = jet(27);
myplot = @(x,y) plot(x,y,'ro')
myline = @(x0,x1,y,c) line([x0,x1],[y,y],'color',mycolors(c,:));

figure; f = plot(0,0); hold on; rowfun( myline, [x(:,6), x(:,8), x(:,7), x(:,1) ] );


% Comparison between Nentries in State1 versus Nentries in State2 (x)
% and comparison between Medians in State1 versus Medians in State2 (y)

figure('color','k','windowstate','maximized'); f = plot(0,0); set(gca,'color','k','Xcolor','w','YColor','w','TickDir','out','box','off'); hold on; rowfun( myplot, [ x_(:,14), x_(:,4), x_(:,17), x_(:,7) ] );
xlabel('Ratio of State 2/State 1 Segments'); ylabel('Median State2/Median State1')
%%

figure('color','k','windowstate','maximized'); f = plot(0,0); set(gca,'color','k','Xcolor','w','YColor','w','TickDir','out','box','off'); hold on; 
rowfun( myplot, [ x_(:,14), x_(:,4), x_(:,17), table(ones(162,1)) ] );
xlabel('Ratio of State 2/State 1 Segments'); ylabel('Median State2')