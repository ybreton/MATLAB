classdef UndoSystem < handle
    % UndoSystem
    %   stores a set of undos, each labeled by a name
    
    properties (Access = public)
        maxUndo = 10;
        Undo = {}; UndoNames = {};
    end
    
    methods
        function self = UndoSystem(n)
            if nargin==0
                n = self.maxUndo;
            end
            self.maxUndo = n;
            self.Undo = {};
        end
        
        function StoreUndo(self, X, name)
            % stores X in the UndoStack
            self.Undo{end+1} = X;
            self.UndoNames{end+1} = name;
            if length(self.Undo) > self.maxUndo
                self.Undo(1) = [];
                self.UndoNames(1) = [];
            end
        end
               
        function X = PopUndo(self)
            if self.anythingToUndo
                % recalls X from the undo stack
                X = self.Undo{end};
                self.Undo(end) = []; self.UndoNames(end) = [];
            else
                X = {};
            end
        end
        
        function b = anythingToUndo(self)
            b = ~isempty(self.Undo);
        end
        
        function nm = nextUndoName(self)
            if ~isempty(self.UndoNames)
                nm = self.UndoNames{end};
            else
                nm = '';
            end
        end
    end
    
end

