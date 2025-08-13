# Generating $H \to cb$ private samples in CMS

## Usage

To begin, run the following command to generate or renew an X.509 certificate in the current directory:

```
./x509up-gen
```

1. Test the Setup

   ```bash
   BASEDIR="${PWD}"
   mkdir -p /tmp/${USER} && cd /tmp/${USER} && rm -rf Hcb  # This makes the test run much faster!
   "${BASEDIR}"/x509run "${BASEDIR}"/x509up "${BASEDIR}"/bootstrap HIG-RunIISummer20UL18wmLHEGEN-M0075_all.sh 10
   ```

2. Submit HTCondor Jobs for Large-Scale Production

   Edit HIG-RunIISummer20UL18wmLHEGEN-M0075_all.jdl: Set the number of events per job. A value of 100 events per ROOT file is generally sufficient. Set also the number of jobs to submit (10000 by default).

   Then:

   ```bash
   condor_submit HIG-RunIISummer20UL18wmLHEGEN-M0075_all.jdl
   ```

---

Contact: \<lyazj@github.com\> or \<seeson@pku.edu.cn\>
