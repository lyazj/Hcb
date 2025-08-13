#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc700
[ -z "$1" ] && EVENTS=10 || EVENTS="$1"
[ -z "$2" ] && UPLOAD="" || UPLOAD="/eos/user/${USER:0:1}/${USER}/MiniAODStore/V0/2018/MC/HplusToCS_M-75_TuneCP5_13TeV-madgraph-pythia8/HIG-RunIISummer20UL18wmLHEGEN-MS075/$2.root"
echo "Events: ${EVENTS}"
echo "Upload: ${UPLOAD}"

voms-proxy-info || exit

enter () {
  [ -r $1/src ] || scram p CMSSW $1
  cd $1/src
  cp -r ../../Configuration .
  eval `scram runtime -sh`
  scram b
  cd ../..
}

enter CMSSW_10_6_30_patch1
cmsDriver.py Configuration/GenProduction/python/HIG-RunIISummer20UL18wmLHEGEN-MS075-fragment.py --eventcontent RAWSIM,LHE --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN,LHE --conditions 106X_upgrade2018_realistic_v4 --beamspot Realistic25ns13TeVEarly2018Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" --step LHE,GEN --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIISummer20UL18wmLHEGEN-MS075_1_cfg.py --fileout file:HIG-RunIISummer20UL18wmLHEGEN-MS075.root --mc -n $EVENTS || exit $?

enter CMSSW_10_6_17_patch1
cmsDriver.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 106X_upgrade2018_realistic_v11_L1v1 --beamspot Realistic25ns13TeVEarly2018Collision --step SIM --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIISummer20UL18SIM-08147_1_cfg.py --fileout file:HIG-RunIISummer20UL18SIM-08147.root --filein file:HIG-RunIISummer20UL18wmLHEGEN-MS075.root --runUnscheduled --mc -n $EVENTS || exit $?

enter CMSSW_10_6_17_patch1
cmsDriver.py --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI --conditions 106X_upgrade2018_realistic_v11_L1v1 --step DIGI,DATAMIX,L1,DIGI2RAW --procModifiers premix_stage2 --geometry DB:Extended --datamix PreMix --era Run2_2018 --python_filename HIG-RunIISummer20UL18DIGIPremix-08128_1_cfg.py --fileout file:HIG-RunIISummer20UL18DIGIPremix-08128.root --filein file:HIG-RunIISummer20UL18SIM-08147.root --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" --runUnscheduled --mc -n $EVENTS --no_exec || exit $?
#./patch_premix_inputs.py HIG-RunIISummer20UL18DIGIPremix-08128_1_cfg.py HIG-RunIISummer20UL18DIGIPremix-08128_1_cfg.patch
cmsRun HIG-RunIISummer20UL18DIGIPremix-08128_1_cfg.py || exit $?

enter CMSSW_10_2_16_UL
cmsDriver.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --conditions 102X_upgrade2018_realistic_v15 --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' --step HLT:2018v32 --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIISummer20UL18HLT-08147_1_cfg.py --fileout file:HIG-RunIISummer20UL18HLT-08147.root --filein file:HIG-RunIISummer20UL18DIGIPremix-08128.root --mc -n $EVENTS || exit $?

enter CMSSW_10_6_17_patch1
cmsDriver.py --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --conditions 106X_upgrade2018_realistic_v11_L1v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIISummer20UL18RECO-08147_1_cfg.py --fileout file:HIG-RunIISummer20UL18RECO-08147.root --filein file:HIG-RunIISummer20UL18HLT-08147.root --runUnscheduled --mc -n $EVENTS || exit $?

enter CMSSW_10_6_20
cmsDriver.py --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --conditions 106X_upgrade2018_realistic_v16_L1v1 --step PAT --procModifiers run2_miniAOD_UL --geometry DB:Extended --era Run2_2018 --python_filename HIG-RunIISummer20UL18MiniAODv2-08147_1_cfg.py --fileout file:HIG-RunIISummer20UL18MiniAODv2-08147.root --filein file:HIG-RunIISummer20UL18RECO-08147.root --runUnscheduled --mc -n $EVENTS || exit $?

[ ! -z "${UPLOAD}" ] && xrdcp -f HIG-RunIISummer20UL18MiniAODv2-08147.root "root://eosuser.cern.ch/${UPLOAD}"
