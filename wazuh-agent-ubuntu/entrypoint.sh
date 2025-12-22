#!/usr/bin/env bash
set -euo pipefail

: "${WAZUH_MANAGER:?Set WAZUH_MANAGER to the manager address (overlay IP recommended)}"

AGENT_NAME="${WAZUH_AGENT_NAME:-$(hostname)}"
CONF="/var/ossec/etc/ossec.conf"

# Ensure <client><server><address> points at our manager
if grep -q "<client>" "$CONF"; then
  perl -0777 -i -pe 's#(<client>.*?<server>.*?<address>)(.*?)(</address>)#$1'"$WAZUH_MANAGER"'$3#s' "$CONF" || true
else
  perl -0777 -i -pe 's#</ossec_config>#  <client>\n    <server>\n      <address>'"$WAZUH_MANAGER"'</address>\n      <port>1514</port>\n      <protocol>tcp</protocol>\n    </server>\n  </client>\n</ossec_config>#s' "$CONF"
fi

# Set agent name if the tag exists
perl -0777 -i -pe 's#(<agent_name>)(.*?)(</agent_name>)#$1'"$AGENT_NAME"'$3#s' "$CONF" || true

/var/ossec/bin/wazuh-control start
exec tail -F /var/ossec/logs/ossec.log
