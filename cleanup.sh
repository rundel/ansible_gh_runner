cd runner0/ && sudo ./svc.sh uninstall && cd ..
cd runner1/ && sudo ./svc.sh uninstall && cd ..
cd runner2/ && sudo ./svc.sh uninstall && cd ..
cd runner3/ && sudo ./svc.sh uninstall && cd ..

echo "Deleting runners ..."
sudo rm -rf runner*
