#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/default-env.sh
source ${DIR}/util.sh

: "${INSTALLER_MANIFEST_DIR:=$DIR/../manifests/installer}"
: "${CHARGEBACK_CR_FILE:=$INSTALLER_MANIFEST_DIR/chargeback-crd.yaml}"

if [ "$CHARGEBACK_NAMESPACE" != "tectonic-system" ]; then
    msg "Removing pull secrets"
    kube-remove-non-file secret coreos-pull-secret
fi

msg "Removing Chargeback"
kube-remove \
    "$CHARGEBACK_CR_FILE"

msg "Removing chargeback-helm-operator"
kube-remove \
    "$INSTALLER_MANIFEST_DIR/chargeback-helm-operator-deployment.yaml"

msg "Removing chargeback-helm-operator service account and RBAC resources"
kube-remove \
    "$INSTALLER_MANIFEST_DIR/chargeback-helm-operator-service-account.yaml" \
    "$INSTALLER_MANIFEST_DIR/chargeback-helm-operator-rbac.yaml"


if [ "$SKIP_DELETE_CRDS" == "true" ]; then
    echo "\$SKIP_DELETE_CRDS is true, skipping deletion of Custom Resource Definitions"
else
    msg "Removing Chargeback CRD"
    kube-remove \
        "$INSTALLER_MANIFEST_DIR/chargeback-crd.yaml"

    msg "Removing Custom Resource Definitions"
    kube-remove \
        manifests/custom-resource-definitions
fi
