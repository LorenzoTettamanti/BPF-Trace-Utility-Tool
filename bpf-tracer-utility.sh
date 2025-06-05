#!/bin/bash

#vars
is_traceable=true


while true; do
  echo "-------------------------------------------------------------------"
  echo "BPF TRACE SCRIPTS UTILITY"
  echo "Functions":
  echo ""
  echo "1-> Kprobe offset finder"
  echo "2-> tracepoint category finder"
  echo "3-> exit"
  echo "i--> info"
  echo ""
  echo "Choose a functionality"
  read FUN
  echo ""
  echo "-------------------------------------------------------------------"
  case $FUN in 

    1)
      echo "enter Kprobe name"
      read kprobename
      echo "Is the probe traceable?"
      output=$(sudo bpftrace -l "kprobe:$kprobename" 2>/dev/null)

      if [[ -n "$output" ]]; then 
        is_traceable=true
        echo "kprobe $kprobename is traceable"
        echo ""
        echo "enter structure"
        read struct
        echo "enter field"
        read field
        echo ""
        echo "Kprobe structure info:"
        sudo bpftrace -e "
        kprobe:$kprobename {
          @offset = offsetof(struct $struct, $field);
          printf(\"Offset $field: %d\\\n\", @offset);
          exit();
        }"
        echo ""
        echo "do you want to check if the function has inline implementation? [y/n]"
        read choice
        echo ""
        
        case $choice in 
          y)
            sudo cat /proc/kallsyms | grep $kprobename
            ;;
          n)
            echo "skipping part"
            ;;
        esac
      else
        echo "kprobe $kprobename not traceable"
        is_traceable=false
      fi 
      ;;

    2)
      echo ""
      echo "Enter tracepoint category"
      echo "1-> net"
      read category 
      
      case $category in  
        1)
          echo "enter structure to find similars"
          read struct
          sudo bpftrace -l 'tracepoint:net:*' | grep -i $struct
          echo ""
        ;;
      esac 
      ;;
    
    3)
      echo "exiting..."
      exit
      ;;
    
    i)
      echo "Developers utility tool to navigate in the linux kernel using bpftrace" 
      ;;
  esac
done