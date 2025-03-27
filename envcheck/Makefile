.PHONY: all
build: bin/KCBS010.so bin/KJBM020 bin/REN1200 bin/REN1201

bin/KCBS010.so: src/KCBS010.COB bin
	cobc -m -Icopylib -o $@ $<

bin/KJBM020: src/KJBM020.COB bin
	cobc -x -Icopylib -o $@ $<

bin/REN1200: src/REN1200.COB bin
	cobc -x -Icopylib -Q "-Wl,--no-as-needed" -locesql -I/usr/local/ocesql/copy -o $@ $<

bin/REN1201: src/REN1201.COB bin
	cobc -x -Icopylib -Q "-Wl,--no-as-needed" -locsql -o $@ $<

src/REN1200.COB: src/REN1200.CBL bin
	ocesql $< $@

src/REN1201.COB: src/REN1201.CBL bin
	esqlOC -Q -I copylib -o $@ $<

bin:
	mkdir -p $@

.PHONY: init_db
init_db:
	PGPASSWORD=postgres psql -h db -U postgres < sql/conn_test.sql

.PHONY: check_run
check: build init_db
	@echo "============= Running program check ================="
	@echo "------------- CALL SUBPROGRAM CHECK -----------------"
	cd bin && ITF="../data/KJBM020I.txt" OTF="../data/KJBM020O.txt" ./KJBM020
	@echo "------------ ACCESS TO DATABASE CHECK ---------------"
	cd bin && ./REN1200
	cd bin && ./REN1201

.PHONY: clean
clean:
	@rm -rf bin/* src/REN120*.COB
