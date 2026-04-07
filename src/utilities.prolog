:-dynamic pair/2.

max(X,Y,X):-X>=Y,!.
max(_,Y,Y).

min(X,Y,X):-X=<Y,!.
min(_,Y,Y).

all_between(Min,Max,L):- findall(X, between(Min, Max, X), L).

assert_if_not_exists(X):-
    X-> true ; assertz(X).

ifthenelse(Cond, ThenGoal, _) :- 
    call(Cond), 
    !,
    call(ThenGoal).
ifthenelse(_, _, ElseGoal) :- 
    call(ElseGoal).

% tail-rec max_list
max_list(L,Max):-
	max_el(L,-1,Max).
max_el([],Max,Max).
max_el([X|L],Cmax,Max):-
	max(X,Cmax,Ncmax),
	max_el(L,Ncmax,Max).

% save immutable pair<K,V> in db
save(K,V):-
    retractall(pair(K,_)),
    assertz(pair(K,V)).

get(K,V):-
    pair(K,V).

% computes union of a list of lists of intervals [[[1,2],[3,4]],[[5,6],[7,8]]]
union_intrvl_L([],[]).
union_intrvl_L([H|L],Res):-
    union_intrvl_L(L,TailU), % recursively find tail's union
    merge_ilse(H,TailU,R), % merge 1st list (H) with the tail result
    compute_union_intervals(R,0,0,_,Res). % compute their union

% split list of intervals on T
after_window_start(_,[],[]).
after_window_start(T,[[S,E]|L],[[T,E]|AfterL]) :-
    T < E,
    T > S,
    after_window_start(T,L,AfterL).
after_window_start(T,[[_,E]|L],AfterL) :-
    E =< T,
    after_window_start(T,L,AfterL).
after_window_start(T,[[S,E]|L],[[S,E]|AfterL]) :-
    S >= T,
    after_window_start(T,L,AfterL).

% creates t in interval [Tw,Tq]
create_time_instants(Tw,Tq,[]):-
    Tw > Tq.
create_time_instants(Tw,Tq,[Tw|WindowI]):-
    Tw =< Tq,
    T is Tw + 1,
    create_time_instants(T,Tq,WindowI).

% writes to results file (for query time = Tq) every event and each state's result list
% of intervals printed each on a new line 
write_to_results_file(Tq):-
    writeln(resultsfile,"---------------------------"),
    write(resultsfile,"Query at T= "), write(resultsfile,Tq), nl(resultsfile),
    writeln(resultsfile,"---------------------------"),
    findall(_,(t_entity(X, event, user), event(X,T), write(resultsfile,event(X,T)),nl(resultsfile)), _), 
    (
    findall(st(X,T),(t_entity(X, state, user), state(X,T)), States),
    States \= []
    ->  forall(member(st(X, I), States),
            forall(member(Intrvl, I),
                (write(resultsfile, state(X, Intrvl)), nl(resultsfile))
            )
        )
    ;
    true
    ).    
