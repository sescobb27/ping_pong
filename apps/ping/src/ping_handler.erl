-module (ping_handler).
-export ([init/3, terminate/3, handle/2]).

init(_Type, Req, []) ->
  {shutdown, Req, no_state}.

handle(Req, Opts) ->
  {ok, Req, Opts}.

terminate(_Reason, _Req, _State) ->
  ok.
