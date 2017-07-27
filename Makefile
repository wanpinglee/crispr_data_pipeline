
MASTER_DIR=$(shell pwd)
SRC=$(MASTER_DIR)/src

TRIMMER=$(SRC)/CRISPR.sgRNA_read_trimmer
SGRNG_COUNT=$(SRC)/CRISPR.single_sgRNA_count
MAGECK=$(SRC)/mageck-0.5.6

PYTHON=`which python`
python_version_full=$(wordlist 2,4,$(subst ., ,$(shell $(PYTHON) -V 2>&1)))
python_version_major=$(word 1,${python_version_full})
python_version_minor=$(word 2,${python_version_full})
python_version_patch=$(word 3,${python_version_full})


# all
all:
	@if [ $(python_version_major) -lt 2 ]; then \
		 echo "Please use python version 2.7 or later."; \
	else \
		if [ $(python_version_minor) -lt 7 ]; then \
			echo "Please use python version 2.7 or later."; \
		else \
			$(MAKE) Build; \
		fi \
	fi
.PHONY: all

Build:
	$(MAKE) --no-print-directory -C $(SRC)/bowtie2
	@test -d $(TRIMMER) || (cd $(SRC) && tar -zxvf $(TRIMMER).tar.gz)
	@test -d $(SGRNG_COUNT) || (cd $(SRC) && tar -zxvf $(SGRNG_COUNT).tar.gz)
	@test -d $(MAGECK) || (cd $(SRC) && tar -zxvf $(MAGECK).tar.gz)
	@cd $(MAGECK) && $(PYTHON) setup.py install --prefix=$(MAGECK)

clean:
	$(MAKE) --no-print-directory -C $(SRC)/bowtie2 clean
	@rm -rf $(TRIMMER)
	@rm -rf $(SGRNG_COUNT)
	@rm -rf $(MAGECK)
.PHONY: clean
