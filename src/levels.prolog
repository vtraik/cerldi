% given the name of an event/state (X), 
% level returns the level of X

level(X, L):-
	t_entity(X,_,user),
	definition_conditions(X,XBody),
	formula_level(XBody,L1),
	L is L1 + 1.

formula_level(X,0):-
	t_entity(X,event,input). % simple event (picks) 
formula_level(X,L):-
    definition_conditions(X,Y), % event/state def in X (picks_and_drops and drops) 
    formula_level(Y,L).
% binary ops
formula_level(and(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
formula_level(or(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
formula_level(~>(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
formula_level(union(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
formula_level(intersection(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
formula_level(minus(X,Y),L):-
	formula_level(X,XL),
	formula_level(Y,YL),
	max(XL,YL,L).
% unary ops
formula_level(start(X),L):-
	formula_level(X,L).
formula_level(end(X),L):-
	formula_level(X,L).
formula_level(tnot(X),L):-
	formula_level(X,L).








