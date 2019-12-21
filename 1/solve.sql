create table inputs (mass int);
\copy inputs from 'input.text';

select sum((mass / 3) - 2) from inputs;
