%% stateVector Tutorial
% This provides a detailed introduction to using the stateVector module.
% Written by Jonathan King

%% Overview
%
% The stateVector class helps design and build a state vector ensemble from
% data catalogued in .grid files. This takes place in two phases. Phase 1 
% is the design phase: in this stage you will add variables to a state 
% vector and design them to follow whatever specifications you require. 
% Phase 2 is the build phase: here, the design is finalized and a state 
% vector ensemble is constructed from the design template.
%
% Note that data is not loaded and processed until the end of the build 
% phase. The stateVector class is written to help you design the template
% for a state vector, which lets you build a state vector ensemble without 
% needing to manipulate large data arrays. Let's review some concepts that 
% will help us to design state vector templates.

%% State Vectors
%
% A fundamental concept in ensemble data assimilation is the state vector.
% In brief, a state vector is a collection of state variables and 
% parameters describing the climate. As a rule of thumb, the elements of a
% state vector are the climate variables and parameters you are interested 
% in reconstructing. These values are often generated by a climate model, 
% but can also include data from other sources. For example, some 
% paleoclimate assimilation have used state vectors that include real-world
% proxy records (for the purpose of reconstruction verification). Whatever 
% the application, a state vector can include multiple variables with 
% different spatial and temporal resolutions. For example, I could make a
% state vector consisting of monthly gridded surface temperatures and
% precipitation, and annual-mean, spatial-mean temperature in the Northern 
% Hemisphere.
%
% <See figure: state-vector.svg>
%
% Within the DASH framework, different variables are defined as either
% 1. Describing a different climate variable, or
% 2. Having different spatial or temporal resolution.
% 
% For example, a gridded monthly temperature field and gridded monthly
% precipitation field are different variables because they describe
% different climate parameters. Monthly precipitation and annual 
% precipitation would be different variables because they have different 
% temporal resolution, and gridded temperatures and global mean 
% temperatures are different variables because they have different spatial
% resolution. In my example state vector, there are 3 variables:
% 1. T - Gridded monthly temperature
% 2. Tmean - Annual, global mean temperature
% 3. P - Gridded monthly precipitation
%
% Although T and Tmean both describe temperature, they are considered
% different variables because they have different spatial and temporal
%resolution.

%% Ensembles
%
% A second important concept is the state vector ensemble. This is a
% collection of multiple iterations of a state vector, and is typically 
% used to estimate climate system covariance and as the prior for an 
% assimilation. In paleoclimate, ensemble members (different iterations of
% the state vector) are typically selected from different time slices 
% and/or ensemble members of climate model output. Continuing the previous 
% example, a small ensemble for my state vector might look like:
%
% <See figure: ensemble.svg>
%
% Here, each column is a different ensemble member. Each ensemble member 
% has the T, P, and Tmean variables, but in a different time slice. In the
% case of ensemble member 5, the ensemble member is from the same time step
% as ensemble member 1, but in a different simulation.

%% State and Ensemble Dimensions
%
% Throughout the stateVector tutorial, we will refer to "state dimensions"
% and "ensemble dimensions". These dimensions are the different dimensions 
% of a variable (such as latitude, longitude, time, etc). The state or
% ensemble modifier indicates whether the metadata for the dimension is 
% defined along the state vector or along the ensemble members. If the 
% metadata for a dimension is constant along a row of an ensemble, then it
% is a state dimension. If the dimension's metadata is constant along a
% column of the ensemble, then it is an ensemble dimension. Let's zoom in 
% on the "T" variable from my ensemble as an example.
%
% <See figure: state-dimensions.svg>
%
% Here, we can see that each row is associated with a unique spatial 
% coordinate because each element in the state vector holds the data for a 
% particular grid point. The latitude-longitude coordinate within each row 
% is constant; for example, row 5 always describes the grid point at (X, Y)
% regardless of which ensemble member is selected. Thus, latitude and
% longitude are state dimensions.
%
% By contrast, each column is associated with a constant time and run
% coordinate.
%
% <See figure: ensemble-dimensions.svg>
%
% For example, column 5 always refers to data from year 1 in run 2, 
% regardless of the spatial point. Thus, time and run are ensemble 
% dimensions in this case. As a rule of thumb, the 
% "lat","lon","coord","lev", and "var" dimensions are often state
% dimensions, and the "time" and "run" dimensions are often ensemble
% dimensions. However, this is just a rule of thumb and not a strict 
% requirement; depending on the application, any dimension could be a state
% dimension or ensemble dimension.

