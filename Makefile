BIN      = .build/$(CONFIG)
CONFIG  ?= release
DESTDIR ?= ~/.local/bin
LAUNCHD ?= ~/Library/LaunchAgents

.PHONY: clean install install-launchd-agent

caffeinate-downloads: $(BIN)/caffeinate-downloads
	cp $< $@

clean:
	rm -f caffeinate-downloads
	swift package clean

install: $(DESTDIR) $(DESTDIR)/caffeinate-downloads
install-launchd-agent: $(LAUNCHD)/caffeinate-downloads.plist

$(BIN)/caffeinate-downloads: $(wildcard Sources/*.swift)
	swift build --configuration $(CONFIG)

$(DESTDIR):
	install -d $@

$(DESTDIR)/caffeinate-downloads: $(BIN)/caffeinate-downloads
	install $< $@

$(LAUNCHD)/caffeinate-downloads.plist: launchd-agent.json
	DESTDIR=$(DESTDIR) plutil -convert xml1 -o $@ - <<< $$(envsubst < $<)
