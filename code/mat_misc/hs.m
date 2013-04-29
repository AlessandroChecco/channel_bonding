%HS		search the command history for patterns
%		HS searches the command history file for entries
%		containing a specific pattern using the
%		regular regular expression (REX) engine.
%		the results are displayed in the command window in
%		the format
%				#entry location: line
%		clicking the location will open the history file at
%		this line;
%		clicking the line will copy/paste the contents of the
%		line to the command prompt; return with [ENTER].
%
%		see also: regexp, prefdir
%
%SYNTAX
%-------------------------------------------------------------------------------
%		    HS    P
%		    HS -i P
%		R = HS(P)
%		R = HS('-i',P)
%
%INPUT
%-------------------------------------------------------------------------------
% -i	:	case insensitive search [must(!) be first argument]
%  P	:	a valid REX search pattern built by concatenation of all
%		input arguments seperated by one SPACE character
%		   HS arg1 arg2 ... argN   => P = 'arg1 arg2 ... argN'
%		use \s+ between words to not miss possible other/multiple
%		whitespace character(s), eg, tabs
%		   HS arg1\s+arg2 ... argN => P = 'arg1\s+arg2 ... argN'
%		use 'P' if the pattern contains valid MATLAB syntax, eg,
%		   HS (a)|(b)		   => HS '(a)|(b)'
%		   HS %--		   => HS '%--'
%
%OUTPUT
%-------------------------------------------------------------------------------
% R	:	search results
%
%EXAMPLE
%-------------------------------------------------------------------------------
% %		fill the command history with some nonsense
%		v='CSSM is a NG';
%		vv='a great NG: CSSM';
%		abc___xyz=magic(4);
%		xyz___abc=rand(3);
%		abc___xyz=magic(4)
%
%		hs -i cssm is [ab]+
% %		1 history.m:2476: v='CSSM is a NG';
%		
%		hs '(abc[_]{3,3})|(xyz[_]{3,3})'
% %		1 history.m:2477: abc___xyz=magic(4);
% %		2 history.m:2478: xyz___abc=rand(3);
% %		3 history.m:2479: abc___xyz=magic(4);
%
% %		click the last location entry to open the history file
% %		at line #2479
% %		click the last line entry to copy/paste the command to
% %		the command prompt; rerun again with [ENTER]
%		abc___xyz

% created:
%	us	14-Aug-2006 us@neurol.unizh.ch
% modified:
%	us	21-Apr-2009 21:38:10

%-------------------------------------------------------------------------------
function	p=hs(varargin)

		pd=[prefdir,'/history.m'];
		ropt={
			'-pref'		% disable user defined def options
			'-n'		% precede matches by line # in file
			'-N'		% enumerate matches
%			'-l'		% print name of file
%			'-mp'		% look for all files found in ML's path
%			'-exe'		% make matches executable
			'-cp'		% copy/paste matches
			'-R'		% use REX engine
			'-ix'		% case insensitive search
			'-e'		% search literal pattern
		};

	if	~nargin
		help(mfilename);
	if	nargout
		p='';
	end
		return;
	else
		arg=varargin;
	end

	if	nargin > 1				&&...
		isnumeric(varargin{1})
		GREP_copypaste(varargin{2});
		return;
	end

% case insensitive search [-i]
	if	nargin > 1				&&...
		strcmp(arg{1},'-i')
		ropt(end-1)=arg(1);
		arg(1)=[];
	end

% concatenate args into one string
		arg=sprintf('%s ',arg{:});
		arg(end)='';

		[p,p]=grep(ropt{:},{arg},pd);

	if	~nargout
		clear	p;
	else
		p=p.match;
	end	
