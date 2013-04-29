function progress(ii,total,text1)

if nargin == 2
   text1 = 'Progress: ';
end

ll = numel(text1);
text2 = '';
for i=1:ll
text2=[text2 '\b'];
end

text2 = [text2 '\b\b\b\b\b\b'];
out = [text2 text1 '%2.2f%%'];

fprintf(1,out,(100*ii/total))

end
