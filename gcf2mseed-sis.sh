#!/bin/bash

usage(){
   echo " "
   echo "Script to convert gcf-files from obsis"
   echo "in mseed-files in SDS format"
   echo " "
   echo "This script need a python-obspy script"
   echo "to merge sac-files before convertion for"
   echo "mseed format"
   echo " "
   echo "gcf2mseed-sis.sh NET STA CHA YEAR"
   echo " "
   echo "ex: "
   echo "gcf2mseed-sis.sh OS MC02 HHZ 2013"
   echo " "
   echo "Marcelo Rocha 12/2014 - marcelorocha.unb@gmail.com"
   echo " "
}

if [ -z $1 ]
then
   usage
   exit 1
fi

net=$1
sta=$2
cha=$3
year=$4

if [ $sta == MC01 ]
then
   stasis=mc01
   netsis=mtcla
elif [ $sta == MC02 ]
then
   stasis=mc02 
   netsis=mtcla
elif [ $sta == MC03 ]
then
   stasis=mc03 
   netsis=mtcla
elif [ $sta == MC04 ]
then
   stasis=mc04 
   netsis=mtcla
elif [ $sta == MC05 ]
then
   stasis=mc05 
   netsis=mtcla
elif [ $sta == MC06 ]
then
   stasis=mc06 
   netsis=mtcla
elif [ $sta == BAT1 ]
then
   stasis=bat1 
   netsis=furna
elif [ $sta == BAT2 ]
then
   stasis=bat2 
   netsis=furna
elif [ $sta == SIM1 ]
then
   stasis=sim1 
   netsis=furna
elif [ $sta == SIM2 ]
then
   stasis=sim2 
   netsis=furna
else
   echo "Station not found!!"
   exit 1
fi

# Colocar o diretorio completo ate o ano:
# ex:
#/media/dados/Guralp/data/mtcla/mc01/2013/
#datadir=./dados-sis/mc01/$year/
datadir=/SDS/DATA-SIS/data/$netsis/$stasis/$year/

#Diretorio de trabalho:
workdir=`pwd`

# Diretorio temporario para conversao de dados:
if [ -d temp ]
then
   rm -r temp/*
else
   mkdir temp
fi

#Escolhendo uma componente: 
if   [ $cha == HHE ] || [ $cha == BHE ] || [ $cha == EHE ] || [ $cha == SHE ]
then 
   comp=E
   comp1=e
elif [ $cha == HHN ] || [ $cha == BHN ] || [ $cha == EHN ] || [ $cha == SHN ]
then 
   comp=N
   comp1=n
elif [ $cha == HHZ ] || [ $cha == BHZ ] || [ $cha == EHZ ] || [ $cha == SHZ ]
then 
   comp=Z
   comp1=z
else 
   echo "No component founded..."
   exit 1 
fi

#for dird in `seq -w 189 189`
#for dird in 050 
for dird in `seq -w 1 366`
do
      if [ -d $datadir$dird ]
      then
         echo  $datadir$dird
         cp $datadir$dird/*$comp?.gcf $workdir/temp

         cp $datadir$dird/*$comp1.gcf $workdir/temp
         
         dirdprev=`expr $dird - 1`
         if [ $dirdprev -lt 10 ]
         then 
            dirdprev="00"$dirdprev
         elif [ $dirdprev -lt 100 ]
         then 
            dirdprev="0"$dirdprev
         fi

         if [ -d $datadir$dirdprev ]
         then
            cp $datadir$dirdprev/*T2300Z*$comp?.gcf $workdir/temp
            cp $datadir$dirdprev/*T2330Z*$comp?.gcf $workdir/temp

            cp $datadir$dirdprev/*_2300_*$comp1.gcf $workdir/temp
            cp $datadir$dirdprev/*_2330_*$comp1.gcf $workdir/temp
         fi

         dirdpost=`expr $dird + 1`
         if [ $dirdpost -lt 10 ]
         then 
            dirdpost="00"$dirdpost
         elif [ $dirdpost -lt 100 ]
         then 
            dirdpost="0"$dirdpost
         fi

         if [ -d $datadir$dirdpost ]
         then
            cp $datadir$dirdpost/*T0000Z*$comp?.gcf $workdir/temp

            cp $datadir$dirdpost/*_0000_*$comp1.gcf $workdir/temp
         fi

         cd $workdir/temp

         $workdir/gcf2sac -l *"$comp"?.gcf
         rm *"$comp"?.gcf

         $workdir/gcf2sac -l *"$comp1".gcf
         rm *"$comp1".gcf

         $workdir/sacrgap -f *.sac

         ../obspyMERGESAC $net $sta $cha $year $dird
         cd $workdir
         rm -r temp/*
      fi
done 
