APPNAME=wa
SERVICENAME=stok

REBAR=./rebar3
ERL=erl
ERLC=erlc

PLTFILE=$(CURDIR)/.deps.plt

PATH_TO_CONFIG=config/$(shell hostname).sys.config
ifneq ("$(wildcard $(PATH_TO_CONFIG))","")
	CONFIG=$(PATH_TO_CONFIG)
else
	CONFIG=config/sys.config
endif

all: 
	webpack
	compile

$(REBAR):
	$(ERL) \
		-noshell -s inets start -s ssl start \
		-eval 'httpc:request(get, {"https://s3.amazonaws.com/rebar3/rebar3", []}, [], [{stream, "./rebar3"}])' \
		-s inets stop -s init stop
	chmod +x $(REBAR)

compile: $(REBAR)
	@$(REBAR) compile

dialyzer: $(REBAR)
	@$(REBAR) dialyzer

clean: $(REBAR)
	@$(REBAR) clean

release: $(REBAR)
	@$(REBAR) release

upgrade: $(REBAR)
	@$(REBAR) upgrade

tests: ct

ct: $(REBAR)
	@$(REBAR) ct --sys_config config/sys.config

run: $(REBAR) $(CONFIG)
	$(REBAR) shell --config $(CONFIG) --sname $(SERVICENAME)_$(APPNAME)@localhost 

