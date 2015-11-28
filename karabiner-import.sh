#!/bin/sh
KARABINER="/Applications/Karabiner.app/Contents/Library/bin/karabiner"

if [ -x "${KARABINER}" ]; then
   "${KARABINER}" select 0
   while [ `"${KARABINER}" list | wc -l` -gt 1 ]; do
      "${KARABINER}" delete 1
   done
   "${KARABINER}" append "TEMP"
   "${KARABINER}" select 1
   "${KARABINER}" delete 0
   "${KARABINER}" rename 0 "Default"

   "${KARABINER}" append "Ctrl<->Fn|Alt<->Cmd"
   "${KARABINER}" select 1

   "${KARABINER}" set general.dont_remap_external 1
   "${KARABINER}" set general.dont_remap_non_apple_keyboard 1
   "${KARABINER}" set remap.commandL2optionL 1
   "${KARABINER}" set remap.consumer_to_fkeys_f1 1
   "${KARABINER}" set remap.consumer_to_fkeys_f3 1
   "${KARABINER}" set remap.consumer_to_fkeys_f5 1
   "${KARABINER}" set remap.consumer_to_fkeys_f7 1
   "${KARABINER}" set remap.controlL2fn 1
   "${KARABINER}" set remap.fn2controlL 1
   "${KARABINER}" set remap.optionL2commandL 1
fi
