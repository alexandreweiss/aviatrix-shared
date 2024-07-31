# Migrate to new U22

## Exsiting ctrl
- Public IP : 108.143.24.233 / avx-ctrl-we-public-ip
- Private IP : 192.168.11.4
- NSG : avx-ctrl-we-security-group
- Old name : avx-ctrl-we-vm
- Azure account : azure-alweiss

1. Backup old ctrl + power off
2. Install new u22 image on v. 7.1.3958
3. Detach old ctrl public IP
4. Migrate old basic Public IP to Standard Public IP
5. Shutdown new ctrl + assigne old ctrl public ip
6. Power on new ctrl
7. Add cloud account where the backup is located
8. Ack public IP change Q by saying Yes
9. Check GWs status
10. Deploy new Copilot
11. Provide Service Account and private IP of Controller
12. Restore data