end
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%	GREP
%	created:
%		us	14-Jan-1987	us@neurol.unizh.ch
%	note:
%		this utility is inserted by SSC (us) removing all comments
%		this utility is available on the FEX at
%		http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=9647&objectType=FILE
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%$SSC_INSERT_BEG   21-Apr-2009/21:38:10   F:/usr/matlab/unix/grep.m
% SSC automatic file insertion utility
%     - us@neurol.unizh.ch [ver 06-Nov-2008/21:09:02]
%     - all empty spaces and comments are stripped for brevity
%     - original code available upon request
function	[pout,p]=grep(varargin)
	if	nargin > 1				&&...
		isnumeric(varargin{1})
		GREP_copypaste(varargin{2});
		return;
	end
		ver='21-Apr-2009 21:25:51';
		tim=clock;
		F=false;
		T=true;
		com='command line';
		memupd=2^14;
		fmtexe= {'<a href="matlab:%s">%s</a>'};
		fmtcp=	{['<a href="matlab:',mfilename,'(0,[''%s''])">%s</a>']};
		fmtopen={'<a href="matlab:opentoline(''%s'',%-1d)">%s</a>: %s'};
		deot= {' '};
		dspc=8;
	optiontable={
	'-c'		F	0	[]	F	'count matches'
	'-cp'		F	0	[]	F	'copy/paste match'
	'-bs'		F	1	{inf}	F	'buffer size'
	'-D'		F	0	[]	F	'major proc steps'
	'-d'		F	0	[]	F	'minor proc steps'
	'-da'		F	0	[]	F	'show all ouput including proc steps'
	'-e'		F	1	{}	T	'pattern list'
	'-exe'		F	0	[]	F	'make matches executable'
	'-f'		F	1	com	F	'pattern file'
	'-fp'		F	0	[]	F	'show full path'
	'-Id'		F	1	{}	T	'only include folders with one matching token'
	'-If'		F	1	{}	T	'only include files with one matching token'
	'-Ip'		F	1	{}	T	'only include full paths with one matching token'
	'-i'		F	0	[]	F	'ignore case'
	'-l'		F	0	[]	F	'print file name'
	'-mp'		F	0	[]	F	'add files found by WHICH to search'
	'-N'		F	0	[]	F	'enumerate matches for each file'
	'-Na'		F	0	[]	F	'enumerate all matches'
	'-Nf'		F	0	[]	F	'enumerate files'
	'-Np'		F	0	[]	F	'show index of matching pattern'
	'-n'		F	0	[]	F	'print line number'
	'-pref'		F	0	[]	F	'disable user defined preferences'
	'-Q'		F	0	[]	F	'no file name prefix'
	'-R'		F	0	[]	F	'regular expression engine'
	'-r'		F	0	[]	F	'search in subfolders'
	'-rng'		F	2	[0,0]	F	'show surrounding lines'
	'-S'		F	0	[]	F	'silent mode except error msg: save runtime output'
	'-s'		F	0	[]	F	'silent mode except error msg: only collect data'
	'-t'		F	0	[]	F	'text search'
	'-u'		F	0	[]	F	'does not produce underlined text'
	'-V'		F	0	[]	F	'print file before search'
	'-v'		F	0	[]	F	'print non-matching lines'
	'-Xd'		F	1	{}	T	'exclude folders with matching token'
	'-Xf'		F	1	{}	T	'exclude files with matching token'
	'-Xp'		F	1	{}	T	'exclude full paths with matching token'
	'-x'		F	0	[]	F	'complete match'
	'-dt'		F	1	[]	F	'GREP: detab output'
	'-fmtexe'	F	1	fmtexe	F	'GREP: exe format'
	'-fmtcp'	F	1	fmtcp	F	'GREP: copy/paste format'
	'-fmtopen'	F	1	fmtopen	F	'GREP: open format'
	'-memupd'	F	1	memupd	F	'GREP: memory allocation steps'
	'-EOT'		F	1	deot	F	'DETAB: EOT character'
	'-TAB'		F	1	dspc	F	'DETAB: SPACES/TAB'
	};
	if	nargout
		pout=[];
	end
		p=GREP_ini_grep(ver,tim,varargin{:});
		[p,msg]=GREP_set_opt(optiontable,p,p.defopt,varargin{:});
	if	~isempty(msg)
	if	nargin==1
		p=GREP_show_res(100,p,msg);
	end
	if	nargout
		pout=p;
	end
		return;
	end
		p.npat=p.opt.ns;
		p.pattern=p.opt.pattern(:);
		p.porigin=p.opt.f.val;
		p.pfound=zeros(p.npat,1);
		p.pfindex=cell(p.npat,1);
	if	p.opt.t.flg
		p=GREP_get_string(p);
	else
		p=GREP_show_res(-100,p,sprintf('GREP> searching folders    ...'));
		t1=clock;
		p=GREP_get_folders(p);
		p.runtime(2)=etime(clock,t1);
		p=GREP_show_res( -99,p,sprintf('GREP> done %13.3f   %d folders',p.runtime(1),p.nfolder));
	if	p.nfolder
		p=GREP_show_res( -98,p,sprintf('GREP> searching files      ...'));
		t1=clock;
		p=GREP_get_files(p);
		p.runtime(3)=etime(clock,t1);
		p=GREP_show_res( -97,p,sprintf('GREP> done %13.3f   %d files',p.runtime(2),p.nfiles));
	end
	end
	if	nargout
	if	p.opt.t.flg
		pout=p.match;
	else
		pout=unique(p.files);
	end
	end
		p=GREP_ini_grep(p);
end
function	p=GREP_xhelp(p,fnam,tag)
		[fp,msg]=fopen(which(fnam),'rt');
	if	fp > 0
		hs=fread(fp,inf,'*char').';
		fclose(fp);
		ib=strfind(hs,tag);
	if	isempty(ib)	||...
		numel(ib)<2
		hs=sprintf('GREP> help sectio <%s> not found/not valid',tag);
	else
		hs=hs(ib(end-1)+length(tag)+1:ib(end)-1);
		hs=strrep(hs,p.par.hdel,'');
	end
	else
		hs=sprintf('%s: <%s>',msg,fnam);
	end
		disp(hs);
