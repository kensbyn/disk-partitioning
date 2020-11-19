#!/bin/bash
# command: ./partdisk.sh azureuser ./keys/azureuser ./hosts/<list_of_dns>

partitionDisk(){

    pssh -i -h $3 -l $1 -x "-i $2 -o StrictHostKeyChecking=no" "echo ',,8e;' | sudo sfdisk /dev/sdc; sudo partprobe";

}

createAndExtend(){
    pssh -i -h $3 -l $1 -x "-i $2 -o StrictHostKeyChecking=no" "sudo pvcreate /dev/sdc1; sudo vgextend rootvg /dev/sdc1; sudo lvextend -l +100%FREE /dev/mapper/rootvg-rootlv; sudo resize2fs /dev/mapper/rootvg-rootlv";
}


showLoading() {
  mypid=$!
  loadingText=$1

  echo -ne "$loadingText\r"

  while kill -0 $mypid 2>/dev/null; do
    echo -ne "$loadingText.\r"
    sleep 0.5
    echo -ne "$loadingText..\r"
    sleep 0.5
    echo -ne "$loadingText...\r"
    sleep 0.5
    echo -ne "\r\033[K"
    echo -ne "$loadingText\r"
    sleep 0.5
  done

   echo "$loadingText...FINISHED"
}

partitionDisk $1 $2 $3 & showLoading "Partitioning data disk..."
sleep 2
echo "Done!"
sleep 5

createAndExtend $1 $2 $3 showLoading "Creating PV and extending rootlv..."
sleep 2
echo "Done!"