%% Sequences
%
% Sometimes, you may want an ensemble dimension to have some structure 
% along the state vector, which this tutorial will refer to as a "sequence". 
% Sequences most commonly occur when including multiple, sequential time
% steps in a state vector.
%
% For example, let's say I want my "T" variable to include the spatial grid
% from June, July, and August in a given year. The state vector ensemble 
% for this variable would have the following structure.
%
% <See figure: sequence.svg>
%
% We can see that the ensemble dimension "time" now has metadata along both
% the state vector and the ensemble. The columns still refer to a unique
% (time, run) coordinate, but the rows also refer to a particular month. 
% This additional metadata along the state vector forms a sequence for the
% time dimension. Note that time is still an ensemble dimension because 
% metadata along the ensemble is still required to form a unique time 
% coordinate. For example, we know an element in row 1 is from June, but we
% don't know the year until referencing a specific ensemble member.

%% Dimension Indices
% As mentioned, the stateVector class builds state vectors from data 
% catalogued in .grid files. However, we  will not always need to use *all*
% of a .grid file's data in a state vector ensemble; often, a small subset 
% of the data is sufficient. As such, we will need a way to select subsets 
% of .grid file data. In stateVector, we will do this by selecting specific
% elements along the dimensions of the .grid file's N-dimensional array.
%
% For example, say I have a .grid file that organizes a 4D array that is 
% lat x lon x time x run and that the "lat" metadata is given by:
lat = -90:90;
 
% If I only want to include the Northern Hemisphere in my state vector, 
% then I will want to use elements 92 through 181 along the "lat" dimension.

%% State and Reference Indices
%
% As the name suggests, state indices are the dimension indices for a state
% dimension. They indicate which elements along a dimension to add to a
% state vector.
%
% The dimension indices for ensemble dimensions are slightly more complex.
% We will refer to these as "reference indices" (the reason for this name 
% will become clear later). Reference indices specify which elements along
% a dimension can be used as ensemble members. For example, say that "time"
% is an ensemble dimension, and that the time consists of monthly data from
% 1850 to 2005. If I use reference indices that point to month of June,
% then all ensemble members will be selected from the month of June.
%
% <See figure: reference-indices.svg>
% <See figure: ref-ensemble.svg>

%%  Example workflow
%
% You can use gridfile metadata to easily obtain dimension indices. As 
% detailed in the gridfile tutorial, you can obtain a .grid file's metadata
% via:
grid = gridfile('myfile.grid');
meta = grid.metadata;

% From here, you can easily obtain state and reference indices. For example:

% Northern Hemisphere
NH_indices = meta.lat > 0;

% January of every year
Jan_indices = year(meta.time) == 1;

% Ensemble members 2-5
Run_indices = ismember(meta.run, [2:5]);

%% Sequence indices
%
% We use the name "reference indices", because they form the reference 
% point for sequences. Using the same example, let's say that I want each 
% state vector to hold data from June in three successive years. This is a 
% sequence with 3 elements (one element per year). We will need to provide 
% a set of sequence indices, which will indicate how to find these three 
% elements for each ensemble member. Each sequence index specifies how many
% data indices past the reference index to find the next element in the
% sequence. For this example, the sequence indices would be:
seqIndices = [0, 12, 24];

% The first sequence index (0), says to use the data at the reference index
% as the first June. Since the data is monthly, June of the following year 
% is 12 data indices away from this first June, so sequence index 2 is 12. 
% Finally, the third June is 24 months away from the first June, so its 
% sequence index is 24.
%
% <See figure: sequence-indices.svg>
% <See figure: seq-ensemble.svg>

