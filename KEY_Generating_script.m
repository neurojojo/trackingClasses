% September 9th, 2019 
% Creating the database for Signe's data
ALLtrackingFilesMap = containers.Map(f.Filename, [1:size(f,1)]);
save('ALLtrackingmap.mat','ALLtrackingFilesMap');

%%
logfile = fopen('loading_9122019','w');

for i = 1:size(signeMATLABtableKey,1)
   
    try
    t = tracksTableClass( signeMATLABtableKey.Filename{i}, signeMATLABtableKey.Key(i,:) ); t.saveTables(t);
    s = segsTableClass(t); t.saveTables(s);
    b = brownianTableClass(s); t.saveTables(b);
    catch
       fprintf(logfile,'Failure %s\n',signeMATLABtableKey.Key(i,:)) 
    end
end

%% Split, if necessary, the Genotype into date and name (if present)

genotype_col = 3;
the_genotypes = signeMATLABtableKey(:,genotype_col);

getdates = @(x) regexp( char( x ),'^\d+','match');
getinits = @(x) regexp( regexp( char( x ),'(?<=\d{6}[\s|_]).*?(?=[_|\s])','match'), '[A-Z]{2,3}','match'); % For categorical variables

%getdiff = @(init_,info_) regexp( info_, sprintf('(?<=%s).*',init_), 'match' ); % Search for everything after initials

dates = rowfun(getdates, the_genotypes, 'OutputVariableNames', 'Date' )
initials = rowfun(getinits, the_genotypes, 'OutputVariableNames', 'Initials' )

%%
newtable = [ dates, initials, the_genotypes ];

for i = 1:size(newtable,1)
   
    t_ = regexprep( char( newtable(i,:).Genotype ), sprintf('%s',char( newtable(i,:).Date{1} ) ), '' );
    t_ = regexprep( t_, char( newtable(i,:).Initials{1}), '');
    t_ = regexprep( t_, '[_]{1,3}','' );
    t_ = regexprep( t_, '[\s]{2,3}',' ');
    newtable(i,:).Genotype = t_;
    
end

%%

signeMATLABtableKey.Date = newtable.Date;
signeMATLABtableKey.Genotype = newtable.Genotype;
signeMATLABtableKey.Initials = newtable.Initials;


%% Sept 17, 2019

save( 'signeMATLABtableKey.mat', 'signeMATLABtableKey' )