Chia Non Root Docker image

## Build Image
Set PUID or PGID to your user id and group id. This will make sure mounted volume doesn't has permission problem.  
```bash
docker build \
    --build-arg PYTHONVERSION=3.8 \
    --build-arg CHIAVERSION=1.1.6 \
    --build-arg PUID=$(id -u) \
    --build-arg PGID=$(id -g) \
    -t localhost/chia:1.1.6 .
```

Farmer and Plotter can use same folder.  
Keyfile is saved on both ~/.chia/config/ssl and ~/.local/share/python_keyring  
Both are reusable but require to be in one home folder  

## Run Farmer.
Make sure port 8444 and 8447 are accessible from remote machine
```bash
mkdir -p ~/chia-farmer
docker run --rm -it -v ~/chia-farmer:/home/chia localhost/chia:1.1.6 chia-init
docker run --rm -it -v ~/chia-farmer:/home/chia localhost/chia:1.1.6 chia keys generate

# Run farmer with harvester
docker run \
    --rm -d -it \
    -v ~/chia-farmer:/home/chia \
    -v ~/chia-plots:/plots \
    -p 8444:8444 \
    -p 8447:8447 \
    -e CHALLENGE=5 \
localhost/chia:1.1.6 chia-farmer

# Run farmer only ( harvester still run but with empty plots )
docker run \
    --rm -d -it \
    -v ~/chia-farmer:/home/chia \
    -p 8444:8444 \
    -p 8447:8447 \
    -e CHALLENGE=5 \
localhost/chia:1.1.6 chia-farmer
```

## Run Plotter
To run simultaneously each plotter must have their own temporary folder
```bash
# Create tmp folder for plot creation, can be any path
mkdir -p ~/chia-plots-tmp/plot1

# Create plot folder, can be any path
mkdir -p ~/chia-plots

# Run plot in same machine as farmer
docker run \
    --rm -it \
    -v ~/chia-farmer:/home/chia \
    -v ~/chia-plots-tmp/plot1:/tmp \
    -v ~/chia-plots:/plots \
localhost/chia:1.1.6 chia-plot

# Run plot in different machine
# To get farmer and pool key run docker exec -it <your farmer container> chia keys show
docker run \
    --rm -it \
    -v ~/chia-plots-tmp/plot1:/tmp \
    -v ~/chia-plots:/plots \
    -e FARMER_KEY=your.farmer.public.key \
    -e POOL_KEY=your.pool.public.key \
localhost/chia:1.1.6 chia-plot
```

Docker environment for chia-plot
| key | default | info |
|---|---|---|
|THREAD|4|-r|
|PLOTSIZE|32|-k|
|BUFFER|3389|-b|
|BUCKETS|128|-u|
|FARMER_KEY|null|Your farmer key|
|POOL_KEY|null|Your pool key|
|CLEAR_TMP|1|Clear temporary folder ( unfinished plot )|
|NOBITFIELD|null|-e|
|DELAY|0|Delay started plotting by second, might be usefull for multiple plot|
|PLOTNUM|1|-n|
  
## Run Harvester
Harvester require to have their own identification ( private key ). You must create their own folder and reinit
Harvester require to have farmer ca to connect, farmer ip and farmer port ( default is 8447 )
Harvester does not require farmer private or public key
Haverster does not require to open any port
```bash
mkdir -p ~/chia-harvester
docker run --rm -it -v ~/chia-harvester:/home/chia localhost/chia:1.1.6 chia-init
docker run \
    --rm -it \
    -v ~/chia-harvester:/home/chia \
    -v ~/chia-farmer/.chia/mainnet/ssl/ca:/farmer-ca \
    -v ~/chia-plots:/plots \
    -e FARMER_ADDR=your.farmer.ip \
    -e FARMER_PORT=8447 \
    -e CHALLENGE=5 \
localhost/chia:1.1.6 chia-harvester
```

## Logging
By default chia only log WARNING message  
To debug you have to change the log level manually to INFO before starting any service  
```bash

```
If the service already run you need to stop the container and remove it   
Since it share the same volume you can edit directly in .chia/mainnet/config/config.yaml  
```bash
docker exec -it <your container> chia-log
```
