
MASTER_DIR=$(shell pwd)
SRC=$(MASTER_DIR)/src

TRIMMER=$(SRC)/CRISPR.sgRNA_read_trimmer
SGRNG_COUNT=$(SRC)/CRISPR.single_sgRNA_count
MAGECK=$(SRC)/mageck
FASTQC=fastqc_v0.11.5

PYTHON=`which python`
python_version_full=$(wordlist 2,4,$(subst ., ,$(shell $(PYTHON) -V 2>&1)))
python_version_major=$(word 1,${python_version_full})
python_version_minor=$(word 2,${python_version_full})
python_version_patch=$(word 3,${python_version_full})

export PKG_CONFIG_PATH=$(MASTER_DIR)/build/lib/pkgconfig

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
	@cd src/libgtextutils && ./reconf && ./configure --prefix=$(MASTER_DIR)/build
	$(MAKE) --no-print-directory -C $(SRC)/libgtextutils
	$(MAKE) --no-print-directory -C $(SRC)/libgtextutils install
	@cd src/fastx_toolkit && ./reconf && ./configure --prefix=$(MASTER_DIR)/build
	$(MAKE) --no-print-directory -C $(SRC)/fastx_toolkit
	$(MAKE) --no-print-directory -C $(SRC)/fastx_toolkit install
	@test -d $(TRIMMER) || (cd $(SRC) && tar -zxvf $(TRIMMER).tar.gz)
	@test -d $(SGRNG_COUNT) || (cd $(SRC) && tar -zxvf $(SGRNG_COUNT).tar.gz)
	@mkdir -p $(MASTER_DIR)/build
	@cd $(MAGECK) && $(PYTHON) setup.py install --prefix=$(MASTER_DIR)/build
	@test -d $(FASTQC) || (cd $(SRC) && tar -zxvf $(FASTQC).tar.gz)
	@chmod 755 $(SRC)/$(FASTQC)/fastqc

clean:
	$(MAKE) --no-print-directory -C $(SRC)/bowtie2 clean
	$(MAKE) --no-print-directory -C $(SRC)/fastx_toolkit clean
	@rm -rf $(TRIMMER)
	@rm -rf $(SGRNG_COUNT)
	@rm -rf $(MASTER_DIR)/build
	@rm -rf $(FASTQC)
.PHONY: clean
