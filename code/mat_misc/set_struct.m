function result = set_struct(string_struct,string_field,vector)
% result = set_struct(string_struct,string_field,vector)
% string_struct = name of the struct
% string_field = name of the field
% note apparently it can be simplyfied with [structArray(1:length(array)).fieldname] = cell_array{:};

    sstring = ['''' string_struct  ''''];

    if evalin('caller',['exist(' sstring ',''var'')'])
        F = @(S,h) setfield(S, string_field, h);
        result = arrayfun(F, evalin('caller', string_struct), vector);
    else
        %disp(['creating non existing struct ' string_struct '.' string_field])
        result = struct(string_field,num2cell(vector));
    end
   
    
end
