function [f, ca, o] = spider_plot(data,tle,rng,lbl,leg,sig_dim,f)
% create a spider plot for ranking the data
%
% data -> n_dimensions x n_samples
%
% function [f, ca, o] = spider(data,tle,rng,lbl,leg,f)
%
% inputs  6 - 5 optional
% data    input data (NxM) (# axes (M) x # data sets (N))     class real
% tle     spider plot title                                   class char
% rng     peak range of the data (Mx1 or Mx2)                 class real
% lbl     cell vector axes names (Mxq) in [name unit] pairs   class cell
% leg     data set legend identification (1xN)                class cell
% f       figure handle or plot handle                        class real
%
% outptus 3 - 3 optional
% f       figure handle                                       class integer
% x       axes handle                                         class real
% o       series object handles                               class real
%
% michael arant - jan 30, 2008
%
% to skip any parameter, enter null []
% 

% data check
if nargin < 1; help spider; error('Need data to plot'); end

% size segments and number of cases

[r c] = size(data);
% exit for too few axes
if r < 3
	errordlg('Must have at least three measuremnt axes')
	error('Program Termination:  Must have a minimum of three axes')
end

% title
if ~exist('tle','var') || isempty(tle) || ~ischar(tle)
	tle = 'Spider Plot';
end

% check for maximum range
if ~exist('rng','var') || isempty(rng) || ~isreal(rng)
	% no range given or range is in improper format
	% define new range
	rng = [min([min(data,[],2) zeros(r,1)],[],2) max(data,[],2)];
	% check for negative minimum values
	if ~isempty(ismember(-1,sign(data)))
		% negative value found - adjust minimum range
		for ii = 1:r
			% negative range for axis ii - set new minimum
			if min(data(ii,:)) < 0
				rng(ii,1) = min(data(ii,:)) - ...
							0.25 * (max(data(ii,:)) - min(data(ii,:)));
			end
		end
	end
elseif size(rng,1) ~= r
	if size(rng,1) == 1
		% assume that all axes have commom scale
		rng = ones(r,1) * rng;
	else
		% insuffent range definition
		uiwait(msgbox(char('Range size must be Mx1 - number of axes x 1', ...
			sprintf('%g axis ranges defined, %g axes exist',size(rng,1),r))))
		error(sprintf('%g axis ranges defined, %g axes exist',size(rng,1),r))
	end
elseif size(rng,2) == 1
	% assume range is a maximum range - define minimum
	rng = sort([min([zeros(r,1) min(data,[],2) - ...
						0.25 * (max(data,[],2) - min(data,[],2))],[],2) rng],2);
end

% check for axis labels
if ~exist('lbl','var') || isempty(lbl)
	% no labels given - define a default lable
	lbl = cell(r,1); for ii = 1:r; lbl(ii) = cellstr(sprintf('Axis %g',ii)); end
elseif size(lbl,1) ~= r
	if size(lbl,2) == r
		lbl = lbl';
	else
% 		uiwait(msgbox(char('Axis labels must be Mx1 - number of axes x 1', ...
% 			sprintf('%g axis labels defined, %g axes exist',size(lbl,1),r))))
% 		error(sprintf('%g axis labels defined, %g axes exist',size(lbl,1),r))
	end
elseif ischar(lbl)
	% check for charater labels
	lbl = cellstr(lbl);
end

if ~exist('leg','var') || isempty(leg)
	% no data legend - define default legend
	leg = cell(1,c); for ii = 1:c; leg(ii) = cellstr(sprintf('Set %g',ii)); end
elseif numel(leg) ~= c/3
% 	uiwait(msgbox(char('Data set label must be 1XN - 1 x number of sets', ...
% 		sprintf('%g data sets labeled, %g exist',numel(leg),c))))
% 	error(sprintf('%g data sets labeled, %g exist',numel(leg),c))
end


% check for figure or axes
if ~exist('f','var')
	% no figure or axes requested - generate new ones
	f = figure; ca = gca(f); cla(ca); hold on; set(f,'color','w')
elseif ismember(f,get(0,'children')')
	% existing figure - clear and set up
	ca = gca(f); hold on;
elseif isint(f)
	% generating a new figure
	figure(f); ca = gca(f); cla(ca); hold on
else
	% may be an axes - may be garbage
	try
		%is this an axes?
		if ismember(get(f,'parent'),get(0,'children')')
			% existing figure axes - use
			ca = f; f = get(f,'parent'); hold on
		end
	catch
		% make new figure and axes
		disp(sprintf('Invalid axes handle %g passed.  Generating new figure',f))
		f = figure; ca = gca(f); cla(ca); hold on
	end
end

% set the axes to the current text axes
axes(ca)
% set to add plot
set(ca,'nextplot','add');

% clear figure and set limits
set(ca,'visible','off'); set(f,'color','w')
set(ca,'xlim',[-1.25 1.25],'ylim',[-1.25 1.25]); axis(ca,'equal','manual')
% title
text(0,1.3,tle,'horizontalalignment','center','fontweight','bold','fontsize',17);


% define data case colors
col = color_index(c/3);


% scale by range
angw = linspace(0,2*pi,r+1)';
mag = (data - rng(:,1) * ones(1,c)) ./ (diff(rng,[],2) * ones(1,c));
% scale trimming
mag(mag < 0) = 0; mag(mag > 1) = 1;
% wrap data (close the last axis to the first)
ang = angw(1:end-1); angwv = angw * ones(1,c); magw = [mag; mag(1,:)];


% make the plot
% define the axis locations
start = [zeros(1,r); cos(ang')]; stop = [zeros(1,r); sin(ang')];
% plot the axes
grey=[0,0,0]+0.8;
plot(ca,start,stop,'color',grey,'linestyle','-','LineWidth',3); axis equal
% plot axes markers
inc = 0.2:.2:1; mk = .025 * ones(1,5); tx = 5 * mk; tl = 0:.2:1;
% loop each axis ang plot the line markers and labels
% add axes
for ii = 1:r
	% plot tick marks
        
% 	tm = plot(ca,[[cos(ang(ii)) * inc + sin(ang(ii)) * mk]; ...
% 			[cos(ang(ii)) * inc - sin(ang(ii)) * mk]], ...
% 			[[sin(ang(ii)) * inc - cos(ang(ii)) * mk] ;
% 			[sin(ang(ii)) * inc + cos(ang(ii)) * mk]],'color',grey);
        
    % plot concentric circles
    
    theta = linspace(0, 2*pi, 50).';
    plot(cos(theta)*inc, sin(theta)*inc,'color',grey,'LineWidth',3);
       
    	tm = plot(ca,[[cos(ang(ii)) * inc + sin(ang(ii)) * mk]; ...
			[cos(ang(ii)) * inc - sin(ang(ii)) * mk]], ...
			[[sin(ang(ii)) * inc - cos(ang(ii)) * mk] ;
			[sin(ang(ii)) * inc + cos(ang(ii)) * mk]],'color',grey);
    
 if ii==1 % to label just one axis
	% label the tick marks
	for jj = 1:5
		temp = text([cos(ang(ii)) * inc(jj) + sin(ang(ii)) * tx(jj)], ...
				[sin(ang(ii)) * inc(jj) - cos(ang(ii)) * tx(jj)], ...
  				num2str(jj), ...
				'fontsize',8,'color',grey-0.5,'FontSize',10,'fontweight', 'bold');
		% flip the text alignment for lower axes %   				num2str(chop(rng(ii,1) + inc(jj)*diff(rng(ii,:)),2)), ...
		if ang(ii) >= pi
			set(temp,'HorizontalAlignment','right')
        end
    
    end
  end  
	% label each axis
    if exist('sig_dim') && ismember(ii,sig_dim) % significant axis
        
	temp = text([cos(ang(ii)) * 1.1 + sin(ang(ii)) * 0], ...
			[sin(ang(ii)) * 1.1 - cos(ang(ii)) * 0], ...
			char(lbl(ii,:)), 'fontweight', 'bold');
	% flip the text alignment for right side axes
	if ang(ii) > pi/2 && ang(ii) < 3*pi/2
		set(temp,'HorizontalAlignment','right')
    end
    
    else
        
        temp = text([cos(ang(ii)) * 1.1 + sin(ang(ii)) * 0], ...
			[sin(ang(ii)) * 1.1 - cos(ang(ii)) * 0], ...
			char(lbl(ii,:)),'FontSize',13);
	% flip the text alignment for right side axes
	if ang(ii) > pi/2 && ang(ii) < 3*pi/2
		set(temp,'HorizontalAlignment','right')
    end
        
        
    end
end


% plot the data
o = polar(ca,angw*ones(1,c),magw);
% set color of the lines
for ii = 1:c; 
    if mod(ii,3)==2
    set(o(ii),'color',col(floor(ii/3)+1,:),'linewidth',5); 
    end
    if mod(ii,3)==1
     %  set(o(ii),'color',col(floor(ii/3)+1,:),'linewidth',3);
       set(o(ii),'color',col(floor(ii/3)+1,:),'linestyle',':','linewidth',2.5);
    end
    if mod(ii,3)==0
      %  set(o(ii),'color',col(floor(ii/3),:),'linewidth',3);
          set(o(ii),'color',col(floor(ii/3),:),'linestyle',':','linewidth',2.5);
    end
end

% fill - shadow
% x=0:0.01:2*pi;                  %#initialize x array
% y1=sin(x);                      %#create first curve
% y2=sin(x)+.5;                   %#create second curve
% X=[x,fliplr(x)];                %#create continuous x value array for plotting
% Y=[y1,fliplr(y2)];              %#create y values for out and then back
% fill(X,Y,'b');  

%  x=angw;
%   y1=magw(:,1);
%   y2=magw(:,3);
%   
%   Y=[y1,y2];
%   fill(x,Y,'b')


% apply the legend
% legenda = cell(1,c);
% for k=1:c
%     if mod(k,3)==2
%         legenda{k}=leg{floor(k/3)+1};
%     end
% end
%temp = legend(o,leg,'location','northeastoutside');
temp = legend(o(find(mod([1:length(o)],3)==2)),leg,'location','northeastoutside');

return

   
function c = chop(x, t)
%CHOP    Round matrix elements.
%        CHOP(X, t) is the matrix obtained by rounding the elements of X
%        to t significant binary places.
%        Default is t = 24, corresponding to IEEE single precision.

if nargin < 2, t = 24; end
[m, n] = size(x);

%  Use the representation:
%  x(i,j) = 2^e(i,j) * .d(1)d(2)...d(s) * sign(x(i,j))

%  On the next line `+(x==0)' avoids passing a zero argument to LOG, which
%  would cause a warning message to be generated.

y = abs(x) + (x==0);
e = floor(log2(y) + 1);
c = pow2(round( pow2(x, t-e) ), e-t);
        
end

end


% integer test
function [res] = isint(val)
% determines if value is an integer
% function [res] = isint(val)
%
% inputs  1
% val     value to be checked              class real
%
% outputs 1
% res     result (1 is integer, 0 is not)  class integer
%
% michael arant     may 15, 2004
if nargin < 1; help isint; error('I / O error'); end

% check for real number
if isreal(val) & isnumeric(val)
%	check for integer
	if round(val) == val
		res = 1;
	else
		res = 0;
	end
else
	res = 0;
end

end

% set color scales
function [val] = color_index(len)
% get unique colors for each item to plot
% function [val] = color_index(len)
%
% inputs  1
% len     number of objects     class integer
%
% outputs 1
% val     color vector          class real
%
% michael arant
if nargin < 1 | nargout < 1; help color_index; error('I / O error'); end

if len == 1
	val = [0 0 0];
else
	% initial color posibilities (no white)
	% default color scale
	col = [	0 0 0
			0 0 1
			0 1 1
			0 1 0
			1 1 0
			1 0 1
			1 0 0];

	% reduce if fewer than 6 items are needed (no interpolation needed)
	switch len
		case 1, col([2 3 4 5 6 7],:) = [];
		case 2, col([1 2 3 5 6],:) = [];
		case 3, col([1 3 5 6],:) = [];
		case 4, col([3 5 6],:) = [];
		case 5, col([5 6],:) = [];
		case 6, col(6,:) = [];
	end

	% number of requested colors
	val = zeros(len,3); val(:,3) = linspace(0,1,len)';

	% interpolate to fill in colors
	val(:,1) = interp1q(linspace(0,1,size(col,1))',col(:,1),val(:,3));
	val(:,2) = interp1q(linspace(0,1,size(col,1))',col(:,2),val(:,3));
	val(:,3) = interp1q(linspace(0,1,size(col,1))',col(:,3),val(:,3));
end

end
