%% Loading data (findFoldersClass)

options.TLD = 'Z:/#BackupMicData';
options.search_folder = '_SM';
options.search_subfolder = 'analysis_output.mat';
options.optional_args = {'FilesToFind','signe'};
tic; signeFolders = findFoldersClass(options); toc;
% Takes about one minute

%%

tic; signeFolders.makeTrackObjs; toc;
tic; signeFolders.makeSegObjs; toc;
tic; signeFolders.makeHMMSegObjs; toc;
tic; signeFolders.switchHMMstates; toc;
tic; signeFolders.patchTracks; toc; % Computes the total number of tracks in a segment (currently only for two state models)
signeFolders.assignNames(); % Currently this use parseFilename which is set up for signe's data

% About 2 minutes per gigabyte
%% Clear out Brownian Tables that aren't good

objects_to_clear = readtable('objects_to_clear.csv');
rowfun( @(x,y) signeFolders.clearTables( x, y{1} ), objects_to_clear, 'NumOutputs', 0, 'ErrorHandler', @(x,y,z) signeFolders.doNothing() )
signeFolders.computeRelativeSegIdx();
signeFolders.collectParameters();

signeFolders.saveTables();
%% Restart rc_obj from here (1/6/2020)

%% Modifications to the folders object

tic; rc_obj = resultsClusterClass( signeFolders ); toc;

%% Handling text
rc_obj.computeClusters( signeFolders );
writetable( rc_obj.subfoldersTable, 'jan6_rc_subfolderstable.csv' )
% Restored an older version of the subfolders table file
rc_obj.subfoldersTable = readtable( 'nov21_rc_subfolderstable_after_mat_import.csv' );

%% Pooling

[unique_labels,idx_labels,newSuperclusters] = unique( rc_obj.subfoldersTable.Shortname );
newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;
writetable( rc_obj.subfoldersTable, 'jan6_rc_subfolderstable_after_mat_import.csv' )

%%

rc_obj.getConsolidatedLifetimes( signeFolders );
rc_obj.computeSegInfo();
rc_obj.makeDiffusionTable( signeFolders );
rc_obj.consolidateSuperclusterLifetimes( signeFolders );

rc_obj.getSequences( signeFolders );

%%
cellfun(@(y) sum( cellfun( @(x) gt(numel(regexp(x{1},y)),0), mytables ) ), {'E','IC','IF','IS','CI','CF','CS','FI','FC','FS','SI','SC','SF'} )

%%

output = [];

for objectnames = fields( mikeFolders.segs )'
    
    % Freely diffusing 
    idx = rowfun(@(x) gt(numel( regexp(x{1},'(CD|ID)') ),0),...
        accumulator_tables.(objectnames{1}).dictionaryTable(:,1),'OutputFormat','uniform');
    d_after_c = sum( accumulator_tables.(objectnames{1}).dictionaryTable( find(idx==true) , 2 ).Count );
    
    idx = rowfun(@(x) gt(numel( regexp(x{1},'(D.*[C]$|D.*[I]$)') ),0),...
        accumulator_tables.(objectnames{1}).dictionaryTable(:,1),'OutputFormat','uniform');
    d_end_c = sum( accumulator_tables.(objectnames{1}).dictionaryTable( find(idx==true) , 2 ).Count );
    
    
    idx = rowfun(@(x) gt(numel( regexp(x{1},'(C.*[D]$|I.*[D]$)') ),0),...
        accumulator_tables.(objectnames{1}).dictionaryTable(:,1),'OutputFormat','uniform');
    c_end_d = sum( accumulator_tables.(objectnames{1}).dictionaryTable( find(idx==true) , 2 ).Count );
    
    output = [output; [d_after_c,d_end_c,c_end_d]];
end

%% Output the lengths
lengths = structfun( @(y) cellfun( @(x) numel(x), y.dictionaryTable.States ), rc_obj.sequencesTable , 'UniformOutput', false);
for objs_ = fields(lengths)'
    rc_obj.sequencesTable.( objs_{1} ).dictionaryTable.Length = lengths.( objs_{1} );
end


%% End of rc_obj loading


%% Start from new
load('C:\MATworkspaces\allfolders_06-Jan-2020.mat'); signeFolders = obj;
load('C:\MATworkspaces\rc_obj_13-Jan-2020.mat '); rc_obj = obj;

%% 
figure('color','w'); hold on;
arrayfun( @(x) plot(signeFolders,8,x,'LineWidth',1), [1:1000] )
set(gca,'XColor','w','YColor','w')

figure('color','w'); hold on;
arrayfun( @(x) plot(signeFolders,8,x,'LineWidth',1), [1:1000] )
set(gca,'XColor','w','YColor','w')


%% Visualizing 2d map

mytable = signeFolders.hmmsegs.obj_5.brownianTable
[x1,y1] = deal( rowfun(@(x) mean(x{1}), mytable.State1(:,{'hmm_xSeg'}) ),...
    rowfun(@(x) mean(x{1}), mytable.State1(:,{'hmm_ySeg'}) ));
[x2,y2] = deal( rowfun(@(x) mean(x{1}), mytable.State2(:,{'hmm_xSeg'}) ),...
    rowfun(@(x) mean(x{1}), mytable.State2(:,{'hmm_ySeg'}) ));

figure; 
subplot(1,2,1); imagesc( (1/numel(x1.Var1))*histcounts2(x1.Var1,y1.Var1,[64,64]) ); axis image; title('State 1 (all segments)')
subplot(1,2,2); imagesc( (1/numel(x2.Var1))*histcounts2(x2.Var1,y2.Var1,[64,64]) ); axis image; title('State 2 (all segments)')
%subplot(1,3,3); imagesc( histcounts2(x2.Var1,y2.Var1,[64,64])./histcounts2(x1.Var1,y1.Var1,[64,64]) ); axis image; title('Odds of State 1 versus State 2 (all segments)');

set(gcf,'position',[55,280,670,330])

