idEx = false(1,length(EnteringCPTime));
    for cp = 1 : length(EnteringCPTime)
        t0 = EnteringCPTime(cp);
        if cp>length(FeederTimes)
            t1 = max(sd.x.range);
        else
            t1 = FeederTimes(cp);
        end
        x0 = sd.x.restrict(t0,t1);
        y0 = sd.y.restrict(t0,t1);
        X = x0.data;
        Y = y0.data;
        if length(X(~isnan(X)))<=2&&length(Y(~isnan(Y)))<=2
            idEx(cp) = true;
        end
    end
    idInc = ~idEx;