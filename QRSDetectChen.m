function [idx] = QRSDetectChen(fileName,m, normCnst)
    signal = load(fileName);
    
    signal = signal.val(1,:);

    M = 5;
    alpha = 0.05;
    gama = 0.15;

    b = 1/M*(ones(1, M));
    a = 1;

    y2 = delayseq(reshape(signal,[],1),-(M+1)/2);

    y2 = reshape(y2,1,[]);

    y1 = filter(b, a, signal);

    y = y2 - y1;

    y = y.^2;

    y = movsum(y, 54);
    x = 1:length(y);


    local_maxima = islocalmax(y(1:5000),'MinSeparation',230);

    threshold = alpha*gama*mean(y(local_maxima));

    max_peak = 0;

    on_hill = 0;
    complexes = 1;

    for i=1:length(y)
        if y(i) >= threshold && on_hill == 0
            left_border = i - 1;
            on_hill = 1;
        end
        if y(i) <= threshold && on_hill == 1 
            on_hill = 0;
            right_border = i;
            peak_loc = (left_border + right_border)/2;
            peak_loc = floor(peak_loc);
            ecgs(complexes) = peak_loc;
            complexes = complexes + 1;
            threshold = alpha*gama*max_peak + (1-alpha)*threshold;
        end
        if on_hill == 1
            if y(i) >= max_peak
               max_peak = y(i); 
            end
        end
    end
    
    idx = ecgs;

    plot(x,y,x(local_maxima),y(local_maxima),'r*')
    
end

