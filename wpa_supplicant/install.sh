#!/bin/bash
# This script installs wpa_supplicant the first time.

if ! dpkg -l wpasupplicant | grep ii >/dev/null; then
    dpkg -i /data/wpa_supplicant/libreadline8*.deb
    dpkg -i /data/wpa_supplicant/wpasupplicant_2.9*.deb
fi


DATA_WPASUPPLICANT_DIR=/data/wpa_supplicant

WPASUPPLICANT_CONF_DIR=/etc/wpa_supplicant/conf
CA_PEM=${WPASUPPLICANT_CONF_DIR}/CA.pem
CLIENT_PEM=${WPASUPPLICANT_CONF_DIR}/Client.pem
PRIVATEKEY_PEM=${WPASUPPLICANT_CONF_DIR}/PrivateKey.pem
WPASUPPLICANT_CONF=${WPASUPPLICANT_CONF_DIR}/wpa_supplicant.conf

WPASUPPLICANT_SERVICE_DIR=/etc/systemd/system/wpa_supplicant.service.d
OVERRIDE_CONF=${WPASUPPLICANT_SERVICE_DIR}/override.conf

ONBOOT_DIR=/data/on_boot.d
ATT_BYPASS_SCRIPT=${ONBOOT_DIR}/0-att-bypass.sh

ATT_BYPASS_SERVICE=/etc/systemd/system/setup-att-bypass.service


if [ ! -d "$WPASUPPLICANT_CONF_DIR" ]; then
    mkdir -p ${WPASUPPLICANT_CONF_DIR}
fi

if [ ! -f "$CA_PEM" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/CA.pem ${WPASUPPLICANT_CONF_DIR}
fi

if [ ! -f "$CLIENT_PEM" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/Client.pem ${WPASUPPLICANT_CONF_DIR}
fi

if [ ! -f "$PRIVATEKEY_PEM" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/PrivateKey.pem ${WPASUPPLICANT_CONF_DIR}
fi

if [ ! -f "$WPASUPPLICANT_CONF" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/wpa_supplicant.conf ${WPASUPPLICANT_CONF_DIR}
fi



if [ ! -d "$WPASUPPLICANT_SERVICE_DIR" ]; then
    mkdir -p ${WPASUPPLICANT_SERVICE_DIR}
fi

if [ ! -f "$OVERRIDE_CONF" ]; then
    if /sbin/ethtool eth8 | grep -q "Link detected:"; then
        cp ${DATA_WPASUPPLICANT_DIR}/override_UDMPro_UDMProSE.conf ${DATA_WPASUPPLICANT_DIR}/override.conf
        cp ${DATA_WPASUPPLICANT_DIR}/override_UDMPro_UDMProSE.conf ${OVERRIDE_CONF}
    else
        cp ${DATA_WPASUPPLICANT_DIR}/override_UDM.conf ${DATA_WPASUPPLICANT_DIR}/override.conf
        cp ${DATA_WPASUPPLICANT_DIR}/override_UDM.conf ${OVERRIDE_CONF}
    fi
fi



if [ ! -d "$ONBOOT_DIR" ]; then
    mkdir -p ${ONBOOT_DIR}
fi

if [ ! -f "$ATT_BYPASS_SCRIPT" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/0-att-bypass.sh ${ONBOOT_DIR}
    chmod +x ${ATT_BYPASS_SCRIPT}
fi

if [ ! -f "$ATT_BYPASS_SERVICE" ]; then
    cp ${DATA_WPASUPPLICANT_DIR}/setup-att-bypass.service /etc/systemd/system
    systemctl enable setup-att-bypass
fi



systemctl daemon-reload
systemctl enable wpa_supplicant.service
systemctl restart wpa_supplicant.service
