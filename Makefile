
#-------------------------------------------------------------------------------
# edit these values to suit your environment or specify the desired values as
# environment variables before calling make e.g.
#	$ DOMAIN="sub.example.com" make target
ifndef DOMAIN
DOMAIN= example.com
endif
ifndef KSK_ALG
KSK_ALG= ECDSAP384SHA384
endif
ifndef ZSK_ALG
ZSK_ALG= ECDSAP256SHA256
endif
#------------------------------------------------------------------------------

.PHONY: checkzone signzone list clean ds

KEYGEN_KSK= ldns-keygen -ka
KEYGEN_ZSK= ldns-keygen -a
SIGNZONE= ldns-signzone -n
LIST_ALG= ldns-keygen -a list

zonefile.signed: zonefile keys
	${SIGNZONE} zonefile $$(cat keys | tr "\n" " ")
	chmod +x $@

checkzone:
	nsd-checkzone ${DOMAIN} ${DOMAIN}.zone

zonefile: checkzone
	cp -f ${DOMAIN}.zone zonefile

keys:
	mkdir -m 700 ksk
	mkdir -m 700 zsk
	echo -n "ksk/" > keys
	${KEYGEN_KSK} ${KSK_ALG} ${DOMAIN} >> keys
	mv *.ds *.key *.private ksk
	echo -n "zsk/" >> keys
	${KEYGEN_ZSK} ${ZSK_ALG} ${DOMAIN} >> keys
	mv *.key *.private zsk

signzone: zonefile.signed
	cp -f zonefile.signed ${DOMAIN}.zone.signed

list:
	${LIST_ALG} | sed -E /'(hmac|^DSA)'/d

clean:
	rm -f ${DOMAIN}.zone.signed
	rm -f zonefile.signed
	rm -f zonefile

cleanall: clean
	rm -rf ksk
	rm -rf zsk
	rm -f keys

ds: keys
	@cat ksk/*\.ds
