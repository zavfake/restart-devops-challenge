# IaC menggunakan Terraform

Infrastructure as Code (IaC) adalah teknik untuk mengelola resource cloud menggunakan kode. Terraform adalah salah satu alat untuk implementasi IaC.

## 1. Buat IAM user

AWS Console -> IAM -> Users -> Create user

- User name: `restart`
- Uncheck "Access user to management console"
- Next → Attach policies directly → pilih `AmazonEC2FullAccess`
- Create User

## 2. Buat programmatic access untuk user

- Pilih user `restart`
- Create access key (kanan atas)
- Pilih CLI
- Check "I understand ...."
- Download .csv file
- Done

3. Setup akun IAM yang barusan dibuat ke AWS CLI local

- Buka command prompt di komputer lokal
- Pastikan AWS CLI terinstall:
  ```sh aws --version```
- Jika sudah muncul versi maka anda bisa lanjut, jika belum install dulu. Panduan install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Di command prompt ketik
  ```sh aws configure --profile restart" ```
- Isi konfigurasi sesuai .csv file di poin sebelumnya
- Important! cek konfigurasi profile "cat ~/.aws/credentials". Pastikan konfigurasi profile sudah tersimpan di file tersebut (terdapat nama profile dan konfigurasi token).

## 4. Install Terraform

Panduan: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
Verifikasi: `terraform --version`

## 5. Struktur proyek

- `main.tf`    → definisi EC2, security group, user_datasrc
- `terraform.tf` → required providers / versi library IaC
- `hello.html` → file html yang akan di deploy di server EC2

## 6. Menjalankan Terraform

```sh
terraform init
terraform plan
terraform apply
```

Setelah apply, console akan mengeluarkan public IP. Anda dapat mengeluarkan public IP lagi dengan *command*:

```sh
terraform output instance_public_ip
```

## 7. Menghapus resource

```sh
terraform destroy
```

---

# (Bonus) Implementasi CI/CD menggunakan GitHub Actions

CI/CD otomatis menghubungkan environment development dan production. Berikut langkah singkat:

1. Buat SSH key di lokal:

```sh
ssh-keygen -t rsa -b 4096 -C "email-github@gmail.com"
```

- beri nama key
- kosongkan passphrase

Anda akan mendapatkan 2 key, key dan key.pub. key merupakan private key, dan key.pub merupakan pubic key.

2. Daftarkan public key di EC2:
   Konek ssh ec2 via aws console instance connect, jalankan kode berikut:

```sh
cd ~/.ssh
nano authorized_keys
exit
# tambahkan isi public key ke file authorized_keys di server menggunakan nano
```

3. Uji SSH via local console:

```sh
ssh -i private_key_name_path ec2-user@<public_ip>
```

pastikan ssh connected sebelum masuk ke langkah berikutnya.

4. Buat environment & secrets di GitHub:

- Repository → Settings → Environments → New environment `AWSRestartDeployer`
- Tambahkan secrets:
  - `EC2_HOST` = public IP EC2
  - `EC2_SSH_KEY` = private key
  - `EC2_USER` = `ec2-user` (untuk AWS Linux)

5. Tambahkan workflow deploy di `.github/workflows/deploy.yml` (copy dari repo).
6. Uji dengan push:

```sh
git add .
git commit -m "Added: Workflows action"
git push origin main
```

7. Setelah sukses, update `hello.html` dan push ulang untuk melihat auto-deploy (langkah 6).
8. Lihat workflow yang berjalan melalui github -> repository_anda -> actions.

---

Catatan penting:

- `user_data` hanya berjalan saat pembuatan instance. Untuk menerapkan perubahan `user_data`, tandai ulang instance:

```sh
terraform taint aws_instance.challenge
terraform apply
```

- Pastikan AMI dan instance type punya arsitektur yang sama (x86_64 vs arm64).
- Jangan simpan token/credential sensitif di repo. Gunakan Secrets Manager atau SSM Parameter untuk produksi.
- Security group konfigurasi membuka port 22 (SSH) dan 80 (HTTP) — sesuaikan CIDR untuk keamanan.
