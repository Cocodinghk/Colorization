function [res]=add_edge(img, thresh)
    % add edge map in input image
    % using canny operator
    img_binarized = im2bw(img, thresh);
    res = edge(img_binarized, 'canny');
    res = uint8(res * 255) + img;