end
function	p=GREP_ini_grep(ver,tim,varargin)
	if	isstruct(ver)
		p=ver;
		p=GREP_update(0,p);
		tim=p.par.tim;
		p.nxfolder=p.par.chkex(1);
		p.nxfiles=p.par.chkex(2);
		p.nafolder=p.nfolder+p.nxfolder;
		p.nafiles=p.nfiles+p.nxfiles;
		p.mdepth=max(p.fdepth);
	if	~isempty(p.result)
		p.result=char(p.result);
	end
	if	~p.opt.D.flg	&&...
		~p.opt.d.flg
		p=rmfield(p,'par');
	end
		p.runtime(1)=etime(clock,tim);
		return;
	end
		magic='GREP';
		fsep='/';
		par.tab=sprintf('\t');		% 009 = TAB: horizontal tab
		par.cr=sprintf('\r');		% 013 =  CR: carriage return
		par.lf=sprintf('\n');		% 010 =  LF: line feed
		par.ptab=[];			% DETAB parameters
		par.rxopt={			% rex engine parameters
			'lineanchors'
			'dotexceptnewline'
		};
		par.wcopt='*?';			% wildcards
		par.fsep=fsep;
		par.isold=0;
		par.nbytes=0;
		par.nlines=0;
		par.mfc=1;
		par.mlc=1;
		par.memupd=[];
		par.afc=0;
		par.alc=0;
		par.clc=1;
		par.cd=[];
		par.cf=[];
		par.cfn=0;
		par.cn=[];
		par.cs=[];
		par.csn=0;
		par.s=[];
		par.eol=[];
		par.str='<>';
		par.chkpath=false;		% true if I[]/X[] flags are set
		par.chkex=[0,0];
		par.hasmatch=false;
		par.nmatch=0;
		par.rng=[];
		par.hdel='%$';
		par.comt=[];
		par.reft=[];
		par.prefopt='-pref';
		par.tim=tim;
		p.magic=magic;
		p.ver=ver;
		p.mver=version;
		p.mrel=sscanf(version('-release'),'%d');
		p.rundate=datestr(tim);
		p.runtime=[0,0,0];
		oopt={};
		sopt=getpref;
	if	~isempty(sopt)
	if	isfield(sopt,'grep')		&&...
		isfield(sopt.grep,'opt')
		oopt=sopt.grep.opt;
	elseif	isfield(sopt,'GREP')		&&...
		isfield(sopt.GREP,'opt')
		oopt=sopt.GREP.opt;
	end
	end
		p.defopt=oopt;
		p.opt={};
		p.msg=[];
		p.par=par;
		p.section_1='===== FOLDERS  =====';
		p.nfolder=0;
		p.nxfolder=0;
		p.nafolder=0;
		p.folder{1,1}=[];
		p.fenum=[];
		p.mdepth=0;
		p.fdepth(1,1)=0;
		p.section_2='===== PATTERNS =====';
		p.npat=0;
		p.pattern={};
		p.porigin={};
		p.pfound=[];
		p.pfindex={};
		p.section_3='===== FILES    =====';
		p.nfiles=0;
		p.nxfiles=0;
		p.nafiles=0;
		p.nbytes=0;
		p.nlines=0;
		p.section_4='===== MATCHES  =====';
		p.mfiles=0;
		p.mbytes=0;
		p.mlines=0;
		p.pfiles=0;
		p.pcount=0;
		p.ufiles={};
		p.files={};
		p.lcount=[];
		p.findex=[];
		p.pindex=[];
		p.line=[];
		p.match={};
		p.result={};
