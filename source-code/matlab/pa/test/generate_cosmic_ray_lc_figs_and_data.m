function generate_cosmic_ray_lc_figs_and_data(rootTaskDir, dawgDir, ...
    channels, quarter, refPdfFile, isK2)
%**************************************************************************
% function generate_cosmic_ray_lc_figs_and_data()
%**************************************************************************
% Analyze the distribution of detected background cosmic rays for each
% channel. Compare the distribution of detected events with the expected
% distribution and plot (1) the goodness-of-fit across the FOV, and (2) the
% expected and observed histogram for each channel.
%
% INPUTS
%     rootTaskDir    The full path to the directory containing task 
%                    directories for the pipeline instance (this is the
%                    directory containing the uow/ subdirectory). If
%                    unspecified, the current working directory is used.
%     dawgDir        The full path to the directory containing DAWG figures
%                    and data. 
%     channels       A list of channel numbers.
%     quarter        The quarter or campaign number.
%     refPdfFile     The full path to a file containing a reference PDF
%                    that describes the expected distribution of cosmic ray
%                    events. The file must contain a struct named
%                    condPdfStruct, with the followign fields:
%
%                    condPdfStruct
%                    |-.x    A pixel event magnitude (photoelectrons)
%                     -.p    Probability density at point x, given a pixel 
%                            event has occurred p(x | pixel event).
%     isK2           An optional flag indicating whether we're processing
%                    Kepler (false) or K2 (true) data (default = false).
%
% OUTPUTS
%     This function creates the directory dawgDir/cosmic_ray and populates
%     it with figures and data for each channel.
%
% NOTES  
%   - The chi-squared distance (useful for comparing histograms) between
%     two vectors x and y is defined as: 
%
%         d(x,y) = sum( (xi-yi)^2 / (xi+yi) ) / 2;
%
%**************************************************************************
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
    cadenceType = 'long';

    if exist('isK2', 'var') && isK2 == true
        quarterStr = ['c' num2str(quarter)];
    else
        quarterStr = ['q' num2str(quarter)];        
    end
    
    load(refPdfFile);
    startingDir = pwd;
        
    outputDir = fullfile(dawgDir, 'cosmic_ray');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    cd(outputDir);

    [modules, outputs] = convert_mod_out_to_from_channel(channels);

    %------------------------------------------------------------------
    % Plot expected and observed background distributions of event
    % energies.
    %------------------------------------------------------------------
    distance = zeros(length(channels), 1);
    for iChannel = 1:length(channels)          
        [binCounts, expectedBinCounts, binCenters] = ...
            generate_cosmic_ray_dawg_figures( ...
                channels(iChannel), quarter, cadenceType, ...
                'taskDir', rootTaskDir, 'pdf', condPdfStruct );

         distance(iChannel) = pdist2_alt( rowvec(binCounts), ...
             rowvec(expectedBinCounts), 'chisq' );
    end

    %------------------------------------------------------------------
    % Generate FOV goodness-of -fit plot.
    %
    % The histogram of detected cosmic rays is expected to deviate
    % significantly from the predicted histogram, especially at lower
    % energies. What this plot does is to highlight any outlying
    % channels.
    %------------------------------------------------------------------
    fovFigureHandle = fovPlottingClass.plot_on_modout(modules, ...
        outputs, distance);
    fovFigureHandle = ...
        fovPlottingClass.make_ccd_legend_plot(fovFigureHandle);

    titleStr = sprintf('%s Cosmic Ray Histogram Goodness-of-Fit', quarterStr);
    title({titleStr, '(chi-squared distance from expected histogram)'});
    
    hcb = colorbar;
    yLabelHandle = get(hcb,'ylabel');
    set(yLabelHandle ,'String', '\chi^2 distance');

    saveas(fovFigureHandle, fullfile(outputDir, 'lc_goodness_of_fit_across_fov.fig'));
    save(fullfile(outputDir, 'per_channel_distance_metrics.mat'), ...
        'distance','modules', 'outputs');

    cd(startingDir);
end