%% Mean Indices
%
% If we want to take a mean over an ensemble dimension, we will need to
% provide a set of mean indices, which will indicate how to find elements
% in the mean for each ensemble member. The syntax here is similar to
% sequence indices: each mean index specifies how many data indices past 
% the reference index to find the next element in the mean. If the 
% reference indices point to the month of June, then
meanIndices = [0, 1, 2, 3];

% would cause each state vector to hold the mean of data from June, July,
% August, and September in each year.
%
% <See figure: mean-indices.svg>
% <See figure: mean-ensemble.svg>
%
% If you have both mean and sequence indices, then the mean indices will be
% applied to *each* sequence element. For example
seqIndices = [0, 12, 24];
meanIndices = [0, 1, 2, 3];

% would create state vectors consisting of the June-September mean in three
% consecutive years.
%
% <See figure: meanseq-indices.svg>
% See figure: meanseq-ensemble.svg>
%
% Alright, that's enough about indices. Let's start making a state vector!


%% Create a new stateVector
%
% To initialize a new state vector, use:
sv = stateVector;

% This will create an empty state vector. We can now start adding variables
% to the vector. For the rest of this tutorial, we will use "sv" to refer
% to a stateVector object. However, feel free to use a different naming 
% convention in your own code.

% Optional: Name the state vector.
% You can give the state vector an identifying name by providing a string
% as the first input. For example:
sv = stateVector('NH Surface Temperature');

% will create a state vector named "NH Surface Temperature". You can get 
% the name of a stateVector via:
sv.name

% If you want to change the name of a state vector, you can also rename
% it later.

% Optional: Disable console output
% By default, state vectors will print notification messages to the console
% when certain design choices are made. You can use the second input to 
% stateVector to specify whether to provide these notification. Use false 
% to disable notifications, as per:
sv = stateVector('My name', false);

% If you change your mind, you can also enable/disable notifications later.

%% Add variables to a state vector
%
% Now that we have an empty state vector, we'll want to start adding
% variables to it. To add a variable, use the "add" method. For each 
% variable, provide an identifying name, as well as the gridfile that holds
% the necessary data, as per:
sv = sv.add('myVariable', 'my-gridfile.grid');

