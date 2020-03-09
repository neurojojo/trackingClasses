function terms_struct = parseFilename( filename )
    
        %terms = {'Sulpiride','D2','ins','ptx','Quinpirole','cyclodextrin','Myr','Lacro'};
        %queries = {'Sulp\w*','\w*D2\w*','\w*ins\w*','ptx\w*','quin\w*','\w*dext\w*','myr\w*','Lacro\w*'};
        
        terms = {'D2','ins','Myr','PTXR','Sulpiride','Quinpirole','Cyclodextrin','Treatment','Lacro'};
        queries = {'\w*D2','\w*ins\w*','myr\w*','ptxr\w*','Sulp\w*','quin\w*','\w*dext\w*','No\sTreat','Lacro\w*'};
        
        if isempty(filename)
           filename = ''; 
        else
            filename = filename{1};
        end
        
        w = warning('off','all');
        % Match terms to queries

        filename = regexprep( filename, '[_|\-|\\]', ' ' );
        
        
        takelast = @(x) regexp(x,'([^,]+)$','match');
        
        % Experimenter's initials
        % First two/three capitolized letters
        myregexp1 = @(x) strjoin( regexp( x, '(?<=[0-9]{6}\s)[A-Z]{2,4}(?=[_|\s])', 'match' ), ',' );

        % Check for imaged object (Gprotein)
        myregexp2_1 = @(x) takelast( strjoin( regexp( x, '(?<=[_|\s|-])G\w*(?=[_|\s|-])', 'match' ), ',' ) );
        % Check for imaged object (arrestin)
        myregexp2_2 = @(x) takelast( strjoin( regexpi( x, '(\w*Arr\w*)', 'match' ), ',' ) );
        % Check for imaged object (subunits)
        myregexp2_3 = @(x) takelast( strjoin( regexpi( x, '(\w*alfa[\s|]\w*)', 'match' ), ',' ) );

        % Check for drugs/mutations/etc
        % (WARNING: This does not necessarily make sense and may not be a stable
        % use case for the regexp string)
        myregexp3 = @(x,term) takelast( strjoin( regexpi( x, sprintf('(?<=[_| |-|\\])%s\w*(?=[_| |-|\\])',term), 'match' ), ',' ) );

        % Check for quantities
        % WILL NOT RETURN more than 5 digits
        % Ex: 99999 ng is maximum, 100000 ng would not pass
        myregexp5 = @(x) strjoin( regexpi(x,'((?<=[\s])[\d]{1,5}[\s]{0,1}[A-Z]g[\s]{0,1}\w*)','match'), ',' );

        % Check for concentrations
        % WILL NOT RETURN more than 5 digits
        myregexp6 = @(x) strjoin( regexpi(x,'((?<=[\s])[\d]{1,5}[\s]{0,1}[A-Z]M[\s]{0,1}\w*)','match'), ',' );
        
        extractCell = @(x) cell2mat(x);
        
        terms_struct.('Experimenter') = myregexp1( filename );
        terms_struct.('Gprotein') = myregexp2_1( filename );
        %terms_struct.('Subunits') = extractCell(myregexp2_3( filename ));
        
        for i = 1:numel(terms)
            tmp = myregexp3( filename, queries{i} );
            if ~isempty(tmp); terms_struct.(terms{i}) = tmp{1};
            else; terms_struct.(terms{i}) = [];
            end
        end
        
        terms_struct.('Quantities') =  myregexp5( filename );
        terms_struct.('Concentrations') = myregexp6( filename );
        
        % Signe specific rules %
        if isempty(terms_struct.('Gprotein')) & isempty(terms_struct.('Myr')); terms_struct.('Gprotein')='Gi1'; end
        if isempty(terms_struct.('Gprotein')) & ~isempty(terms_struct.('Myr')); terms_struct.('Gprotein')='Myr'; end
        
        
end