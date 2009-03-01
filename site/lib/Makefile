all: Smarty
	#

Smarty:
	curl -sL "http://www.smarty.net/do_download.php?download_file=Smarty-2.6.21.tar.gz" > Smarty-2.6.21.tar.gz
	tar -xzf Smarty-2.6.21.tar.gz
	mv Smarty-2.6.21/libs Smarty
	rm -rf Smarty-2.6.21 Smarty-2.6.21.tar.gz

clean:
	rm -rf Smarty
