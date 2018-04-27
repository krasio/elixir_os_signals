-module(os_signals_handler).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_info/2, handle_call/2, terminate/2]).

% note weird signature because we use gen_event:swap_sup_handler/3
init({[Delay, HandleSignal], _}) ->
    {ok, {Delay, HandleSignal}}.

handle_event(sigterm, {Delay, Subscriber} = State) ->
    io:format("#PID~p: SIGTERM received. Stopping in ~p ms.~n", [self(), Delay]),
    Subscriber ! please_stop,
    erlang:send_after(Delay, self(), stop),
    {ok, State}
    ;
handle_event(ErrorMsg, S) ->
    % everything else goes to default handler
    erl_signal_handler:handle_event(ErrorMsg, S),
    {ok, S}.

handle_info(stop, State) ->
    io:format("#PID~p: Stopping due to earlier SIGTERM.~n", [self()]),
    ok = init:stop(),
    {ok, State}
    ;
handle_info(_, State) ->
    {ok, State}.

handle_call(_Request, State) ->
    {ok, ok, State}.

terminate(Args, State) ->
    erl_signal_handler:terminate(Args, State).