%**************************************************************************
function crraObj  = reconstruct_cosmic_ray_object(rootTaskDir, ...
            quarter, channelOrModout, targetSubtaskIndex)
    CONVERT_EVENTS_TO_ZERO_BASED = true;
        
    paTaskDir = get_group_dir( 'PA', channelOrModout, 'quarter',  quarter, ...
        'rootPath', rootTaskDir, 'fullPath', true);
    paTaskDir = paTaskDir{1};
    subtaskDir = find_subtask_dirs_by_processing_state(paTaskDir, 'TARGETS');
    subtaskDir = subtaskDir{targetSubtaskIndex};

    load(fullfile(paTaskDir, 'pa_state.mat'), 'motionPolyStruct', ...
        'cosmicRayEvents', 'reactionWheelZeroCrossingIndicators', 'isArgaCadence');
    load(fullfile(paTaskDir, subtaskDir, 'pa-inputs-0.mat'));
    
    % Get Thruster firing flags from the first subtask.
    s = load(fullfile(paTaskDir, 'st-0','pa-outputs-0.mat'));
    thrusterFiringEvents = ...
        s.outputsStruct.definiteThrusterActivityIndicators | ...
        s.outputsStruct.possibleThrusterActivityIndicators;
    clear s

    crraObj = cosmicRayResultsAnalysisClass(inputsStruct, ...
        motionPolyStruct, cosmicRayEvents, CONVERT_EVENTS_TO_ZERO_BASED);
    crraObj.set_zero_crossing_indicators(reactionWheelZeroCrossingIndicators);
    crraObj.set_argabrightening_indicators(isArgaCadence);
    crraObj.set_thruster_firing_indicators(thrusterFiringEvents);
end


function [binCounts, expectedBinCounts, binCenters] = ...
    generate_cosmic_ray_dawg_figures(channel, quarter, cadenceType, varargin)
