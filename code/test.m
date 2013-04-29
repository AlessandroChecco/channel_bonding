for i=1:numel(p)
    fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bFixing multiple solutions: %2.2f%%',(100*i/numel(p)))
    for j=i+1:numel(p)
        ii = i;
        jj = j;
        if isequal(t(:,ii),t(:,jj)) %&& p(ii)>precision
            p(jj) = p(jj) + p(ii);
            p(ii) = 0;
        end
    end
end