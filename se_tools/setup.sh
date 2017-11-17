
se_engine_lib="/usr/lib/libe2a71chi2c.so"
se_engine_conf="/etc/ssl/opensslA71CH_i2c.cnf"
	
if [ -e ${se_engine_lib} ]; then
	rm ${se_engine_lib}
fi

echo "Copy SE Engine Library"
cp libe2a71chi2c.so.1.0.0 ${se_engine_lib}

if [ ! -e ${se_engine_lib} ]; then
	echo "Copy failed\n"
fi

if [ -e ${se_engine_conf} ]; then
	rm ${se_engine_conf}
fi
	
echo "Copy SE Engine configure file"
cp opensslA71CH_i2c.cnf ${se_engine_conf}

if [ ! -e ${se_engine_conf} ]; then
	echo "Copy failed\n"
fi


