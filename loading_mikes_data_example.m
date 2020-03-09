% Loading only '180222_MH' data
options.TLD = 'Z:/#BackupMicData';
options.search_folder = '180222_MH';
options.search_subfolder = 'results.mat';
options.optional_args = {'FilesToFind','default','DC1>DC2'};
tic; mikeFolders = findFoldersClass(options); toc;
mikeFolders.collectParameters();

%%
tic; mikeFolders.makeTrackObjs; toc;
tic; mikeFolders.makeSegObjs; toc;
%%
mikeFolders.computeRelativeSegIdx();
mikeFolders.assignNames();

tic; rc_obj = resultsClusterClass( mikeFolders ); toc;
rc_obj.computeClusters( mikeFolders );
%%

[unique_labels,idx_labels,newSuperclusters] = unique( rc_obj.subfoldersTable.Shortname );
newSuperclustersTable = table( unique(newSuperclusters), unique_labels );
newSuperclustersTable.Properties.VariableNames = {'Supercluster','Clustertext'};

rc_obj.clustersTable = sortrows( newSuperclustersTable, 'Supercluster' );
rc_obj.subfoldersTable.Supercluster = newSuperclusters;
writetable( rc_obj.subfoldersTable, 'mh_dec18_rc_subfolderstable_after_mat_import.csv' )

%% 

accumulator_table = struct();

for objectnames = fields( mikeFolders.segs )'
    
    tmp = mikeFolders.segs.( sprintf('%s',objectnames{1}) ).segsTable;
    tmp.segType_letters = repmat(' ', numel(tmp.segType), 1);
    tmp.segType_letters( tmp.segType== 0 ) = 'I';
    tmp.segType_letters( tmp.segType== 1 ) = 'C';
    tmp.segType_letters( tmp.segType== 2 ) = 'D';
    tmp.segType_letters( tmp.segType== 3 ) = 'V';
    tmp.segType_letters( isnan(tmp.segType) == 1 ) = 'N';
    
    mytables = arrayfun( @(x) tmp( tmp.trackIdx == x,:).segType_letters', unique( tmp.trackIdx ), 'UniformOutput', false );

    %fprintf('%s %1.5f\n', objectnames{1}, 100*numel(find( cellfun( @(x) numel(x), cellfun( @(x) regexp( x{1}, 'II' ), mytables , 'UniformOutput', false))==1 )) / size(mytables,1))
    %bad_tracks = cellfun(@(x) or( strcmp(x{1},'E'), isempty(x{1}) ), mytables , 'UniformOutput', true);
    %out = arrayfun( @(x) mytables{x}, find(bad_tracks==0) );

    out = mytables;
    % Use a for loop to create a structure (for now)
    accumulator = struct();

    for i = 1:size(out,1)
           if ~isfield( accumulator, out{i} )
               accumulator.( sprintf('%s',out{i}) ) = 1;
           else
               accumulator.( sprintf('%s',out{i}) ) = accumulator.( sprintf('%s',out{i}) )+1;
           end
    end

    accumulator_tables.(objectnames{1}).dictionaryTable = table( fields( accumulator ), struct2array(accumulator)', 'VariableNames', {'States','Count'} );
    
end

%%

output = [];

for objectnames = fields( mikeFolders.segs )'
    
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