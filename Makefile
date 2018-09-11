DRAFT:=constrained-voucher
VERSION:=$(shell ./getver ${DRAFT}.mkd )
YANGDATE=2018-09-01
CWTDATE1=yang/ietf-constrained-voucher@${YANGDATE}.yang
CWTSIDDATE1=ietf-constrained-voucher@${YANGDATE}.sid
CWTSIDLIST1=ietf-constrained-voucher-sid.txt
CWTDATE2=yang/ietf-constrained-voucher-request@${YANGDATE}.yang
CWTSIDLIST2=ietf-constrained-voucher-request-sid.txt
CWTSIDDATE2=ietf-constrained-voucher-request@${YANGDATE}.sid
PYANG=./pyang.sh

# git clone this from https://github.com/mbj4668/pyang.git
# then, cd pyang/plugins;
#       wget https://raw.githubusercontent.com/core-wg/yang-cbor/master/sid.py
# sorry.
PYANGDIR=/sandel/src/pyang

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

${CWTDATE1}: ietf-constrained-voucher.yang
	mkdir -p yang
	sed -e"s/YYYY-MM-DD/${YANGDATE}/" ietf-constrained-voucher.yang > ${CWTDATE1}

${CWTDATE2}: ietf-constrained-voucher-request.yang
	mkdir -p yang
	sed -e"s/YYYY-MM-DD/${YANGDATE}/" ietf-constrained-voucher-request.yang > ${CWTDATE2}

ietf-constrained-voucher-tree.txt: ${CWTDATE1}
	${PYANG} --path=../../anima/bootstrap/yang -f tree --tree-print-groupings --tree-line-length=70 ${CWTDATE1} > ietf-constrained-voucher-tree.txt

ietf-constrained-voucher-request-tree.txt: ${CWTDATE2}
	${PYANG} --path=../../anima/bootstrap/yang -f tree --tree-print-groupings --tree-line-length=70 ${CWTDATE2} > ietf-constrained-voucher-request-tree.txt

%.xml: %.mkd ${CWTDATE1} ${CWTDATE2} ietf-constrained-voucher-tree.txt ietf-constrained-voucher-request-tree.txt ${CWTSIDLIST1} ${CWTSIDLIST2}
	kramdown-rfc2629 ${DRAFT}.mkd | ./insert-figures >${DRAFT}.xml
	: git add ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? $@

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

submit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submit

#${CWTSIDLIST1} ${CWTSIDDATE1}: ${CWTDATE1}
#	mkdir -p yang
#	${PYANG} --path=../../anima/bootstrap/yang --list-sid --update-sid-file ${CWTSIDDATE1} ${CWTDATE1} | ./truncate-sid-table >ietf-constrained-voucher-sid.txt

#${CWTSIDLIST1} ${CWTSIDDATE1}: ${CWTDATE1}
#	mkdir -p yang
#	${PYANG} --path=../../anima/bootstrap/yang --list-sid --generate-sid-file 1001100:50 ${CWTDATE1} | ./truncate-sid-table >ietf-constrained-voucher-sid.txt

boot-sid1:
	${PYANG} --path=../../anima/bootstrap/yang --list-sid --generate-sid-file 1001100:50 ${CWTDATE1}

boot-sid2:
	${PYANG} --path=../../anima/bootstrap/yang --list-sid --generate-sid-file 1001150:50 ${CWTDATE2}


#${CWTSIDLIST2} ${CWTSIDDATE2}: ${CWTDATE2}
#	mkdir -p yang
#	${PYANG} --path=../../anima/bootstrap/yang --list-sid --generate-sid-file 1001150:50 ${CWTDATE2}  | ./truncate-sid-table >ietf-constrained-voucher-request-sid.txt


version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml ${CWTDATE1} ${CWTDATE2}

.PRECIOUS: ${DRAFT}.xml
