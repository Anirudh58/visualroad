# Visual Road: A Video Data Management Benchmark

- This repo is an extension of visualroad, please check their [project website](https://db.cs.washington.edu/projects/visualroad) for more details about the benchmark, links to the papers, sample videos, and pregenerated datasets.

## Building the Docker Image

1. Install [Docker CE](https://docs.docker.com/install/linux/docker-ce/), if not already installed.
2. Install [Python 3.6](https://www.python.org/downloads/) or later, if not already installed:
3. Clone the [Visual Road repository](https://github.com/georgia-tech-db/visualroad.git) and build the benchmark image:

```sh
git clone https://github.com/georgia-tech-db/visualroad
cd visualroad
docker build -t carlasim/eva .
```

## Synthetic Dataset Generation

1. Generate a scale-one dataset with videos of 10 sec each with the following command. Note: `-l` flag specifies what objects you need ground truth info for. 

```sh
mkdir dataset
chmod 777 dataset
docker-compose run generator -s 1 -d 10 -l [car,pedestrian] dataset
```

2. The generator service supports a number of additional options (e.g., `--height`, `--width`, `--duration`).  Execute `docker-compose run generator -h` for a complete list.
