function [freq_pow,conditions,all_combos, n_trials] = whisker_freq(data_table,varargin)

% defaults parameters
params = struct(...
    'CNO'                , [false true],... 
    'postlesion_ION'     , [false true],...
    'essai_tente'        , [      true],...
    'reward_zone_width'  , [        30],...
    'essai_interessai'   , [      true],...
    'hold_time'          , 1           ,...
    'reussite'           , [      true],...
    ...
    'wind'         , 100,  ... % in ms, length of Hamming window
    'noverlap'     , 50,   ... % window overlap, in % of 'wind'
    'nlog'         , false, ... % log normalize
    ...
    'fs'           ,1000,...
    'low_band'     ,[0 3],...
    'med_band'     ,[3 15],...
    'hi_band'      ,[15 30]...
    );

params = parse_input_params(params,varargin);

conditions = {'CNO','postlesion_ION','essai_tente','reward_zone_width','essai/interessai','hold_time','reussite'};
condition_values = { params.CNO, params.postlesion_ION, params.essai_tente, params.reward_zone_width,...
                     params.essai_interessai, params.hold_time, params.reussite};

                 
% stft params                 
wind_pts  = floor(params.wind*params.fs/1000);
nover_pts = floor(wind_pts*params.noverlap/100);
if params.nlog
    nfft = logspace(log10(1),log10(30),256);
else
    nfft = 30*(1:256)/256;
end

%identify all possible combinations of condition values
num_cond_vals = cellfun(@numel,condition_values);
num_combo     = prod(num_cond_vals);
all_combos    = nan(num_combo,length(conditions));
all_indexes   = cell(num_combo,1);
n_trials      = zeros(num_combo,1);

% variables to store band power
low_f = nan(num_combo,1);
med_f = nan(num_combo,1);
hi_f  = nan(num_combo,1);
low_f_lastsec = nan(num_combo,1);
med_f_lastsec = nan(num_combo,1);
hi_f_lastsec  = nan(num_combo,1);

for cond = 1:length(conditions)
    cond_pattern       = repmat(condition_values{cond},prod(num_cond_vals(1:cond-1)),1);
    all_combos(:,cond) = repmat(cond_pattern(:),num_combo/numel(cond_pattern),1);
end
               
% find table indexes for all possible combinations of condition values
for combo = 1:num_combo
    relevant_trials = 1:size(data_table,2);
    for cond = 1:length(conditions)
        relevant_trials = relevant_trials(cell2mat(data_table{conditions(cond),relevant_trials})==all_combos(combo,cond));
    end
    all_indexes{combo} = relevant_trials;
    n_trials(combo)    = length(relevant_trials);
end
figure;

% perfor analyses trial by trial
for combo = 1:num_combo
    relevant_trials = all_indexes{combo};
    for trial = 1:length(relevant_trials)
        whisker_pos = data_table{{'position_vibrisse'},relevant_trials(trial)}{:};
        
        % correct for missing points and slightly smooth
        timeframe = (0:numel(whisker_pos)-1)*(1/params.fs);      
        inn = ~isnan(whisker_pos);
        whisker_pos = smooth(interp1(timeframe(inn),whisker_pos(inn),timeframe,'spline'));        
        
        [s,f,t] = spectrogram(detrend(whisker_pos,'constant'),wind_pts,nover_pts,nfft,params.fs);
        
%         subplot(2,1,1);
%         spectrogram(detrend(whisker_pos,'constant'),params.wind,params.noverlap,nfft,fs,'yaxis');
%         subplot(2,1,2);
%         hold off;
%         plot(timeframe,whisker_pos);
%         hold on;
%         plot( [tw(1) tw(end)],[100 130;100 130],'k-','linewidth',2);
        
        low_f(combo,trial)         = mean(mean(abs(s(f>=params.low_band(1) & f<=params.low_band(2),:))));
        low_f_lastsec(combo,trial) = mean(mean(abs(s(f>=params.low_band(1) & f<=params.low_band(2),t>=timeframe(end)-1))));
        med_f(combo,trial)         = mean(mean(abs(s(f>=params.med_band(1) & f<=params.med_band(2),:))));
        med_f_lastsec(combo,trial) = mean(mean(abs(s(f>=params.med_band(1) & f<=params.med_band(2),t>=timeframe(end)-1))));
        hi_f(combo,trial)          = mean(mean(abs(s(f>=params.hi_band(1)  & f<=params.hi_band(2),:))));
        hi_f_lastsec(combo,trial)  = mean(mean(abs(s(f>=params.hi_band(1)  & f<=params.hi_band(2),t>=timeframe(end)-1))));
        
%         pause;
        
    end
end

freq_pow = struct('low_band'      ,low_f,...
                  'med_band'      ,med_f,...
                  'hi_band'       ,hi_f,...
                  'low_band_hold' ,low_f_lastsec,...
                  'med_band_hold' ,med_f_lastsec,...
                  'hi_band_hold'  ,hi_f_lastsec);
              

%% Todo Michael:
% 1- transpose the table to allow direct  variable access using '.' (e.g. table.duree)
% 2- Use variable names that are short, but informative (e.g. jui-2-6_allsessions, not 'table' or 'experiment.m'). 
% 3- do not use the '/' character in variable names (e.g. 'essai/interessai')

end