% Note that the name of the variable DOES NOT need to be the same as the 
% name of the variable in the .grid file or associated data source. Use 
% whatever name you find useful to identify the variable in the state 
% vector. Note that all variable names must be valid MATLAB variable names;
% they must start with a letter, and can only include letters, numbers, and underscores. Also, you cannot give multiple variables the same name. You can also [rename variables](rename#rename-variable-in-a-state-vector) if you would like to change their names later. If you'd like a reminder of the variables in a state vector, you can return their names using:
sv.variableNames

% Optional: Set auto-coupling options
% 
% (Note: This is an advanced setting not necessary for most standard 
% applications. If you would like to learn about variable coupling, 
% please see the variable coupling page.)
%
% You can specify whether the variable should be automatically coupled to 
% new variables using the third input argument. By default, variables are
% automatically coupled to other variables. To disable this, set the third 
% input to false:
sv = sv.add('myVariable', 'my-gridfile.grid', false);

% Optional: Set overlap options
%
% (Note: This is an advanced setting not necessary for many standard 
% applications. If you would like to learn about variable overlap, please
% see the overlap page.)
%
% You can specify whether the variable should allow overlap in state vector
% ensembles using the fourth input argument. By default, variables do not
% allow overlap. To enable overlap, set the fourth input to true:
sv = sv.add('myVariable', 'my-gridfile.grid', [], true);

%% Select ensemble and state dimensions
%
% Use the "design" method to specify variable dimensions as state or
% ensemble dimensions. To do this, provide the name of the variable, the 
% name of the dimension, and indicate the type of the dimension. To specify
% a state dimension, you can use any of:
sv = sv.design('myVariable', 'dimensionName', 'state');
sv = sv.design('myVariable', 'dimensionName', 's');
sv = sv.design('myVariable', 'dimensionName', true);

% To set an ensemble dimension, use any of:
sv = sv.design('myVariable', 'dimensionName', 'ensemble');
sv = sv.design('myVariable', 'dimensionName', 'ens');
sv = sv.design('myVariable', 'dimensionName', 'e');
sv = sv.design('myVariable', 'dimensionName', false);

% Note that when a variable is first added to a state vector, all 
% dimensions are set as state dimensions. Thus, you only need to specify a 
% dimension as a state dimension when you want to provide state indices.

% Specify state or reference indices
%
% By default, state vector uses every index along a .grid file dimension as
% state or reference indices. However, you can use the fourth input to 
% specify a different set of indices: this may either be a vector of linear
% indices, or a logical vector the length of the dimension in the .grid 
% file. The following line:
sv = sv.design('myVariable', 'dimensionName', type, indices);

% specifies state or reference indices for a dimension. Note that "type" 
% can be any of the inputs used to indicate a state or ensemble dimension.

% Design multiple dimensions and/or variables at once
%
% You can design multiple variables at the same time by providing a string 
% vector of variable names as the first input. For example
vars = ["T","P","Tmean"];
sv = sv.design(vars, "time", "ensemble", indices);

% will use the time dimension as an ensemble dimension and specify 
% reference indices for the each of the "T", "P", and "Tmean" variables.
%
% You can also design multiple dimensions at the same time by providing a 
% string vector of dimension names as the second argument. When this is the
% case, using 'state', 's', or true as the third argument will set all 
% listed dimensions as state dimensions. Likewise, using 'ensemble', 'ens',
% 'e', or false as the third argument will set all listed dimensions as 
% ensemble dimensions.
dims = ["lat","lon","time","run"];

% Set all dimensions as state dimensions
sv = sv.design('myVariable', dims, 'state')

% Set all dimensions as ensemble dimensions
sv = sv.design('myVariable', dims, false)


% If you would like to use different settings for different dimensions, use
% a string or logical vector with one element per dimension listed in dims. 
% For example:
dims = ["lat","lon","time","run"];

% Use different settings with a string vector
type = ["state","state","ens","ens"];
sv = sv.design('myVariable', dims, type);

% Use different settings with a logical vector
type = [true true false false];
sv = sv.design('myVariable', dims, type);

% either of these approaches would specify 'lat' and 'lon' as state 
% dimensions, and 'time' and 'run' as ensemble dimensions.

% Specify indices for multiple dimensions
%
% If you would like to specify state or reference indices for multiple 
% dimensions, then the fourth argument should be a cell vector with one 
% element per listed dimension. Each element should hold the indices for 
% the corresponding dimension. Use an empty array to use the default of all
% indices for a dimension. For example:
dims = ["lat","lon","time","run"];
indices = {49:96, [], 1:12:12000, []};
sv = sv.design('myVariable', dims, type, indices);

% would use elements 49 to 96 along the latitude dimension, all elements 
% along the longitude dimension, every 12th element along the time dimension,
% and every element along the run dimension.

% Coupled variable notification
%
% Sometimes, using the design method on a variable will alter the dimension
% settings for other variables and a notification will be printed to the 
% console. Don't panic. This is the desired behavior for most assimilations
% and occurs because of variable coupling. You can disable these 
% notifications if you do not want to receive them.

%% Use a sequence along an ensemble dimension
%
% To specify a sequence for a variable, use the "sequence" method. In order,
% you will need to provide
% 1. the name of the variable,
% 2. the name of the ensemble dimension being given a sequence,
% 3. sequence indices, and
% 4. sequence metadata.
%
% For example:
sv = sv.sequence('T', 'time', [0 1 2], ["June";"July";"August"]);

% would use a 3 element sequence down the time dimension of the "T" 
% variable, and the three sequence elements would have associated metadata 
% of "June", "July", and "August", respectively. Note that sequence 
% metadata may be a numeric, logical, char, string, cellstring, or datetime
% matrix and must have one row per sequence element. each row must be 
% unique and may not contain NaN or NaT elements.

% Provide a sequence for multiple variables or dimensions
%
% To specify sequence options for multiple variables, use a string vector
% of variable names as the first input. To set sequence options for 
% multiple dimensions, use a string vector of dimension names as the second
% argument. When this is the case, the third and fourth inputs should be 
% cell vectors with one element per listed dimension. Each element of the
% third input should hold the sequence indices for the corresponding 
% dimension, and each element of the fourth element should hold the 
% metadata for the corresponding dimension. For example:
dims = ["time","run"];
indices = {[0 12 24], 0:12};
meta = {["Year 1";"Year 2";"Year 3"], (1:13)''};
sv = sv.design(variableNames, dims, indices, meta);

% would specify sequences for both the time and run dimensions.

%% Take a mean over a dimension
%
% It is often useful to take the mean of a dimension in a state vector 
% variable. For example, you could take the mean over the "lon" dimension 
% so that state vector elements are zonal means. Or you could take the mean
% over the "time" dimension if you want state vector elements to average 
% over multiple months or years. To take a mean, we will use "mean" method.

% Take a mean over state dimensions
%
% To take a mean over state dimensions of variables, provide in order
% 1. The names of the appropriate variables, and
% 2. The names of the state dimensions over which to take a mean.
%
% For example, if "lat" and "lon" are state dimensions, then:
vars = ["T","P"];
dims = ["lat","lon"];
sv = sv.mean(vars, dims);

% will take a mean over the "lat" and "lon" dimensions of the "T" and "P"
% variables.

% Take a mean over ensemble dimensions
%
% To take a mean over an ensemble dimension, you will also need to provide
% mean indices as the third input. For example:
sv = sv.mean('T', 'time', [0 1 2]);
% To take a mean over multiple ensemble dimensions, the third input should
% be a cell vector with one element per listed dimension. Each element
% should hold the mean indices for the associated dimension. For example
dims = ["time", "run"];
meanIndices = {[0 1 2], 0:11};
sv = sv.mean('T', dims, meanIndices);

% would take a 3 element mean over the time dimension, and a 12 element
% mean over the run dimension.

% Take a mean over a mix of state and ensemble dimensions
%
% To specify mean options for both state and ensemble dimensions 
% simultaneously, use the same syntax as for multiple ensemble dimensions 
% and use empty arrays as the mean indices for the state dimensions. For 
% example, say that "lat" and "lon" are state dimensions and "time" is an
% ensemble dimension. Then:
dims = ["lat","lon","time"];
indices = {[], [], [0 1 2]};
sv = sv.mean('T', dims, indices);

% would take a mean over all three dimensions.

% Optional: Specify NaN options
%
% You can use the fourth input to specify how to treat NaN values in a
% mean. By default, NaN values are included in means. To omit NaN values 
% from the means of all listed dimensions, use either of the following 
% options:
sv = sv.mean(variables, dimensions, indices, 'omitnan');
sv = sv.mean(variables, dimensions, indices, true);

% To include NaN values for all listed dimensions, use either of the
% following options:
sv = sv.mean(variables, dimensions, indices, 'includenan');
sv = sv.mean(variables, dimensions, indices, false);

% If you would like to specify different NaN options for different 
% dimensions, use either a string vector or logical vector with one element
% per listed dimension. For example:
dims = ["lat","lon","time"];

% Different settings with a string vector
nanflag = ["includenan", "omitnan", "includenan"];
sv = sv.mean(variables, dims, indices, nanflag);

% Different settings with a logical vector.
omitnan = [false, true, false];
sv = sv.mean(variables, dims, indices, omitnan);

% would include NaN values in means taken over the "lat" and "time" 
% dimensions, but omit NaN values in the mean taken over the "lon"
% dimension

% Optional: Reset Mean options
%
% You can reset mean options for variables and dimensions. When you reset
% the options, no mean is taken. Use
sv.resetMeans

% to reset means for all dimensions of all variables in a state vector.
% Use:
sv.resetMeans(variableNames)

% to reset means for all dimensions of specific variables, and
sv.resetMeans(variableNames, dimensionNames)

% to reset means for specific dimensions of listed variables.

%% Weighted Means
%
% Often, it is useful to take a weighted mean over dimensions of a variable. 
% For example, you may wish to take a latitude weighted mean when averaging
% over data from a climate model grid. Or you may wish to take a time mean 
% that gives different weights to different months.
%
% To take a weighted mean, use the "weightedMean" method and provide in order
% 1. The names of the variables with a weighted mean,
% 2. The names of the dimensions with a weighted mean,
% 3. The weights

% Weights should be a numeric vector. If weights are for a state dimension,
% they should have one element per state index. If weights are for an 
% ensemble dimension, they should have one element per mean index. For example
sv = sv.design('T', 'lat', 'state', 49:96);
weights = cosd( lat(49:96) );
sv = sv.weightedMean('T', 'lat', weights);

% could be used to provide weights for a mean over state dimension "lat". 
% Likewise
sv = sv.design('T', 'time', 'ensemble', 1:12:12000);
sv = sv.mean('T', 'time', 0:5);
weights = [1 2 3 3 2 1];
sv = sv.weightedMean('T', 'time', weights);

% could be used to provide weights for a mean over ensemble dimension "time".

% Provide weights for multiple dimensions using a cell
%
% If you want to provide weights for multiple dimensions, one option is to
% use a cell vector with one element per listed dimension. Each element 
% should contain the weights for the corresponding dimension. For example:
dims = ["lat", "time"];
weights = {latWeights, timeWeights};
sv = sv.weightedMean(variables, dims, weights);

% could be used to specify mean weights for the "lat" and "time" dimensions.

% Provide weights for multiple dimensions using an array.
%
% Sometimes, you may have a multi-dimensional array of weights. For example, 
% some climate models provide "areacella" output, a matrix that reports the
% area of each grid cell. Such output can be used to take area weighted 
% means as an alternative to latitudinal weights. To use an array of weights,
% the dimensions of the weights must be in the same order as listed dimensions.
% For example, say that "lat" and "lon" are state dimensions with 96 and 
% 144 state indices, respectively. Then, to make the following call:
sv = sv.weightedMean(variables, ["lat", "lon"], weights);

% weights should be a 96 x 144 matrix. By contrast, to do
sv = sv.weightedMean(variables, ["lon", "lat", weights]);

% weights should be a 144 x 96 matrix.

% Resetting means
%
% Whenever you use the "resetMeans" method, all weights are deleted for the
% relevant dimensions.

%% Build a state vector ensemble
%
% Once the state vector design template is finished, you are ready to build
% an ensemble. Use the "build" command and provide the desired 
% number of ensemble members. For example
X = sv.build(150);

%will build and return a state vector ensemble with 150 ensemble members.

% Select ensemble members sequentially
%
% By default, "build" selects ensemble members at random from the 
% reference indices. For example, say that the time dimension for monthly 
% data over 100 years. If we make time an ensemble dimension and use the 
% first month of each year as the reference indices
sv = sv.design(variables, 'time', 'ensemble', 1:12:1200);

% then
X = sv.build(50);

% will build an ensemble with 50 ensemble members and each ensemble member 
% will be selected from the first month of a random year.
%
% However, you can also require "build" to select ensemble members 
% sequentially from the reference indices by setting the second input to 
% false. Using the previous example:
X = sv.build(50, false);

% will build an ensemble with 50 ensemble members. The first ensemble
% member will be the first month of year 1. The second ensemble member will
% be the first month of year 2, and the 50th ensemble member will be the
% first month of year 50, etc.

% Nice! That's the tutorial. You're now ready to try out stateVector for
% your own applications.