#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2022, Studio Family Karaoke.
# All rights reserved.
#

# Debug mode.
#set -x

_DB="bec"
_SQLUP="-uroot -pbandung"
_SKDATE="2022-%"

# Table base ORDERID keyword.
_ORDERS="orders"
_ORDER_DETAIL="order_detail"
_ORDER_HAPUS="order_hapus"
_ROOM_DETAIL="room_detail"
_TBL_BERITAACARA="tbl_beritaacara"
_TRANSAKSI="transaksi"

# Table base STRUKNO keyword.
_PAYMENT="payment"
_PAYMENT_DETAIL="payment_detail"
_TBL_PAY="tbl_pay"
_TBL_PAY_MEMBER="tbl_pay_member"
_TRANS_DETAIL="trans_detail"
_TRANS_PAY="trans_pay"

# SQL function.
#SQLDELORDERID() {
#    mysql ${_SQLUP} -e "
#        DELETE FROM ${_DB}.${_ORDERS} WHERE ORDERID = '${_ORDERID}';
#        DELETE FROM ${_DB}.${_ORDER_DETAIL} WHERE ORDERID = '${_ORDERID}';
#        DELETE FROM ${_DB}.${_ORDER_HAPUS} WHERE ORDERID = '${_ORDERID}';
#        DELETE FROM ${_DB}.${_ROOM_DETAIL} WHERE ORDERID = '${_ORDERID}';
#        DELETE FROM ${_DB}.${_TBL_BERITAACARA} WHERE ORDERID = '${_ORDERID}';
#        DELETE FROM ${_DB}.${_TRANSAKSI} WHERE ORDERID = '${_ORDERID}';
#    "
#}

#SQLDELSTRUKNO() {
#    mysql ${_SQLUP} -e "
#        DELETE FROM ${_DB}.${_PAYMENT} WHERE STRUKNO = '${_STRUKNO}';
#        DELETE FROM ${_DB}.${_PAYMENT_DETAIL} WHERE STRUKNO = '${_STRUKNO}';
#        DELETE FROM ${_DB}.${_TBL_PAY} WHERE STRUKNO = '${_STRUKNO}';
#        DELETE FROM ${_DB}.${_TBL_PAY_MEMBER} WHERE STRUKNO = '${_STRUKNO}';
#        DELETE FROM ${_DB}.${_TRANS_DETAIL} WHERE STRUKNO = '${_STRUKNO}';
#        DELETE FROM ${_DB}.${_TRANS_PAY} WHERE STRUKNO = '${_STRUKNO}';
#    "
#}

# Search ORDERID base on SKDATE.
ORDERID="$(mysql ${_SQLUP} -Bs -e "SELECT ORDERID FROM ${_DB}.${_ORDERS} WHERE ORDDATE LIKE '${_SKDATE}';")"

# Seek and delete process.
echo "${ORDERID}" | while read -r _ORDERID
do
    Q1="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_ORDERS} WHERE ORDERID = '${_ORDERID}';")"

    if [ $? = "0" ] && [ -n ${Q1} ]; then
        echo "Table ${_ORDERS}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_ORDERS}: ${_ORDERID} -- Something went wrong."
    fi

    Q2="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_ORDER_DETAIL} WHERE ORDERID = '${_ORDERID}';")"
    if [ $? = "0" ] && [ -n ${Q2} ]; then
        echo "Table ${_ORDER_DETAIL}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_ORDER_DETAIL}: ${_ORDERID} -- Something went wrong."
    fi

    Q3="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_ORDER_HAPUS} WHERE ORDERID = '${_ORDERID}';")"
    if [ $? = "0" ] && [ -n ${Q3} ]; then
        echo "Table ${_ORDER_HAPUS}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_ORDER_HAPUS}: ${_ORDERID} -- Something went wrong."
    fi

    Q4="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_ROOM_DETAIL} WHERE ORDERID = '${_ORDERID}';")"
    if [ $? = "0" ] && [ -n ${Q4} ]; then
        echo "Table ${_ROOM_DETAIL}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_ROOM_DETAIL}: ${_ORDERID} -- Something went wrong."
    fi

    Q5="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TBL_BERITAACARA} WHERE ORDERID = '${_ORDERID}';")"
    if [ $? = "0" ] && [ -n ${Q5} ]; then
        echo "Table ${_TBL_BERITAACARA}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_TBL_BERITAACARA}: ${_ORDERID} -- Something went wrong."
    fi

    Q6="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TRANSAKSI} WHERE ORDERID = '${_ORDERID}';")"
    if [ $? = "0" ] && [ -n ${Q6} ]; then
        echo "Table ${_TRANSAKSI}: ${_ORDERID} -- Deleted."
    else
        echo "Table ${_TRANSAKSI}: ${_ORDERID} -- Something went wrong."
    fi

    # Search STRUKNO base on ORDERID.
    STRUKNO="$(mysql ${_SQLUP} -Bs -e "SELECT STRUKNO FROM ${_DB}.${_PAYMENT} WHERE ORDERID = '${_ORDERID}'; \
                                       SELECT STRUKNO FROM ${_DB}.${_TBL_PAY_MEMBER} WHERE TANGGAL LIKE '${_SKDATE}';")"

    echo "$STRUKNO" | while read -r _STRUKNO
    do

    P1="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_PAYMENT} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P1} ]; then
        echo "Table ${_PAYMENT}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_PAYMENT}: ${_STRUKNO} -- Something went wrong."
    fi

    P2="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_PAYMENT_DETAIL} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P2} ]; then
        echo "Table ${_PAYMENT_DETAIL}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_PAYMENT_DETAIL}: ${_STRUKNO} -- Something went wrong."
    fi

    P3="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TBL_PAY} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P3} ]; then
        echo "Table ${_TBL_PAY}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_TBL_PAY}: ${_STRUKNO} -- Something went wrong."
    fi

    P4="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TBL_PAY_MEMBER} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P4} ]; then
        echo "Table ${_TBL_PAY_MEMBER}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_TBL_PAY_MEMBER}: ${_STRUKNO} -- Something went wrong."
    fi

    P5="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TRANS_DETAIL} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P5} ]; then
        echo "Table ${_TRANS_DETAIL}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_TRANS_DETAIL}: ${_STRUKNO} -- Something went wrong."
    fi

    P6="$(mysql ${_SQLUP} -e "DELETE FROM ${_DB}.${_TRANS_PAY} WHERE STRUKNO = '${_STRUKNO}';")"
    if [ $? = "0" ] && [ -n ${P6} ]; then
        echo "Table ${_TRANS_PAY}: ${_STRUKNO} -- Deleted."
    else
        echo "Table ${_TRANS_PAY}: ${_STRUKNO} -- Something went wrong."
    fi
    done
done
