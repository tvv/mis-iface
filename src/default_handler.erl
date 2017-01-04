-module(default_handler).
-behaviour(cowboy_http_handler).
-export([
          init/3, 
          handle/2, 
          terminate/3
        ]).

-include("include/wa.hrl").

init({tcp, _}, Req, _) ->
  {ok, Req, #{}}.

handle(Req, State) ->
  {PathInfo, Req1} = cowboy_req:path_info(Req),
  try process(PathInfo, Req1, State) of
    {Req2, State2} -> 
      {ok, Req2, State2}
  catch 
    Ex:Exv ->
      ?ERROR("Got exception ~p:~p\n~w", [Ex, Exv, erlang:get_stacktrace()]),
      Req2 = reply(500, <<"exception">>, Req1),
      {ok, Req2, State}
  end.

terminate(_Reason, _Req, _State) ->
  ok.

%
% processing
%

process([<<"auth">>], Req, State) ->
  case iomod:get_request_json_body(Req) of
    {ok, #{<<"login">> := Login}, Req2} ->  
      {reply(#{
        token => iomod:smd5(binary, iomod:random_str("token", 12, ?TOKEN_ABC)),
        user => #{
          id => 1,
          name => Login,
          login => Login
        }
      }, Req2), State};
    Any ->
      ?ERROR("Can't read response body. ~p", [Any]),
      {reply(400, <<"wrong request data">>, Req), State}
  end;

process(PathInfo, Req, State) ->
  ?ERROR("Can't process ~p", [PathInfo]),
  {reply(404, <<"not found">>, Req), State}.

reply(Msg, Req) ->
  reply(200, Msg, Req).

reply(200, Msg, Req) ->
  iomod:out_json(200, #{
    success => true,
    error => null,
    validation => null,
    data => Msg
  }, Req);
reply(400, Msg, Req) ->
  iomod:out_json(400, #{
    success => false,
    error => <<"validation fails">>,
    validation => Msg,
    data => null
  }, Req);
reply(Status, Msg, Req) ->
  iomod:out_json(Status, #{
    success => false,
    error => Msg,
    validation => null,
    data => null
  }, Req).