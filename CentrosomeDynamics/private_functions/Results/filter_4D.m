function B = filter_4D(A, dims)

h =  ones(dims(1),dims(2),dims(3),dims(4)) / (dims(1)*dims(2)*dims(3)*dims(4));
B = imfilter(A,h);
