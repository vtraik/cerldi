% instant formulas
transform_instant_formula(X, Transformed, T):- % hit input event
    t_entity(X,event,_),
    Transformed = (event(X,T)). % eg. picks_and_drops/drinks
transform_instant_formula(and(X,Y), Transformed, T):-!,
    transform_instant_formula(X, XTr, T),
    transform_instant_formula(Y, YTr, T),
    Transformed = (
        XTr , YTr
    ).
transform_instant_formula(or(X,Y), Transformed, T):-!,
    transform_instant_formula(X, XTr, T),
    transform_instant_formula(Y, YTr, T),
    Transformed = (
        XTr ; YTr
    ).
transform_instant_formula(tnot(X), Transformed, T):-!, % true when X doesnt hold in window
    transform_instant_formula(X, XTr, Ti),
    Transformed = (
        findall(Ti,XTr,XtrueList), % get t where X is true
        list_to_ord_set(XtrueList,XtrueList2),
        get(window_tinstants,CurrentTimeList), % get current window's interval [t1,..,tn]
        ord_subtract(CurrentTimeList,XtrueList2,ResList),
        member(T,ResList)
    ).
transform_instant_formula(start(X), Transformed, T):-!, % [T,_] of Φ-
    transform_durative_formula(X, XTr, I),
    Transformed = (
        findall(I,XTr,XintrvList), % get lists of intervals I where X is true
        list_to_ord_set(XintrvList,XintrvList2), % removes same lists of intrv eg. [[1,2],[3,4]] , [[1,2],[3,4]]
        union_intrvl_L(XintrvList2,Res),
        member([T,_],Res) % return starts of res list
    ).
transform_instant_formula(end(X), Transformed, T):-!, % [_,T] of Φ-
    transform_durative_formula(X, XTr, I),
    Transformed = (
        findall(I,XTr,XintrvList), % get lists of intervals I where X is true
        list_to_ord_set(XintrvList,XintrvList2),
        union_intrvl_L(XintrvList2,Res),
        member([_,T],Res) % return ends of res list
    ).


% Durative formulas
set_formula(OP,Ltr,Rtr,Il,Ir,I,Transformed) :-
    get(id,IdValue),
    Transformed = (
        findall(Il,Ltr,S),
        findall(Ir,Rtr,E),
        get(tstart,Tstart),
        findall(Intrvl,retained_intrvl(Intrvl,IdValue,Tstart),IList), % get previous retained_intervals
        list_to_ord_set(S,SN1), % removes same lists of intrv eg. [[1,2],[3,4]] , [[1,2],[3,4]]
        list_to_ord_set(E,EN1),
        list_to_ord_set(IList,NIList),
        union_intrvl_L(SN1,SN), % merges a list of interval lists 
        union_intrvl_L(EN1,EN),
        get(tstart,Tstart),
        % get starts and ends in window interval
        after_window_start(Tstart,SN,ST),
        after_window_start(Tstart,EN,ET),
        after_window_start(Tstart,NIList,NIListT),
        temporal_operation(OP,ST,ET,TI),
        temporal_union(TI,NIListT,I), % union with retained intervals
        get(tcrit,Tcrit),
        retain_uim(I,IdValue,Tcrit)
    ),
    NIdValue is IdValue + 1, save(id,NIdValue).

temporal_operation(union,S,E,I) :- temporal_union(S,E,I).
temporal_operation(intersection,S,E,I) :- temporal_intersection(S,E,I).
temporal_operation(minus,S,E,I) :- temporal_difference(S,E,I).

transform_durative_formula(X,Transformed,I) :-
    X =.. [OP,L,R],
    member(OP,[union,intersection,minus]), !,
    transform_durative_formula(L,Ltr,Il),
    transform_durative_formula(R,Rtr,Ir),
    set_formula(OP,Ltr,Rtr,Il,Ir,I,Transformed).


transform_durative_formula(X,Transformed,I):- % hit state_def obj
    t_entity(X,state,user),
    Transformed = (state(X,I)).
transform_durative_formula(~>(L,R), Transformed, I):-!,
    get(id,IdValue),
    transform_instant_formula(L,Ltr,Ts),
    transform_instant_formula(R,Rtr,Te),
    Transformed = (
        findall(Ts,Ltr,S),
        findall(Te,Rtr,E),
        get(tstart,Tstart),
        findall(Rs,retained_start(Rs,IdValue,Tstart),LRs), % get list of retained starts 
        list_to_ord_set(S,SUnique),
        list_to_ord_set(E,EUnique),
        list_to_ord_set(LRs,LRsUnique),
        ord_union(SUnique,LRsUnique,NS), % merge previous starts with current 
        maximal_intervals(NS,EUnique,I),
        get(tcrit,Tcrit),
        retain_mi(I,IdValue,Tcrit) % keep starts (if needed) for next windows
    ),
    NIdValue is IdValue + 1, save(id,NIdValue).

% retains starts that overlap Tcrit for later use.
retain_mi([],_,_).
retain_mi([[S,E]|I],Id, Tcrit) :-
    E > Tcrit,
    S =< Tcrit,
    assert_if_not_exists(retained_start(S,Id,Tcrit)),
    retain_mi(I,Id,Tcrit).
retain_mi([[S,E]|I],Id, Tcrit) :-
    \+ (E > Tcrit,S =< Tcrit),
    retain_mi(I,Id,Tcrit).


% retains intervals that overlap Tcrit for later use for oper: union, intersection, minus.
retain_uim([],_,_).
retain_uim([[S,E]|I],Id, Tcrit) :-
    E > Tcrit,
    S =< Tcrit,
    assert_if_not_exists(retained_intrvl([S,E],Id,Tcrit)),
    retain_uim(I,Id,Tcrit).
retain_uim([[S,E]|I],Id, Tcrit) :-
    \+ (E > Tcrit,S =< Tcrit),
    retain_uim(I,Id,Tcrit).


