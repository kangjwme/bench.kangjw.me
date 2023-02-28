apt update -y
apt install sysbench wget -y
wget https://bench.kangjw.me/besttrace

bash <(curl -L -s https://bench.kangjw.me/00-systeminfo.sh)

# geekbench
bash <(curl -L -s https://bench.kangjw.me/04-cpubench.sh)
bash <(curl -L -s https://bench.kangjw.me/03-yabs.sh) -i -f
bash <(curl -L -s https://bench.kangjw.me/05-memorybench.sh)

# fio
bash <(curl -L -s https://bench.kangjw.me/06-ddtest.sh)
bash <(curl -L -s https://bench.kangjw.me/03-yabs.sh) -i -g

# network
bash <(curl -L -s https://bench.kangjw.me/02-besttrace.sh)
bash <(curl -L -s https://bench.kangjw.me/01-speedtest.sh)
bash <(curl -L -s https://bench.kangjw.me/03-yabs.sh) -f -g


