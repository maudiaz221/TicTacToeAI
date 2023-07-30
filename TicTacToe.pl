:- dynamic iplayed/1, play/1, oppPlayed/1, allPlayed/1.

play(1).
play(2).
play(3).
play(4).
play(5).
play(6).
play(7).
play(8).
play(9).

min(X,Y,X):-
	X < Y,!.
min(_,Y,Y).

max(X,Y,X):-
	X > Y,!.
max(_,Y,Y).

encuentraMax([[Play,_]],Play).
encuentraMax([[Play1,Value1],[Play2,Value2]|Cola],Play):-
	max(Value1,Value2,Mayor),
	(Mayor is Value1 -> encuentraMax([[Play1,Mayor]|Cola],Play)
		;encuentraMax([[Play2,Mayor]|Cola],Play)),!.





start(Play,1):-
	assertz(iplayed(Play)),
	assertz(allPlayed(Play)),
	retract(play(Play)),
	!.

start(Play,0):-
	assertz(oppPlayed(Play)),
	assertz(allPlayed(Play)),
	retract(play(Play)),
	!.

unstart(Play,Turn):-
	(Turn =:= 0 -> retract(oppPlayed(Play)),retract(allPlayed(Play)),assertz(play(Play))
	; retract(iplayed(Play)),retract(allPlayed(Play)),assertz(play(Play))).

playsMade(PlaysMade):-
	findall(Play, allPlayed(Play),PlaysMade),
	!.

playsOpponentMade(PlaysMadeOpp):-
	findall(Play, oppPlayed(Play),PlaysMadeOpp),
	!.

playsIMade(PlaysIMade):-
	findall(Play, iplayed(Play),PlaysIMade),
	!.


possiblePlays(Plays):-
	findall(Play, play(Play),Plays),
	!.


reset():-
	retractall(play(_)),
	retractall(oppPlayed(_)),
	retractall(iplayed(_)),
	retractall(allPlayed(_)),
	assertz(play(1)),
	assertz(play(2)),
	assertz(play(3)),
	assertz(play(4)),
	assertz(play(5)),
	assertz(play(6)),
	assertz(play(7)),
	assertz(play(8)),
	assertz(play(9)).

revise(Win):-
	(((iplayed(1),iplayed(2),iplayed(3));(iplayed(1),iplayed(5),iplayed(9))
				;(iplayed(1),iplayed(4),iplayed(7));(iplayed(7),iplayed(8),iplayed(9))
				;(iplayed(7),iplayed(5),iplayed(3));(iplayed(3),iplayed(6),iplayed(9))
				;(iplayed(4),iplayed(5),iplayed(6));(iplayed(8),iplayed(5),iplayed(2))) -> Win is 1

	;((oppPlayed(1),oppPlayed(2),oppPlayed(3));(oppPlayed(1),oppPlayed(5),oppPlayed(9))
				;(oppPlayed(1),oppPlayed(4),oppPlayed(7));(oppPlayed(7),oppPlayed(8),oppPlayed(9))
				;(oppPlayed(7),oppPlayed(5),oppPlayed(3));(oppPlayed(3),oppPlayed(6),oppPlayed(9))
				;(oppPlayed(4),oppPlayed(5),oppPlayed(6));(oppPlayed(8),oppPlayed(5),oppPlayed(2))) -> Win is -1
	;(not(play(_)) -> Win is 0.5; false)).


choose(Play,Heuristic):-
	possiblePlays(Plays),
	length(Plays,Depth),
	minimax(Play,Lista,Depth,1,Heuristic),
	encuentraMax(Lista,Play),
	write(Lista),
	start(Play,1).


%ganoPierdoEnMedioDelJuego


minimax(_,_,_,_,Heuristic):-
	revise(Heuristic),
	!.

%alcanceMaxDepth

minimax(_,_,0,_,Heuristic):-
	revise(Heuristic),
	!.

%1esX
minimax(Play,Lista,Depth,1,Heuristic):-
	possiblePlays(Plays),
	NewDepth is Depth -1,
	BestValue is -50,
	forEachPlay(Play,Lista,Plays,1,BestValue,NewDepth,Aregresar),
	Heuristic = Aregresar,
	!.


%1esO
minimax(Play,Lista,Depth,0,Heuristic):-
	possiblePlays(Plays),
	NewDepth is Depth -1,
	BestValue is 50,
	forEachPlay(Play,Lista,Plays,0,BestValue,NewDepth,Aregresar),
	Heuristic = Aregresar,
	!.

%al guardar el maximo valor heuristico tambien puedo guardar la jugada que deberia hacer
%caso para el maximizador
forEachPlay(_,_,[],1,NewBest,_,NewBest):-!.

forEachPlay(Play,[[Playi,Heuristic]|Cola],[Playi|Resto],1,BestValue,Depth,Aregresar):-
	start(Playi,1),
	minimax(Play,_,Depth,0,Heuristic),
	max(BestValue,Heuristic,NewBest),
	unstart(Playi,1),
	forEachPlay(Play,Cola,Resto,1,NewBest,Depth,Aregresar).
	

%faltacasoparamin

forEachPlay(_,_,[],0,NewBest,_,NewBest).

forEachPlay(Play,[[Playi,Heuristic]|Cola],[Playi|Resto],0,BestValue,Depth,Aregresar):-
	start(Playi,0),
	minimax(Play,_,Depth,1,Heuristic),
	min(BestValue,Heuristic,NewBest),
	unstart(Playi,0),
	forEachPlay(Play,Cola,Resto,0,NewBest,Depth,Aregresar).
