#! /bin/bash

echo "Azure Instance Metadata Service details "
echo -n "1.Display Entire Metadata for azure Instance\n 2.Display details for compute\n 3. Display details for Network \n"
read value
if [[ ! $value =~ ^[0-9]+$ ]] ; then
    echo "No good"
    exit
fi

if [ $value -eq 1 ]
then
  curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
elif [ $value -eq 2 ]
then
  echo " 1. Display all compute\n 2. Display particular data\n "
  read value2
  if [ $value2 -eq 1 ]
  then
    curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute?api-version=2021-02-01" | jq
  else [ $value2 -eq 2 ]
    echo "Please enter Metadata you want to search in Compute "
        read cdata
        curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/$cdata?api-version=2018-10-01&format=text"
  fi
elif [ $value -eq 3 ]
then
  echo " 1. Display all Network\n 2. Display Public Ip or Private Ipaddress\n "
  read value3
  if [ $value3 -eq 1 ]
  then
    curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network?api-version=2021-02-01" | jq
  elif [ $value3 -eq 2 ]
  then
    echo "type publicIpAddress or privateIpAddress to get the details\n"
    read ipaddress
    if [[ $ipaddress = "publicIpAddress" ]]
    then
      curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-08-01&format=text"
    elif [[ $ipaddress = "privateIpAddress" ]]
    then
      curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text"
    fi
  else
    echo " Please select valid Input"
  fi
fi
