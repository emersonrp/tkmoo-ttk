#!/bin/sh
TKMOO_LIB_DIR=build/.tkMOO-lite
TKMOO_BIN_DIR=build
EXECUTABLE=tkmoo
LIB_FILES=plugins
BIN_FILES=$EXECUTABLE

WISH=`which wish`
if [ `echo $?` = "2" ]; then
    echo "***";
    echo "*** Can't find executable '$WISH'";
    echo "*** You can set the correct path for the wish executable";
    echo "*** by editing the variable 'WISH' in 'build.sh'";
    echo "***";
    exit;
fi

echo "#!$WISH" > $EXECUTABLE
echo "set tkmooLibrary $TKMOO_LIB_DIR" >> $EXECUTABLE
cat ./source.tcl >> $EXECUTABLE
# r-xr-xr-x
chmod 0555 $EXECUTABLE

mkdir -p $TKMOO_BIN_DIR
cp -fr $BIN_FILES $TKMOO_BIN_DIR
mkdir -p $TKMOO_LIB_DIR
cp -fr $LIB_FILES $TKMOO_LIB_DIR

echo "You should move the contents of '`pwd`/$TKMOO_BIN_DIR/' to";
echo "to somewhere in your path and '`pwd`/$TKMOO_LIB_DIR/' to ~";