function dockAllFigures(h,sortFigs)
% Docks all figures in a single figure window.
% dockAllFigures docks all open figures.
% dockAllFigures(h) docks figures in vector h, in numerical order.
% dockAllFigures(h,0) docks figures in vector h in the order they have been
% entered
% dockAllFigures([],0) docks all figures in vector h in the order they
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
        disp(['Figure ' num2str(h(iH)) ' : ' name ' (' file ') docked.'])
    elseif ~isempty(name)
        disp(['Figure ' num2str(h(iH)) ' : ' name ' docked.'])
    elseif ~isempty(file)
        disp(['Figure ' num2str(h(iH)) ' (' file ') docked.'])
    else
        disp(['Figure ' num2str(h(iH)) ' docked.'])
    end
    set(h(iH),'WindowStyle','docked')
end