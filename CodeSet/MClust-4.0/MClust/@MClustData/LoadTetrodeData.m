function OK = LoadTetrodeData(self)

% find basename
[fn dn] = uigetfile(self.TText, ...
    'Select the spike data file from the desired tetrode.');
if isequal(fn,0) % user hit cancel
    return
end
[self.TTdn self.TTfn self.TText] = fileparts(fullfile(dn,fn));
if exist(fullfile(self.TTdn, 'FD'), 'dir')
    self.FDdn = fullfile(self.TTdn, 'FD');
else
    self.FDdn = self.TTdn;
end

% Calculate features
OK = self.FillFeatures();
end
