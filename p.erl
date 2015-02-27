%% Kamil Tekiela 27/02/2015
%% IT Carlow AI assignement

-module(p).
-compile(export_all).


%PARSER
parser(L) -> 
	Lex = lexer(L),
	{R, []} = p([], Lex),
	R.

p(_, [ '(' | P]) -> 
	{In, Out} = p([], P),
	p(In, Out);
p(R, [ ')' | P]) -> {R, P};
p(B, [ {oper, O} = _ | P]) -> 
	{A, T} = p(null, P),
	p({O, B, A}, T);
p([], [N | P]) -> p(N, P);
p(_, [N | P]) -> {N, P};
p(R, T) -> {R, T}.

lexer([$~|R]) -> 	[{num, 0}, {oper, minus}] ++ lexer(R);		%additive inverse
lexer([$(|R]) -> 	[ '(' 					| lexer(R)];
lexer([$)|R]) -> 	[ ')' 					| lexer(R)];
lexer([$+|R]) -> 	[{oper, plus}		| lexer(R)];
lexer([$-|R]) -> 	[{oper, minus} 	| lexer(R)];
lexer([$*|R]) -> 	[{oper, mul}		| lexer(R)];
lexer([$/|R]) -> 	[{oper, divis}		| lexer(R)];
lexer([X|_] = L) when X =< $9, X >= $0 ->
	{Num, R} = lex_num(L, 0),
	[{num, Num}|lexer(R)];
lexer([_|R]) -> lexer(R);
lexer([]) -> [].
	
lex_num([X|R], N) when X =< $9, X >= $0 ->
	lex_num(R, 10*N + X - $0);
lex_num(R, N) -> {N, R}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%EVALUATOR
evaluator({minus, A, B}) -> 		evaluator(A)-evaluator(B);
evaluator({plus, A, B}) ->			evaluator(A)+evaluator(B);
evaluator({mul, A, B}) ->			evaluator(A)*evaluator(B);
evaluator({divis, A, B}) ->			evaluator(A)/evaluator(B);
evaluator({num, A}) ->				A.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%COMPILER
compiler(E) ->
	C = c(E, [{pop}, {ret}]),
	C.

c({minus, A, B}, L) -> 		N1 = [{sub} | L], N2 = c(A, N1), 	c(B, N2);
c({plus, A, B}, L) -> 		N1 = [{add} | L], N2 = c(A, N1), 	c(B, N2);
c({mul, A, B}, L) -> 		N1 = [{mul} | L], N2 = c(A, N1), 	c(B, N2);
c({divis, A, B}, L) -> 		N1 = [{'div'} | L], N2 = c(A, N1), 	c(B, N2);
c({num, A}, L) ->			[{push, {num, A}}| L].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SIMULATOR
simulator(P) -> 
	ok = s(P, []).
	
s([{push, {num, N}} | P], S) -> 	s(P, [N|S]);
s([{sub} | P], [N1, N2 | S]) -> 		s(P, [N1-N2|S]);
s([{add} | P], [N1, N2 | S]) -> 		s(P, [N1+N2|S]);
s([{mul} | P], [N1, N2 | S]) -> 		s(P, [N1*N2|S]);
s([{'div'} | P], [N1, N2 | S]) -> 		s(P, [N1/N2|S]);
s([{pop} | P], [N1| S]) -> 			io:format("~p~n", [N1]), s(P, S);
s([{ret} | _], []) -> 					ok.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

