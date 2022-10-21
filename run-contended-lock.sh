#!/bin/bash
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

wait_before_run() {
  sleep 10
}

wait_before_run
./target/release/mpsc | tee target/mpsc.csv

wait_before_run
./target/release/futures-channel | tee target/futures-channel.csv

wait_before_run
./target/release/flume | tee target/flume.csv

wait_before_run
./target/release/flume-async | tee target/flume_async.csv

wait_before_run
./target/release/crossbeam-channel | tee target/crossbeam-channel.csv

wait_before_run
./target/release/async-channel | tee target/async-channel.csv

wait_before_run
./target/release/kanal | tee target/kanal.csv

# wait_before_run
# ./target/release/kanal-async | tee target/kanal-async.csv

wait_before_run
./target/release/kanal_parkinglot | tee target/kanal_parkinglot.csv

# wait_before_run
# ./target/release/kanal_parkinglot-async | tee target/kanal_parkinglot-async.csv

wait_before_run
./target/release/kanal_stdlock | tee target/kanal_stdlock.csv

# wait_before_run
# ./target/release/kanal_stdlock-async | tee target/kanal_stdlock-async.csv

wait_before_run
./target/release/go_bench | tee target/go.csv

./plot.py target/*.csv

echo "Test Environment:"
uname -srvp
rustc --version
go version
