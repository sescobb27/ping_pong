-module (bunny_client).
-export ([init/0, produce/3, subscribe/3, open_channel/1, close_channel/1, consume_msg/2]).

-include_lib("amqp_client/include/amqp_client.hrl").

-spec init() -> pid().
init() ->
  Worker = poolboy:checkout(bunny_pool, false),
  RabbitConnection1 = gen_server:call(Worker, get_connection),
  Channel= open_channel(RabbitConnection1),
  ok = create_queues([<<"ping">>, <<"pong">>], Channel),
  bunny_client:close_channel(Channel),
  poolboy:checkin(bunny_pool, Worker).

open_channel(Connection) ->
  {ok, Channel} = amqp_connection:open_channel(Connection),
  Channel.

create_queues([], _Channel) ->
  ok;
create_queues([Queue | Tail], Channel) ->
  amqp_channel:call(Channel, #'queue.declare'{queue = Queue}),
  create_queues(Tail, Channel).

-spec produce(atom(), binary(), binary()) -> ok | {error, any()}.
produce(Channel, Queue, Msg) ->
  amqp_channel:cast(Channel,
     #'basic.publish'{
       exchange = <<"">>,
       routing_key = Queue
     },
     #amqp_msg{payload = Msg}).

subscribe(Channel, Queue, Consumer) ->
  Sub = #'basic.consume'{queue = Queue},
  #'basic.consume_ok'{} = amqp_channel:subscribe(Channel, Sub, Consumer).

close_channel(Channel) ->
  amqp_channel:close(Channel).

consume_msg(Channel, Queue) ->
  receive
      {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Body}} ->
          amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),
          io:format("[consuming] ~p from ~p queue~n", [Body, Queue])
  end.
