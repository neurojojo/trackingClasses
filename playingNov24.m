objs = table(unique( rc_obj.lifetimesTable.Obj_Idx ))
mytable = rc_obj.lifetimesTable;
tables_by_idx = rowfun(@(x) mytable(mytable.Obj_Idx==x,:), objs, 'OutputFormat', 'cell');
%% # of 1-length segments and the states they are in
details.title = '# of 1-length segments';
details.xlabel = 'State 1';
details.ylabel = 'State 2';

thisout = cellfun(@(x) x, tables_by_idx, 'UniformOutput',false );

thisout2 = cellfun(@(x) histc(x( eq(x.tracksInSeg,1), : ).State,[1:2])', thisout, 'UniformOutput',false );

thisout2_mat = cell2mat( thisout2 );

figure('color','w'); loglog( thisout2_mat(:,1), thisout2_mat(:,2), 'ro' ); box off;
set(gca,'TickDir','out')
xlabel(details.xlabel); ylabel(details.ylabel); title(details.title);
xlim([0,2000]); ylim([0,2000]); hold on; plot([1,2000],[1,2000],'k--')

%% 

figure('color','w');

mytable = table('Size',[0,3],'VariableNames',{'fraction_1state','lifetimes_1states','lifetimes_switching'},'VariableTypes',{'double','double','double'})

for iterated_obj_table = thisout'
    this_obj_table = iterated_obj_table{1};
    mytracks = unique( this_obj_table.trackIdx ); % Get the indices of the tracks
    mytracks = mytracks( find( histc( this_obj_table.trackIdx, mytracks ) > 1) );
    logical_1state_tracks = eq(1,rowfun( @(x) numel(unique(this_obj_table(this_obj_table.trackIdx == x,:).State)),...
        table(mytracks),'OutputFormat','uniform' ));
    fraction_1state = sum(logical_1state_tracks)/numel(mytracks); % # of 1-state tracks
    lifetimes_1state_tracks = this_obj_table(logical_1state_tracks,:).Lifetime; % # Lifetime of segments from 1-state tracks
    lifetimes_2state_tracks = this_obj_table(~logical_1state_tracks,:).Lifetime; % # Lifetime of segments from 1-state tracks
    mytable = [mytable; table( fraction_1state, mean(lifetimes_1state_tracks), mean(lifetimes_2state_tracks),'VariableNames',{'fraction_1state','lifetimes_1states','lifetimes_switching'}) ];
end
%tables_by_idx = rowfun(@(x) mytable(mytable.Obj_Idx==x,:), objs, 'OutputFormat', 'cell');

%% Plot state1 and state2
figure('color','w');
Nbins = [24,24];

mytable = signeFolders.hmmsegs.obj_147.brownianTable
output = rowfun( @(x,y) [mean(x{1}),mean(y{1})], mytable.State1(:,{'hmm_xSeg','hmm_ySeg'}));
N1 = histcounts2( output.Var1(:,1), output.Var1(:,2), Nbins );
subplot(1,3,1); imagesc(N1); set(gca,'XTick',[],'YTick',[]);

output = rowfun( @(x,y) [mean(x{1}),mean(y{1})], mytable.State2(:,{'hmm_xSeg','hmm_ySeg'}));
N2 = histcounts2( output.Var1(:,1), output.Var1(:,2), Nbins );
subplot(1,3,2); imagesc(N2); set(gca,'XTick',[],'YTick',[]);

N3 = N2./N1;
subplot(1,3,3); imagesc(N3); set(gca,'XTick',[],'YTick',[]);
