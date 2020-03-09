function output = replaceEntries( input_table, replacement_table_location )
    
    replacement_table = readtable( replacement_table_location, 'delimiter', ';' );
    % Prepare table
    replacement_table(:,1) = rowfun( @(x) regexprep( x, '\s{2,}', ''), replacement_table(:,1) );
    replacement_table(:,2) = rowfun( @(x) regexprep( x, '\s{2,}', ''), replacement_table(:,2) );
    %
    for i = 1:size( replacement_table, 1 )   
        idx = find( cellfun(@isempty ,regexp(input_table, replacement_table(i,:).Original{1})) == 0 );
        if ~isempty(idx); for j = idx'; input_table{j} = replacement_table(i,:).Replacement{1}; end; end
    end

    output = input_table;
    
end

