-module(erltrix_client).
-behaviour(gen_server).

-export([start_link/0, sync/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
          conn :: reference(),
          token :: string()
         }).

-define(USER, "@vendor:localhost.localdomain").
-define(PASS, "password").
-define(HOST, "localhost.localdomain").
-define(PORT, "443").

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

sync() ->
    gen_server:call(?MODULE, sync).

%% callbacks

init([]) ->
    logger:notice("Starting bot.."),
    User = list_to_binary(os:getenv("ERLTRIX_USER", ?USER)),
    Pass = list_to_binary(os:getenv("ERLTRIX_PASS", ?PASS)),
    Host = os:getenv("ERLTRIX_HOST", ?HOST),
    Port = list_to_integer(os:getenv("ERLTRIX_PORT", ?PORT)),
    {ok, ConnRef} = hackney:connect(hackney_ssl, Host, Port, []),
    {ok, Payload} = auth_for_token(ConnRef, User, Pass),
    Token = extract_token(Payload),
    {ok, #state{ conn = ConnRef, token = Token }}.

handle_call(sync, _From, State = #state{ token = Token, conn = ConnRef }) ->
    logger:notice("Got sync request"),
    case sync_client(ConnRef, Token) of
        {ok, Payload} ->
            B = jsone:decode(Payload),
            process_events(B);
        Other -> 
            logger:notice("Got some other message type (maybe renew token?): ~p", [Other])
    end,
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions

% Translated from alkiematrix
auth_for_token(ConnRef, User, Pass) ->
    logger:notice("Authenticating for token"),
    Method = post,
    Path = <<"/_matrix/client/v3/login">>,
    Headers = [
        {<<"Content-Type">>, <<"application/json">>},
        {<<"Accept">>, <<"application/json">>}
    ],
    Payload = jsone:encode(#{
        <<"type">> => <<"m.login.password">>,
        <<"identifier">> => #{
            <<"type">> => <<"m.id.user">>,
            <<"user">> => User
        },
        <<"password">> => Pass
    }),
    Req = {Method, Path, Headers, Payload},
    {ok, _, _, ConnRef} = hackney:send_request(ConnRef, Req),
    hackney:body(ConnRef).

extract_token(Payload) -> 
    #{ <<"access_token">> := Token } = jsone:decode(Payload),
    logger:notice("Extracted access token: ~p", [Token]),
    Token.

sync_client(ConnRef, Token) ->
    logger:notice("Token: ~p", [Token]),
    Method = get,
    Path = <<"/_matrix/client/v3/sync">>,
    Headers = [
        {<<"Content-Type">>, <<"application/json">>},
        {<<"Accept">>, <<"application/json">>},
        {<<"Authorization">>, <<"Bearer ", Token/binary>>}
    ],
    Payload = <<>>,
    Req = {Method, Path, Headers, Payload},
    {ok, _, _, ConnRef} = hackney:send_request(ConnRef, Req),
    hackney:body(ConnRef).

process_events(BodyMap) ->
    logger:notice("Keys: ~p", [maps:keys(BodyMap)]),
    ok.


