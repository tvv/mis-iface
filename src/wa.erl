-module(wa).
-export([
          start/0
        ]).

start() ->
  application:ensure_all_started(lager),
  lists:foldl(fun(I, _) -> ok = appstart(I) end, [], [
      sync,
      crypto,
      gproc,
      ranch,
      cowlib,
      cowboy,
      asn1,
      public_key,
      ssl,
      gun,
      pooler,
      ux,
      wa
    ]).

appstart(App) ->
  case application:start(App) of
    ok -> 
      ok;
    {error, {already_started, App}} -> 
      ok;
    Err -> 
      io:format("{start} Got error ~p on ~p ~n", [Err, App]),
      error
  end.
