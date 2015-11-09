# Program to process examples
VIT = ./vit -q
EX_DIR = ./example

vit : lex.yy.c  vit.c  vit.h
	gcc lex.yy.c vit.c -o vit

lex.yy.c : vit.l
	flex vit.l

vit.c vit.h : vit.y
	bison vit.y -d -o vit.c


debug :
	@$(VIT) $(EX_DIR)/test1.v > ex.log   2>&1
	@$(VIT) $(EX_DIR)/test2.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/test3.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/test4.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/test5.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/test7.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/test8.v >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/BLK_MEM_GEN_V4_3.v    >> ex.log  2>&1
	@$(VIT) $(EX_DIR)/FIFO_GENERATOR_V6_2.v >> ex.log  2>&1
	@echo -n "Number of lines with errors in examples: "
	@diff -b ex.log $(EX_DIR)/ex.log | wc -l

test : debug
	@rm -f ex.log


clean :
	@rm -f vit.exe vit.c vit.h vit lex.yy.c
