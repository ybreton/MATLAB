function undockAllFigures(h,sortFigs)
% Undocks all figures in a single figure window.
% undockAllFigures undocks all open figures.
% undockAllFigures(h) undocks figures in vector h, in numerical order.
% undockAllFigures(h,0) undocks figures in vector h in the order they have been
% entered
% undockAllFigures([],0) undocks all figures in vector h in the order they
% appear as children of the MATLAB window.
%

if nargin<2
    sortFigs = true;
end
sortFigs = sortFigs==1;

if nargin<1
    h = get(0,'Children');
else
    if isempty(h)
        h = get(0,'Children');
    end
end

if isempty(h)
    warning('No figures to dock.')
end

if sortFigs
    h = sort(h);
end
assert(all(strcmpi(get(h,'type'),'figure')),'Handles must point to figures.')

for iH=1:length(h)
    name = get(h(iH),'Name');
    file = get(h(iH),'FileName');
    if ~isempty(name)&&~isempty(file)
        disp(['Figure ' num2str(h(iH)) ' : ' name ' (' file ') undocked.'])
    elseif ~isempty(name)
        disp(['Figure ' num2str(h(iH)) ' : ' name ' undocked.'])
    elseif ~isempty(file)
        disp(['Figure ' num2str(h(iH)) ' (' file ') undocked.'])
    else
        disp(['Figure ' num2str(h(iH)) ' docked.'])
    end
    set(h(iH),'WindowStyle','normal')
end