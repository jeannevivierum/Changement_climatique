#!/bin/sh

# Vérifiez s'il y a deux arguments passés au script
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <range> <filename>"
    exit 1
fi

# Séparez la chaîne d'arguments <range> en deux variables start et end
IFS=',' read -r start end <<< "$1"

# Exécutez la commande sed avec les arguments correctement formatés
sed -i "${start},${end}s/^/# /" "$2"
