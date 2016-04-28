function res = shiftImg(im, vect)

height = size(im, 1);
width = size(im, 2);

[pty, ptx] = find(im ~= 0);
%pty = pty + vect(1,1);
pty = pty - vect(1,1);
ptx = ptx + vect(1,2);

invalid = (pty > height) | (pty < 1) | (ptx > width) | (ptx < 1);

pty(invalid) = [];
ptx(invalid) = [];

res = zeros(height, width);
idx = sub2ind([height, width], round(pty), round(ptx));
res(idx) = 1;
end