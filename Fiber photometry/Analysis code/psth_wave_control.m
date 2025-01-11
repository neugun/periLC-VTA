function [psth_control] = psth_wave_control(trigger_times,interval,values,control_from,control_to,offset,z_score)
    N = length(values);                              %%%所有和interval有关，需要改变数值
    %得到psth，需要输入trigger1_times（共几个输入）,interval（0.01）,values（频率）,basal_time（2）,odor_time（10）,control_time(-2),control_time(0),offset,z_score十个值
    times = 0:interval:(N-1)*interval;            %%%所有和interval有关，需要改变数值
    times = times';
    val1 = cell(1,length(trigger_times));
    val2 = cell(1,length(trigger_times));
    
for i=1:length(trigger_times)                              %使用了一个循环语句
       k1 = times > trigger_times(i) + control_from & times < trigger_times(i) + control_to;   %times要介于（-2,0之间）k1=1
       b = trigger_times(i) +control_from;                   %b=98
       c = trigger_times(i) +control_to;                    %b=110
%        d = times(1295:2494)
        k = times >= b & times < c;                       %k=(1)
        if sum(k) > (-control_from+control_to)/interval           %(basal_time+odor_time)/interval =1200 %%%所有和interval有关，需要改变数值
            m = find(k == 1,1,'first');
            k(m) = [];
        end
        if sum(k) < (-control_from+control_to)/interval
            m = find(k == 1,1,'first');
            k(m-1)=1;                        %没看懂
        end
       
       val1{1,i} = values(k1)-offset;              %为何同时减去offset.val1表示每一个时间点的值，但是K1表示
       val2{1,i} = values(k)-offset;               %val1表示每一个时间点的值，k表示转换过来的时间
       average = mean(values(k1)-offset);      %先算直接的值
       stdev = std(values(k1)-offset);
       if z_score==1                        %先算zscore,                                          但是放电的话，计算方法就不需要 - average)/(average)，直接是values;
       pre = (values(k)-offset - average)/stdev;
       else
       pre = (values(k)-offset - average)/(average);
       end   
       val2{1,i} = pre;                     %将pre的值赋予val2                                %%%%%%%%%%%%%%%%%%%%
       
end

psth_control= cell2mat(val2)';                     
