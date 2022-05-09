# Visual Road: A Video Data Management Benchmark

- This repo is an extension of visualroad, please check their [project website](https://db.cs.washington.edu/projects/visualroad) for more details about the benchmark, links to the papers, sample videos, and pregenerated datasets.

## Building the Visual Road Docker Image

Because of licensing restrictions on the Unreal engine, we cannot release a pre-built Docker container for the Visual Road benchmark.  However, we have striven to make the build process as painless as possible!  Note that Visual Road depends on Unreal version 4.22.0 and only supports Linux builds.

1. Install [Docker CE](https://docs.docker.com/install/linux/docker-ce/), if not already installed.
2. Install [Python 3.6](https://www.python.org/downloads/) or later, if not already installed:


3. Clone the [Visual Road repository](https://github.com/georgia-tech-db/visualroad.git) and build the benchmark image:

```sh
git clone https://github.com/uwdb/visualroad
cd visualroad
docker build -t carlasim/eva .
```

## Synthetic Dataset Generation

1. Generate dataset with the following commands.

```sh
mkdir dataset
chmod 777 dataset
docker-compose run generator -s 1 -d 10 -l [car,pedestrian] dataset
```

2. The generator service supports a number of additional options (e.g., `--height`, `--width`, `--duration`).  Execute `docker-compose run generator -h` for a complete list.
