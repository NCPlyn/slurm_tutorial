## Slurm
- **Installation**
    - `sudo apt update`
    - Control server (slurmctld):
        - `sudo apt install slurmctld`
    - Compute server (slurmd):
        - `sudo apt install slurmd`
- **Configuration**
    - I recommend using/editing example connfiguration in this repo (ver. 19.05), but you can search online for "configurator.html (version of slurmd/slurmctld)"
    - Set "SlurmctldHost" to "machine name(machine domain)" (ex.: pascal(pascal.domain.cz))
    - Set "StateSaveLocation" to `/var/spool/slurmctld`
    - Set "SlurmctldLogFile" to `/var/log/slurm-llnl/slurmctld.log`
    - Set "SlurmdLogFile" to `/var/log/slurm-llnl/slurmd.log`
    - Set "ProctrackType" to `proctrack/cgroup`
    - Set "SlurmctldPidFile" to `/run/slurm/slurmctld.pid`
    - Set "SlurmdPidFile" to `/run/slurm/slurmd.pid`
    - For Nodes RealMemory, Sockets, Cores etc.. use command `slurmd -C` on compute node
    - Set "NodeName" to only the name of machine (ex.: tesla)
    - Set "NodeAddr" to the full domain address (ex. tesla.domain.cz) or ip
    - If you are going to use GPUs:
        - Add `GresTypes=gpu,mps` to the conf file
        - Set "SelectType" to `select/cons_tres`
        - Add `Gres=gpu:v100:2,mps:200` to every compute node with correct gpu type/name and count, for mps refer to [this](https://slurm.schedmd.com/gres.html#MPS_Management)
        - Create new file `/etc/slurm-llnl/gres.conf` and paste this on every compute node. (Needs to be edited to fit the compute node hardware)
        ```
        Name=gpu Type=v100 File=/dev/nvidia0
        Name=gpu Type=v100 File=/dev/nvidia1
        Name=mps Count=200
        ```
    - Paste the final config file to `/etc/slurm-llnl/slurm.conf` on **every** machine
- **Create needed folders and assign permissions**
    ```
    sudo mkdir -p /var/spool/slurmd &
    sudo mkdir -p /var/spool/slurmctld &
    sudo mkdir -p /var/log/slurm-llnl &
    sudo mkdir -p /run/slurm &
    sudo chmod -R 755 /var/spool/slurmd &
    sudo chmod -R 755 /var/spool/slurmctld &
    sudo chmod -R 755 /var/log/slurm-llnl &
    sudo chmod -R 755 /run/slurm &
    sudo chown -R slurm:slurm /var/spool/slurmd &
    sudo chown -R slurm:slurm /var/spool/slurmctld &
    sudo chown -R slurm:slurm /var/log/slurm-llnl &
    sudo chown -R slurm:slurm /run/slurm
    ```
- **Configure tmpfiles.d**
    - `sudo nano /etc/tmpfiles.d/slurm.conf`
    - Paste this and save: `d /run/slurm 0775 slurm slurm -`
- **Configure systemctld**
    - Control server (slurmctld):
        - `sudo nano /etc/systemd/system/multi-user.target.wants/slurmctld.service`
        - Edit "PIDFile" to `/run/slurm/slurmctld.pid`
    - Compute server (slurmd):
        - `sudo nano /etc/systemd/system/multi-user.target.wants/slurmd.service`
        - Edit "PIDFile" to `/run/slurm/slurmd.pid`
- **Configure cgroup.conf on compute servers**
    - `sudo nano /etc/slurm-llnl/cgroup.conf`
    - Paste this and save:
        ```
        CgroupAutomount=yes
        ConstrainCores=yes
        ConstrainRAMSpace=yes
        ConstrainDevices=yes
        ```
- **Copy Munge key to every compute server**
    - With access to root on compute server
        - On Control server: `sudo scp /etc/munge/munge.key root@<compute-node-ip>:/etc/munge/munge.key`
    - Without access to root on compute server
        - On Control server: `sudo scp /etc/munge/munge.key <node-user>@<compute-node-ip>:/home/<node-user>/munge.key`
        - On Compute server:
            - `sudo mv /home/<node-user>/munge.key /etc/munge/munge.key`
            - `sudo chown munge:munge /etc/munge/munge.key`
    - `sudo systemctl restart munge`
    - `sudo chown munge:munge /etc/munge/munge.key`
- **Start slurm**
    - Control server (slurmctld):
        - `sudo systemctl enable slurmctld`
        - `sudo systemctl start slurmctld`
    - Compute server (slurmd):
        - `sudo systemctl enable slurmd`
        - `sudo systemctl start slurmd`
- **Test**
    - You should most likely use LDAP and some sort of NAS to have slurm properly working
    - `scontrol show node` should show working compute servers
    - `sinfo` should should show idle partitions
    - `sbatch test.sh` with test.sh in this repo should return computed number Pi. Using `squeue` you should see the task being proccessed
