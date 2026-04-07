%
% Operators of the language ldi
% 

:-op(1149, fx,event_def).
:-op(1149, fx, state_def).

:-op(1199, xfx, :=).

:-op(1039,xfy,minus).
:-op(1038,xfy,intersection). 
:-op(1037,xfy,union).
:-op(1036, xfy, ~>). 

:-op(1035, xfy, or). 
:-op(1034, xfy, and).
:-op(1033, fy, tnot).

op_list([~>, and, or, tnot, start, end,union,intersection,minus]).
