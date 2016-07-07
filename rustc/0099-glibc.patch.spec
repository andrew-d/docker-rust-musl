--- mk/main.mk.old
+++ mk/main.mk
@@ -461,7 +461,7 @@
 
 ifeq ($(1),0)
 # Don't run the stage0 compiler under valgrind - that ship has sailed
-CFG_VALGRIND_COMPILE$(1) =
+CFG_VALGRIND_COMPILE$(1) = @@GLIBC_PATH@@
 else
 CFG_VALGRIND_COMPILE$(1) = $$(CFG_VALGRIND_COMPILE)
 endif
