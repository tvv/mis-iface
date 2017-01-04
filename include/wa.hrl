%
% Common project options
%

-define(AFTER(Timeout, Event), {ok, _} = timer:send_after(Timeout, Event)).
-define(ASYNC(F), proc_lib:spawn(fun() -> F end)).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 50, Type, [I]}).
-define(CHILD(I, Type, Param), {I, {I, start_link, Param}, permanent, 50, Type, [I]}).
-define(CHILD(Id, I, Type, Param), {Id, {I, start_link, Param}, permanent, 50, Type, [I]}).

%
% Configuration
%

-define(CONFIG(Key, Default), application:get_env(wa, Key, Default)).
-define(PV(Key, Set), proplists:get_value(Key, Set)).
-define(PV(Key, Set, Default), proplists:get_value(Key, Set, Default)).

%
% Logger
%

-define(ERROR(Msg), lager:error(Msg, [])).
-define(ERROR(Msg, Params), lager:error(Msg, Params)).
-define(INFO(Msg), lager:info(Msg, [])).
-define(INFO(Msg, Params), lager:info(Msg, Params)).
-define(WARNING(Msg), lager:warning(Msg, [])).
-define(WARNING(Msg, Params), lager:warning(Msg, Params)).
-define(DEBUG(Msg), lager:debug(Msg, [])).
-define(DEBUG(Msg, Params), lager:debug(Msg, Params)).

%
% Pub/Sub
%

-define(ME(Reg), gproc:reg({n, l, Reg})).
-define(LOOKUP(Reg), iomod:lookup(Reg)).
-define(LOOKUPS(Reg), iomod:lookups(Reg)).
-define(PUB(Event, Msg), iomod:pub(Event, Msg)).
-define(SUB(Event), iomod:sub(Event)).
-define(UNSUB(Event), iomod:unsub(Event)).
-define(LOOKUP_SUB(Reg), gproc:lookup_pids({p, l, Reg})).
-define(IS_SUB(Event), lists:any(fun({P, _}) -> P =:= self() end, gproc:lookup_local_properties(Event))).

%
% Users
%

-define(S2MS(S), S * 1000).
-define(RECONNECT_TIMEOUT, ?S2MS(5)).
-define(GUN_TIMEOUT, ?S2MS(60)).

-define(MAX_PG_INT, 2147483647).
-define(MAX_CHAT_HISTORY, 40).

-define(CAPTCHA_ABC, "qwertyupafhkxvnmQWERYUPAFHKXVNM3479"). 
-define(PWD_ABC, "qwertyupasdfghkzxcvbnmQWERTYUPASDFGHKZXCVLNM2345679").
-define(TOKEN_ABC, "qwertyuiopasdfghjklzxcvbnm1234567890QWERTYUIOPASDFGHJKLZXCVBNM"). 

-define(EPOCH, 62167219200).

-define(OK, #{ result => ok, can => ok }).
-define(OK(Can), #{ result => ok, can => Can }).
-define(ER(Error), #{ result => error, error => Error, can => ok }).
-define(ER(Error, Can), #{ result => error, error => Error, can => Can }).

-define(DEFAULT_OKATO, 45).

%
% Shortcuts
%

-define(IF(Action, Then, Else), if Action =:= true -> Then; true -> Else end).