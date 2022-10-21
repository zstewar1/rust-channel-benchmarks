#!/bin/bash
export RUSTFLAGS="-C target-cpu=native"
set -euxo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")"

if [ "${1-}" = "--build" ]; then
  cargo clean

  mkdir -p target

  cargo build --release --bin cpu-eater
  cargo build --release --bin mpsc
  cargo build --release --bin futures-channel
  cargo build --release --bin flume
  cargo build --release --bin flume-async
  cargo build --release --bin crossbeam-channel
  cargo build --release --bin async-channel
  cargo build --release --bin kanal
  cargo build --release --bin kanal-async
  cargo build --release --bin kanal_parkinglot
  cargo build --release --bin kanal_parkinglot-async
  cargo build --release --bin kanal_stdlock
  cargo build --release --bin kanal_stdlock-async
  go build -o target/release/go_bench go.go
fi

loadpid=
loadcpu() {
  sleep 10
  ./target/release/cpu-eater --threads=400 --seed=6630343 &
  loadpid=$!
  sleep 10
}

unloadcpu() {
  kill -SIGTERM $loadpid
}

loadcpu
./target/release/mpsc | tee target/mpsc.csv
unloadcpu

loadcpu
./target/release/futures-channel | tee target/futures-channel.csv
unloadcpu

loadcpu
./target/release/flume | tee target/flume.csv
unloadcpu

loadcpu
./target/release/flume-async | tee target/flume_async.csv
unloadcpu

loadcpu
./target/release/crossbeam-channel | tee target/crossbeam-channel.csv
unloadcpu

loadcpu
./target/release/async-channel | tee target/async-channel.csv
unloadcpu

loadcpu
./target/release/kanal | tee target/kanal.csv
unloadcpu

loadcpu
./target/release/kanal-async | tee target/kanal-async.csv
unloadcpu

loadcpu
./target/release/kanal_parkinglot | tee target/kanal_parkinglot.csv
unloadcpu

loadcpu
./target/release/kanal_parkinglot-async | tee target/kanal_parkinglot-async.csv
unloadcpu

loadcpu
./target/release/kanal_stdlock | tee target/kanal_stdlock.csv
unloadcpu

loadcpu
./target/release/kanal_stdlock-async | tee target/kanal_stdlock-async.csv
unloadcpu

loadcpu
./target/release/go_bench | tee target/go.csv
unloadcpu

./plot.py target/*.csv

echo "Test Environment:"
uname -srvp
rustc --version
go version
