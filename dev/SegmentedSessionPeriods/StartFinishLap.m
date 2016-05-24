function [start,finish] = StartFinishLap(Duration)
finish = cumsum(Duration);
start = finish-Duration+1;
