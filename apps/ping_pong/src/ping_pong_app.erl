%%%-------------------------------------------------------------------
%% @doc ping_pong public API
%% @end
%%%-------------------------------------------------------------------

-module(ping_pong_app).

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/1]).

%%====================================================================
%% API
%%====================================================================
start() ->
  application:start(?MODULE),
  bunny_pool_sup:start_link(),
  bunny_client:init(),
  application:ensure_all_started(ping),
  application:ensure_all_started(pong).

start(_StartType, _StartArgs) ->
    ping_pong_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
