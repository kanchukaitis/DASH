classdef (Abstract) ensembleFilter
    %% ensembleFilter  Implement common utilities for ensemble-based data assimilation filters
    % ----------

    properties (SetAccess = protected)
        
        %% General

        label_;             % A label for the filter

        %% Sizes

        nState = 0;         % The number of state vector elements
        nMembers = 0;       % The number of ensemble members
        nPrior = 0;         % The number of priors
        nSite = 0;          % The number of proxy/observation sites
        nTime = 0;          % The number of assimilated time steps
        nR = 0;             % The number of observation uncertainties

        %% Essential inputs
        
        Y;                  % Proxy records / observations
        Ye;                 % Proxy estimates / observation estimates
        X;                  % The prior
        whichPrior          % Indicates which prior to use in each assimilated time step

        R;                  % Proxy uncertainties / observation uncertainties
        whichR;             % Indicates which set of uncertainties to use in each assimilated time step
        Rtype;              % Indicates the type of uncertainties: 0-error variances, 1-error covariances

    end

    methods

        % General
        varargout = label(varargin);

        % Essential inputs
        obj = observations(obj, Y);
        obj = prior(obj, X, whichPrior);
        obj = estimates(obj, Ye, whichPrior);
        obj = uncertainties(obj, R, whichR, Rtype)
        
    end