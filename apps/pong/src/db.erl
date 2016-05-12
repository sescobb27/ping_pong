-module (db).
-export ([init/0, increment/0, get_value/0]).

-include_lib("stdlib/include/qlc.hrl").

-record (ping_counter, {uuid, count}).

init() ->
  mnesia:start(),
  mnesia:create_schema([node()]),
  mnesia:create_table(ping_counter, [
    {attributes, record_info(fields, ping_counter)},
    {ram_copies, [node()]},
    {type, set}
  ]).

increment() ->
  F = fun () ->
    mnesia:write(#ping_counter{ uuid = uuid:new(self()), count = 1 })
  end,
  mnesia:transaction(F).

get_value() ->
  F = fun () ->
    Q = qlc:q([Value || #ping_counter{count = Value} <- mnesia:table(ping_counter)]),
    qlc:fold(fun (Val, Acc) ->
      Acc + Val
    end, 0, Q)
  end,
  {atomic, Result} = mnesia:transaction(F),
  Result.
