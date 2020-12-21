#!/usr/bin/env python
#-*-coding:utf-8-*-
# generate fabric connection files. include yaml and json format.
# python3 only, do not support python2
import argparse
import json
import yaml

CONN_FILE_VERSION = "1.0.0"
BASE_PATH = f"../volume/client"

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project', help=u'project name, e.g fabricapp')

    parser.add_argument('--orgname', help=u'org name')
    parser.add_argument('--mspid', help=u'org msp id')

    parser.add_argument('--peer', help=u'peer host port, e.g peer0.org1.fabric.test:7051')
    parser.add_argument('--peertlscert', help=u'peer tls cert file path')

    parser.add_argument('--rca', help=u'rca host port, e.g rca.org1.fabric.test:7054')
    parser.add_argument('--rcacert', help=u'rca cert file path')

    parser.add_argument('--tlsca', help=u'tlsca host port, e.g tlsca.fabric.test:7054')
    parser.add_argument('--tlscacert', help=u'tls ca cert file path')

    args = parser.parse_args()
    return args

def client_format(org_name):
    client = {
        "organization": org_name,
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": 300,
                },
            },
        },
    }
    return client

def org_format(org_name, mspid, peer0, rca0):
    org = {
        org_name: {
            "mspid": mspid,
            "peers": [
                peer0,     
            ],
            "certificateAuthorities": [
                rca0,
            ],
        },
    }
    return org

def peer_format(peer_host, peer_grpc, peer_tls_cert):
    peer = {
        peer_host: {
            "url": peer_grpc,
            "tlsCaCerts": {
                "pem": peer_tls_cert,
            },
            "grpcOptions": {
                "ssl-target-name-override": peer_host,
                "hostnameOverride": peer_host,
            },
        },
    }
    
    return peer

def ca_format(ca_name, ca_url, rca_cert):
    ca = {
        ca_name: {
            "url": ca_url,
            "caName": ca_name,
            "tlsCaCerts": {
                "pem": [
                    rca_cert,
                ]
            },
            "httpOptions": {
                "verify": False,
            },
        },
    }
    return ca

def json_format(name, client, orgs, peers, cas):
    conn = {
        "name": name,
        "version": CONN_FILE_VERSION,
        "client": client,
        "organizations": orgs,
        "peers": peers,
        "certificateAuthorities": cas,
    }
    
    return conn

def read_cert_file(path):
    with open(path, 'r') as f:
        return f.read()

def write_json_format(org_name, data):
    path = f"{BASE_PATH}/{org_name}/connection.json"
    with open(path, 'w') as f:
        f.write(data)

def write_yaml_format(org_name, data):
    path = f"{BASE_PATH}/{org_name}/connection.yaml"
    with open(path, 'w') as f:
        f.write(data)

def run():
    args = parse_args()
    project_name = args.project
    
    org_name = args.orgname
    mspid = args.mspid

    peer_host_port = args.peer
    peer_host = peer_host_port.split(':')[0]
    peer_grpcs = f"grpcs://{peer_host_port}"
    peer_tls_cert = args.peertlscert

    rca_host_port = args.rca
    rca_host = rca_host_port.split(':')[0]
    rca_url = f"https://{rca_host_port}"
    rca_cert = args.rcacert

    tlsca_host_port = args.tlsca
    tlsca_host = tlsca_host_port.split(':')[0]
    tlsca_url = f"https://{tlsca_host_port}"
    tlsca_cert = args.tlscacert

    # todo, check all arguments have benn passed

    client = client_format(org_name)
    org = org_format(org_name, mspid, peer_host, rca_host)
    peer = peer_format(peer_host, peer_grpcs, read_cert_file(peer_tls_cert))
    rca = ca_format(rca_host, rca_url, read_cert_file(rca_cert))
    tlsca = ca_format(tlsca_host, tlsca_url, read_cert_file(tlsca_cert))
    cas = {}
    cas.update(rca)
    cas.update(tlsca)

    data = json_format(project_name, client, org, peer, cas)

    write_json_format(org_name, json.dumps(data, indent=4))
    write_yaml_format(org_name, yaml.dump(data))

if __name__ == "__main__":
    run()