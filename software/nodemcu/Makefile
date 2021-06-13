include env.make

NODEMCU-COMMAND=$(NODEMCU-UPLOADER) -b $(SPEED) -p $(PORT)

LUA_FILES := $(wildcard *.lua)

.PHONY: clean
clean:
	$(NODEMCU-COMMAND) file format

.PHONY: list
list:
	$(NODEMCU-COMMAND) file list

.PHONY: restart
restart:
	$(NODEMCU-COMMAND) node restart

.PHONY: upload
upload: $(LUA_FILES)
	$(NODEMCU-COMMAND) upload $(foreach f, $^, $(f))

.PHONY: flash
flash:
	# Erase flash to avoid inconsistent state:
	esptool.py --port $(PORT) erase_flash
	# Upload firmware
	esptool.py --port $(PORT) write_flash -fm dio 0x00000 nodemcu-master-18-modules-2018-05-02-18-57-49-float.bin
