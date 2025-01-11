function [psth,psth_mean, sem] = psth_wave2(trigger_times,interval,values, ...
    basal_time,odor_time,control_from,control_to,offset,z_score,Bout_off)
    N = length(values);                            
    times = 0:interval:(N-1)*interval;            %%%
    times = times';
%     val1 = cell(1,length(trigger_times));
    val2 = cell(1,length(trigger_times));
           
    
for i=1:length(trigger_times)                              %
       k1 = times > trigger_times(i) + control_from & times < trigger_times(i) + control_to;   %times
       b = trigger_times(i) - basal_time;                   %b=98
       c = trigger_times(i) + odor_time;                    %b=110
       k = times >= b & times <= c;                       %k=(1)

        if sum(k)< 1
            break;  % ZZ add, Exit the loop if x is equal to 1
        end
        
        if sum(k) > (basal_time+odor_time)/interval           %(basal_time+odor_time)/interval =1200 %%%
            m = find(k == 1,1,'first');
            k(m) = [];
        end
        if sum(k) < (basal_time+odor_time)/interval
            m = find(k == 1,1,'first');
            if m >1
                k(m-1)=1;  %%ZZ edit 03132024
            end
        end

       
%        val1{1,i} = values(k1)-offset;              %
        val2{1,i} = values(k)-offset;               %val1
       
       %% original 
       average = mean(values(k1)-offset);      %
       stdev = std(values(k1)-offset);
       
       
       if z_score==1                        %
           pre = (values(k)-offset - average)/stdev;
       elseif z_score==0 
           pre = (values(k)-offset - average)/(average);
       else            
           %% all activity


%            %% filter data
%             % Calculate the mean and standard deviation
%             meanValue = mean(Bout_off);
%             stdDev = std(Bout_off);
%             
%             % Define the cutoff values (2 standard deviations from the mean)
%             lowerBound = meanValue - 2 * stdDev;
%             upperBound = meanValue + 2 * stdDev;
%             
%             % Find indices of values within 2 standard deviations
%             indicesWithinBounds = (Bout_off >= lowerBound) & (Bout_off <= upperBound);
%             
%             % Filter the data
%             Bout_off = Bout_off(indicesWithinBounds);

           average = mean(Bout_off -offset);      %
%            average = median(Bout_off -offset); 

           stdev = std(Bout_off -offset);
           pre = (values(k)- offset - average)/stdev; 
       end   
       val2{1,i} = pre;                      %%%%%%%%%%%%%%%%%%%%
       
end

%% ZZ edit 20240617, the first array is not right size
        % Get the size of each array
        sizes = cellfun(@(x) size(x, 1), val2);        
        % Find the most common size
        most_common_size = mode(sizes);
        % Pad arrays to match the most common size
        val2 = cellfun(@(x) [x; zeros(most_common_size - size(x, 1), 1)], val2, 'UniformOutput', false);

psth = cell2mat(val2)';                     

sem = std(psth)/(length(trigger_times)-1)^0.5;
psth_mean = mean(psth,1);
% psth_mean = mean(psth,2);