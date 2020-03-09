%% Loading data (findFoldersClass)

options.search = '_SM'; options.folder = 'Z:/#BackupMicData';

options.searchTracking=1;
options.optional_args = {'FilesToFind','signe'};
options.FilesToFind='signe'

signeFolders = findFoldersClass(options);
signeFolders.makeTrackObjs
signeFolders.makeSegObjs
signeFolders.makeHMMSegObjs

%% Loading one directory to examine (tracksTableClass)

thisClusterText_table = readtable('thisClusterText_table.csv','HeaderLines',0,'Delimiter',',');

%% Set options for the summary execution

options.thisClusterText_location = 'C:/MATLAB/databaseClasses/thisClusterText_table.csv';
options.Savefolder = 'C:/MATLAB/Outputplots/';
options.Save = 0;
options.Logdata = 1; 

searchterm = 'D2'; mysearch = @(x) numel(regexpi(x{1},sprintf('%s',searchterm)))
SC = find( table2array(rowfun( mysearch, sc_obj.ClusterText ))==1 )

parameter='Median lifetime'
ylims = [0,7];

options.search.State = 2;
options.search.MinTracks = 0;
options.search.SC = [6];
options.search.Cell = [];
options.search.Identifier = 0;

sc_obj = summaryClass( rc_obj, signeFolders, options )
%%
figure('color','w'); boxplot( log(sc_obj.filteredTable.Lifetime), sc_obj.filteredTable.Supercluster, 'Jitter', 1 );
sgtitle( sprintf('%s %s (State %i)',searchterm,parameter,options.search.State) ); ylim(ylims); sc_obj.switchLabels(); camroll(-90); grid on
%if strcmp(searchterm,'myr'); set(gca,'Position',topplot_pos); end
%if strcmp(searchterm,'ins4a'); set(gca,'Position',bottomplot_pos); end
%% Show only compound segments

options.OnlyCompoundSegments = 1; 
options.Logdata = 1; 
options.StateToPlot = 2; 

sc_obj = summaryClass( rc_obj, signeFolders, options ); 
sc_obj.showBoxplot( rc_obj, options );
set(gca, 'XTickLabel', cellfun( switchlabel, curr_labels , 'UniformOutput', false))

%%
options.Logdata = 1; options.VariableToShow = 'State2_Lifetimes'; output.showBoxplot( rc_obj, options );


%% Setting up an ANOVAN

options.Superclusters = [1,2]
output.showBoxplot( rc_obj, options )
 
%%

options.Logdata = 1; output.showBoxplot( rc_obj, options )


%%

options.VariableToShow = 'State1_Lifetimes';
output.showBoxplot( rc_obj, options )

options.VariableToShow = 'State2_Lifetimes';
output.showBoxplot( rc_obj, options )

%%

[~,data] = output.showBoxplot( rc_obj, options )


%%

options.Logdata = 0; options.VariableToShow = 'State1_Lifetimes'; options.Superclusters = [1,2,14,16]; [a,b,c,d,e] = output.showBoxplot( rc_obj, options );

options.Logdata = 0; options.VariableToShow = 'State2_Lifetimes'; options.Superclusters = [1,2,14,16]; [a,b,c,d,e] = output.showBoxplot( rc_obj, options );

options.Logdata = 1; options.VariableToShow = 'State1_Lifetimes'; options.Superclusters = [1,2,14,16]; [a,b,c,d,e] = output.showBoxplot( rc_obj, options );

options.Logdata = 1; options.VariableToShow = 'State2_Lifetimes'; options.Superclusters = [1,2,14,16]; [a,b,c,d,e] = output.showBoxplot( rc_obj, options );

output.showCDFs(rc_obj,options)


%%

options.VariableToShow = 'State1_Lifetimes'; options.Superclusters = [1,2,21,17]; output.showBoxplot( rc_obj, options );
options.VariableToShow = 'State2_Lifetimes'; options.Superclusters = [1,2,21,17]; output.showBoxplot( rc_obj, options );


%%

options.Search = '100 ng'; output.showBoxplot( rc_obj, options )
options.Search = '1200 ng'; output.showBoxplot( rc_obj, options )

%%

%options = rmfield(options,'Search');
options.VariableToShow = 'State1_Lifetimes'; options.Superclusters = [3,4]; output.showBoxplot( rc_obj, options );
options.VariableToShow = 'State2_Lifetimes'; options.Superclusters = [3,4]; output.showBoxplot( rc_obj, options );

%%

options.VariableToShow = 'State1_Lifetimes'; output.showCDFs(rc_obj,options)
%%
options.VariableToShow = 'State2_Lifetimes'; output.showCDFs(rc_obj,options)

%%
options.Superclusters = [16,19]; options.VariableToShow = 'State2_Lifetimes'; output.showBoxplot(rc_obj,options)


%%

rc_obj.getConsolidatedLifetimes( signeFolders )

%% Check that the file exists

diff_coeff = @( tmp, state ) .5 * ( sqrt( -2* tmp.cfg.locerror^2 + tmp.results.ML_params.sigma_emit( state )^2)^2 * tmp.cfg.fs )*tmp.cfg.umperpx^2

for i = 92:size( signeFolders.subfolderTable , 1 );
    
    tmp = load ( signeFolders.subfolderTable(i,:).Name{1} );
    if isfield(tmp,'cfg')
        D(i,1) = diff_coeff( tmp, 1 );
        D(i,2) = diff_coeff( tmp, 2 );
    end
    i
end
