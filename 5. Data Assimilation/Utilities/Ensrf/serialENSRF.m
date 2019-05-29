function[Amean, Avar, Ye, R, update, calib] = serialENSRF( M, D, R, F, w )
%% Implements data assimilation using an ensemble square root filter with serial
% updates for individual observations. Time steps are assumed independent
% and processed in parallel.
%
% [A, Y] = dashDA( M, D, R, F, w )
% Performs data assimilation.
%
% ----- Inputs -----
%
% M: The model ensemble. (nState x nEns)
%
% D: The observations. (nObs x nTime)
%
% R: Observation uncertainty. NaN values will be determined via dynamic R
%    generation by the PSM. (nObs x nTime)
%
% w: Covariance localization weights. (nState x nObs)
%
% F: An array of proxy system models of the "PSM" class. One model for each
%      observation. (nObs x 1)
%
% ----- Outputs -----
%
% Amean: Updated ensemble mean (nState x nTime)
%
% Avar: Updated ensemble variance (nState x nTime)
%
% Ye: Proxy estimates. (nObs x nEns x nTime)

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Get some sizes
[nObs, nTime] = size(D);
[nState, nEns] = size(M);

% Decompose the initial ensemble. Clear the ensemble to free memory.
[Mmean, Mdev] = decomposeEnsemble(M);
clearvars M;

% Preallocate the output
Amean = NaN( nState, nTime );
Avar = NaN( nState, nTime );
Ye = NaN( nObs, nEns, nTime );
update = false( nObs, nTime );
calib = NaN( nObs, nTime );

% Each time step is independent, process in parallel
for t = 1:nTime
    t
    
    % Initialize the update for this time step
    Am = Mmean;
    Ad = Mdev;    
    
    % For each observation that is not a NaN
    for d = 1:nObs
        if ~isnan( D(d,t) )
            
            % Get the model elements to pass to the PSM
            Mpsm = Am(F{d}.H) + Ad(F{d}.H,:);                   %#ok<PFBNS>
            
            % Run the PSM. Generate R. Error check.
            [Ye(d,:,t), R(d,t), update(d,t)] = getPSMOutput( F{d}, Mpsm, R(d,t), t, d );
            
            % If no errors occured in the PSM, and the R value is valid,
            % update the analysis
            if update(d,t)
                
                % Decompose the model estimate
                [Ymean, Ydev] = decomposeEnsemble( Ye(d,:,t) );

                % Get the Kalman gain and alpha scaling factor
                [K, a] = serialKalman( Ad, Ydev, w(:,d), R(d,t) );    %#ok<PFBNS>
                
                % Update
                Am = Am + K*( D(d,t) - Ymean );
                Ad = Ad - (a * K * Ydev);    
                
                % Get the calibration ratio
                calib(d,t) = ( D(d,t) - Ymean ) ./ ( var(Ye(d,:,t)) + R(d,t) );
            end
        end
    end
    
    % Record the mean and variance of the final analysis for the time step
    Amean(:,t) = Am;
    Avar(:,t) = var( Ad, 0 ,2 );
end

end