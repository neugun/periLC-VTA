function [psth_control] = psth_wave_control(trigger_times,interval,values,control_from,control_to,offset,z_score)
    N = length(values);                              %%%
    %
    times = 0:interval:(N-1)*interval;            
    times = times';
    val1 = cell(1,length(trigger_times));
    val2 = cell(1,length(trigger_times));
    
for i=1:length(trigger_times)                             
       k1 = times > trigger_times(i) + control_from & times < trigger_times(i) + control_to;   
       b = trigger_times(i) +control_from;                  
       c = trigger_times(i) +control_to;                   
        k = times >= b & times < c;                      
        if sum(k) > (-control_from+control_to)/interval           
            m = find(k == 1,1,'first');
            k(m) = [];
        end
        if sum(k) < (-control_from+control_to)/interval
            m = find(k == 1,1,'first');
            k(m-1)=1;                        
        end
       
       val1{1,i} = values(k1)-offset;              
       val2{1,i} = values(k)-offset;               
       average = mean(values(k1)-offset);      
       stdev = std(values(k1)-offset);
       if z_score==1                         
           pre = (values(k)-offset - average)/stdev;
       else
           pre = (values(k)-offset - average)/(average);
       end   
       val2{1,i} = pre;                     
end

psth_control= cell2mat(val2)';                     
