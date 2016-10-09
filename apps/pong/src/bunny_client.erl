-module (bunny_client).
-export ([
  init/0,
  produce/3,
  subscribe/2,
  subscribe/3,
  open_channel/1,
  close_channel/1,
  consume_msg/2,
  consume_msg/3]).

-include_lib("amqp_client/include/amqp_client.hrl").

-spec init() -> pid().
init() ->
  Worker = poolboy:checkout(bunny_ping_pool, false),
  RabbitConnection1 = bunny_worker:get_connection(Worker),
  Channel= open_channel(RabbitConnection1),
  ok = create_queues([<<"ping">>, <<"pong">>], Channel),
  bunny_client:close_channel(Channel),
  poolboy:checkin(bunny_ping_pool, Worker).

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

subscribe(Channel, Queue) ->
  Sub = #'basic.consume'{queue = Queue},
  #'basic.consume_ok'{} = amqp_channel:call(Channel, Sub).

close_channel(Channel) ->
  amqp_channel:close(Channel).

consume_msg(Channel, Queue) ->
  receive
    #'basic.consume_ok'{} ->
      consume_msg(Channel, Queue);
    #'basic.cancel_ok'{} ->
      ok;
    {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Body}} ->
      amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),
      io:format("[consuming] ~p from ~p queue~n", [Body, Queue]),
      Body
  end.

consume_msg(Channel, Queue, Key) ->
  receive
    #'basic.consume_ok'{} ->
      consume_msg(Channel, Queue, Key);
    #'basic.cancel_ok'{} ->
      ok;
    {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Body}} ->
      Msg = binary_to_term(Body),
      KeyFromMsg = maps:get(key, Msg),
      case KeyFromMsg of
        Key ->
          amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),
          io:format("[consuming] ~p from ~p queue~n", [Body, Queue]),
          Body;
        _ ->
          amqp_channel:cast(Channel, #'basic.nack'{delivery_tag = Tag}),
          consume_msg(Channel, Queue, Key)
      end
  end.
