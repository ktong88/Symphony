cd ../run
. ../jenkins/setting_licenses_all.sh
echo ">>> Licenses are set"
echo $LM_LICENSE_FILE

. ../jenkins/setting_mentor_questa.sh
echo ">>> Mentor Questa is set"
cd ../run
which vsim

cp -f ../jenkins/config_options/optionDefaults/* ../scripts_config/
echo ">>> Default config scripts are copied over"

cd ../run
rm -rf ../regression_results
echo ">>> Cleaned the regression folder manually"

echo ">>> Preparing regression"
cat << EOF > jenkins_run_sim.tcl
set argv "-noshell"
source ../scripts_config/run_simu.tcl
run_regression
exit
EOF

echo ">>> Starting regression"
tclsh jenkins_run_sim.tcl
echo ">>> Jenkins regression completed <<<"