%**************************************************************************
% function generate_cosmic_ray_dawg_figures(varargin)
%**************************************************************************
% The reference PDF file can be manually retrived from SVN and placed in 
% the current directory as follows:
% 
% INPUTS
%     channel       : A scalar channel number in the range [1,84]
%                     (required parameter).
%     quarter       : A scalar quarter number in the range [0,17]
%                     (required parameter). 
%     cadenceType   : A string specifying 'long' or 'short'. Interpretation 
%                     is case-insensitive (required parameter).
%
%     The following are optional inputs specified as attribute/value pairs
%     (see usage example below):
%
%     taskDir       : A root-level task file directory. This directory must
%                     contain a subdirectory named 'uow', which provides
%                     the task-to-channel mapping.
%     outputRoot    : A string specifying the directory under which to save
%                     the results. It will be created if it doesn't exist
%                     already. Results are saved under the current
%                     directory by default.  
%     snrThresh     : SNR above which probability of detection of cosmic
%                     ray effects is high (default=5).  
%     bkgndMean     : Our best guess at the mean background value (in e-)
%                     in the absence of any data (default=1e6). 
%     pdf           : If not specified a PDF is retrieved from the SVN
%     |               repository.
%     |-.x            A pixel event magnitude (photoelectrons)
%      -.p            Probability density at point x, given a pixel event
%                     has occurred p(x | pixel event).
%
% OUTPUTS
%     Creates a directory under outputRoot and saves a .fig file to it.
%
% USAGE EXAMPLE
%     >> generate_cosmic_ray_dawg_figures(1, 15, 'long', ...
%        'taskDir', '~/test', 'pdf', condPdfStruct)
%
% NOTES
%     Definitions:
%         pixel event      The charge deposited in a single pixel by a
%                          cosmic ray. 
%         particle event   The set of all pixel events resulting from a
%                          single particle. 
% 
%     The red curve in the figures is a scaled version of the simulated
%     pixel event probability density function p( c | pixel event ). That
%     is, given that the pixel was affected by a single cosmic ray, the
%     probability density p as a function of the charge c (electrons)
%     deposited in the pixel. The scaling factor is obtained as follows:    
% 
%     1. Determine the cosmic ray magnitude m at which we confidently
%        expect a detection (currently this is set to 5 sigma, where sigma
%        is the mean uncertainty of calibrated background pixels). The 5
%        sigma is based on our simulation experiments during development of
%        the cosmic ray cleaner. The probability of detection was typically
%        high (>0.8) above SNR=5 and near 1.0 by the time SNR > 10.
%     2. Estimate prob( event_magnitude > m) as the integral of the
%        simulation-based PDF on the interval [m,Inf) 
%     3. Count the number N of detected pixel events having magnitude > m.
%     4. Scale factor =  N / prob( event_magnitude > m)
% 
%     Note that we are comparing flight data processing results to a model
%     that has been seen to underestimate the number of higher energy
%     cosmic rays.  The cosmic ray simulations used to produce the
%     conditional PDF assumed the following:
% 
%     -	The adopted cosmic ray flux of 5 per cm^2 per second.
%     -	The distribution of charge deposited per particle event, as
%       estimated by Ball Aerospace. This accounts for pixel sensitivity
%       and refers to the total number of electrons deposited across all
%       affected pixels by a single particle.   
%     -	Charge is "deposited" uniformly along a particle's path through the
%       detector array. 
%     -	Angles of incidence are in the range [0 deg, 89 deg] (we excluded
%       angles close to 90 deg in order to simplify calculations). 
%
%**************************************************************************
    DEFAULT_OUT_DIR       = './cosmic_ray_distribution_figs';
    OUTPUT_FIG_FILE_NAME  = 'cr_energy_distribution.fig';
    OUTPUT_DATA_FILE_NAME = 'histogram_data.mat';
    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addRequired('channel',           @(x)isnumeric(x) && isscalar(x) && ismember(x, 1:84) );
    parser.addRequired('quarter',           @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17      );
    parser.addRequired('cadenceType',       @(s)any(strcmpi(s, {'LONG', 'SHORT'}))               );
    parser.addParamValue('taskDir',                '.', @(s)isdir(s)                             );
    parser.addParamValue('outputRoot', DEFAULT_OUT_DIR, @(s)isdir(s)                             );
    parser.addParamValue('snrThresh',              5.0, @(x)isnumeric(x) && isscalar(x) && x >=0 );
    parser.addParamValue('bkgndMean',              1e6, @(x)isnumeric(x) && isscalar(x) && x >=0 );
    parser.addParamValue('pdf',             struct([]), @(x)isstruct(x)                          );
    parser.parse(channel, quarter, cadenceType, varargin{:});

    [module, output] = convert_to_module_output(parser.Results.channel);
    quarter          = parser.Results.quarter;
    taskDir          = parser.Results.taskDir;
    outputRoot       = parser.Results.outputRoot;
    cadenceType      = parser.Results.cadenceType;
    condPdfStruct    = parser.Results.pdf;
    snrThresh        = parser.Results.snrThresh;
    bkgndMean        = parser.Results.bkgndMean;
    
    % ---------------------------------------------------------------------
    % Configure.
    % ---------------------------------------------------------------------
    isLongCadence = strcmpi(cadenceType, 'long');    
    if isLongCadence
        outputSubDir = 'lc';
    else
        outputSubDir = 'sc';
    end
    
    outputPath = fullfile(outputRoot, outputSubDir, ...
        ['mod_', num2str(module), '_out_', num2str(output)]);
    
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end

    taskFileSubDir = get_group_dir( ...
        'PA', [module, output], 'quarter', quarter, ...
        'rootPath', taskDir, 'fullPath', false); 

    % ---------------------------------------------------------------------
    % Obtain the reference PDF, if not provided.
    % ---------------------------------------------------------------------
    if ~exist('condPdfStruct', 'var') || isempty(condPdfStruct)
        fprintf('Pixel event PDF not specified. Retrieving from SVN repo ...\n');
        
        referencePdfSrc = ['svn+ssh://host/path/to/test-data/', ...
              'condPdfStruct.mat'];

        [~, name, ext] = fileparts(referencePdfSrc);
        referencePdfFileName = [name, ext];
        referencePdfDest = fullfile(outputRoot, referencePdfFileName);
        if ~exist(referencePdfDest, 'file')
            unix(['svn cat ', referencePdfSrc, ' > ', referencePdfDest]);
        end 

        % condPdfStruct.mat contains the pdf p(x | pixel event). That is,
        % given that the pixel was affected by a single cosmic ray particle
        % event, the probability density p at the point x, where x denotes
        % the charge (e-) deposited in the pixel.
        load(referencePdfDest, 'condPdfStruct');
    end
    
    % ---------------------------------------------------------------------
    % Load cosmic ray data and generate figures.
    % ---------------------------------------------------------------------    
    if isLongCadence
        bkgndSubTaskDir = find_subtask_dirs_by_processing_state( ...
            fullfile(taskDir,taskFileSubDir{1}), 'BACKGROUND' );
        load( fullfile( taskDir, taskFileSubDir{1}, bkgndSubTaskDir{1}, ...
              'pa-outputs-0.mat')); 

        % Estimate mean background uncertainy.
        load( fullfile( taskDir, taskFileSubDir{1}, bkgndSubTaskDir{1}, ...
            'pa-inputs-0.mat')); 
        meanBkgndUncertainty = ...
            mean(colvec([inputsStruct.backgroundDataStruct.uncertainties]));
        clear inputsStruct;
        threshold = snrThresh * meanBkgndUncertainty;
        
        % Generate background cosmic ray histogram for this mod.out.
        deltas = [outputsStruct.backgroundCosmicRayEvents.delta];
        subtitle = ['LC background events, module ', num2str(module), ...
            ' output ', num2str(output)];
        [h, binCounts, expectedBinCounts, binCenters] = ...
            generate_histogram_with_fitted_probs(deltas, ...
            condPdfStruct.p, condPdfStruct.x, ...
            threshold, subtitle);
                
    else % Short Cadence
        finalSubTaskDir = find_subtask_dirs_by_processing_state( ...
            fullfile(taskDir,taskFileSubDir{1}), 'AGGREGATE_RESULTS' );
        load( fullfile( taskDir, taskFileSubDir{1}, finalSubTaskDir{1}, ...
            'pa-outputs-0.mat')); 

        % Estimate mean background uncertainy.
        meanBkgndUncertainty = sqrt(bkgndMean);
        threshold = snrThresh * meanBkgndUncertainty;

        % Generate background cosmic ray histogram for this mod.out.
        deltas = [outputsStruct.targetStarCosmicRayEvents.delta];
        subtitle = ['SC M1 target events, module ', num2str(module), ...
            ' output ', num2str(output)];
        [h, binCounts, expectedBinCounts, binCenters] = ...
            generate_histogram_with_fitted_probs(deltas, ...
            condPdfStruct.p, condPdfStruct.x, ...
            threshold, subtitle);
    end
    
    % Save outputs.
    saveas(h, fullfile(outputPath, OUTPUT_FIG_FILE_NAME));
    save(fullfile(outputPath, OUTPUT_DATA_FILE_NAME), ...
        'binCounts', 'expectedBinCounts', 'binCenters');
    close(h);
