#!/usr/bin/python
# Author: Hee Won Lee <knowpd@research.att.com>
# Created on 12/8/2017

config_file = 'config.yaml'

import os, sys, subprocess, copy, argparse, yaml

def run_bash(cmd):
    # Refer to http://stackoverflow.com/questions/4417546/constantly-print-subprocess-output-while-process-is-running
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    # Poll process for new output until finished
    while True:
        nextline = process.stdout.readline()
        if nextline == '' and process.poll() is not None:
            break
        sys.stdout.write(nextline)
        sys.stdout.flush()

    output = process.communicate()[0]
    exitCode = process.returncode

    if (exitCode == 0):
        return output
    else:
        raise exitCode

def arg_handler():
    parser = argparse.ArgumentParser(description='This program runs various benchmark \
            tools with a single config file.')
    parser.add_argument("benchmark_tool", help="options: fio")
    parser.add_argument("-c", "--config", default="config.yaml", help="config file (default: %(default)s)")
    args = parser.parse_args()
    main(args)


def load_config(config_file):
    # Read config.yaml
    with open(config_file) as stream:
        config = yaml.load(stream)

    # Preclude items that are `enabled = false`
    myconf = copy.deepcopy(config)
    for k1, v1 in config.iteritems():
        for k2, v2 in v1.iteritems():
            if k2 == 'enabled' and v2 == False:
                var = k1.upper() + '_' + k2.upper()
                os.environ[var] = 'false'
                myconf.pop(k1)
    # For debugging
    #print conf_disabled
    #print myconf

    # Add to environment variables
    myenv = {}
    for k1, v1 in myconf.iteritems():
        for k2, v2 in v1.iteritems():
            if k2 == 'env':
                for k3, v3 in v2.iteritems():
                    var = k1.upper() + '_' + k3.upper()
                    myenv[var] = str(v3)
                    os.environ[var] = str(v3)
                    #print  var + ' = ' + str(v3)

    # For debugging
    #print myenv
    #print os.getenv('INFLUXDB_IP', '')
    #print os.environ.get('INFLUXDB_IP')
    #print os.environ

def fio_eta():
    cnt = 0
    randbslist = os.environ.get('FIO_RANDBSLIST')
    seqbslist = os.environ.get('FIO_SEQBSLIST')
    readratiolist = os.environ.get('FIO_READRATIOLIST')
    iodepthlist = os.environ.get('FIO_IODEPTHLIST')
    numjobslist = os.environ.get('FIO_NUMJOBSLIST')
    runtime = os.environ.get('FIO_RUNTIME')

    factor1 =  len(readratiolist.split()) * len(iodepthlist.split()) * \
                 len(numjobslist.split())
    if randbslist is not None:
        cnt = cnt + len(randbslist.split()) * factor1
    if seqbslist is not None:
        cnt = cnt + len(seqbslist.split()) * factor1

    eta = int(runtime) * cnt
    eta_unit = 'sec'

    if eta >= 86400:
        eta = eta / 86400.
        eta_unit = 'day'
    elif eta >= 3600:
        eta = eta / 3600.
        eta_unit = 'hr'
    elif eta >= 60:
        eta = eta / 60.
        eta_unit = 'min'

    return eta, eta_unit, int(runtime), cnt

def main(args):
    # Generate env variables
    load_config(args.config)

    # ETA
    if args.benchmark_tool == 'fio': 
        print("ETA: %.1f %s (each runtime: %d sec, count:  %d)" % fio_eta())

    # Run
    cmd = ('cd ' +  args.benchmark_tool + '; ./run.sh')
    run_bash(cmd)

if __name__ == "__main__":
    arg_handler()
