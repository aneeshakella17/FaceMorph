function [new_img] = beier_neely(source, transfer, source_lines, trans_lines)   
  for i = 0:2:100
     t = i/100.0;     
     new_img = make_image(source, transfer, source_lines, trans_lines, t);
     imshow(new_img)
     imwrite(new_img, strcat(int2str(i), '.jpg'));
  end
end



function [new_img] = make_image(source, transfer, source_lines, trans_lines, t)
   avg_lines = (1 - t) * source_lines + t * trans_lines;
   im1_part = morph(source, source_lines, avg_lines); 
   im2_part = morph(transfer, trans_lines, avg_lines);
   new_img = (1 - t) * im1_part + t * im2_part;
end


function [new_img] = morph(img, img_lines, avg_lines)
a  = 0.1;
b  = 0.5; 
p = 1;
[height, width,~] = size(img);
numlines = size(avg_lines);
new_img = img;


for y = 1:height 
    for x = 1:width 
        X = [x, y];
        sum = 0;
        dsum = [0, 0];
        for line = 1:(numlines - 1)
            Pi = [avg_lines(line, 1), avg_lines(line, 2)];
            Qi = [avg_lines(line + 1, 1), avg_lines(line + 1, 2)];
            QPi = Qi - Pi; 
            
            src_Pi = [img_lines(line, 1), img_lines(line, 2)];
            src_Qi = [img_lines(line + 1,1), img_lines(line + 1, 2)];
            srcQPi = src_Qi - src_Pi; 
            
            u = dot((X - Pi), QPi) / (norm(QPi))^2;
            v = dot((X - Pi), perp(QPi)) / norm(QPi);
            xi = src_Pi+u*srcQPi+(v*perp(srcQPi)) / norm(srcQPi);
            Di = X - xi;
            
            
            if u < 0
               dist = norm(X - Pi);
            elseif u > 1
                dist = norm(X - Qi);
            else
                dist = abs(v);
            end
            
            length = norm(QPi);
            weight = ((length^p)/(a + dist))^b;
            dsum(1) = dsum(1) +  Di(1) * weight;  
            dsum(2) = dsum(2) + Di(2) * weight;
            sum  = sum + weight;
        end
        
        newX(1) = X(1) + dsum(1)/sum;
        newX(2) = X(2) + dsum(2)/sum;
        
        if(newX(1) >= 1 && newX(1) <= width && newX(2) >= 1 && newX(2) <= height)
            new_img(X(2), X(1), :) = img(int32(newX(2)), int32(newX(1)), :);
        else
            new_img(X(2), X(1), :) = img(X(2),X(1), :);
        end
    end
end
end


function ret = perp(vector)
    ret = [-vector(2), vector(1)];
end


function dist = norm(point)
    dist  = sqrt(point(1).^2 + point(2).^2);
end