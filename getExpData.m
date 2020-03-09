function terms_struct = parseFilename( filename, terms )

    % Experimenter's initials
    % First two/three capitolized letters
    myregexp1 = @(x) regexp( x, '(?<=[_|\s])[A-Z]{2,3}(?=[_|\s])', 'match' )

    % Check for G-protein
    myregexp2 = @(x) regexp( x, '(?<=[_|\s|-])G\w*(?=[_|\s|-])', 'match' )

    % Check for drugs/mutations/etc
    % (WARNING: This does not necessarily make sense and may not be a stable
    % use case for the regexp string)
    myregexp3 = @(x,term) regexp( x, sprintf('(?<=[_| |-|\\])%s\w*(?=[_| |-|\\])',term), 'match' )

    terms_struct.('Experimenter') = myregexp1( filename );
    terms_struct.('Gprotein') = myregexp2( filename );
    
    
    for i = 1:numel(terms)
        terms_struct.(sprintf('%s',terms{i})) = myregexp3( filename, terms{i} );
    end
    
    
end