-file("/home/mateus.santana/.asdf/installs/erlang/22.3.4/lib/parsetools-2.1.8/include/leexinc.hrl", 0).
%% The source of this file is part of leex distribution, as such it
%% has the same Copyright as the other files in the leex
%% distribution. The Copyright is defined in the accompanying file
%% COPYRIGHT. However, the resultant scanner generated by leex is the
%% property of the creator of the scanner and is not covered by that
%% Copyright.

-module(safe_erl_term).

-export([string/1,string/2,token/2,token/3,tokens/2,tokens/3]).
-export([format_error/1]).

%% User code. This is placed here to allow extra attributes.
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 24).

-export([terms/1]).

terms(Tokens) ->
  terms(Tokens, []).

terms([{dot, _} = H], Buffer) ->
  [buffer_to_term([H|Buffer])];
terms([{dot, _} = H|T], Buffer) ->
  [buffer_to_term([H|Buffer])|terms(T, [])];
terms([H|T], Buffer) ->
  terms(T, [H|Buffer]).

buffer_to_term(Buffer) ->
  {ok, Term} = erl_parse:parse_term(lists:reverse(Buffer)),
  Term.

unquote(TokenChars, TokenLen) ->
  lists:sublist(TokenChars, 2, TokenLen - 2).

tokenize_atom(TokenChars, TokenLine) ->
  try list_to_existing_atom(TokenChars) of
    Atom -> {token, {atom, TokenLine, Atom}}
  catch
    error:badarg -> {error, "illegal atom " ++ TokenChars}
  end.

escape([$\\|Cs]) ->
  do_escape(Cs);
escape([C|Cs]) ->
  [C|escape(Cs)];
escape([]) -> [].

do_escape([O1,O2,O3|S]) when
    O1 >= $0, O1 =< $7, O2 >= $0, O2 =< $7, O3 >= $0, O3 =< $7 ->
  [(O1*8 + O2)*8 + O3 - 73*$0|escape(S)];
do_escape([$^,C|Cs]) ->
  [C band 31|escape(Cs)];
do_escape([C|Cs]) when C >= $\000, C =< $\s ->
  escape(Cs);
do_escape([C|Cs]) ->
  [escape_char(C)|escape(Cs)].

escape_char($n) -> $\n;       %\n = LF
escape_char($r) -> $\r;       %\r = CR
escape_char($t) -> $\t;       %\t = TAB
escape_char($v) -> $\v;       %\v = VT
escape_char($b) -> $\b;       %\b = BS
escape_char($f) -> $\f;       %\f = FF
escape_char($e) -> $\e;       %\e = ESC
escape_char($s) -> $\s;       %\s = SPC
escape_char($d) -> $\d;       %\d = DEL
escape_char(C) -> C.

-file("/home/mateus.santana/.asdf/installs/erlang/22.3.4/lib/parsetools-2.1.8/include/leexinc.hrl", 14).

format_error({illegal,S}) -> ["illegal characters ",io_lib:write_string(S)];
format_error({user,S}) -> S.

string(String) -> string(String, 1).

string(String, Line) -> string(String, Line, String, []).

%% string(InChars, Line, TokenChars, Tokens) ->
%% {ok,Tokens,Line} | {error,ErrorInfo,Line}.
%% Note the line number going into yystate, L0, is line of token
%% start while line number returned is line of token end. We want line
%% of token start.

string([], L, [], Ts) ->                     % No partial tokens!
    {ok,yyrev(Ts),L};
string(Ics0, L0, Tcs, Ts) ->
    case yystate(yystate(), Ics0, L0, 0, reject, 0) of
        {A,Alen,Ics1,L1} ->                  % Accepting end state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {A,Alen,Ics1,L1,_S1} ->              % Accepting transistion state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {reject,_Alen,Tlen,_Ics1,L1,_S1} ->  % After a non-accepting state
            {error,{L0,?MODULE,{illegal,yypre(Tcs, Tlen+1)}},L1};
        {A,Alen,Tlen,_Ics1,L1,_S1} ->
            Tcs1 = yysuf(Tcs, Alen),
            L2 = adjust_line(Tlen, Alen, Tcs1, L1),
            string_cont(Tcs1, L2, yyaction(A, Alen, Tcs, L0), Ts)
    end.

%% string_cont(RestChars, Line, Token, Tokens)
%% Test for and remove the end token wrapper. Push back characters
%% are prepended to RestChars.

-dialyzer({nowarn_function, string_cont/4}).

