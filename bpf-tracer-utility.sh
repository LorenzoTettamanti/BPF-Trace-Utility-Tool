#!/bin/bash

#vars
is_traceable=true


list_menu() {
  echo "1-> Kprobe offset finder"
  echo "2-> Tracepoint category finder"
  echo "3-> List available kprobes/tracepoints"
  echo "q-> exit"
  echo "i-> info"
}

while true; do
  echo "-------------------------------------------------------------------"
  echo "BPF TRACE SCRIPTS UTILITY"
  echo "Functions":
  echo ""
  list_menu
  echo ""
  echo "Choose a functionality"
  read FUN
  echo ""
  echo "-------------------------------------------------------------------"
  case $FUN in 
    1)
      clear
      echo "Kprobe Offset Finder: insert the kprobe name and the field name to retrieve all offsets corresponding to matching fields."
      echo ""
      echo " Output format: <var-type> <var-name> <offset> <bit length>"
      echo " Example: 	char     name[16];      /*   304    16 */ "
      echo ""

      echo "enter Kprobe name:"
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
        if [[ -z "$struct" || -z "$field" ]]; then
          echo -e "Error: Structure and fieldd cannot be empty.\nPlease try again."
          continue
        fi
        echo ""
        echo "Kprobe structure info:"
        sudo pahole -C $struct | grep $field
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
      clear
      echo "Tracepoint category finder and save the result in a .txt file"
      echo ""
      echo "Available categories (partial list):"
      sudo ls /sys/kernel/debug/tracing/events/ | grep -v '^_' > ./categories_list.txt
      echo "Categories have been saved to ./categories_list.txt"
      echo "Enter tracepoint category (e.g., net, sched, block, ...):"
      read -r category 
      if [[ -z "$category" ]]; then
        echo -e "Category cannot be empty"
        continue
      fi
      echo "Enter structure to find similars:"
      read -r struct
      if [[ -z "$struct" ]]; then
        echo -e "Struct cannot be empty"
        continue
      fi
      sudo bpftrace -l "tracepoint:$category:*" | grep -i $struct
      echo ""
      ;;
    
    3)
      clear
      echo "List available kprobes/tracepoints and save the result in a .txt file"
      echo "List what? (kprobes/tracepoints)"
      read -r what
      case $what in
        kprobes)
          echo "Available kprobes:"
          sudo bpftrace -l "kprobe:*" > ./kprobes_list.txt
          echo "Kprobes have been saved to ./kprobes_list.txt"
          ;;
        tracepoints)
          echo "Available tracepoints (all categories):"
          sudo bpftrace -l "tracepoint:*" > ./tracepoints_list.txt
          echo "Tracepoints have been saved to ./tracepoints_list.txt"
          ;;
        *)
          echo "Unknown option"
          ;;
      esac
      ;;

    q|Q)
      echo "Exiting..."
      exit 0
      ;;

    i)
      echo "Developers utility tool to navigate in the linux kernel using bpftrace and pahole" 
      ;;

    *)
      echo -e "Invalid option. Please try again.\n"
      ;;
  esac
done