end

%**************************************************************************
% Plot the histogram of detected events and fit the expected PDF to the
% histogram. What we're interested in seeing is how the RELATIVE
% probabilities between bins agree with the relative frequencies observed.
%**************************************************************************
function [h, binCounts, expectedBinCounts, binCenters] = generate_histogram_with_fitted_probs( ...
    deltas, probabilityDensity, binCenters, threshold, subtitle)

    if ~exist('subtitle','var')
        subtitle = '';
    end

    titleStr = 'Cosmic Ray Pixel Event Charge Histogram';

    % Estimate the probability of a cosmic ray pixel event within each bin.
    binWidths = [diff(binCenters), 0];
    binProbability = probabilityDensity .* binWidths;
    
    % Determine the appropriate scaling factor for the PDF curve.
    firstBinAboveThreshold = find(binCenters > threshold, 1);
    nEventsAboveThreshold = length(find(deltas > threshold));
    probEventMagnitudeGtThreshold = ...
        sum( binProbability( firstBinAboveThreshold:end ) );
    scaleFactor = nEventsAboveThreshold / probEventMagnitudeGtThreshold;
    
    % Create a histogram of pixel event magnitudes, excluding events
    % greater than the level of the last bin center. These are excluded in
    % order to a void plotting a catch-all bin on the right side of the
    % histogram with a large number of counts.
    deltasBelowLastBin = deltas(deltas < binCenters(end));
    h = figure('color', 'white');
    binCounts = hist(deltasBelowLastBin, binCenters);
    bar(binCenters, binCounts)
    yRange = ylim;
    hold on
    plot(binCenters, scaleFactor * binProbability, 'Color', 'r', 'LineWidth', 2);
    xMax = binCenters(end - 1);
    yMax = 1.1 * yRange(2);
    axis([0, xMax, 0, yMax])
    
    title({titleStr, subtitle}, 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('e-');
    ylabel('number of pixel events');
    
    % Mark the threshold on the plot.
    hold on
    yLimits = ylim;
    markerXCoords = [threshold; threshold];
    markerYCoords = [yLimits(1); yLimits(2)];
    plot(markerXCoords, markerYCoords, 'Color', 'g', 'LineWidth', 2, 'LineStyle', '--');
    
    legend({'Detected Pixel Events', 'Expected Pixel Events', 'Confident Dectection Threshold'}, ...
        'Location', 'NorthEast');
    format_current_figure('Scaled Pixel Event PDF', 2.0);

    expectedBinCounts = scaleFactor * binProbability;
end

%**************************************************************************  
% p = mark_cadences_with_lines(h, cadences, color, style, width)
%**************************************************************************  
% INPUTS:
%     h             : An axes handle or [] to use current axes.
%     cadences      : List of relative cadences (indices) to mark.
%     color         : A 3-element vector
%**************************************************************************        
function p = mark_cadences_with_lines(h, cadences, color, style, width)
    if ~any(cadences)
        return
    end

    if ~ishandle(h)
        h = gca;
    end
        
    if ~exist('color','var')
        color = [0.7 0.7 0.7];
    end

    if ~exist('style','var')
        style = '-';
    end

    if ~exist('width','var')
        width = 0.5;
    end

    axes(h);
    
    original_hold_state = ishold(h);
    if original_hold_state == false
        hold on
    end

    nCadences = length(cadences);
    yLimits = ylim;
    markerXCoords = reshape([cadences(:)';cadences(:)'; nan(1, nCadences)], 3*nCadences, 1);
    markerYCoords = repmat([yLimits(1); yLimits(2); nan], nCadences, 1);
    plot(markerXCoords, markerYCoords, 'LineStyle',style,'Color', color, 'LineWidth', width);
        
    
    if original_hold_state == false
        hold off
    end
end

%**************************************************************************
% format_current_figure.m 
% Format all axes in the current figure.
%**************************************************************************
function h_fig = format_current_figure(dataLabels, setLineWidth)

    if ~exist('setLineWidth', 'var')
        setLineWidth = true;
    end
    
    % Get handles for all non-legend axes.
    h_fig   = gcf();
    children = get(h_fig, 'Children');
    h_axes = findobj(children, 'Type', 'axes','-not','Tag','legend');
    
    for iAxes = 1:length(h_axes)
        format_axes(h_axes(iAxes), dataLabels, setLineWidth);
    end

    refreshdata(h_fig);
end

%**************************************************************************
function format_axes(h_axes, dataLabels, setLineWidth)
    FONT = 'Arial';
    LINE_WIDTH = 1.0;
    LINE_WIDTH_DELTA = 1;
        
    h_leg   = legend(h_axes);
    h_title = get(h_axes,'Title');
    h_xlab  = get(h_axes,'XLabel');
    h_ylab  = get(h_axes,'YLabel');

    axesProperties = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'normal', ...
        'LineWidth', 1 ...
        );

    xLabelProperties = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'bold' ...
        );

    titleProperties  = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 16, ...
        'FontWeight', 'bold' ...
        );

    legendProperties  = struct(...
        'FontName',  FONT, ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'normal' ...
        );

    set(h_axes,  axesProperties);
    set(h_title, titleProperties);
    set(h_xlab,  xLabelProperties);
    set(h_ylab,  xLabelProperties);
    set(h_leg,   legendProperties);

    % Modify line widths, if desired.
    if setLineWidth
        h_tmp = get(h_axes, 'Children');
        h_line = findobj(h_tmp, 'Type', 'line');

        % Find lines representing data series
        h_data = [];
        for n = 1:length(h_line)
            if any(strcmp( get(h_line(n), 'DisplayName'), dataLabels ))
                h_data = [h_data, h_line(n)];
            end
        end

        % Plot lines with increasing width (the list of child handles is in the
        % reverse plotting order).
        for i = 1:length(h_data)
            set(h_data(i), 'LineWidth', LINE_WIDTH + i*LINE_WIDTH_DELTA);
        end
    end
    
end

