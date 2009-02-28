all: ModestMaps sift
	#

ModestMaps:
	svn co http://modestmaps.mapstraction.com/svn/trunk/py/ModestMaps

sift:
	curl -O http://www.vlfeat.org/download/vlfeat-0.9.3-bin.tar.gz
	tar -xzf vlfeat-0.9.3-bin.tar.gz
	mv vlfeat/bin/mac/sift ./
	rm -rf vlfeat vlfeat-0.9.3-bin.tar.gz

clean:
	rm -rf ModestMaps
	rm -f sift
