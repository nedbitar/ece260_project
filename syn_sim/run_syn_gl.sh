#!/bin/bash
unset LD_PRELOAD

xrun \
  -clean \
  -define INITIALIZE_MEMORY \
  -xminitialize 0 \
  +access+rwc \
  +xm64bit \
  +xmtimescale+1ns/1ps \
  +xmoverride_timescale \
  +notimingchecks \
  -v ./fullchip.out.v \
  -v ./tcbn65gplus.v \
  ./fullchip_gl_tb.v \
-gui
