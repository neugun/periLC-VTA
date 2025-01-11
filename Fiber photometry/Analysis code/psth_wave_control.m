function [psth_control] = psth_wave_control(trigger_times,interval,values,control_from,control_to,offset,z_score)
    N = length(values);                              %%%���к�interval�йأ���Ҫ�ı���ֵ
    %�õ�psth����Ҫ����trigger1_times�����������룩,interval��0.01��,values��Ƶ�ʣ�,basal_time��2��,odor_time��10��,control_time(-2),control_time(0),offset,z_scoreʮ��ֵ
    times = 0:interval:(N-1)*interval;            %%%���к�interval�йأ���Ҫ�ı���ֵ
    times = times';
    val1 = cell(1,length(trigger_times));
    val2 = cell(1,length(trigger_times));
    
for i=1:length(trigger_times)                              %ʹ����һ��ѭ�����
       k1 = times > trigger_times(i) + control_from & times < trigger_times(i) + control_to;   %timesҪ���ڣ�-2,0֮�䣩k1=1
       b = trigger_times(i) +control_from;                   %b=98
       c = trigger_times(i) +control_to;                    %b=110
%        d = times(1295:2494)
        k = times >= b & times < c;                       %k=(1)
        if sum(k) > (-control_from+control_to)/interval           %(basal_time+odor_time)/interval =1200 %%%���к�interval�йأ���Ҫ�ı���ֵ
            m = find(k == 1,1,'first');
            k(m) = [];
        end
        if sum(k) < (-control_from+control_to)/interval
            m = find(k == 1,1,'first');
            k(m-1)=1;                        %û����
        end
       
       val1{1,i} = values(k1)-offset;              %Ϊ��ͬʱ��ȥoffset.val1��ʾÿһ��ʱ����ֵ������K1��ʾ
       val2{1,i} = values(k)-offset;               %val1��ʾÿһ��ʱ����ֵ��k��ʾת��������ʱ��
       average = mean(values(k1)-offset);      %����ֱ�ӵ�ֵ
       stdev = std(values(k1)-offset);
       if z_score==1                        %����zscore,                                          ���Ƿŵ�Ļ������㷽���Ͳ���Ҫ - average)/(average)��ֱ����values;
       pre = (values(k)-offset - average)/stdev;
       else
       pre = (values(k)-offset - average)/(average);
       end   
       val2{1,i} = pre;                     %��pre��ֵ����val2                                %%%%%%%%%%%%%%%%%%%%
       
end

psth_control= cell2mat(val2)';                     