end
function	[p,msg]=GREP_set_opt(otbl,p,defopt,varargin)
		o=[];
		msg=[];		%#ok MLINT 2006a
		o.des1='===== OPTIONS =====';
	for	i=1:size(otbl,1)
		fn=otbl{i,1}(2:end);
		o.(fn).flg=otbl{i,2};
		o.(fn).acc=otbl{i,5};
		o.(fn).des=otbl{i,6};
		o.(fn).def=otbl{i,4};
		o.(fn).val=otbl{i,4};
	end
		p.opt=o;
		argn=numel(varargin);
	if	argn < 2
	if	~argn
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	elseif	numel(varargin{1}) > 1
	switch	lower(varargin{1}(1:2))
	case	{'-p'}
		GREP_xhelp(p,mfilename,'___FORMAT___');
		msg=true;
	case	{'-e'}
		GREP_xhelp(p,mfilename,'___EXAMPLE___');
		msg=true;
	case	{'-f'}
		GREP_xhelp(p,mfilename,'___OUTPUT___');
		msg=true;
	otherwise
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	end
	else
		help(mfilename);
		msg=sprintf('GREP> needs at least two arguments');
	end
		return;
	end
		lst=GREP_get_arg(otbl,varargin{:});
	if	~isempty(defopt)
	if	lst.argn == 1	&&...
		strcmp(lst.ic(1),p.par.prefopt)
		msg=sprintf('GREP> needs at least two arguments');
		return;
	elseif	~strcmp(lst.ic(1),p.par.prefopt)
		lst=GREP_get_arg(otbl,defopt{:},varargin{:});
	end
	end
		no=numel(lst.ox);
		olst=cell(no,3);
	for	i=1:no
		ix=lst.ox(i);
		olst(i,:)={otbl{ix,1},lst.ax(i),ix};
		fn=otbl{ix,1}(2:end);
		o.(fn).flg=xor(otbl{ix,2},1);
	if	otbl{ix,3} > 0
		vx=lst.ax(i)+1:lst.ax(i)+otbl{ix,3};
	if	vx(end) <= lst.argn
	if	o.(fn).acc
	if	~iscell(lst.ic(vx))
		lst.ic(vx)={lst.ic(vx)};
		o.(fn).val=[o.(fn).val;{lst.ic(vx)}];
	else
		o.(fn).val=[o.(fn).val,lst.ic{vx}];
	end
	else
		o.(fn).val=lst.ic(vx);
	end
	else
		o.(fn).flg=otbl{ix,2};
		msg=sprintf('GREP> parameters missing for option <%s> [%-1d]',...
				otbl{ix,1},otbl{ix,3});		%#ok MLINT 2006a
	end
	end
	end
		p.opt=o;
		mval=o.memupd.val;
	if	o.memupd.flg
	if	iscell(mval)
	if	ischar(mval{:})
		mval=sscanf(mval{:},'%d');
	else
		mval=mval{:};
	end
	end
	if	isempty(mval)	||...
		isinf(mval)	||...
		mval~=mval
		msg='GREP> -memupd: invalid memory allocator';
		return;
	end
	end
		p.par.memupd=abs(mval(1));
		p=GREP_update(-1,p);
		msg='GREP> -rng: invalid format/values';
		rng=[0,0];
		trng=o.rng.val;
	if	o.rng.flg
	if	iscell(trng)
	for	i=1:2
		trng=o.rng.val{i};
	if	ischar(trng)
	try
		[rng(i),cnt]=sscanf(trng,'%d');
	if	~cnt
		return;
	end
	catch						%#ok	pre-2008a
		return;
	end
	else
		rng(i)=trng;
	end
	end
	else
		rng=o.rng.val;
	end
	if	any(isinf(rng))	||...
		any(rng~=rng)
		msg=[msg,' [NaN|Inf]'];
		return;
	end
	end
		p.par.rng=fix(abs(rng));
		msg='GREP> -bs: invalid buffer size';
		tbs=o.bs.val;
	if	o.bs.flg
	if	iscell(tbs)
		tbs=tbs{:};
	end
	if	ischar(tbs)
	try
		[tbs,cnt]=sscanf(tbs,'%f');
	catch						%#ok	pre-2008a
		return;
	end
	if	cnt < 1
		tbs=inf;
	end
	end
	else
		tbs=o.bs.val{1};
	end
		msg=[];
		o.bs.val=abs(tbs);
	if	o.Id.flg	||...
		o.If.flg	||...
		o.Ip.flg	||...
		o.Xd.flg	||...
		o.Xf.flg	||...
		o.Xp.flg
		p.par.chkpath=true;
	end
		o.des2='===== INPUT =====';
		o.alst=[lst.ic;'*****CELL*****'];
		o.olst=olst;
		o.ns=0;
		o.pattern=varargin{end-1};
		o.nf=0;
		o.fclass='c';
		o.ftype='f';
		o.files=varargin{end};
		o.fpat={};
		o.fnam={};
		o.fext={};
		o.npat=0;
		o.xpat=0;
		o.upat=0;
	if	~iscell(o.pattern)
		o.pattern={o.pattern};
	end
	if	o.e.flg
		o.pattern=o.e.val;
	end
	if	o.f.flg
	if	iscell(o.f.val{1})
		o.f.val{1}=o.f.val{1}{:};
	end
		pnam=o.f.val{1};
	if	exist(pnam,'file')
		o.pattern=textread(pnam,'%s','delimiter','\n','whitespace','');
	else
		msg=sprintf('GREP> pattern file not existing <%s>',pnam);
	end
	end
		o.ns=numel(o.pattern);
	if	~iscell(o.files)
		o.fclass='s';
		o.alst(end)={'*****STRING*****'};
		o.files={o.files};
	end
	if	o.mp.flg
		of=o.files;
		o.files={};
		fmp={};
		wc=0;
	for	i=1:numel(of)
		wfile=which(of{i},'-all');
	if	~isempty(wfile)
		wc=wc+1;
		fmp{wc,1}=wfile;			%#ok
	else
		wc=wc+1;
		fmp{wc,1}=of(i);			%#ok
	end
	end
		o.files=[o.files,fmp(:).'];
		o.files=cat(1,o.files{:});
	end
		o.ns=numel(o.pattern);
		o.nf=numel(o.files);
	if	~o.t.flg
	for	i=1:o.nf
	if	isempty(o.files{i})
		o.files{i}=[cd,p.par.fsep,'*.*'];
	end
	if	o.files{i}(end)=='/'	||...
		o.files{i}(end)=='\'
		o.files{i}=o.files{i}(1:end-1);
	end
		o.fpat{i}=o.files{i};
		o.fnam{i}='*.*';
		o.fext{i}='.*';
	if	strcmp(o.fpat{i},'.')
		o.fpat{i}=cd;
	end
	if	~exist(o.files{i},'dir')
		[o.fpat{i},o.fnam{i},o.fext{i}]=fileparts(o.files{i});
	if	isempty(o.fpat{i})
		o.fpat{i}=cd;
	end
	if	isempty(o.fnam{i})
		o.fnam{i}='*';
	end
	if	isempty(o.fext{i})
		o.fext{i}='.*';
	end
		o.fnam{i}=[o.fnam{i},o.fext{i}];
	end
	end
		o.npat=0;
		o.xpat=1;
		o.upat=1;
		[o.fpat,ix]=sort(o.fpat(:));
		o.files=o.files(ix);
		o.fnam=o.fnam(ix);
		o.fext=o.fext(ix);
		[o.npat,o.npat,o.xpat]=unique(o.fpat);
		o.npat=numel(o.npat);
		o.upat=find([1;diff(o.xpat)]>0);
	else
		o.ftype='s';
		o.files=o.files(:).';
		o.fpat={'command line'};
		o.fnam={'<string>'};
	end
	if	o.exe.flg	||...
		o.cp.flg	||...
		o.dt.flg
		p.par.ptab=GREP_ini_detab(o);
	end
	if	o.cp.flg
	if	~usejava('jvm')
		disp(sprintf('GREP> the [-cp] option requires JAVA to run'));
		o.cp.flg=false;
	else
		o.exe.flg=false;
	end
	end
		p.par.comt=o.fmtexe.val{:};
		p.par.cpt=o.fmtcp.val{:};
		p.par.reft=o.fmtopen.val{:};
		p.opt=o;
end
function	lst=GREP_get_arg(otbl,varargin)
		pat=sprintf('GREP>ARG|%20.19f[',rand);
		arg=varargin(1:end-1);
		ic=cellfun(@(x) [pat,class(x),']'],arg,'uniformoutput',false);
		il=cellfun('isclass',arg,'char');
		ic(il)=arg(il);
		ic=sprintf('%s ',ic{:});
		ic=strread(ic,'%s');
		[ox,io]=ismember(ic,otbl(:,1));		%#ok MLINT 2006a
		lst.ox=io(io>0);
		lst.ax=find(io);
		lst.argn=numel(ic);
		iv=strfind(ic,pat);
		lst.iv=~cellfun('isempty',iv);
		lst.ic=ic;
		lst.ic(lst.iv)=arg(~il);
end
function	p=GREP_get_folders(p)
	for	i=1:p.opt.npat
		cf=p.opt.fpat{p.opt.upat(i)};
		cf=strrep(cf,filesep,p.par.fsep);
		p=GREP_get_folder(p,cf,cf,0,i);
	end
end
function	p=GREP_get_folder(p,frot,crot,depth,ix)
	if	~depth
		p=GREP_show_res(-10,p,sprintf('GREP> folder              <%s>',frot));
	if	exist(frot,'dir')
		[tf,p]=GREP_chk_path(1,p,frot,'***FOLDER***');
	if	tf
		p.nfolder=p.nfolder+1;
		p.folder{p.nfolder,1}=strrep(frot,filesep,p.par.fsep);
		p.fenum(p.nfolder,1)=ix;
	end
	else
		msg=sprintf('GREP> folder not found <%s>',frot);
		p=GREP_show_res(100,p,msg);
	end
	end
	if	~p.opt.r.flg
		return;
	end
		rd=dir(crot);
		rx=[rd.isdir]==1;
		rd=rd(rx);
		nd=numel(rd);
	for	i=1:nd
	if	rd(i).isdir && rd(i).name(1) ~= '.'
	if	~isempty(crot)
		nrot=[crot,p.par.fsep,rd(i).name];
	else
		nrot=rd(i).name;
	end
		nrot=strrep(nrot,filesep,p.par.fsep);
		[tf,p]=GREP_chk_path(1,p,nrot,'***SUBFOLDER***');
	if	tf
		p.nfolder=p.nfolder+1;
		depth=depth+1;
		p.fdepth(p.nfolder,1)=depth;
		p.folder{p.nfolder,1}=strrep(nrot,filesep,p.par.fsep);
		p.fenum(p.nfolder,1)=ix;
		p=GREP_show_res(-9,p,sprintf('- subfolder %5d/%6d  <%s>',depth,p.nfolder,nrot));
		p=GREP_get_folder(p,frot,nrot,depth,ix);
		depth=depth-1;
	end
	end
	end
	if	~depth
		p.par.isold=0;
	end
end
function	p=GREP_get_files(p)
	for	i=1:p.opt.nf
		cn=p.opt.fnam{i};
		fx=find(p.fenum==p.opt.xpat(i));
		cp=p.folder(fx);
	for	j=1:numel(fx)
		p.par.cd=cp{j};
		p=GREP_show_res(-8,p,sprintf('GREP> files %5d/%7d <%s:%s>',i,j,p.par.cd,cn));
		d=dir([p.par.cd,p.par.fsep,cn]);
	if	~isempty(d)
	for	k=1:numel(d)
	if	~d(k).isdir
		p.par.cfn=p.par.cfn+1;
		p.par.cf=[p.par.cd,p.par.fsep,d(k).name];
		p.par.cn=d(k).name;
		[tf,p]=GREP_chk_path(2,p,p.par.cf,p.par.cn);
	if	tf
		p=GREP_show_res(-7,p,sprintf('- file	  %7d/%7d <%s>',k,numel(d),p.par.cf));
		p=GREP_get_file(p);
	end
	end
	end
	end
	end
	end
end
function	p=GREP_get_file(p)
		[fp,msg]=fopen(p.par.cf,'rb');
	if	fp < 0
		msg=sprintf('GREP> cannot open file <%s>\nGREP> %s',p.par.cf,msg);
		p=GREP_show_res(100,p,msg);
	else
		[p.par.s,p.par.nbytes]=fread(fp,p.opt.bs.val,'*char');
		p.par.s=p.par.s.';
		fclose(fp);
	if	ispc
		p.par.s=strrep(p.par.s,[p.par.cr,p.par.lf],p.par.lf);
	end
		p.par.s=strrep(p.par.s,char(0),'^');
		p=GREP_show_res(2,p);
		p=GREP_get_match(p);
	end
end
function	[tf,p]=GREP_chk_path(mode,p,fnam,frot)
		tf=true;
	if	~p.par.chkpath
		return;
	end
		ixi=true;
		ixe=false;
	switch	mode
	case	1
		smode='FOLDER';
	if	p.opt.Id.flg
		ix=regexp(fnam,p.opt.Id.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xd.flg
		ix=regexp(fnam,p.opt.Xd.val);
		ixe=any(~cellfun('isempty',ix));
	end
	end
	case	2
		smode='FILE';
	if	p.opt.If.flg
		ix=regexp(frot,p.opt.If.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xf.flg
		ix=regexp(frot,p.opt.Xf.val);
		ixe=any(~cellfun('isempty',ix));
	end
	if	~ixe
		smode='PATH';
	if	p.opt.Ip.flg
		ix=regexp(fnam,p.opt.Ip.val);
		ixi=any(~cellfun('isempty',ix));
	end
	if	ixi
	if	p.opt.Xp.flg
		ix=regexp(fnam,p.opt.Xp.val);
		ixe=any(~cellfun('isempty',ix));
	end	% does not match PATH Xp
	end	% does not macht PATH Ip
	end	% does not match FILE Xf
	end	% does not match FILE If
	end	% switch
	if	~ixi		||...
		ixe
		p.par.chkex(mode)=p.par.chkex(mode)+1;
		p=GREP_show_res(-50,p,sprintf('* exclude %7.7s         <%s>',smode,fnam));
		tf=false;
	end
end
function	p=GREP_get_string(p)
		p.opt.u.flg=true;
		s=p.opt.files;
	if	p.opt.fclass == 'c'
		ss=s;
		ix=[0,cumsum(cellfun('length',s)+1)];
		s=zeros(1,ix(end),'uint8');
		ix=ix+1;
	for	i=1:numel(ix)-1
		s(ix(i):ix(i+1)-2)=ss{i};
	end
		s(ix(2:end)-1)=p.par.lf;
		s=char(s);
	elseif	p.opt.fclass == 's'
		s=char(s{:});
		is=size(s);
		s=[s,repmat(p.par.lf,is(1),1)];
		s=reshape(s.',1,[]);
	end
		ix=strfind(s,p.par.lf);
		eol=ix;
		ix=strfind(s,p.par.cr);
		eol=[eol,ix];
		eol=[0,sort(eol),max(eol)+1];
		p.par.s=s;
		p.par.cn=p.par.str;
		p.par.cf=p.par.str;
		p=GREP_get_match(p,eol);
end
function	p=GREP_get_match(p,eol)
		p.par.hasmatch=false;
		s=p.par.s;
		p.par.clc=1;
	if	p.opt.i.flg
		s=lower(s);
	end
	if	nargin == 1
		p.par.eol=[0,strfind(s,p.par.lf),numel(s)+1];
	else
		p.par.eol=eol;
	end
		p.par.nlines=numel(p.par.eol)-2;
		p.nfiles=p.nfiles+1;
		p.nbytes=p.nbytes+p.par.nbytes;
		p.nlines=p.nlines+p.par.nlines;
	for	j=1:p.opt.ns
		p.par.csn=j;
		str=p.opt.pattern{j};
		strl=numel(str);
	if	p.opt.i.flg
		str=lower(str);
	end
		p.par.cs=str;
	if	p.opt.R.flg
		ix=regexp(s,str,p.par.rxopt{:});
	else
		ix=strfind(s,str);
	end
		p.par.nmatch=0;
	if	~isempty(ix)
		[lx,lx]=histc(ix,p.par.eol);	%#ok MLINT 2006a
		lx=lx(find([diff(lx),1]));	%#ok MLINT 2006a
	if	p.opt.v.flg
		tl=1:numel(p.par.eol)-2;
		ll=tl~=0;
		ll(lx)=false;
		lx=tl(ll);
	end
		nx=numel(lx);
	if	nx
		p=GREP_show_res(-2,p,lx,0);
		lm=lx;
		lb=lx;
	if	p.opt.rng.flg
		rng=p.par.rng;
		lt=ones(rng(1)+rng(2)+1,nx);
		lt(1,:)=lx-rng(1);
		lt=cumsum(lt,1);
		lm=zeros(size(lt),'int8');
		lm(1:rng(1),:)=1;
		lm(rng(1)+1,:)=2;
		lm(rng(1)+2:end,:)=3;
		lm(lt<=0)=-1;
		lm(lt>p.par.nlines)=-1;
		lt=lt(:).';
		lm=lm(:).';
		lt=lt(lm~=-1);
		lm=lm(lm~=-1);
		lb=[diff(lm)<0,false];
		lx=lt;
		nx=numel(lx);
	end
		
	for	i=1:nx
		sx=p.par.eol(lx(i))+1:p.par.eol(lx(i)+1)-1;
		nl=lx(i);
		nm=p.par.s(sx);
	if	~p.opt.x.flg	||...
		numel(sx)==strl
		p.par.nmatch=p.par.nmatch+1;
		p=GREP_show_res(3,p,nl,nm,lm(i),lb(i));
	if	~p.opt.c.flg	||...
		i==1
		p=GREP_update(3,p,nl,nm);
	end
	end
	end	% each	match
	end	% found match
	end	% found matches
	if	p.par.nmatch
		p.par.hasmatch=true;
		p.pfiles=p.pfiles+1;
		p.pcount=p.pcount+nx;
		p.pfound(j)=p.pfound(j)+nx;
		p.pfindex(j)={[p.pfindex{j},p.mfiles+1]};
		p.files(p.pfiles,1)={p.par.cf};
		p.ufiles(p.mfiles+1,1)={p.par.cf};
		p.lcount(p.pfiles,1)=nx;
		p.findex=[p.findex;repmat(p.pfiles,nx,1)];
		p.pindex=[p.pindex;repmat(j,nx,1)];
	if	p.opt.c.flg
		p=GREP_show_res(4,p);
	end
	end
	end	% for each <string>
	if	p.par.hasmatch
		p.mfiles=p.mfiles+1;
		p.mbytes=p.mbytes+p.par.nbytes;
		p.mlines=p.mlines+p.par.nlines;
	end
end
function	p=GREP_update(mode,p,varargin)
persistent	line match result
	switch	mode
	case	3
	if	p.par.alc <= p.par.mlc
		line=[line;zeros(p.par.memupd,1)];
		match=[match;cell(p.par.memupd,1)];
		p.par.alc=p.par.alc+p.par.memupd;
	end
		line(p.par.mlc,1)=varargin{1};
		match(p.par.mlc,1)={varargin{2}};
		p.par.mlc=p.par.mlc+1;
		p.par.clc=p.par.clc+1;
		return;
	case	4
	if	p.par.afc <= p.par.mfc
		result=[result;cell(p.par.memupd,1)];
		p.par.afc=p.par.afc+p.par.memupd;
	end
		result(p.par.mfc,1)={varargin{1}};
		p.par.mfc=p.par.mfc+1;
		return;
	case	-1
		line=zeros(p.par.memupd,1);
		match=cell(p.par.memupd,1);
		result=cell(p.par.memupd,1);
		p.par.alc=p.par.alc+p.par.memupd;
		p.par.afc=p.par.afc+p.par.memupd;
		return;
	case	0
		p.line=line(1:p.par.mlc-1);
		p.match=match(1:p.par.mlc-1);
		p.result=result(1:p.par.mfc-1);
		return;
	end
end
function	p=GREP_show_res(mode,p,varargin)
		if	p.opt.da.flg
			p=GREP_show_entry(mode,p,varargin{:});
			return;
		end
		if	p.opt.s.flg	&&...
			mode < 100
			return;
		else
		if	mode < -10
		if	~p.opt.D.flg	&&...
			~p.opt.d.flg
			return;
		end
		elseif	mode < 0
		if	~p.opt.d.flg
			return;
		end
		end
		end
			p=GREP_show_entry(mode,p,varargin{:});
end
function	p=GREP_show_entry(mode,p,varargin)
			str=[];
			txt=[];		%#ok MLINT 2006a
			ref=[];
			des='->+';
	if	p.opt.fp.flg
			p.par.cn=p.par.cf;
	end
	switch	mode
	case	{-100 -99 -98 -97 -50 -10 -9 -8 -7}
			str=varargin{1};
	case	-2
			str=sprintf('+ match  %16d <%s>',numel(varargin{1}),p.par.cf);
	case	2
		if	p.opt.V.flg
			str=sprintf('%s',p.par.cf);
		end
	case	3
			cline=varargin{1};
			cmatch=varargin{2};
		if	p.opt.l.flg	&&...
			p.par.nmatch==1
			str=sprintf('%-1d %s [%s]',p.mfiles+1,p.par.cf,p.par.cs);
		end
		if	p.opt.exe.flg	||...
			p.opt.cp.flg	||...
			p.opt.dt.flg
			p.par.ptab.par.ix=strfind(cmatch,p.par.tab);
		if	~isempty(p.par.ptab.par.ix)
			cmatch=GREP_run_detab(cmatch,p);
		end
		if	p.opt.exe.flg
			cmatch=sprintf(p.par.comt,cmatch,cmatch);
		end
		if	p.opt.cp.flg
			cmatch=strrep(cmatch,'''','''''');
			cmatch=sprintf(p.par.cpt,cmatch,cmatch);
		end
		end
		if	~p.opt.c.flg
		if	p.opt.D.flg	||...
			p.opt.d.flg
			ref=sprintf('%17d',cline);
			txt=sprintf('%17d:	  <%s>',cline,cmatch);
		elseif	p.opt.n.flg	&&...
			~p.opt.Q.flg
			ref=sprintf('%s:%-1d',p.par.cn,cline);
			txt=sprintf('%s:%-1d: %s',p.par.cn,cline,cmatch);
		elseif	p.opt.n.flg	&&...
			p.opt.Q.flg
			ref=sprintf('%-1d',cline);
			txt=sprintf('%-1d: %s',cline,cmatch);
		elseif	~p.opt.Q.flg
			ref=sprintf('%s',p.par.cn);
			txt=sprintf('%s: %s',p.par.cn,cmatch);
		else
			txt=sprintf('%s',cmatch);
		end
		if	~isempty(ref)
		if	~p.opt.u.flg
			txt=sprintf(p.par.reft,p.par.cf,cline,ref,cmatch);
		end
		end
		if	p.opt.Np.flg
			txt=sprintf('%-1d %s',p.par.csn,txt);
		end
		if	p.opt.N.flg
			txt=sprintf('%-1d %s',p.par.clc,txt);
		end
		if	p.opt.Nf.flg
			txt=sprintf('%-1d %s',p.mfiles+1,txt);
		end
		if	p.opt.Na.flg
			txt=sprintf('%-1d %s',p.par.mlc,txt);
		end
		if	p.opt.rng.flg
			cmod=des(varargin{3});
			cbrk=varargin{4};
			txt=sprintf('%c %s',cmod,txt);
		if	cbrk
			txt=sprintf('%s\n%s',txt,'');
		end
		end
		if	~isempty(str)
			str=str2mat(str,txt);
		else
			str=txt;
		end
		end	% -show line ~<-c>
	case	4
		if	p.opt.c.flg
			str=sprintf('%-d',p.lcount(p.pfiles));
		end
	case	100
			p.msg=varargin{1};
		if	ischar(p.msg)
			str=p.msg;
		end
	end
		if	~isempty(str)
			p=GREP_update(4,p,str);
		if	~p.opt.S.flg
			disp(str);
		end
		end
end
function	p=GREP_ini_detab(opt)
		tlen=opt.TAB.val;
	if	opt.exe.flg
		opt.EOT.val=opt.EOT.def;
	end
		par.t=cell(tlen,1);
	for	i=1:tlen
		p.par.t{i,1}=sprintf('%*s',i,opt.EOT.val{:}(1));
	end
		p.par.ix=[];
end
function	ss=GREP_run_detab(ss,varargin)
		p=varargin{1};
		opt=p.opt;
		par=p.par.ptab.par;
		tmax=size(ss,2);
		tlen=opt.TAB.val;
		tt=tlen:tlen:tmax*tlen;
		tp=par.ix;
		nt=numel(tp);
		tn=1:nt;
		tm=tt(tn);
		tx=tm-tp+tn;
		tx(end)=[];
		tx=[0,tx]+tp-tn;
		tx=tm-tx;
		tx=mod(tx-1,tlen)+1;
		tx=par.t(tx);
		ss=regexprep(ss,'\t',tx,'once');
end
function	GREP_copypaste(s,varargin)
		import	java.lang.*
		import	java.awt.*;
		import	java.awt.event.*;
		clipboard('copy',s);
		rob=Robot;
		rob.keyPress(KeyEvent.VK_CONTROL);
		rob.keyPress(KeyEvent.VK_V);
        rob.keyRelease(KeyEvent.VK_V);
		rob.keyRelease(KeyEvent.VK_CONTROL);
end
%$SSC_INSERT_END   21-Apr-2009/21:38:10   F:/usr/matlab/unix/grep.m
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------