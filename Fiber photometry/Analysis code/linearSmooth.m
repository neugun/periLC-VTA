function result = linearSmooth(data,smooth_res)


r = size(data,1);
c = size(data,2);

ci = 1:smooth_res:c;

result = zeros(r,length(ci));

for i = 1:r
    result(i,:) = interp1(data(i,:),ci,'PCHIP');
end
