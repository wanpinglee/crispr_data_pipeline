
MASTER_DIR=$(shell pwd)
SRC=$(MASTER_DIR)/src

TRIMMER=$(SRC)/CRISPR.sgRNA_read_trimmer
SGRNG_COUNT=$(SRC)/CRISPR.single_sgRNA_count
MAGECK=$(SRC)/mageck-0.5.6

# all
all:
	$(MAKE) --no-print-directory -C $(SRC)/bowtie2
	@test -d $(TRIMMER) || (cd $(SRC) && tar -zxvf $(TRIMMER).tar.gz) # unzip trimmer
	@test -d $(SGRNG_COUNT) || (cd $(SRC) && tar -zxvf $(SGRNG_COUNT).tar.gz) # unzip sgRNA_counter
	@test -d $(MAGECK) || (cd $(SRC) && tar -zxvf $(MAGECK).tar.gz) # unzip MAGECK
.PHONY: all

clean:
	$(MAKE) --no-print-directory -C $(SRC)/bowtie2 clean
	@rm -rf $(TRIMMER)
	@rm -rf $(SGRNG_COUNT)
	@rm -rf $(MAGECK)
.PHONY: clean
