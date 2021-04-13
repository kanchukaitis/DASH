function[] = checkMissingR(obj)
%% Checks that each observation has an R variance or R covariances in each
% required time step.
%
% obj.checkMissingR

% If observations are set, get the time steps for each set of R values
if ~isempty(obj.Y)
    obj = obj.finalizeWhich;
    for c = 1:obj.nR
        times = find(obj.whichR==c);

        % R variances
        if ~obj.Rcov
            hasobs = any(~isnan(obj.Y(:,times)), 2);
            missing = hasobs & isnan(obj.R(:,c));
            assert(~any(missing), sprintf('R variance set %.f must have a value for site %.f', c, find(missing,1)));

        % R covariances need both row and column
        else
            [site1, site2] = find(isnan(obj.R(:,:,c)));
            for k = 1:numel(times)
                t = times(k);
                missing = find( ~isnan(obj.Y(site1,t)) & ~isnan(obj.Y(site2,t)), 1);
                assert(isempty(missing), sprintf('R covariance set %.f must have a covariance betwee site %.f and site %.f', c, site1(missing), site2(missing)));
            end
        end
    end
end

end