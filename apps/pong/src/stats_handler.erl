-module (stats_handler).
-export ([init/3, terminate/3, handle/2]).

init(_Type, Req, []) ->
  {ok, Req, no_state}.

handle(Req, Opts) ->
  Value = db:get_value(),
  Json = jsone:encode(#{ stats => Value }),
  {ok, Req2} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/json">>}
  ], Json, Req),
  {ok, Req2, Opts}.

terminate(_Reason, _Req, _State) ->
  ok.
