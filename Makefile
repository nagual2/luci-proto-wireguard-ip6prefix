# Convenience wrapper — see Makefile.build
.PHONY: all apk ipk clean test
all apk ipk clean test:
	$(MAKE) -f Makefile.build $@
