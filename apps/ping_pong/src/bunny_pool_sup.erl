-module (bunny_pool_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  Children = poolboy:child_spec(bunny_pool, [
      {name, {local, bunny_pool}},
      {size, 70},
      {max_overflow, 20},
      {worker_module, bunny_worker}
    ], []),
  {ok, { {one_for_one, 10, 10}, [Children]} }.

%%====================================================================
%% Internal functions
%%====================================================================
