number = 5;

number = exp(number, 2);

disp(number);

 

function number = exp(number, exp) 

    for i = 2:exp

        number = number * number;

    end

end

disp(exp(2,0))