string_cont(Rest, Line, {token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, {end_token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, skip_token, Ts) ->
    string(Rest, Line, Rest, Ts);
string_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, Ts);
string_cont(_Rest, Line, {error,S}, _Ts) ->
    {error,{Line,?MODULE,{user,S}},Line}.

%% token(Continuation, Chars) ->
%% token(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {token,State,CurrLine,TokenChars,TokenLen,TokenLine,AccAction,AccLen}

token(Cont, Chars) -> token(Cont, Chars, 1).

token([], Chars, Line) ->
    token(yystate(), Chars, Line, Chars, 0, Line, reject, 0);
token({token,State,Line,Tcs,Tlen,Tline,Action,Alen}, Chars, _) ->
    token(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Action, Alen).

%% token(State, InChars, Line, TokenChars, TokenLen, TokenLine,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% The argument order is chosen to be more efficient.

token(S0, Ics0, L0, Tcs, Tlen0, Tline, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{token,S1,L1,Tcs,Alen1,Tline,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{token,S1,L1,Tcs,Tlen1,Tline,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     true -> {eof,L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,Ics1,L1,_S1} ->    % No token match
            Error = {Tline,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            {done,{error,Error,L1},Ics1};
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->       % Use last accept match
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            token_cont(Tcs1, L2, yyaction(A1, Alen1, Tcs, Tline))
    end.

%% token_cont(RestChars, Line, Token)
%% If we have a token or error then return done, else if we have a
%% skip_token then continue.

-dialyzer({nowarn_function, token_cont/3}).

token_cont(Rest, Line, {token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, {end_token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {end_token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, skip_token) ->
    token(yystate(), Rest, Line, Rest, 0, Line, reject, 0);
token_cont(Rest, Line, {skip_token,Push}) ->
    NewRest = Push ++ Rest,
    token(yystate(), NewRest, Line, NewRest, 0, Line, reject, 0);
token_cont(Rest, Line, {error,S}) ->
    {done,{error,{Line,?MODULE,{user,S}},Line},Rest}.

%% tokens(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Tokens,AccAction,AccLen}
%% {skip_tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Error,AccAction,AccLen}

tokens(Cont, Chars) -> tokens(Cont, Chars, 1).

tokens([], Chars, Line) ->
    tokens(yystate(), Chars, Line, Chars, 0, Line, [], reject, 0);
tokens({tokens,State,Line,Tcs,Tlen,Tline,Ts,Action,Alen}, Chars, _) ->
    tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Ts, Action, Alen);
tokens({skip_tokens,State,Line,Tcs,Tlen,Tline,Error,Action,Alen}, Chars, _) ->
    skip_tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Error, Action, Alen).

%% tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Ts, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Alen1,Tline,Ts,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Tlen1,Tline,Ts,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error, no need to skip here.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     Ts == [] -> {eof,L1};
                     true -> {ok,yyrev(Ts),L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            %% Skip rest of tokens.
            Error = {L1,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            tokens_cont(Tcs1, L2, Token, Ts)
    end.

%% tokens_cont(RestChars, Line, Token, Tokens)
%% If we have an end_token or error then return done, else if we have
%% a token then save it and continue, else if we have a skip_token
%% just continue.

-dialyzer({nowarn_function, tokens_cont/4}).

tokens_cont(Rest, Line, {token,T}, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {end_token,T}, Ts) ->
    {done,{ok,yyrev(Ts, [T]),Line},Rest};
tokens_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    {done,{ok,yyrev(Ts, [T]),Line},NewRest};
tokens_cont(Rest, Line, skip_token, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {error,S}, _Ts) ->
    skip_tokens(Rest, Line, {Line,?MODULE,{user,S}}).

%%skip_tokens(InChars, Line, Error) -> {done,{error,Error,Line},Ics}.
%% Skip tokens until an end token, junk everything and return the error.

skip_tokens(Ics, Line, Error) ->
    skip_tokens(yystate(), Ics, Line, Ics, 0, Line, Error, reject, 0).

%% skip_tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

skip_tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Error, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        {A1,Alen1,Ics1,L1} ->                  % Accepting end state
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,[],L1,S1} ->                 % After an accepting state
            {more,{skip_tokens,S1,L1,Tcs,Alen1,Tline,Error,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,Tlen1,[],L1,S1} ->           % After a non-accepting state
            {more,{skip_tokens,S1,L1,Tcs,Tlen1,Tline,Error,A1,Alen1}};
        {reject,_Alen1,_Tlen1,eof,L1,_S1} ->
            {done,{error,Error,L1},eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            skip_cont(Tcs1, L2, Token, Error)
    end.

%% skip_cont(RestChars, Line, Token, Error)
%% Skip tokens until we have an end_token or error then return done
%% with the original rror.

-dialyzer({nowarn_function, skip_cont/4}).

skip_cont(Rest, Line, {token,_T}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {end_token,_T}, Error) ->
    {done,{error,Error,Line},Rest};
skip_cont(Rest, Line, {end_token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    {done,{error,Error,Line},NewRest};
skip_cont(Rest, Line, skip_token, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {skip_token,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {error,_S}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0).

-compile({nowarn_unused_function, [yyrev/1, yyrev/2, yypre/2, yysuf/2]}).

yyrev(List) -> lists:reverse(List).
yyrev(List, Tail) -> lists:reverse(List, Tail).
yypre(List, N) -> lists:sublist(List, N).
yysuf(List, N) -> lists:nthtail(N, List).

%% adjust_line(TokenLength, AcceptLength, Chars, Line) -> NewLine
%% Make sure that newlines in Chars are not counted twice.
%% Line has been updated with respect to newlines in the prefix of
%% Chars consisting of (TokenLength - AcceptLength) characters.

-compile({nowarn_unused_function, adjust_line/4}).

adjust_line(N, N, _Cs, L) -> L;
adjust_line(T, A, [$\n|Cs], L) ->
    adjust_line(T-1, A, Cs, L-1);
adjust_line(T, A, [_|Cs], L) ->
    adjust_line(T-1, A, Cs, L).

%% yystate() -> InitialState.
%% yystate(State, InChars, Line, CurrTokLen, AcceptAction, AcceptLen) ->
%% {Action, AcceptLen, RestChars, Line} |
%% {Action, AcceptLen, RestChars, Line, State} |
%% {reject, AcceptLen, CurrTokLen, RestChars, Line, State} |
%% {Action, AcceptLen, CurrTokLen, RestChars, Line, State}.
%% Generated state transition functions. The non-accepting end state
%% return signal either an unrecognised character or end of current
%% input.

-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.erl", 360).
yystate() -> 12.

yystate(19, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(19, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(7, Ics, Line, Tlen+1, Action, Alen);
yystate(19, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line+1, Tlen+1, Action, Alen);
yystate(19, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(19, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 33 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(19, [C|Ics], Line, Tlen, Action, Alen) when C >= 35, C =< 91 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(19, [C|Ics], Line, Tlen, Action, Alen) when C >= 93 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(19, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,19};
yystate(18, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(18, [39|Ics], Line, Tlen, Action, Alen) ->
    yystate(10, Ics, Line, Tlen+1, Action, Alen);
yystate(18, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line+1, Tlen+1, Action, Alen);
yystate(18, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(18, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 38 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(18, [C|Ics], Line, Tlen, Action, Alen) when C >= 40, C =< 91 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(18, [C|Ics], Line, Tlen, Action, Alen) when C >= 93 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(18, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,18};
yystate(17, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(11, Ics, Line, Tlen+1, Action, Alen);
yystate(17, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,17};
yystate(16, [10|Ics], Line, Tlen, _, _) ->
    yystate(16, Ics, Line+1, Tlen+1, 8, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(16, Ics, Line, Tlen+1, 8, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 32 ->
    yystate(16, Ics, Line, Tlen+1, 8, Tlen);
yystate(16, Ics, Line, Tlen, _, _) ->
    {8,Tlen,Ics,Line,16};
yystate(15, [94|Ics], Line, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [93|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(7, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line+1, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 33 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 35, C =< 91 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(15, [C|Ics], Line, Tlen, Action, Alen) when C >= 95 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(15, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,15};
yystate(14, [94|Ics], Line, Tlen, Action, Alen) ->
    yystate(18, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [93|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [39|Ics], Line, Tlen, Action, Alen) ->
    yystate(10, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line+1, Tlen+1, Action, Alen);
yystate(14, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 38 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [C|Ics], Line, Tlen, Action, Alen) when C >= 40, C =< 91 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(14, [C|Ics], Line, Tlen, Action, Alen) when C >= 95 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(14, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,14};
yystate(13, Ics, Line, Tlen, _, _) ->
    {4,Tlen,Ics,Line};
yystate(12, [125|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [123|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [93|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [91|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [62|Ics], Line, Tlen, Action, Alen) ->
    yystate(3, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [61|Ics], Line, Tlen, Action, Alen) ->
    yystate(3, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [47|Ics], Line, Tlen, Action, Alen) ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [46|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [39|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [35|Ics], Line, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(16, Ics, Line+1, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 32 ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 43, C =< 45 ->
    yystate(13, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(4, Ics, Line, Tlen+1, Action, Alen);
yystate(12, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,12};
yystate(11, Ics, Line, Tlen, _, _) ->
    {5,Tlen,Ics,Line};
yystate(10, [92|Ics], Line, Tlen, _, _) ->
    yystate(14, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, [39|Ics], Line, Tlen, _, _) ->
    yystate(2, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, [10|Ics], Line, Tlen, _, _) ->
    yystate(5, Ics, Line+1, Tlen+1, 1, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(5, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 38 ->
    yystate(5, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 40, C =< 91 ->
    yystate(5, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 93 ->
    yystate(5, Ics, Line, Tlen+1, 1, Tlen);
yystate(10, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line,10};
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, 3, Tlen);
yystate(9, Ics, Line, Tlen, _, _) ->
    {3,Tlen,Ics,Line,9};
yystate(8, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(0, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line+1, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 33 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 35, C =< 91 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 93 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,8};
yystate(7, [92|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, [34|Ics], Line, Tlen, _, _) ->
    yystate(0, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, [10|Ics], Line, Tlen, _, _) ->
    yystate(8, Ics, Line+1, Tlen+1, 2, Tlen);
yystate(7, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(8, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 91 ->
    yystate(8, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, [C|Ics], Line, Tlen, _, _) when C >= 93 ->
    yystate(8, Ics, Line, Tlen+1, 2, Tlen);
yystate(7, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line,7};
yystate(6, Ics, Line, Tlen, _, _) ->
    {6,Tlen,Ics,Line};
yystate(5, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [39|Ics], Line, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line+1, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 38 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 40, C =< 91 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 93 ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(5, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,5};
yystate(4, [95|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 0, Tlen);
yystate(4, [64|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 0, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(4, Ics, Line, Tlen+1, 0, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(4, Ics, Line, Tlen+1, 0, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(4, Ics, Line, Tlen+1, 0, Tlen);
yystate(4, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,4};
yystate(3, [62|Ics], Line, Tlen, Action, Alen) ->
    yystate(11, Ics, Line, Tlen+1, Action, Alen);
yystate(3, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,3};
yystate(2, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line};
yystate(1, Ics, Line, Tlen, _, _) ->
    {7,Tlen,Ics,Line};
yystate(0, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line};
yystate(S, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,S}.

%% yyaction(Action, TokenLength, TokenChars, TokenLine) ->
%% {token,Token} | {end_token, Token} | skip_token | {error,String}.
%% Generated action function.

yyaction(0, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_0(TokenChars, TokenLine);
yyaction(1, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_1(TokenChars, TokenLen, TokenLine);
yyaction(2, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_2(TokenChars, TokenLen, TokenLine);
yyaction(3, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_3(TokenChars, TokenLine);
yyaction(4, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_4(TokenChars, TokenLine);
yyaction(5, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_5(TokenChars, TokenLine);
yyaction(6, _, _, TokenLine) ->
    yyaction_6(TokenLine);
yyaction(7, _, _, TokenLine) ->
    yyaction_7(TokenLine);
yyaction(8, _, _, _) ->
    yyaction_8();
yyaction(_, _, _, _) -> error.

-compile({inline,yyaction_0/2}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 12).
yyaction_0(TokenChars, TokenLine) ->
     tokenize_atom (TokenChars, TokenLine) .

-compile({inline,yyaction_1/3}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 13).
yyaction_1(TokenChars, TokenLen, TokenLine) ->
     tokenize_atom (escape (unquote (TokenChars, TokenLen)), TokenLine) .

-compile({inline,yyaction_2/3}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 14).
yyaction_2(TokenChars, TokenLen, TokenLine) ->
     { token, { string, TokenLine, escape (unquote (TokenChars, TokenLen)) } } .

-compile({inline,yyaction_3/2}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 15).
yyaction_3(TokenChars, TokenLine) ->
     { token, { integer, TokenLine, list_to_integer (TokenChars) } } .

-compile({inline,yyaction_4/2}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 16).
yyaction_4(TokenChars, TokenLine) ->
     { token, { list_to_atom (TokenChars), TokenLine } } .

-compile({inline,yyaction_5/2}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 17).
yyaction_5(TokenChars, TokenLine) ->
     { token, { list_to_atom (TokenChars), TokenLine } } .

-compile({inline,yyaction_6/1}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 18).
yyaction_6(TokenLine) ->
     { token, { dot, TokenLine } } .

-compile({inline,yyaction_7/1}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 19).
yyaction_7(TokenLine) ->
     { token, { '/', TokenLine } } .

-compile({inline,yyaction_8/0}).
-file("/home/mateus.santana/Documents/projects/git/elixir/valenca/deps/cowboy_telemetry/_build/default/plugins/hex_core/src/safe_erl_term.xrl", 20).
yyaction_8() ->
     skip_token .

-file("/home/mateus.santana/.asdf/installs/erlang/22.3.4/lib/parsetools-2.1.8/include/leexinc.hrl", 313).
