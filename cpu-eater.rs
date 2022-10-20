use clap::Parser;
use rand::distributions::Standard;
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use std::thread;

#[derive(Parser, Debug)]
struct Args {
    #[arg(short, long, default_value_t = 4)]
    threads: usize,
    #[arg(short, long)]
    seed: Option<u64>,
}

fn main() {
    let args = Args::parse();

    let mut base_rng = match args.seed {
        None => ChaCha20Rng::from_entropy(),
        Some(seed) => ChaCha20Rng::seed_from_u64(seed),
    };

    thread::scope(|s| {
        for tid in 0..args.threads {
            let threadrng = ChaCha20Rng::from_rng(&mut base_rng).unwrap();
            s.spawn(move || {
                let megahash = threadrng
                    .sample_iter(Standard)
                    .take(usize::MAX)
                    .fold(1u32, |prev: u32, next: u32| {
                        prev.wrapping_mul(31).wrapping_add(next)
                    });
                println!("Thread {}: Megahash = {}", tid, megahash);
            });
        }
    });
}
